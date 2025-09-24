unit ServiceManager;

interface

uses
  Windows, WinSvc, SysUtils, Classes;

type
  TServiceState = (ssUnknown, ssStopped, ssStartPending, ssStopPending, ssRunning,
                   ssContinuePending, ssPausePending, ssPaused);

  EServiceException = class(Exception);

  TWindowsServiceManager = class
  private
    FSCManager: SC_HANDLE;
    function GetServiceState(const ServiceName: string): TServiceState;
    function WaitForServiceState(const ServiceName: string; DesiredState: TServiceState; TimeoutMs: DWORD = 30000): Boolean;
    function StateToString(State: TServiceState): string;
  public
    constructor Create;
    destructor Destroy; override;

    function ServiceExists(const ServiceName: string): Boolean;
    function IsServiceRunning(const ServiceName: string): Boolean;
    function StartService(const ServiceName: string): Boolean;
    function StopService(const ServiceName: string): Boolean;
    function RestartService(const ServiceName: string): Boolean;
    function GetServiceStatus(const ServiceName: string): string;
  end;

implementation

{ TWindowsServiceManager }

constructor TWindowsServiceManager.Create;
begin
  inherited Create;
  // Open connection to the service control manager
  FSCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT or SC_MANAGER_ENUMERATE_SERVICE or SERVICE_START or SERVICE_STOP);
  if FSCManager = 0 then
    raise EServiceException.CreateFmt('Failed to open Service Control Manager. Error: %d', [GetLastError]);
end;

destructor TWindowsServiceManager.Destroy;
begin
  if FSCManager <> 0 then
    CloseServiceHandle(FSCManager);
  inherited Destroy;
end;

function TWindowsServiceManager.ServiceExists(const ServiceName: string): Boolean;
var
  Service: SC_HANDLE;
begin
  Result := False;
  Service := OpenService(FSCManager, PChar(ServiceName), SERVICE_QUERY_STATUS);
  if Service <> 0 then
  begin
    Result := True;
    CloseServiceHandle(Service);
  end;
end;

function TWindowsServiceManager.GetServiceState(const ServiceName: string): TServiceState;
var
  Service: SC_HANDLE;
  Status: SERVICE_STATUS;
  BytesNeeded: DWORD;
begin
  Result := ssUnknown;

  Service := OpenService(FSCManager, PChar(ServiceName), SERVICE_QUERY_STATUS);
  if Service = 0 then
    raise EServiceException.CreateFmt('Failed to open service "%s". Error: %d', [ServiceName, GetLastError]);

  try
    if not QueryServiceStatus(Service, Status) then
      raise EServiceException.CreateFmt('Failed to query service status for "%s". Error: %d', [ServiceName, GetLastError]);

    case Status.dwCurrentState of
      SERVICE_STOPPED: Result := ssStopped;
      SERVICE_START_PENDING: Result := ssStartPending;
      SERVICE_STOP_PENDING: Result := ssStopPending;
      SERVICE_RUNNING: Result := ssRunning;
      SERVICE_CONTINUE_PENDING: Result := ssContinuePending;
      SERVICE_PAUSE_PENDING: Result := ssPausePending;
      SERVICE_PAUSED: Result := ssPaused;
    end;
  finally
    CloseServiceHandle(Service);
  end;
end;

function TWindowsServiceManager.IsServiceRunning(const ServiceName: string): Boolean;
begin
  Result := GetServiceState(ServiceName) = ssRunning;
end;

function TWindowsServiceManager.WaitForServiceState(const ServiceName: string;
  DesiredState: TServiceState; TimeoutMs: DWORD = 30000): Boolean;
var
  StartTime: DWORD;
  CurrentState: TServiceState;
begin
  StartTime := GetTickCount;

  repeat
    CurrentState := GetServiceState(ServiceName);
    if CurrentState = DesiredState then
    begin
      Result := True;
      Exit;
    end;

    Sleep(500); // Wait 500ms between checks
  until (GetTickCount - StartTime) >= TimeoutMs;

  Result := False;
end;

function TWindowsServiceManager.StartService(const ServiceName: string): Boolean;
var
  Service: SC_HANDLE;
  Args: PChar;
begin
  Result := False;
  Args := nil;

  if not ServiceExists(ServiceName) then
    raise EServiceException.CreateFmt('Service "%s" does not exist', [ServiceName]);

  if IsServiceRunning(ServiceName) then
  begin
    Result := True; // Already running
    Exit;
  end;

  Service := OpenService(FSCManager, PChar(ServiceName), SERVICE_START);
  if Service = 0 then
    raise EServiceException.CreateFmt('Failed to open service "%s" for starting. Error: %d', [ServiceName, GetLastError]);

  try
    if not WinSvc.StartService(Service, 0, Args) then
    begin
      if GetLastError <> ERROR_SERVICE_ALREADY_RUNNING then
        raise EServiceException.CreateFmt('Failed to start service "%s". Error: %d', [ServiceName, GetLastError]);
    end;

    // Wait for service to start
    Result := WaitForServiceState(ServiceName, ssRunning);

  finally
    CloseServiceHandle(Service);
  end;
end;

function TWindowsServiceManager.StopService(const ServiceName: string): Boolean;
var
  Service: SC_HANDLE;
  Status: SERVICE_STATUS;
begin
  Result := False;

  if not ServiceExists(ServiceName) then
    raise EServiceException.CreateFmt('Service "%s" does not exist', [ServiceName]);

  if GetServiceState(ServiceName) = ssStopped then
  begin
    Result := True; // Already stopped
    Exit;
  end;

  Service := OpenService(FSCManager, PChar(ServiceName), SERVICE_STOP);
  if Service = 0 then
    raise EServiceException.CreateFmt('Failed to open service "%s" for stopping. Error: %d', [ServiceName, GetLastError]);

  try
    if not ControlService(Service, SERVICE_CONTROL_STOP, Status) then
    begin
      if GetLastError <> ERROR_SERVICE_NOT_ACTIVE then
        raise EServiceException.CreateFmt('Failed to stop service "%s". Error: %d', [ServiceName, GetLastError]);
    end;

    // Wait for service to stop
    Result := WaitForServiceState(ServiceName, ssStopped);

  finally
    CloseServiceHandle(Service);
  end;
end;

function TWindowsServiceManager.RestartService(const ServiceName: string): Boolean;
begin
  Result := False;

  if not ServiceExists(ServiceName) then
    raise EServiceException.CreateFmt('Service "%s" does not exist', [ServiceName]);

  // Stop the service first
  if not StopService(ServiceName) then
    raise EServiceException.CreateFmt('Failed to stop service "%s" during restart', [ServiceName]);

  // Start the service
  if not StartService(ServiceName) then
    raise EServiceException.CreateFmt('Failed to start service "%s" during restart', [ServiceName]);

  Result := True;
end;

function TWindowsServiceManager.StateToString(State: TServiceState): string;
begin
  case State of
    ssUnknown: Result := 'Unknown';
    ssStopped: Result := 'Stopped';
    ssStartPending: Result := 'Start Pending';
    ssStopPending: Result := 'Stop Pending';
    ssRunning: Result := 'Running';
    ssContinuePending: Result := 'Continue Pending';
    ssPausePending: Result := 'Pause Pending';
    ssPaused: Result := 'Paused';
  else
    Result := 'Invalid State';
  end;
end;

function TWindowsServiceManager.GetServiceStatus(const ServiceName: string): string;
begin
  if not ServiceExists(ServiceName) then
    Result := 'Service does not exist'
  else
    Result := StateToString(GetServiceState(ServiceName));
end;

end.
