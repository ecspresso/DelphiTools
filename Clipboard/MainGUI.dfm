object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Sax'
  ClientHeight = 226
  ClientWidth = 368
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    368
    226)
  TextHeight = 15
  object FBtnAlwaysOnTop: TSpeedButton
    Left = 8
    Top = 193
    Width = 25
    Height = 25
    OnClick = FBtnAlwaysOnTopClick
  end
  object FBtnClip1: TButton
    Left = 8
    Top = 8
    Width = 25
    Height = 25
    Caption = #55357#56523
    TabOrder = 0
    OnMouseDown = FBtnClip1MouseDown
    OnMouseEnter = FBtnClip1MouseEnter
  end
  object FBtnClip2: TButton
    Left = 8
    Top = 39
    Width = 25
    Height = 25
    Caption = #55357#56523
    TabOrder = 1
    OnMouseDown = FBtnClip2MouseDown
    OnMouseEnter = FBtnClip2MouseEnter
  end
  object FBtnClip3: TButton
    Left = 8
    Top = 70
    Width = 25
    Height = 25
    Caption = #55357#56523
    TabOrder = 2
    OnMouseDown = FBtnClip3MouseDown
    OnMouseEnter = FBtnClip3MouseEnter
  end
  object FBtnClip4: TButton
    Left = 8
    Top = 101
    Width = 25
    Height = 25
    Caption = #55357#56523
    TabOrder = 3
    OnMouseDown = FBtnClip4MouseDown
    OnMouseEnter = FBtnClip4MouseEnter
  end
  object FBtnClip5: TButton
    Left = 8
    Top = 132
    Width = 25
    Height = 25
    Caption = #55357#56523
    TabOrder = 4
    OnMouseDown = FBtnClip5MouseDown
    OnMouseEnter = FBtnClip5MouseEnter
  end
  object FBtnClip6: TButton
    Left = 8
    Top = 163
    Width = 25
    Height = 25
    Caption = #55357#56523
    TabOrder = 5
    OnMouseDown = FBtnClip6MouseDown
    OnMouseEnter = FBtnClip6MouseEnter
  end
  object FTextArea: TRichEdit
    Left = 39
    Top = 8
    Width = 321
    Height = 209
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object FTimer: TTimer
    Enabled = False
    Interval = 300
    OnTimer = TimerDoneEvent
    Left = 184
    Top = 88
  end
end
