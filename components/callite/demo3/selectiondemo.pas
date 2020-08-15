unit SelectionDemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  CalendarLite;

type

  { TForm1 }

  TForm1 = class(TForm)
    CalendarLite1: TCalendarLite;
    CbMultiselect: TCheckBox;
    CbPersistentSelectedDates: TCheckBox;
    ListBox1: TListBox;
    Panel1: TPanel;
    Splitter1: TSplitter;
    procedure CalendarLite1DateChange(Sender: TObject);
    procedure CbMultiselectChange(Sender: TObject);
    procedure CbPersistentSelectedDatesChange(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.CalendarLite1DateChange(Sender: TObject);
var
  d: TDate;
  selDates: TCalDateArray;
begin
  Listbox1.Items.BeginUpdate;
  try
    Listbox1.Items.Clear;
    selDates := CalendarLite1.SelectedDates;
    for d in selDates do
      Listbox1.Items.Add(DateToStr(d));
  finally
    Listbox1.Items.EndUpdate;
  end;
end;

procedure TForm1.CbMultiselectChange(Sender: TObject);
begin
  CalendarLite1.MultiSelect := cbMultiSelect.Checked;
end;

procedure TForm1.CbPersistentSelectedDatesChange(Sender: TObject);
begin
  if CbPersistentSelectedDates.Checked then
    CalendarLite1.Options := CalendarLite1.Options + [coPersistentSelectedDates]
  else
    CalendarLite1.Options := CalendarLite1.Options - [coPersistentSelectedDates];
end;

end.

