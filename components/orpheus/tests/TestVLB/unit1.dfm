object Form1: TForm1
  Left = 192
  Top = 114
  Width = 554
  Height = 437
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 304
    Width = 425
    Height = 33
    AutoSize = False
    Caption = 'Double-click an item in list'
    Color = clBtnHighlight
    ParentColor = False
  end
  object OvcVirtualListBox1: TOvcVirtualListBox
    Left = 64
    Top = 40
    Width = 425
    Height = 238
    Header = 'Header goes here'
    HeaderColor.BackColor = clBtnFace
    HeaderColor.TextColor = clBtnText
    ProtectColor.BackColor = clRed
    ProtectColor.TextColor = clWhite
    RowHeight = 13
    SelectColor.BackColor = clHighlight
    SelectColor.TextColor = clHighlightText
    ShowHeader = True
    OnGetItem = OvcVirtualListBox1GetItem
    TabOrder = 0
    OnDblClick = OvcVirtualListBox1DblClick
  end
end
