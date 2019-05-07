unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, EditBtn, StdCtrls,
  DBCtrls, DBGrids, paradoxds, db;

type

  { TMainForm }

  TMainForm = class(TForm)
    btnOpen: TButton;
    DataSource1: TDataSource;
    Grid: TDBGrid;
    DBNavigator: TDBNavigator;
    edFileName: TFileNameEdit;
    Paradox: TParadoxDataSet;
    procedure btnOpenClick(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.btnOpenClick(Sender: TObject);
begin
  Paradox.Close;
  Paradox.TableName := edFileName.Filename;
  Paradox.Open;
end;

end.

