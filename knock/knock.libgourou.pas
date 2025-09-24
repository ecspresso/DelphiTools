unit knock.libgourou;

interface

uses
  Windows, SysUtils, Classes;

const
  LIBGOUROU_DLL = 'libgourou.dll';  // Adjust path as needed

type
  // Forward declarations for opaque types
  PDRMProcessor = Pointer;
  PDRMProcessorClient = Pointer;
  TKnockProcessor = class;

  // Error codes (based on libgourou implementation)
  TGourouResult = (
    GOUROU_OK = 0,
    GOUROU_ERROR = -1,
    GOUROU_ADEPT_ERROR = -2,
    GOUROU_FILE_ERROR = -3,
    GOUROU_NETWORK_ERROR = -4,
    GOUROU_DRM_ERROR = -5
  );

  // Device information structure
  TDeviceInfo = record
    DeviceKey: PAnsiChar;
    DeviceKeyLength: Integer;
    DeviceID: PAnsiChar;
    DeviceIDLength: Integer;
    Username: PAnsiChar;
    Password: PAnsiChar;
  end;
  PDeviceInfo = ^TDeviceInfo;

  // External function declarations for libgourou
  // These would correspond to a C wrapper around the C++ libgourou library

  // Device management functions
  function gourou_create_drm_processor(): PDRMProcessor; cdecl; external LIBGOUROU_DLL;
  procedure gourou_free_drm_processor(processor: PDRMProcessor); cdecl; external LIBGOUROU_DLL;

  // Authentication functions
  function gourou_sign_in(processor: PDRMProcessor; username, password: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;
  function gourou_activate_device(processor: PDRMProcessor): TGourouResult; cdecl; external LIBGOUROU_DLL;

  // ACSM processing functions
  function gourou_fulfill(processor: PDRMProcessor; acsm_file: PAnsiChar; output_file: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;
  function gourou_download(processor: PDRMProcessor; adept_file: PAnsiChar; output_file: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;

  // DRM removal functions
  function gourou_remove_drm(processor: PDRMProcessor; encrypted_file: PAnsiChar; output_file: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;

  // Configuration functions
  function gourou_load_adept_keys(processor: PDRMProcessor; adept_dir: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;
  function gourou_save_adept_keys(processor: PDRMProcessor; adept_dir: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;

  // Utility functions
  function gourou_export_private_key(processor: PDRMProcessor; output_file: PAnsiChar): TGourouResult; cdecl; external LIBGOUROU_DLL;
  function gourou_get_last_error(processor: PDRMProcessor): PAnsiChar; cdecl; external LIBGOUROU_DLL;

  // Main Knock implementation class
  TKnockProcessor = class
  private
    FProcessor: PDRMProcessor;
    FAdeptDir: string;
    FLastError: string;

    function GetDefaultAdeptDir: string;
    procedure SetLastError(const Error: string);

  public
    constructor Create;
    destructor Destroy; override;

    // Authentication methods
    function Authenticate(const Username, Password: string): Boolean;
    function LoadExistingKeys(const AdeptDir: string = ''): Boolean;

    // Main processing method (equivalent to knock command)
    function ProcessACSM(const ACSMFile: string; const OutputFile: string = ''): Boolean;

    // Individual step methods
    function FulfillACSM(const ACSMFile, OutputFile: string): Boolean;
    function DownloadBook(const AdeptFile, OutputFile: string): Boolean;
    function RemoveDRM(const EncryptedFile, OutputFile: string): Boolean;

    // Utility methods
    function ExportPrivateKey(const OutputFile: string = ''): Boolean;
    function GetLastErrorMessage: string;

    property AdeptDirectory: string read FAdeptDir write FAdeptDir;
  end;

implementation

{ TKnockProcessor }

constructor TKnockProcessor.Create;
begin
  inherited Create;
  FProcessor := gourou_create_drm_processor();
  if FProcessor = nil then
    raise Exception.Create('Failed to create DRM processor');

  FAdeptDir := GetDefaultAdeptDir;
end;

destructor TKnockProcessor.Destroy;
begin
  if FProcessor <> nil then
    gourou_free_drm_processor(FProcessor);
  inherited Destroy;
end;

function TKnockProcessor.GetDefaultAdeptDir: string;
var
  HomeDir: string;
begin
  // Get user's home directory
  HomeDir := GetEnvironmentVariable('USERPROFILE');
  if HomeDir = '' then
    HomeDir := GetEnvironmentVariable('HOME');

  // Default .config/adept directory
  Result := IncludeTrailingPathDelimiter(HomeDir) + '.config' + PathDelim + 'adept';
end;

procedure TKnockProcessor.SetLastError(const Error: string);
begin
  FLastError := Error;
end;

function TKnockProcessor.Authenticate(const Username, Password: string): Boolean;
var
  UsernameA, PasswordA: AnsiString;
  Result1, Result2: TGourouResult;
begin
  Result := False;

  try
    // Convert to ANSI strings
    UsernameA := AnsiString(Username);
    PasswordA := AnsiString(Password);

    // Sign in
    Result1 := gourou_sign_in(FProcessor, PAnsiChar(UsernameA), PAnsiChar(PasswordA));
    if Result1 <> GOUROU_OK then
    begin
      SetLastError('Sign in failed: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    // Activate device
    Result2 := gourou_activate_device(FProcessor);
    if Result2 <> GOUROU_OK then
    begin
      SetLastError('Device activation failed: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    // Save keys to adept directory
    ForceDirectories(FAdeptDir);
    if gourou_save_adept_keys(FProcessor, PAnsiChar(AnsiString(FAdeptDir))) <> GOUROU_OK then
    begin
      SetLastError('Failed to save ADEPT keys: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('Authentication error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.LoadExistingKeys(const AdeptDir: string): Boolean;
var
  KeyDir: string;
  AdeptDirA: AnsiString;
begin
  Result := False;

  try
    if AdeptDir <> '' then
      KeyDir := AdeptDir
    else
      KeyDir := FAdeptDir;

    if not DirectoryExists(KeyDir) then
    begin
      SetLastError('ADEPT directory does not exist: ' + KeyDir);
      Exit;
    end;

    AdeptDirA := AnsiString(KeyDir);
    if gourou_load_adept_keys(FProcessor, PAnsiChar(AdeptDirA)) <> GOUROU_OK then
    begin
      SetLastError('Failed to load ADEPT keys: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    FAdeptDir := KeyDir;
    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('Load keys error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.ProcessACSM(const ACSMFile: string; const OutputFile: string): Boolean;
var
  TempFile, FinalOutput: string;
  EncryptedFile: string;
begin
  Result := False;

  try
    if not FileExists(ACSMFile) then
    begin
      SetLastError('ACSM file does not exist: ' + ACSMFile);
      Exit;
    end;

    // Determine output filename
    if OutputFile <> '' then
      FinalOutput := OutputFile
    else
      FinalOutput := ChangeFileExt(ACSMFile, '.epub');

    // Step 1: Fulfill ACSM to get download URL and save encrypted file
    EncryptedFile := ChangeFileExt(ACSMFile, '.tmp.epub');

    WriteLn('Downloading the file from Adobe...');
    if not FulfillACSM(ACSMFile, EncryptedFile) then
      Exit;

    if not FileExists(EncryptedFile) then
    begin
      // Try download step separately
      TempFile := ChangeFileExt(ACSMFile, '.adept');
      if FileExists(TempFile) then
      begin
        if not DownloadBook(TempFile, EncryptedFile) then
          Exit;
      end
      else
      begin
        SetLastError('Failed to create encrypted file');
        Exit;
      end;
    end;

    // Step 2: Remove DRM from encrypted file
    WriteLn('Removing DRM from the file...');
    if not RemoveDRM(EncryptedFile, FinalOutput) then
    begin
      // Clean up temp file
      if FileExists(EncryptedFile) then
        DeleteFile(EncryptedFile);
      Exit;
    end;

    // Clean up temp files
    if FileExists(EncryptedFile) then
      DeleteFile(EncryptedFile);
    if FileExists(ChangeFileExt(ACSMFile, '.adept')) then
      DeleteFile(ChangeFileExt(ACSMFile, '.adept'));

    WriteLn('DRM-free EPUB file generated at ' + FinalOutput);
    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('Process ACSM error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.FulfillACSM(const ACSMFile, OutputFile: string): Boolean;
var
  ACSMFileA, OutputFileA: AnsiString;
begin
  Result := False;

  try
    ACSMFileA := AnsiString(ACSMFile);
    OutputFileA := AnsiString(OutputFile);

    if gourou_fulfill(FProcessor, PAnsiChar(ACSMFileA), PAnsiChar(OutputFileA)) <> GOUROU_OK then
    begin
      SetLastError('Fulfill failed: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('Fulfill error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.DownloadBook(const AdeptFile, OutputFile: string): Boolean;
var
  AdeptFileA, OutputFileA: AnsiString;
begin
  Result := False;

  try
    AdeptFileA := AnsiString(AdeptFile);
    OutputFileA := AnsiString(OutputFile);

    if gourou_download(FProcessor, PAnsiChar(AdeptFileA), PAnsiChar(OutputFileA)) <> GOUROU_OK then
    begin
      SetLastError('Download failed: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('Download error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.RemoveDRM(const EncryptedFile, OutputFile: string): Boolean;
var
  EncryptedFileA, OutputFileA: AnsiString;
begin
  Result := False;

  try
    EncryptedFileA := AnsiString(EncryptedFile);
    OutputFileA := AnsiString(OutputFile);

    if gourou_remove_drm(FProcessor, PAnsiChar(EncryptedFileA), PAnsiChar(OutputFileA)) <> GOUROU_OK then
    begin
      SetLastError('DRM removal failed: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('DRM removal error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.ExportPrivateKey(const OutputFile: string): Boolean;
var
  KeyFile: string;
  OutputFileA: AnsiString;
begin
  Result := False;

  try
    if OutputFile <> '' then
      KeyFile := OutputFile
    else
      KeyFile := IncludeTrailingPathDelimiter(FAdeptDir) + 'adobekey_1.der';

    OutputFileA := AnsiString(KeyFile);

    if gourou_export_private_key(FProcessor, PAnsiChar(OutputFileA)) <> GOUROU_OK then
    begin
      SetLastError('Export private key failed: ' + string(gourou_get_last_error(FProcessor)));
      Exit;
    end;

    Result := True;

  except
    on E: Exception do
    begin
      SetLastError('Export private key error: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TKnockProcessor.GetLastErrorMessage: string;
begin
  Result := FLastError;
end;

end.
