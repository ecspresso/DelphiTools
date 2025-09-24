unit MainGUI;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Variants,

  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Clipbrd,

  Winapi.Messages,
  Winapi.Windows, Vcl.Menus, Vcl.Buttons, Vcl.ExtCtrls;

type
  TClipData = record
    Text: string;
    Bitmap: Vcl.Graphics.TBitmap;
  end;

  TMainForm = class(TForm)
    FBtnClip1: TButton;
    FBtnClip2: TButton;
    FBtnClip3: TButton;
    FBtnClip4: TButton;
    FBtnClip5: TButton;
    FBtnClip6: TButton;
    FTextArea: TRichEdit;
    FBtnAlwaysOnTop: TSpeedButton;
    FTimer: TTimer;
    procedure FBtnClip1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FBtnClip3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FBtnClip4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FBtnClip5MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FBtnClip6MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FBtnClip2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FBtnClip1MouseEnter(Sender: TObject);
    procedure FBtnClip2MouseEnter(Sender: TObject);
    procedure FBtnClip3MouseEnter(Sender: TObject);
    procedure FBtnClip4MouseEnter(Sender: TObject);
    procedure FBtnClip5MouseEnter(Sender: TObject);
    procedure FBtnClip6MouseEnter(Sender: TObject);
    procedure FBtnAlwaysOnTopClick(Sender: TObject);
    procedure TimerDoneEvent(Sender: TObject);
  private
    FData1, FData2, FData3, FData4, FData5, FData6: TClipData;
    FAlwaysOnTop: Boolean;
    FTimerTarget: Integer;
    procedure ClipboardToMem(var AClipData: TClipData; const ShowClipboard: Boolean);
    procedure MemToClipboard(const AClipData: TClipData; const Force: Boolean = False);
    procedure HoverAction(const AClipData: TClipData);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TForm5 }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FData1.Bitmap := nil;
  FData2.Bitmap := nil;
  FData3.Bitmap := nil;
  FData4.Bitmap := nil;
  FData5.Bitmap := nil;
  FData6.Bitmap := nil;
  MainForm.Constraints.MinWidth := MainForm.Width;
  MainForm.Constraints.MinHeight := MainForm.Height;
  FTextArea.ScrollBars := TScrollStyle.ssVertical;
  FTextArea.PlainText := False;
  FAlwaysOnTop := False;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FData1.Bitmap) then
    FData1.Bitmap.Free;
  if Assigned(FData2.Bitmap) then
    FData2.Bitmap.Free;
  if Assigned(FData3.Bitmap) then
    FData3.Bitmap.Free;
  if Assigned(FData4.Bitmap) then
    FData4.Bitmap.Free;
  if Assigned(FData5.Bitmap) then
    FData5.Bitmap.Free;
  if Assigned(FData6.Bitmap) then
    FData6.Bitmap.Free;
  inherited;
end;

procedure TMainForm.FBtnClip1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ClipboardToMem(FData1, True)
  else
    MemToClipboard(FData1);
end;

procedure TMainForm.FBtnClip1MouseEnter(Sender: TObject);
begin
  FTimer.Enabled := False;
  FTimerTarget := 1;
  FTimer.Enabled := True;
end;

procedure TMainForm.FBtnClip2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ClipboardToMem(FData2, True)
  else
    MemToClipboard(FData2);
end;

procedure TMainForm.FBtnClip2MouseEnter(Sender: TObject);
begin
  FTimer.Enabled := False;
  FTimerTarget := 2;
  FTimer.Enabled := True;
end;

procedure TMainForm.FBtnClip3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ClipboardToMem(FData3, True)
  else
    MemToClipboard(FData3);
end;

procedure TMainForm.FBtnClip3MouseEnter(Sender: TObject);
begin
  FTimer.Enabled := False;
  FTimerTarget := 3;
  FTimer.Enabled := True;
end;

procedure TMainForm.FBtnClip4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ClipboardToMem(FData4, True)
  else
    MemToClipboard(FData4);
end;

procedure TMainForm.FBtnClip4MouseEnter(Sender: TObject);
begin
  FTimer.Enabled := False;
  FTimerTarget := 4;
  FTimer.Enabled := True;
