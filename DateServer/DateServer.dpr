program DateServer;
{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  Console in 'Console.pas';

{$R *.res}

var
  LPort: Integer;
  s: string;
begin
//  if (ParamCount = 2) and FindCmdLineSwitch('p') then
//    TConsole.Create(StrToInt(ParamStr(1)));

  for var i: Integer := 0 to ParamCount do
    s := ParamStr(i);

end.
