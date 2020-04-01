unit LicenseUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TLicenseFrm }

  TLicenseFrm = class(TForm)
    AcceptBtn: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    OKBtn: TButton;
    RejectBtn: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  LicenseFrm: TLicenseFrm;

function AcceptLicenseForm: Boolean;
function ShowLicense(FirstTime: Boolean): Boolean;


implementation

function AcceptLicenseForm: Boolean;
begin
  Result := ShowLicense(true);
end;

function ShowLicense(FirstTime: Boolean): Boolean;
begin
  with TLicenseFrm.Create(nil) do
  try
    OKBtn.Visible := not FirstTime;
    AcceptBtn.Visible := FirstTime;
    RejectBtn.Visible := FirstTime;
    Bevel2.Visible := FirstTime;
    if FirstTime then
      Memo1.Lines.Add('Click on Accept or Reject below.');

    Result := (ShowModal = mrOK);
  finally
    Free;
  end;
end;


{ TLicenseFrm }

initialization
  {$I licenseunit.lrs}

end.

