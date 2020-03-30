unit RootMethodUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TRootMethodFrm }

  TRootMethodFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    CancelBtn: TButton;
    ReturnBtn: TButton;
    MethodGroup: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Choice : integer;
  end; 

var
  RootMethodFrm: TRootMethodFrm;

implementation

uses
  Math;

{ TRootMethodFrm }

procedure TRootMethodFrm.FormActivate(Sender: TObject);
begin
  CancelBtn.Constraints.MinWidth := Max(CancelBtn.Width, ReturnBtn.Width);
  ReturnBtn.Constraints.MinWidth := CancelBtn.Constraints.MinWidth;
end;

procedure TRootMethodFrm.ReturnBtnClick(Sender: TObject);
begin
  Choice := MethodGroup.ItemIndex + 1;
end;

initialization
  {$I rootmethodunit.lrs}

end.

