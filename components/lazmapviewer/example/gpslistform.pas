unit gpslistform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel, ComCtrls,
  ExtCtrls, Buttons, StdCtrls, mvGpsObj, mvMapViewer;

const
  // IDs of GPS items
  _CLICKED_POINTS_ = 10;

type

  { TGPSListViewer }

  TGPSListViewer = class(TForm)
    BtnDeletePoint: TBitBtn;
    BtnGoToPoint: TBitBtn;
    BtnClose: TBitBtn;
    BtnCalcDistance: TButton;
    ListView: TListView;
    Panel1: TPanel;
    procedure BtnCalcDistanceClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnDeletePointClick(Sender: TObject);
    procedure BtnGoToPointClick(Sender: TObject);
  private
    FViewer: TMapView;
    FList: TGpsObjList;
    procedure SetViewer(AValue: TMapView);
  protected
    procedure Populate;

  public
    destructor Destroy; override;
    property MapViewer: TMapView read FViewer write SetViewer;

  end;

var
  GPSListViewer: TGPSListViewer;

implementation

{$R *.lfm}

uses
  mvTypes, mvEngine,
  globals;

destructor TGPSListViewer.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TGPSListViewer.Populate;
var
  i: Integer;
  item: TListItem;
  gpsObj: TGpsObj;
  area: TRealArea;
begin
  if FViewer = nil then begin
    ListView.Items.Clear;
    exit;
  end;

  FViewer.GPSItems.GetArea(area);
  FList.Free;
  FList := FViewer.GPSItems.GetObjectsInArea(area);
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for i:=0 to FList.Count-1 do begin
      gpsObj := FList[i];
      item := ListView.Items.Add;
//      item.Caption := IntToStr(gpsObj.ID);
      if gpsObj is TGpsPoint then begin
        item.SubItems.Add(gpsObj.Name);
        item.Subitems.Add(LatToStr(TGpsPoint(gpsObj).Lat, true));
        item.Subitems.Add(LonToStr(TGpsPoint(gpsObj).Lon, true));
      end;
    end;
  finally
    ListView.items.EndUpdate;
  end;
end;

procedure TGPSListViewer.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TGPSListViewer.BtnCalcDistanceClick(Sender: TObject);
type
  TCoorRec = record
    Lon: Double;
    Lat: Double;
    Name: String;
  end;
var
  i, iChecked: Integer;
  gpsObj: TGpsObj;
  gpsPt: TGpsPoint;
  TCoorArr: array[0..1] of TCoorRec;
begin
  // count checked items
  iChecked := 0;
  for i:=0 to ListView.Items.Count - 1 do begin
    if ListView.Items.Item[i].Checked then Inc(iChecked);
  end;
  //
  if iChecked <> 2 then begin
    ShowMessage('Please select 2 items to calculate the distance.');
  end
  else begin
    iChecked := 0;
    for i:=0 to ListView.Items.Count - 1 do begin
      if ListView.Items.Item[i].Checked then begin
        gpsObj := FList.Items[i];
        if gpsObj is TGpsPoint then begin
          gpsPt := TGpsPoint(gpsObj);
          TCoorArr[iChecked].Lat := gpsPt.Lat;
          TCoorArr[iChecked].Lon := gpsPt.Lon;
          TCoorArr[iChecked].Name:= gpsPt.Name;
          Inc(iChecked);
        end;
      end;
    end;
    // show distance between selected items
    ShowMessage('Distance between ' + TCoorArr[0].Name + ' and ' + TCoorArr[1].Name + ' is: ' +
    Format('%.2n %s.', [
      CalcGeoDistance(
        TCoorArr[0].Lat,
        TCoorArr[0].Lon,
        TCoorArr[1].Lat,
        TCoorArr[1].Lon,
        DistanceUnit
      ),
      DistanceUnit_Names[DistanceUnit]
      ]));
  end;
end;

procedure TGPSListViewer.BtnDeletePointClick(Sender: TObject);
var
  gpsObj: TGpsObj;
  i: Integer;
  rPt: TRealPoint;
  item: TListItem;
begin
  if ListView.Selected <> nil then begin
    gpsObj := FList[ListView.Selected.Index];
    ListView.Selected.Free;
    FViewer.GpsItems.Clear(_CLICKED_POINTS_);
    for i:=0 to ListView.Items.Count-1 do begin
      item := ListView.Items[i];
      if TryStrToGps(item.SubItems[2], rPt.Lon) and TryStrToGps(item.SubItems[1], rPt.Lat) then
      begin
        gpsObj := TGpsPoint.CreateFrom(rPt);
        gpsObj.Name := item.SubItems[0];
        FViewer.GPSItems.Add(gpsObj, _CLICKED_POINTS_);
      end;
    end;
  end;
end;

procedure TGPSListViewer.BtnGoToPointClick(Sender: TObject);
var
  gpsPt: TGpsPoint;
  gpsObj: TGpsObj;
begin
  if ListView.Selected <> nil then begin
    gpsObj := FList[ListView.Selected.Index];
    if gpsObj is TGpsPoint then begin
      gpsPt := TGpsPoint(gpsObj);
      if Assigned(FViewer) then FViewer.Center := gpsPt.RealPoint;
    end;
  end;
end;

procedure TGPSListViewer.SetViewer(AValue: TMapView);
begin
  if FViewer = AValue then
    exit;
  FViewer := AValue;
  Populate;
end;

end.

