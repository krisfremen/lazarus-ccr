{*********************************************************}
{*                 VpSelResDlg.PAS 1.03                  *}
{*********************************************************}

{* ***** BEGIN LICENSE BLOCK *****                                            *}
{* Version: MPL 1.1                                                           *}
{*                                                                            *}
{* The contents of this file are subject to the Mozilla Public License        *}
{* Version 1.1 (the "License"); you may not use this file except in           *}
{* compliance with the License. You may obtain a copy of the License at       *}
{* http://www.mozilla.org/MPL/                                                *}
{*                                                                            *}
{* Software distributed under the License is distributed on an "AS IS" basis, *}
{* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License   *}
{* for the specific language governing rights and limitations under the       *}
{* License.                                                                   *}
{*                                                                            *}
{* The Original Code is TurboPower Visual PlanIt                              *}
{*                                                                            *}
{* The Initial Developer of the Original Code is TurboPower Software          *}
{*                                                                            *}
{* Portions created by TurboPower Software Inc. are Copyright (C) 2002        *}
{* TurboPower Software Inc. All Rights Reserved.                              *}
{*                                                                            *}
{* Contributor(s):                                                            *}
{*                                                                            *}
{* ***** END LICENSE BLOCK *****                                              *}

unit VpSelResDlg;

interface

uses
  {$IFDEF LCL}
  LCLProc, LCLType, LCLIntf, LResources,
  {$ELSE}
  Windows, Messages,
  {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  VpBaseDS, VpResEditDlg;

type
  TfrmSelectResource = class(TForm)
    VpResourceCombo1: TVpResourceCombo;
    lblSelectResource: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    VpResourceEditDialog1: TVpResourceEditDialog;
    btnAddNew: TButton;
    btnEdit: TButton;
    Bevel1: TBevel;
    procedure btnAddNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSelectResource: TfrmSelectResource;

implementation

{$IFDEF LCL}
 {$R *.lfm}
{$ELSE}
 {$R *.DFM}
{$ENDIF}

procedure TfrmSelectResource.btnAddNewClick(Sender: TObject);
begin
  VpResourceEditDialog1.AddNewResource;
end;

procedure TfrmSelectResource.btnEditClick(Sender: TObject);
begin
  VpResourceEditDialog1.Execute;
end;

end.
 
