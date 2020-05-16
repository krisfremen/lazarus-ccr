unit LoanItUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs;

type

  { TLoanItFrm }

  TLoanItFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel4: TBevel;
    CalendarBtn: TButton;
    CalendarDialog1: TCalendarDialog;
    Panel1: TPanel;
    PrintChk: TCheckBox;
    DayEdit: TEdit;
    YearEdit: TEdit;
    MonthEdit: TEdit;
    MonthLabel: TLabel;
    DayLabel: TLabel;
    YearLabel: TLabel;
    NameEdit: TEdit;
    Label6: TLabel;
    ResetBtn: TButton;
    AmortizeBtn: TButton;
    CloseBtn: TButton;
    AmountEdit: TEdit;
    InterestEdit: TEdit;
    YearsEdit: TEdit;
    PayPerYrEdit: TEdit;
    RePayEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure AmortizeBtnClick(Sender: TObject);
    procedure CalendarBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): boolean;
  public
    { public declarations }
  end; 

var
  LoanItFrm: TLoanItFrm;

implementation

uses
  Math, DateUtils, OutputUnit;

{ TLoanItFrm }

procedure TLoanItFrm.ResetBtnClick(Sender: TObject);
begin
  NameEdit.Text := '';
  MonthEdit.Text := '';
  DayEdit.Text := '';
  YearEdit.Text := '';
  YearsEdit.Text := '';
  AmountEdit.Text := '';
  InterestEdit.Text := '';
  PayPerYrEdit.Text := '';
  RepayEdit.Text := '';
end;

procedure TLoanItFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TLoanItFrm.AmortizeBtnClick(Sender: TObject);
var
  no_per_year, year_payed, month_payed, day, month, j, k : integer;
  fraction, interest, numerator, denominator, payment, total_interest : double;
  amount, interest_payment, total_payed, pcnt_interest, years, no_years : double;
  aname: string;
  msg: String;
  C: TWinControl;
  lReport: TStrings;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;

  aname := NameEdit.Text;
  no_per_year := StrToInt(PayPerYrEdit.Text);
  day := StrToInt(DayEdit.Text);
  month := StrToInt(MonthEdit.Text);
  years := StrToFloat(YearEdit.Text);
  amount := StrToFloat(AmountEdit.Text);
  no_years := StrToFloat(YearsEdit.Text);
  pcnt_interest := StrToFloat(InterestEdit.Text);

  interest := pcnt_interest / 100.0;
  numerator := interest * amount /  no_per_year;
  denominator := 1.0 - (1.0 / power((interest / no_per_year + 1.0), (no_per_year * no_years) ) );
  payment := numerator / denominator;
  RePayEdit.Text := Format('%.2f', [payment]);

  if not PrintChk.Checked then
    exit;

  if (no_per_year < 12) then
    fraction := 12.0 / no_per_year else fraction := 1.0;

  lReport := TStringList.Create;
  try
    lReport.Add(  'PAYMENT SCHEDULE PROGRAM by W. G. Miller');
    lReport.Add(  '');
    lReport.Add(  '---------------------------------------------------------------------------');
    lReport.Add(  '');
    lReport.Add(  'Name of Borrower: ' + aname);
    lReport.Add(  'Amount borrowed: $%.2f at %.2f percent over %.1f years.', [amount, pcnt_interest, no_years]);
    lReport.Add(  '');
    total_interest := 0.0;
    total_payed := 0.0;
    for j := 1 to round(no_years) do
    begin
      lReport.Add('---------------------------------------------------------------------------');
      lReport.Add(' PAYMENT        PAYMENT     INTEREST     BALANCE        TOTAL         TOTAL');
      lReport.Add('   DATE          AMOUNT       PAYED     REMAINING     INTEREST         PAID');
      lReport.Add('---------------------------------------------------------------------------');
      //          'xx/xx/xxxx xxxxxxxxxxxx xxxxxxxxxxxx xxxxxxxxxxxx xxxxxxxxxxxx xxxxxxxxxxxx
      for k := 1 to no_per_year do
      begin
        year_payed := round(years) + j - 1 ;
        month_payed := round(k * fraction + (month - fraction));
        if (month_payed > 12) then
        begin
          year_payed := year_payed + 1;
          month_payed := month_payed - 12;
        end;
        interest_payment := amount * interest / no_per_year;
        amount := amount - payment + interest_payment;
        total_interest := total_interest + interest_payment;
        total_payed := total_payed + payment;
        lReport.Add('%2d/%2d/%4d %12.2f %12.2f %12.2f %12.2f %12.2f', [
          month_payed, day, year_payed, payment, interest_payment,
          amount, total_interest, total_payed
        ]);
      end; // next k
      lReport.Add('');
    end; // next j

    DisplayReport(lReport);

  finally
    lReport.Free;
  end;
