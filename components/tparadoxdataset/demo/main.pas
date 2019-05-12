unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, EditBtn, StdCtrls,
  DBCtrls, DBGrids, ExtCtrls, Buttons, paradoxds, db;

type

  { TMainForm }

  TMainForm = class(TForm)
    Bevel1: TBevel;
    CbFilterField: TComboBox;
    CbFilterValues: TComboBox;
    DataSource: TDataSource;
    DBImage: TDBImage;
    DBMemo: TDBMemo;
    DBGrid: TDBGrid;
    DBNavigator: TDBNavigator;
    DBText: TDBText;
    CbFiltered: TCheckBox;
    LblEqual: TLabel;
    Paradox: TParadoxDataSet;
    BtnSetBookmark: TSpeedButton;
    BtnGotoBookmark: TSpeedButton;
    BtnFilter: TSpeedButton;
    procedure BtnFilterClick(Sender: TObject);
    procedure BtnGotoBookmarkClick(Sender: TObject);
    procedure BtnSetBookmarkClick(Sender: TObject);
    procedure CbFilteredChange(Sender: TObject);
    procedure CbFilterFieldChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ParadoxAfterOpen(DataSet: TDataSet);
  private
    FBookmark: TBookmark;
    procedure PopulatePickList;
    procedure UpdateControlStates;

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.BtnGotoBookmarkClick(Sender: TObject);
begin
  Paradox.GoToBookmark(FBookmark);
end;

procedure TMainForm.BtnFilterClick(Sender: TObject);
begin
  Paradox.Filtered := False;
  if CbFilterValues.Text <> '' then begin
    Paradox.Filter := CbFilterField.Items[CbFilterField.ItemIndex] + ' = ' + QuotedStr(CbFilterValues.Text);
    Paradox.Filtered := true;
  end;
end;

procedure TMainForm.BtnSetBookmarkClick(Sender: TObject);
begin
  FBookmark := Paradox.GetBookmark;
  UpdateControlStates;
end;

procedure TMainForm.CbFilteredChange(Sender: TObject);
begin
  Paradox.Filtered := CbFiltered.Checked;
  UpdateControlStates;
end;

procedure TMainForm.CbFilterFieldChange(Sender: TObject);
begin
  PopulatePickList;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  AutoSize := false;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Paradox.TableName := 'mushrooms.db';
  DBMemo.DataField := 'Notes';
  DBImage.DataField := 'Picture';
  DBText.DataField := 'CommonName';
  DBGrid.Columns[0].FieldName := 'ID';
  DBGrid.Columns[1].FieldName := 'CommonName';
  DBGrid.Columns[2].FieldName := 'ScientificName';
  DBGrid.Columns[3].FieldName := 'Order';
  DBGrid.Columns[4].FieldName := 'Genus';
  Paradox.Open;
end;

procedure TMainForm.ParadoxAfterOpen(DataSet: TDataSet);
begin
  PopulatePickList;
  FBookmark := nil;
  UpdateControlStates;
end;

procedure TMainForm.PopulatePickList;
var
  pdx: TParadoxDataset;
  L: TStrings;
  F: TField;
begin
  L := TStringList.Create;
  try
    pdx := TParadoxDataset.Create(nil);
    try
      pdx.Tablename := Paradox.TableName;
      pdx.Open;
      F := pdx.FieldByName(CbFilterField.Items[CbFilterField.ItemIndex]);
      while not pdx.EoF do begin
        if L.IndexOf(F.AsString) = -1 then
          L.Add(F.AsString);
        pdx.Next;
      end;
      (L as TStringList).Sort;
      CbFilterValues.Items.Assign(L);
      if CbFilterValues.Items.Count > 0 then begin
        if (CbFilterValues.ItemIndex = -1) then
          CbFilterValues.ItemIndex := 0
        else
        if (CbFiltervalues.ItemIndex >= CbFilterValues.Items.Count) then
          CbFilterValues.ItemIndex := CbFilterValues.Items.Count - 1;
      end;
    finally
      pdx.Free;
    end;
  finally
    L.Free;
  end;
end;

procedure TMainForm.UpdateControlStates;
begin
  CbFilterField.Enabled := Paradox.Filtered;
  LblEqual.Enabled := Paradox.Filtered;
  CbFilterValues.Enabled := Paradox.Filtered;
  BtnFilter.Enabled := Paradox.Filtered;
  BtnGotoBookmark.Enabled := Assigned(FBookmark) and Paradox.BookmarkValid(FBookmark);
end;

end.

