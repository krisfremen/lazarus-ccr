unit gpsptform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ButtonPanel, ColorBox, Spin, mvExtraData;

type

  TGPSSymbol = (gpsPlus, gpsCross, gpsFilledCircle, gpsOpenCircle,
    gpsFilledRect, gpsOpenRect);

  TGPSExtraData = class(TDrawingExtraData)
  private
    FSymbol: TGPSSymbol;
    FSize: Integer;
  public
    constructor Create(aID: Integer); override;
    property Symbol: TGPSSymbol read FSymbol write FSymbol;
    property Size: Integer read FSize write FSize;
  end;

  { TGPSPointForm }

  TGPSPointForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    clbSymbolColor: TColorBox;
    cbSymbols: TComboBox;
    edGPSPointLabel: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblSymbol: TLabel;
    lblSize: TLabel;
    Panel1: TPanel;
    seSize: TSpinEdit;
    procedure FormShow(Sender: TObject);
  private

  public
    procedure GetData(var AName: String; var AColor: TColor;
      var ASymbol: TGPSSymbol; var ASize: Integer);
    procedure SetData(const AName: String; AColor: TColor;
      ASymbol: TGPSSymbol; ASize: Integer);
  end;

var
  GPSPointForm: TGPSPointForm;

implementation

{$R *.lfm}

constructor TGPSExtraData.Create(aID: Integer);
begin
  inherited Create(aID);
  FSymbol := gpsPlus;
  FSize := 10;
end;

procedure TGPSPointForm.FormShow(Sender: TObject);
begin
  edGPSPointLabel.SetFocus;
end;

procedure TGPSPointForm.GetData(var AName: String; var AColor: TColor;
  var ASymbol: TGPSSymbol; var ASize: Integer);
begin
  AName := edGPSPointLabel.Text;
  AColor := clbSymbolColor.Selected;
  ASymbol := TGPSSymbol(cbSymbols.ItemIndex);
  ASize := seSize.Value;
end;

procedure TGPSPointForm.Setdata(const AName: String; AColor: TColor;
  ASymbol: TGPSSymbol; ASize: Integer);
begin
  edGPSPointLabel.Text := AName;
  clbSymbolColor.Selected := AColor;
  cbSymbols.ItemIndex := ord(ASymbol);
  seSize.Value := ASize
end;

end.

