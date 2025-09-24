unit URLDecoder;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.NetEncoding;

type
  TURLDecoder = class
  private
    FInputs: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddInput(AInput: string);
    procedure DecodeAll;
    procedure DecodeUrl(AURL: string);
  end;

implementation

{ TURLDecoder }

procedure TURLDecoder.AddInput(AInput: string);
begin
  FInputs.Add(AInput);
end;

constructor TURLDecoder.Create;
begin
  FInputs := TList<string>.Create;
end;

procedure TURLDecoder.DecodeAll;
var
  LString: string;
begin
  for LString in FInputs do
    DecodeUrl(LString);
end;

procedure TURLDecoder.DecodeUrl(AURL: string);
begin
  Writeln(TNetEncoding.URL.Decode(AURL));
end;

destructor TURLDecoder.Destroy;
begin
  FInputs.Free;
  inherited;
end;

end.
