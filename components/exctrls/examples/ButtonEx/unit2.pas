unit unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExButtons;

type

  { TForm2 }

  TForm2 = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    OKBtn: TButtonEx;
    CancelBtn: TButtonEx;

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  OKBtn := TButtonEx.Create(nil);
  OKBtn.Parent := self;
  OKBtn.Top := Label1.Top + Label1.Height + 16;
  OKBtn.Left := 16;
  //OKBtn.AutoSize := true;
  OKBtn.Caption := 'OK';
  OKBtn.Default := true;
  OKBtn.ModalResult := mrOK;
  OKBtn.DefaultDrawing := false;

  CancelBtn := TButtonEx.Create(nil);
  CancelBtn.Parent := self;
  CancelBtn.Top := OKBtn.Top;
  CancelBtn.Left := 100;
  //CancelBtn.AutoSize := true;
  CancelBtn.Caption := 'Cancel';
  CancelBtn.Cancel := true;
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.DefaultDrawing := false;
end;

end.

