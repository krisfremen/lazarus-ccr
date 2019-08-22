unit umainform;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons, StdCtrls,
  Spin, ueverettrandom;

type

  { Tmainform }

  Tmainform = class(TForm)
    cmdSplit: TBitBtn;
    cmdClose: TBitBtn;
    grpNumElements: TGroupBox;
    grp_HexSize: TGroupBox;
    grpResults: TGroupBox;
    lstResults: TListBox;
    pnlMain: TPanel;
    rgSingleElement: TRadioGroup;
    spArrayNumber: TSpinEdit;
    spHexSize: TSpinEdit;
    procedure cmdSplitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    myEverett: TEverett;
  public

  end;

var
  mainform: Tmainform;

implementation

{$R *.lfm}

{ Tmainform }

procedure Tmainform.FormCreate(Sender: TObject);
begin
  Caption:=Application.Name;
  Icon:=Application.Icon;
  myEverett := TEverett.Create(Self);
  // Set up dialog
  // MyEverett.WaitDialogCaption:='Please wait. contacting server';
  MyEverett.ShowWaitDialog:=TRUE;
end;

procedure Tmainform.FormResize(Sender: TObject);
begin
  // Set minimum size
  if Width < 300 then
    Width := 300;
  if Height < 500 then
    Height := 500;
end;

procedure Tmainform.cmdSplitClick(Sender: TObject);
var
  s: string;
  ct:Integer;
begin
  lstResults.Clear;
  MyEverett.ArraySize:=spArrayNumber.Value;
  MyEverett.HexSize:=spHexSize.Value;
    case rgSingleElement.ItemIndex of
      0:begin
        MyEverett.GetInteger8BitArray;
        for ct:=0 to Pred(MyEverett.ArraySize) do
          lstResults.Items.Add(InttoStr(MyEverett.IntegerArray[ct]));
      end;
      1:begin
        MyEverett.GetInteger16BitArray;
        for ct:=0 to Pred(MyEverett.ArraySize) do
          lstResults.Items.Add(InttoStr(MyEverett.IntegerArray[ct]));
      end;
      2:begin
        MyEverett.GetHexArray;
        for ct:=0 to Pred(MyEverett.ArraySize) do
          lstResults.Items.Add(MyEverett.HexArray[ct]);
      end;
    end;
    s := 'Universe sucessfully split' + LineEnding;
    ShowMessageFmt('%s%d times!',[s,spArrayNumber.Value]);
end;

end.
