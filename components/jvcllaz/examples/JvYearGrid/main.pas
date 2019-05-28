unit main;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF LINUX}clocale,{$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls, Grids,
  ExtCtrls, ComCtrls, JvYearGrid;

type

  { TMainForm }

  TMainForm = class(TForm)
    cmbMonthFormat: TComboBox;
    cmbDayNamesAlignment: TComboBox;
    cmbDayFormat: TComboBox;
    cmbMonthNamesAlignment: TComboBox;
    cmbDaysAlignment: TComboBox;
    CbFlat: TCheckBox;
    JvYearGrid1: TJvYearGrid;
    EdLeftMargin: TSpinEdit;
    EdRightMargin: TSpinEdit;
    EdTopMargin: TSpinEdit;
    EdBottomMargin: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblYear: TLabel;
    Panel1: TPanel;
    udYear: TUpDown;
    procedure cmbDayFormatChange(Sender: TObject);
    procedure cmbDayNamesAlignmentChange(Sender: TObject);
    procedure cmbDaysAlignmentChange(Sender: TObject);
    procedure CbFlatChange(Sender: TObject);
    procedure cmbMonthFormatChange(Sender: TObject);
    procedure cmbMonthNamesAlignmentChange(Sender: TObject);
    procedure EdBottomMarginChange(Sender: TObject);
    procedure EdLeftMarginChange(Sender: TObject);
    procedure EdRightMarginChange(Sender: TObject);
    procedure EdTopMarginChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure udYearClick(Sender: TObject; Button: TUDBtnType);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  DateUtils;

{ TMainForm }

procedure TMainForm.cmbDayNamesAlignmentChange(Sender: TObject);
begin
  JvYearGrid1.DayNamesAlignment := TAlignment(cmbDayNamesAlignment.ItemIndex);
end;

procedure TMainForm.cmbDayFormatChange(Sender: TObject);
begin
  JvYearGrid1.DayFormat := TJvDayFormat(cmbDayFormat.ItemIndex);
end;

procedure TMainForm.cmbDaysAlignmentChange(Sender: TObject);
begin
  JvYearGrid1.DaysAlignment := TAlignment(cmbDaysAlignment.ItemIndex);
end;

procedure TMainForm.CbFlatChange(Sender: TObject);
begin
  JvYearGrid1.Flat := CbFlat.Checked;
end;

procedure TMainForm.cmbMonthFormatChange(Sender: TObject);
begin
  JvYearGrid1.MonthFormat := TJvMonthFormat(cmbMonthFormat.ItemIndex);
end;

procedure TMainForm.cmbMonthNamesAlignmentChange(Sender: TObject);
begin
  JvYearGrid1.MonthNamesAlignment := TAlignment(cmbMonthNamesAlignment.ItemIndex);
end;

procedure TMainForm.EdBottomMarginChange(Sender: TObject);
begin
  JvYearGrid1.CellMargins.Bottom := EdBottomMargin.Value;
end;

procedure TMainForm.EdLeftMarginChange(Sender: TObject);
begin
  JvYearGrid1.CellMargins.Left := EdLeftMargin.Value;
end;

procedure TMainForm.EdRightMarginChange(Sender: TObject);
begin
  JvYearGrid1.CellMargins.Right := EdRightMargin.Value;
end;

procedure TMainForm.EdTopMarginChange(Sender: TObject);
begin
  JvYearGrid1.CellMargins.Top := EdTopMargin.Value;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  JvYearGrid1.Year := YearOf(Date);

  EdLeftMargin.Value := JvYearGrid1.CellMargins.Left;
  EdRightMargin.Value := JvYearGrid1.CellMargins.Right;
  EdTopMargin.Value := JvYearGrid1.CellMargins.Top;
  EdBottomMargin.Value := JvYearGrid1.CellMargins.Bottom;

  cmbDayNamesAlignment.ItemIndex := ord(JvYearGrid1.DayNamesAlignment);
  cmbMonthNamesAlignment.ItemIndex := ord(JvYearGrid1.MonthNamesAlignment);
  cmbDaysAlignment.ItemIndex := ord(JvYearGrid1.DaysAlignment);
  cmbDayFormat.ItemIndex := ord(JvYearGrid1.DayFormat);
  cmbMonthFormat.ItemIndex := ord(JvYearGrid1.MonthFormat);

  udYear.Position := JvYearGrid1.Year;

  CbFlat.Checked := JvYearGrid1.Flat;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  AutoSize := true;
end;

procedure TMainForm.udYearClick(Sender: TObject; Button: TUDBtnType);
begin
  JvYearGrid1.Year := udYear.Position;
end;

end.

