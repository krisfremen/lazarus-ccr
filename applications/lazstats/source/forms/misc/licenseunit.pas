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


implementation

function AcceptLicenseForm: Boolean;
begin
  with TLicenseFrm.Create(nil) do
  try
    Result := (ShowModal = mrOK);
  finally
    Free;
  end;
end;


{ TLicenseFrm }

initialization
  {$I licenseunit.lrs}

end.

