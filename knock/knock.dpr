program knock;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  knock.libgourou in 'knock.libgourou.pas';

procedure ShowUsage;
begin
  WriteLn('Knock - Convert ACSM files to DRM-free EPUB files');
  WriteLn('');
  WriteLn('Usage:');
  WriteLn('  knock <acsm_file> [output_file]          - Process ACSM file');
  WriteLn('  knock --activate <username> <password>   - Activate device with Adobe ID');
  WriteLn('  knock --export-key [output_file]         - Export private key for Calibre DeDRM');
  WriteLn('  knock --help                             - Show this help');
  WriteLn('');
  WriteLn('Examples:');
  WriteLn('  knock my-book.acsm                       - Convert to my-book.epub');
  WriteLn('  knock my-book.acsm my-book-drm-free.epub - Convert with custom output name');
  WriteLn('  knock --activate user@example.com pass   - Activate device');
  WriteLn('  knock --export-key                       - Export key to default location');
  WriteLn('');
  WriteLn('Note: You need to activate your device once before processing ACSM files.');
end;

procedure ShowError(const Message: string);
begin
  WriteLn('Error: ' + Message);
  ExitCode := 1;
end;

function ActivateDevice(const Username, Password: string): Boolean;
var
  Processor: TKnockProcessor;
begin
  Result := False;

  WriteLn('Activating device with Adobe ID...');

  try
    Processor := TKnockProcessor.Create;
    try
      if Processor.Authenticate(Username, Password) then
      begin
        WriteLn('Device activated successfully!');
        WriteLn('ADEPT keys saved to: ' + Processor.AdeptDirectory);
        Result := True;
      end
      else
      begin
        ShowError('Device activation failed: ' + Processor.GetLastErrorMessage);
      end;
    finally
      Processor.Free;
    end;
  except
    on E: Exception do
    begin
      ShowError('Activation error: ' + E.Message);
    end;
  end;
end;

function ExportPrivateKey(const OutputFile: string): Boolean;
var
  Processor: TKnockProcessor;
  KeyFile: string;
begin
  Result := False;

  WriteLn('Exporting private key...');

  try
    Processor := TKnockProcessor.Create;
    try
      // Load existing keys
      if not Processor.LoadExistingKeys then
      begin
        ShowError('Cannot load ADEPT keys. Please activate device first.');
        Exit;
      end;

      if Processor.ExportPrivateKey(OutputFile) then
      begin
        if OutputFile <> '' then
          KeyFile := OutputFile
        else
          KeyFile := IncludeTrailingPathDelimiter(Processor.AdeptDirectory) + 'adobekey_1.der';

        WriteLn('Private key exported to: ' + KeyFile);
        WriteLn('You can import this key into Calibre''s DeDRM plugin.');
        Result := True;
      end
      else
      begin
        ShowError('Key export failed: ' + Processor.GetLastErrorMessage);
      end;
    finally
      Processor.Free;
    end;
  except
    on E: Exception do
    begin
      ShowError('Export error: ' + E.Message);
    end;
  end;
end;

function ProcessACSMFile(const ACSMFile, OutputFile: string): Boolean;
var
  Processor: TKnockProcessor;
begin
  Result := False;

  if not FileExists(ACSMFile) then
  begin
    ShowError('ACSM file not found: ' + ACSMFile);
    Exit;
  end;

  try
    Processor := TKnockProcessor.Create;
    try
      // Try to load existing keys first
      if not Processor.LoadExistingKeys then
      begin
        ShowError('Cannot load ADEPT keys. Please activate device first with --activate option.');
        Exit;
      end;

      if Processor.ProcessACSM(ACSMFile, OutputFile) then
      begin
        Result := True;
      end
      else
      begin
        ShowError('Processing failed: ' + Processor.GetLastErrorMessage);
      end;
    finally
      Processor.Free;
    end;
  except
    on E: Exception do
    begin
      ShowError('Processing error: ' + E.Message);
    end;
  end;
end;

function CheckLibgourouAvailable: Boolean;
var
  Handle: THandle;
begin
  Result := False;

  try
    Handle := LoadLibrary(PChar(LIBGOUROU_DLL));
    if Handle <> 0 then
    begin
      FreeLibrary(Handle);
      Result := True;
    end
    else
    begin
      ShowError('libgourou.dll not found. Please ensure libgourou is compiled and the DLL is available.');
    end;
  except
    on E: Exception do
    begin
      ShowError('Failed to load libgourou.dll: ' + E.Message);
    end;
  end;
end;

var
  Param1, Param2, Param3: string;

begin
  WriteLn('Knock v1.0 - ACSM to EPUB converter using libgourou');
  WriteLn('');

  // Check if libgourou is available
  if not CheckLibgourouAvailable then
    Exit;

  // Parse command line arguments
  if ParamCount = 0 then
  begin
    ShowUsage;
    Exit;
  end;

  Param1 := ParamStr(1);

  if (Param1 = '--help') or (Param1 = '-h') then
  begin
    ShowUsage;
    Exit;
  end;

  if Param1 = '--activate' then
  begin
    if ParamCount < 3 then
    begin
      ShowError('--activate requires username and password parameters');
      ShowUsage;
      Exit;
    end;

    Param2 := ParamStr(2);  // username
    Param3 := ParamStr(3);  // password

    if not ActivateDevice(Param2, Param3) then
      Exit;
  end
  else if Param1 = '--export-key' then
  begin
    Param2 := '';
    if ParamCount >= 2 then
      Param2 := ParamStr(2);  // optional output file

    if not ExportPrivateKey(Param2) then
      Exit;
  end
  else
  begin
    // Process ACSM file
    Param2 := '';
    if ParamCount >= 2 then
      Param2 := ParamStr(2);  // optional output file

    if not ProcessACSMFile(Param1, Param2) then
      Exit;
  end;

  WriteLn('Operation completed successfully.');
end.
