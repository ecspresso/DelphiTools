unit IPManager;

interface

type
  TIPManager = class
  private
    FInputs: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddInput(AInput: string);
    procedure GetAllIPs;
    procedure GetIP(AHostName: string);
  end;

implementation

{ TIPManager }

procedure TIPManager.AddInput(AInput: string);
begin
  FInputs.Add(AInput);
end;

constructor TIPManager.Create;
begin
  FInputs := TList<string>.Create;
end;

destructor TIPManager.Destroy;
begin
  FInputs.Free;
  inherited;
end;

procedure TIPManager.GetAllIPs;
var
  LString: string;
begin
  for LString in FInputs do
    GetIP(LString);
end;

procedure TIPManager.GetIP(AHostName: string);
begin

end;

end.