end;

procedure TLoanItFrm.CalendarBtnClick(Sender: TObject);
var
  d: TDate;
  dy, mn, yr: Integer;
  ok: Boolean;
begin
  ok := (DayEdit.Text <> '') and TryStrToInt(DayEdit.Text, dy) and
        (MonthEdit.Text <> '') and TryStrToInt(MonthEdit.Text, mn) and
        (YearEdit.Text <> '') and TryStrToInt(YearEdit.Text, yr) and
        TryEncodeDate(yr, mn, dy, d);
  if not ok then
     d := Date;
  CalendarDialog1.Date := d;
  if CalendarDialog1.Execute then
  begin
    YearEdit.Text := IntToStr(YearOf(CalendarDialog1.Date));
    MonthEdit.Text := IntToStr(MonthOf(CalendarDialog1.Date));
    DayEdit.Text := IntToStr(DayOf(CalendarDialog1.Date));
  end;
end;

procedure TLoanItFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, AmortizeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  AmortizeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
              {
  w := DayEdit.Width;
  DayEdit.Constraints.MaxWidth := w;
  MonthEdit.Constraints.MaxWidth := w;
  YearEdit.Constraints.MaxWidth := w;
  }
end;

function TLoanItFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := False;

  if MonthEdit.Text = '' then
  begin
    AControl := MonthEdit;
    AMsg := 'This field cannot be empty.';
    exit;
  end;
  if not TryStrToInt(MonthEdit.Text, n) then
  begin
    AControl := MonthEdit;
    AMsg := 'No valid integer in this field.';
    exit;
  end;

  if DayEdit.Text = '' then
  begin
    AControl := DayEdit;
    AMsg := 'This field cannot be empty.';
    exit;
  end;
  if not TryStrToInt(DayEdit.Text, n) then
  begin
    AControl := DayEdit;
    AMsg := 'No valid integer in this field.';
    exit;
  end;

  if YearEdit.Text = '' then
  begin
    AControl := YearEdit;
    AMsg := 'This field cannot be empty.';
    exit;
  end;
  if not TryStrToInt(YearEdit.Text, n) then
  begin
    AControl := YearEdit;
    AMsg := 'No valid integer in this field.';
    exit;
  end;

  if AmountEdit.Text = '' then
  begin
    AControl := AmountEdit;
    AMsg := 'This field cannot be empty';
    exit;
  end;
  if not TryStrToFloat(AmountEdit.Text, x) then
  begin
    AControl := AmountEdit;
    AMsg := 'No valid number in this field.';
    exit;
  end;

  if YearsEdit.Text = '' then
  begin
    AControl := YearsEdit;
    AMsg := 'This field cannot be empty.';
    exit;
  end;
  if not TryStrToFloat(YearsEdit.Text, x) then
  begin
    AControl := YearsEdit;
    AMsg := 'No valid number in this field.';
    exit;
  end;
  if n <= 0 then
  begin
    AControl := YearsEdit;
    AMsg := 'Number of years must be positive.';
    exit;
  end;

  if PayPerYrEdit.Text = '' then
  begin
    AControl := PayPerYrEdit;
    AMsg := 'Payments per year not specified.';
    exit;
  end;
  if not TryStrToInt(PayPerYrEdit.Text, n) then
  begin
    AControl := PayPerYrEdit;
    AMsg := 'No valid integer in this field.';
    exit;
  end;
  if n <= 0 then
  begin
    AControl := PayPerYrEdit;
    AMsg := 'Payments per year must not be zero or negative.';
    exit;
  end;

  if InterestEdit.Text = '' then
  begin
    AControl := InterestEdit;
    AMsg := 'Interest rate not specified.';
    exit;
  end;
  if not TryStrToFloat(InterestEdit.Text, x) then
  begin
    AControl := InterestEdit;
    AMsg := 'No valid number given as interest rate.';
    exit;
  end;

  Result := true;
end;

initialization

 {$I loanitunit.lrs}

end.

