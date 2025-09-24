unit Console;

interface

uses
  System.SysUtils,
  System.Types,
  ConsoleConsts,
  ServiceManager;

type
  TConsole = class
  private const
    FSERIVCE_NAME: string = 'IBS_gds_db';
  private
    FWindowsServiceManager: TWindowsServiceManager;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RestartService;
    procedure Run;
    procedure StartService;
    procedure StopService;
    procedure WriteCommands;
    procedure WriteStatus;
  end;

implementation

constructor TConsole.Create;
begin
  FWindowsServiceManager := TWindowsServiceManager.Create;
end;

destructor TConsole.Destroy;
begin
  FWindowsServiceManager.Free;
  inherited;
end;

procedure TConsole.RestartService;
begin
  try
    if FWindowsServiceManager.RestartService(FSERIVCE_NAME) then
      Writeln(sRestartSuccess)
    else
      Writeln(sRestartFailure);
  except
    on E: Exception do
      Writeln(E.Message);
  end;
end;

procedure TConsole.Run;
var
  LResponse: string;
begin
  WriteCommands;
  
  while True do
  begin
    Write(cArrow);
    Readln(LResponse);
    LResponse := LowerCase(LResponse);
    if sametext(LResponse, cCommandStart) then
      StartService
    else if sametext(LResponse, cCommandStatus) then
      WriteStatus
    else if sametext(LResponse, cCommandStop) then
      StopService
    else if sametext(LResponse, cCommandRestart) then
      RestartService
    else if sametext(LResponse, cCommandHelp) then
      WriteCommands
    else if sametext(LResponse, cCommandExit) then
      break
    else
    begin
      Writeln(sInvalidCommand);
    end;
  end;
end;

procedure TConsole.StartService;
begin
  try
    if FWindowsServiceManager.StartService(FSERIVCE_NAME) then
      Writeln(sStartSuccess)
    else
      Writeln(sStartFailure);
  except
    on E: Exception do
      Writeln(E.Message);
  end;
end;

procedure TConsole.StopService;
begin
  try
    if FWindowsServiceManager.StopService(FSERIVCE_NAME) then
      Writeln(sStopSuccess)
    else
      Writeln(sStopFailure);
  except
    on E: Exception do
      Writeln(E.Message);
  end;
end;

procedure TConsole.WriteCommands;
begin
  Writeln(sCommands);
end;

procedure TConsole.WriteStatus;
begin
  Writeln(FWindowsServiceManager.GetServiceStatus(FSERIVCE_NAME));
end;

end.
