unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ExCheckCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    CheckBoxEx1: TCheckBoxEx;
    CheckBoxEx2: TCheckBoxEx;
    CheckBoxEx3: TCheckBoxEx;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RadioButtonEx1: TRadioButtonEx;
    RadioButtonEx2: TRadioButtonEx;
    RadioButtonEx3: TRadioButtonEx;
    RadioGroupEx1: TRadioGroupEx;
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioButtonEx1GetImageIndex(Sender: TObject; AHover, APressed,
      AEnabled: Boolean; AState: TCheckboxState; var AImgIndex: Integer);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.CheckBox1Change(Sender: TObject);
begin
  CheckboxEx1.AutoSize := true;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RadioGroupEx1.Buttons[0].ThemedCaption := false;
  RadioGroupEx1.Buttons[1].ThemedCaption := false;
  RadioGroupEx1.Buttons[2].ThemedCaption := false;
  RadioGroupEx1.Buttons[0].Font.Color := clRed;
  RadioGroupEx1.Buttons[1].Font.Color := clGreen;
  RadioGroupEx1.Buttons[2].Font.Color := clBlue;
  RadioGroupEx1.Buttons[3].Enabled := false;
  Label6.Caption := 'This box contains ' + IntToStr(RadioGroupEx1.ButtonCount) + ' buttons';
end;

procedure TMainForm.RadioButtonEx1GetImageIndex(Sender: TObject; AHover,
  APressed, AEnabled: Boolean; AState: TCheckboxState; var AImgIndex: Integer);
begin
  if AState = cbChecked then AImgIndex := 1 else AImgIndex := 0;
end;

end.

