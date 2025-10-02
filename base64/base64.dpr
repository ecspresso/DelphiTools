program base64;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.NetEncoding,
  System.SysUtils;

function ParamIsEncode(AParameter: string): Boolean;
begin
  Result := SameText(AParameter, 'e') or SameText(AParameter, '-e') or SameText(AParameter, '--encode');
end;

function ParamIsDecode(AParameter: string): Boolean;
begin
  Result := SameText(AParameter, 'd') or SameText(AParameter, '-d') or SameText(AParameter, '--decode');
end;

procedure ShowHelp;
begin
  Writeln('Usage:');
  Writeln('-e, --encode <string>: Base64 encodes a string.');
  Writeln('-d, --decode <string>: Base64 decodes a string.');
  Writeln('No parameter: interactive encode/decode.');
end;

var
  i: Integer;
  LUserInput: string;
  LDecode, LEncode: Boolean;

begin
  LUserInput := '';

  if ParamCount = 0 then
  begin
    while LUserInput <> 'quit' do
    begin
      Writeln('1. Encode (e)');
      Writeln('2. Decode (d)');
      Writeln('3. Quit (q)');
      Write('> ');
      Readln(LUserInput);

      if (LUserInput = '1') or (LUserInput = 'e') or (LUserInput = 'encode') then
      begin
        while LUserInput <> 'back' do
        begin
          Writeln('');
          Writeln('Enter string to encode or ''back'' to go back.');
          Write('> ');
          Readln(LUserInput);
          if not LUserInput.IsEmpty then
            Writeln(TNetEncoding.base64.Encode(LUserInput));
        end;
      end
      else if (LUserInput = '2') or (LUserInput = 'd') or (LUserInput = 'decode') then
      begin
        while LUserInput <> 'back' do
        begin
          Writeln('');
          Writeln('Enter string to encode or ''back'' to go back.');
          Write('> ');
          Readln(LUserInput);
          if not LUserInput.IsEmpty then
            Writeln(TNetEncoding.base64.Encode(LUserInput));
        end;
      end
      else if (LUserInput = '3') or (LUserInput = 'q') or (LUserInput = 'quit') then
      begin
        Exit;
      end;
    end;
  end
  else if ParamCount = 2 then
  begin
    if ParamIsEncode(ParamStr(1)) then
      Writeln(TNetEncoding.base64.Encode(ParamStr(2)))
    else if ParamIsDecode(ParamStr(1)) then
      Writeln(TNetEncoding.base64.Decode(ParamStr(2)))
    else
    begin
      ShowHelp;
    end;
  end
  else
    ShowHelp;

end.
