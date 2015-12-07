{
 *****************************************************************************
 *                                                                           *
 *  This file is part of the iPhone Laz Extension                            *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit environment_iphone_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, StdCtrls,
  IDEOptionsIntf, ProjectIntf,
  iPhoneExtOptions, iphonesimctrl;

type

  { TiPhoneSpecificOptions }

  TiPhoneSpecificOptions = class(TAbstractIDEOptionsEditor)
    Button1: TButton;
    cmbDefaultSDK: TComboBox;
    ddSimDevice: TComboBox;
    ddPhoneSimType: TComboBox;
    edtCompilerPath: TEdit;
    edtRTLPath: TEdit;
    edtCompilerOptions: TEdit;
    edtPlatformsPath: TEdit;
    edtSimBundle: TEdit;
    edtSimApps: TEdit;
    Label1: TLabel;
    lblDefaultDevice: TLabel;
    lblSimType: TLabel;
    lblRTLUtils: TLabel;
    lblSimAppPath: TLabel;
    lblCompilerPath: TLabel;
    lblXCodeProject: TLabel;
    lblCmpOptions: TLabel;
    Label5: TLabel;
    lblSimSettings: TLabel;
    lblSimBundle: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure edtCompilerOptionsChange(Sender: TObject);
    procedure lblSimTypeClick(Sender: TObject);
    procedure lblCmpOptionsClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    function GetTitle: String; override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
    procedure Setup(ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings(AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings(AOptions: TAbstractIDEOptions); override;
  end;

implementation

{$R *.lfm}

{ TiPhoneSpecificOptions }

procedure TiPhoneSpecificOptions.lblCmpOptionsClick(Sender: TObject);
begin

end;

procedure TiPhoneSpecificOptions.Button1Click(Sender: TObject);
var
  dir  : String;
begin
  dir:=EnvOptions.PlatformsBaseDir;
  EnvOptions.PlatformsBaseDir:=edtPlatformsPath.Text;
  EnvOptions.RefreshVersions;

  cmbDefaultSDK.Clear;
  EnvOptions.GetSDKVersions(cmbDefaultSDK.Items);

  EnvOptions.PlatformsBaseDir:=dir;
  EnvOptions.RefreshVersions;
end;

procedure TiPhoneSpecificOptions.edtCompilerOptionsChange(Sender: TObject);
begin

end;

procedure TiPhoneSpecificOptions.lblSimTypeClick(Sender: TObject);
begin

end;

function TiPhoneSpecificOptions.GetTitle: String;
begin
  Result:='Files';
end;

procedure TiPhoneSpecificOptions.Setup(ADialog: TAbstractOptionsEditorDialog);
begin

end;

procedure TiPhoneSpecificOptions.ReadSettings(AOptions: TAbstractIDEOptions);
var
  opt : TiPhoneEnvironmentOptions;
  idx : integer;
  i   : integer;
  j   : integer;
  sd  : TSimDevice;
begin
  if not Assigned(AOptions) or not (AOptions is TiPhoneEnvironmentOptions) then Exit;
  opt:=TiPhoneEnvironmentOptions(AOptions);
  opt.Load;

  edtPlatformsPath.Text := opt.PlatformsBaseDir;
  edtCompilerPath.Text := opt.CompilerPath;
  edtRTLPath.Text := opt.BaseRTLPath;
  edtCompilerOptions.Text := opt.CommonOpt;
  edtSimBundle.Text := opt.SimBundle;
  edtSimApps.Text:= opt.SimAppsPath;

  cmbDefaultSDK.Items.Clear;
  opt.GetSDKVersions(cmbDefaultSDK.Items);
  cmbDefaultSDK.ItemIndex:=cmbDefaultSDK.Items.IndexOf(opt.DefaultSDK);

  if EnvOptions.DeviceCount=0 then
    EnvOptions.DeviceListReload;
  idx:=-1;
  ddSimDevice.Clear;
  for i:=0 to EnvOptions.DeviceCount-1 do begin
    sd:=EnvOptions.Device[i];
    if sd.isavail then begin
      j:=ddSimDevice.Items.Add( sd.name );
      ddSimDevice.Items.Objects[j]:=sd;
      if sd.id=EnvOptions.DefaultDeviceID then
        idx:=j;
    end;
  end;
  if idx>=0 then ddSimDevice.ItemIndex:=idx;
end;

procedure TiPhoneSpecificOptions.WriteSettings(AOptions: TAbstractIDEOptions);
var
  opt : TiPhoneEnvironmentOptions;
begin
  if not Assigned(AOPtions) or not (AOptions is TiPhoneEnvironmentOptions) then Exit;
  opt:=TiPhoneEnvironmentOptions(AOptions);

  opt.PlatformsBaseDir:=edtPlatformsPath.Text;
  opt.CompilerPath:=edtCompilerPath.Text;
  opt.BaseRTLPath:=edtRTLPath.Text;
  opt.CommonOpt:=edtCompilerOptions.Text;
  opt.SimBundle:=edtSimBundle.Text;
  opt.SimAppsPath:=edtSimApps.Text;

  if ddSimDevice.ItemIndex>=0 then
    opt.DefaultDeviceID:=TSimDevice(ddSimDevice.Items.Objects[ddSimDevice.ItemIndex]).id;
  opt.Save;
end;

class function TiPhoneSpecificOptions.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result:=TiPhoneEnvironmentOptions;
end;

initialization
  RegisterIDEOptionsEditor(iPhoneEnvGroup, TiPhoneSpecificOptions, iPhoneEnvGroup+1);

end.

