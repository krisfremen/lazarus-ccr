unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ColorBox,
  Spin, ExtCtrls, switches, indSliders;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbSliderColor: TColorButton;
    cbVertical: TCheckBox;
    cbAutoRotate: TCheckBox;
    cbColorBelow: TColorButton;
    cbColorBetween: TColorButton;
    cbColorAbove: TColorButton;
    cbFlat: TCheckBox;
    cbEnabled: TCheckBox;
    cbTransparent: TCheckBox;
    cbFormColor: TColorButton;
    cmbThumbStyle: TComboBox;
    cbColorThumb: TColorButton;
    cmbSliderMode: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    seTrackThickness: TSpinEdit;
    seDefaultSize: TSpinEdit;
    procedure cbAutoRotateChange(Sender: TObject);
    procedure cbColorAboveColorChanged(Sender: TObject);
    procedure cbColorBelowColorChanged(Sender: TObject);
    procedure cbColorBetweenColorChanged(Sender: TObject);
    procedure cbColorThumbColorChanged(Sender: TObject);
    procedure cbEnabledChange(Sender: TObject);
    procedure cbFlatChange(Sender: TObject);
    procedure cbSliderColorColorChanged(Sender: TObject);
    procedure cmbSliderModeChange(Sender: TObject);
    procedure cmbThumbStyleChange(Sender: TObject);
    procedure cbTransparentChange(Sender: TObject);
    procedure cbVerticalChange(Sender: TObject);
    procedure cbFormColorColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure seDefaultSizeChange(Sender: TObject);
    procedure seTrackThicknessChange(Sender: TObject);
  private
    slider: TMultiSlider;
    procedure PositionChangeHandler(Sender: TObject; AKind: TThumbKind; AValue: Integer);

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  slider := TMultiSlider.Create(self);
  slider.Parent := self;
  slider.Align := alTop;
  slider.BorderSpacing.Around := 8;
//  slider.Left := 8;
//  slider.Top := 8;
  slider.Vertical := false;
  slider.OnPositionChange := @PositionChangeHandler;

  cbColorBelow.ButtonColor := slider.ColorBelow;
  cbColorAbove.ButtonColor := slider.ColorAbove;
  cbColorBetween.ButtonColor := slider.ColorBetween;
  cbColorThumb.ButtonColor := slider.ColorThumb;
  cbSliderColor.ButtonColor := slider.Color;
  cbFormColor.ButtonColor := Color;
  cbTransparent.Checked := slider.Color = clNone;
  seTrackThickness.Value := slider.TrackThickness;
  seDefaultSize.Value := slider.DefaultSize;
  cmbSliderMode.ItemIndex := ord(slider.SliderMode);
end;

procedure TForm1.seDefaultSizeChange(Sender: TObject);
begin
  slider.DefaultSize := seDefaultSize.Value;
end;

procedure TForm1.seTrackThicknessChange(Sender: TObject);
begin
  slider.TrackThickness := seTrackThickness.Value;
end;

procedure TForm1.cbVerticalChange(Sender: TObject);
begin
  slider.Vertical := cbVertical.Checked;
  if slider.Vertical then slider.Align := alLeft else slider.Align := alTop;
end;

procedure TForm1.cbFormColorColorChanged(Sender: TObject);
begin
  Color := cbFormColor.ButtonColor;
end;

procedure TForm1.cbColorThumbColorChanged(Sender: TObject);
begin
  slider.ColorThumb := cbColorThumb.ButtonColor;
end;

procedure TForm1.cbAutoRotateChange(Sender: TObject);
begin
  slider.AutoRotate := cbAutoRotate.Checked;
end;

procedure TForm1.cbColorAboveColorChanged(Sender: TObject);
begin
  slider.ColorAbove := cbColorAbove.ButtonColor;
end;

procedure TForm1.cbColorBelowColorChanged(Sender: TObject);
begin
  slider.ColorBelow := cbColorBelow.ButtonColor;
end;

procedure TForm1.cbColorBetweenColorChanged(Sender: TObject);
begin
  slider.ColorBetween := cbColorBetween.ButtonColor;
end;

procedure TForm1.cbSliderColorColorChanged(Sender: TObject);
begin
  slider.Color := cbSliderColor.ButtonColor;
end;

procedure TForm1.cmbSliderModeChange(Sender: TObject);
begin
  slider.SliderMode := TSliderMode(cmbSliderMode.ItemIndex);
end;

procedure TForm1.cbEnabledChange(Sender: TObject);
begin
  slider.Enabled := cbEnabled.Checked;
end;

procedure TForm1.cbFlatChange(Sender: TObject);
begin
  slider.Flat := cbFlat.Checked;
end;

procedure TForm1.cmbThumbStyleChange(Sender: TObject);
begin
  slider.ThumbStyle := TThumbStyle(cmbThumbStyle.ItemIndex);
end;

procedure TForm1.cbTransparentChange(Sender: TObject);
begin
  if cbTransparent.Checked then
    slider.Color := clNone;
end;

procedure TForm1.PositionChangeHandler(Sender: TObject; AKind: TThumbKind;
  AValue: Integer);
begin
  case AKind of
    tkMin: Label1.Caption := 'Min = ' + intToStr(AValue);
    tkValue: Label2.Caption := 'Value = ' + IntToStr(AValue);
    tkMax: Label3.Caption := 'Max = ' + IntToStr(AValue);
  end;
end;

end.