end;

procedure TMainForm.FBtnClip5MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ClipboardToMem(FData5, True)
  else
    MemToClipboard(FData5);
end;

procedure TMainForm.FBtnClip5MouseEnter(Sender: TObject);
begin
  FTimer.Enabled := False;
  FTimerTarget := 5;
  FTimer.Enabled := True;
end;

procedure TMainForm.FBtnClip6MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ClipboardToMem(FData6, True)
  else
    MemToClipboard(FData6);
end;

procedure TMainForm.FBtnClip6MouseEnter(Sender: TObject);
begin
  FTimer.Enabled := False;
  FTimerTarget := 6;
  FTimer.Enabled := True;
end;

procedure TMainForm.TimerDoneEvent(Sender: TObject);
var
  LClipData: TClipData;
  LButton: TButton;
  TopLeft, BottomRight: TPoint;
  ButtonRect: TRect;
  MousePos: TPoint;
begin
  LButton := nil;
  LClipData.Bitmap := nil;

  case FTimerTarget of
    1:
      begin
        LClipData := FData1;
        LButton := FBtnClip1;
      end;
    2:
      begin
        LClipData := FData2;
        LButton := FBtnClip2;
      end;
    3:
      begin
        LClipData := FData3;
        LButton := FBtnClip3;
      end;
    4:
      begin
        LClipData := FData4;
        LButton := FBtnClip4;
      end;
    5:
      begin
        LClipData := FData5;
        LButton := FBtnClip5;
      end;
    6:
      begin
        LClipData := FData6;
        LButton := FBtnClip6;
      end;
  end;

  TopLeft := LButton.ClientToScreen(Point(0, 0));
  BottomRight := LButton.ClientToScreen(Point(LButton.Width, LButton.Height));
  ButtonRect := Rect(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
  MousePos := Mouse.CursorPos;

  if PtInRect(ButtonRect, MousePos) then
    HoverAction(LClipData);
  FTimer.Enabled := False;
end;

procedure TMainForm.HoverAction(const AClipData: TClipData);
var
  LClipBackup: TClipData;
begin
  // Minneshantering
  LClipBackup.Bitmap := nil;
  // Spara klippbordet i LClipMem
  ClipboardToMem(LClipBackup, False);
  // Från AClipData till klippbordet
  MemToClipboard(AClipData, True);
  // Rensa det som visas
  FTextArea.Clear;
  // Visa klippbordet
  FTextArea.PasteFromClipboard;
  // Återställ klippbordet
  MemToClipboard(LClipBackup);
  // Minneshantering
  if Assigned(LClipBackup.Bitmap) then
    LClipBackup.Bitmap.Free;
end;

procedure TMainForm.MemToClipboard(const AClipData: TClipData; const Force: Boolean = False);
begin
  if Assigned(AClipData.Bitmap) then
    Clipboard.Assign(AClipData.Bitmap)
  else if not AClipData.Text.IsEmpty then
    Clipboard.AsText := AClipData.Text
  else if Force then
    Clipboard.AsText := '';
end;

procedure TMainForm.FBtnAlwaysOnTopClick(Sender: TObject);
begin
  if FAlwaysOnTop then
  begin
    FAlwaysOnTop := False;
    FBtnAlwaysOnTop.Caption := '';
    MainForm.FormStyle := TFormStyle.fsNormal;
  end
  else
  begin
    FAlwaysOnTop := True;
    FBtnAlwaysOnTop.Caption := '📌';
    MainForm.FormStyle := TFormStyle.fsStayOnTop;
  end;
end;

procedure TMainForm.ClipboardToMem(var AClipData: TClipData; const ShowClipboard: Boolean);
begin
  AClipData.Text := '';
  if Assigned(AClipData.Bitmap) then
    FreeAndNil(AClipData.Bitmap);

  if Clipboard.HasFormat(CF_TEXT) then
    AClipData.Text := Clipboard.AsText
  else if Clipboard.HasFormat(CF_BITMAP) then
    AClipData.Bitmap.Assign(Clipboard);

  if ShowClipboard then
  begin
    FTextArea.Clear;
    FTextArea.PasteFromClipboard;
  end;
end;

end.
