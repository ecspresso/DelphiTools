program IP;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  IPManager in 'IPManager.pas';

begin
  LDecoder := TURLDecoder.Create;
  try
    try
      if ParamCount >= 1 then
      begin
        for i := 1 to ParamCount do
          LDecoder.AddInput(ParamStr(i));

        LDecoder.DecodeAll;
      end
      else
      begin
        Writeln('Enter URLs (type "quit" to exit):');
        repeat
          Write('> ');
          Readln(LUserInput);
          if LowerCase(LUserInput) <> 'quit' then
          begin
            LDecoder.DecodeUrl(LUserInput);
          end;
        until LowerCase(LUserInput) = 'quit';
      end;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    LDecoder.Free;
  end;
end.
