program IBM;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  ServiceManager in 'ServiceManager.pas',
  Console in 'Console.pas',
  ConsoleConsts in 'ConsoleConsts.pas';

var
  i: Integer;
  Param: string;
  Console: TConsole;

begin
  if ParamCount = 0 then
  begin
    Writeln('status, restart, stop, start');
    Exit;
  end;

  Console := TConsole.Create;

  for i := 1 to ParamCount - 1 do
  begin
    Param := ParamStr(i);
    if Param = 'start' then
      Console.StartService
    else if Param = 'stop' then
      Console.StopService
    else if Param = 'restart' then
      Console.RestartService
    else if Param = 'status' then
      Console.WriteStatus
    else
      Console.WriteCommands;

  end;

  // try
  // TConsole.Create.Run;
  // except
  // on E: Exception do
  // begin
  // Writeln(E.ClassName, ': ', E.Message);
  // Readln;
  // end;
  // end;
end.
