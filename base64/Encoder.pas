unit Encoder;

interface

uses
  System.NetEncoding;

type
  TEncoder = class
  public
    class procedure Encode(ALine: string); static;
    class procedure Decode(ALine: string); static;
  end;

implementation



{ TURLDecoder }

constructor TEncoder.Create;
begin
  FNetEncoding := TNetEncoding.Create;
end;

destructor TEncoder.Destroy;
begin
  FNetEncoding.Free;
  inherited;
end;

procedure TEncoder.DoDecode(ALine: string);
begin
  Writeln(FNetEncoding.Encode(ALine));
end;

procedure TEncoder.DoEncode(ALine: string);
begin
   Writeln(FNetEncoding.Decode(ALine));
end;

{ Static }

class procedure TEncoder.Decode(ALine: string);
var
  LEncoder: TEncoder;
begin
  LEncoder := TEncoder.Create;
  try
    LEncoder.Decode(Aline);
  finally
    LEncoder.Free;
  end;
end;



class procedure TEncoder.Encode(ALine: string);
var
  LEncoder: TEncoder;
begin
  LEncoder := TEncoder.Create;
  try
    LEncoder.Encode(Aline);
  finally
    LEncoder.Free;
  end
end;

end.
