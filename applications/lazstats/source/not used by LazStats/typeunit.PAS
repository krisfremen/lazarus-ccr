unit TypeUnit;

{$MODE Delphi}

interface

uses
  //Windows, Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TTypeFrm = class(TForm)
    TypeRG: TRadioGroup;
    CancelBtn: TButton;
    OKBtn: TButton;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ItemType : integer;
  end;

var
  TypeFrm: TTypeFrm;

implementation

{$R *.lfm}

procedure TTypeFrm.CancelBtnClick(Sender: TObject);
begin
     TypeFrm.Hide;
end;

procedure TTypeFrm.OKBtnClick(Sender: TObject);
begin
     TypeFrm.Hide;
end;

end.
