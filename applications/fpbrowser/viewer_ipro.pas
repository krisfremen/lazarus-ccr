unit viewer_ipro;

{$mode delphi}

interface

uses
  Classes, SysUtils, Graphics, Forms, Controls,
  //
  browserviewer,
  //
  IPHtml, Ipfilebroker, IpMsg;

type
  { TMyIpHtmlDataProvider }

  TMyIpHtmlDataProvider = class(TIpHtmlDataProvider)
  protected
    function DoGetStream(const URL: string): TStream; override;
  end;

  { TiProViewer }

  TiProViewer = class(TBrowserViewer)
  private
    IpHtmlPanel1: TIpHtmlPanel;
    DataProvider1: TMyIpHtmlDataProvider;
    function DataProvider1CanHandle(Sender: TObject; const URL: string
      ): Boolean;
    procedure DataProvider1CheckURL(Sender: TObject; const URL: string;
      var Available: Boolean; var ContentType: string);
    procedure DataProvider1GetHtml(Sender: TObject; const URL: string;
      const PostData: TIpFormDataEntity; var Stream: TStream);
    procedure DataProvider1GetImage(Sender: TIpHtmlNode; const URL: string;
      var Picture: TPicture);
    procedure DataProvider1Leave(Sender: TIpHtml);
    procedure DataProvider1ReportReference(Sender: TObject; const URL: string);
    procedure ShowHTML(Src: string);
  public
    procedure CreateViewer(AParent, AOwner: TWinControl); override;
    procedure LoadFromFile(AFilename: string); override;
//    procedure LoadFromURL(AURL: string); override;
    function GetDocumentTitle: string; override;
    procedure SetShowImages(AValue: Boolean); override;
    procedure HandlePageLoaderTerminated(Sender: TObject); override;
    procedure Reload; override;
  end;

implementation

function TMyIpHtmlDataProvider.DoGetStream(const URL: string): TStream;
var
  ms: TMemoryStream;
begin
  Result:=nil;
  WriteLn('TMyIpHtmlDataProvider.DoGetStream '+URL);

  if URL='fpdoc.css' then begin
    //debugln(['TMyIpHtmlDataProvider.DoGetStream ',FileExists(URL)]);
    ms:=TMemoryStream.Create;
    try
      ms.LoadFromFile(URL);
      ms.Position:=0;
    except
      ms.Free;
    end;
    Result:=ms;
  end;
end;

function TiProViewer.DataProvider1CanHandle(Sender: TObject; const URL: string
  ): Boolean;
begin
  WriteLn('TformBrowser.DataProvider1CanHandle ',URL);
  Result:=True;
end;

procedure TiProViewer.DataProvider1CheckURL(Sender: TObject; const URL: string;
  var Available: Boolean; var ContentType: string);
begin
  WriteLn('TformBrowser.DataProvider1CheckURL ',URL);
  Available:=True;
  ContentType:='text/html';
end;

procedure TiProViewer.DataProvider1GetHtml(Sender: TObject; const URL: string;
  const PostData: TIpFormDataEntity; var Stream: TStream);
var
  lStream: TMemoryStream;
begin
  WriteLn('TformBrowser.DataProvider1GetHtml ',URL);
{  MyPageLoader.LoadBinaryResource(URL, lStream);
  Stream := lStream;
  lStream.Position := 0;}
  Stream := nil;
  LoadFromURL(URL);
end;

procedure TiProViewer.DataProvider1GetImage(Sender: TIpHtmlNode; const URL: string;
  var Picture: TPicture);
var
  lStream: TMemoryStream = nil;
  lStr: String;
begin
  WriteLn('TformBrowser.DataProvider1GetImage ',URL);
  lStr := ExtractFileExt(URL);
  if (lStr = '.jpeg') or (lStr = '.jpg') then
  begin
    try
      MyPageLoader.LoadBinaryResource(URL, lStream);
      Picture := TPicture.Create;
      Picture.Jpeg.LoadFromStream(lStream);
    finally
      lStream.Free
    end;
  end
  else
  begin
    WriteLn('TformBrowser.DataProvider1GetImage Unsupported format: ', lStr);
    Picture := nil;
    Exit;
  end;
//  and (lStr <> '.bmp') and (lStr <> '.png')
end;

procedure TiProViewer.DataProvider1Leave(Sender: TIpHtml);
begin

end;

procedure TiProViewer.DataProvider1ReportReference(Sender: TObject; const URL: string
  );
begin
  //debugln(['TForm1.DataProvider1ReportReference ',URL]);
end;

procedure TiProViewer.ShowHTML(Src: string);
var
  ss: TStringStream;
  NewHTML: TIpHtml;
begin
  ss := TStringStream.Create(Src);
  try
    NewHTML := TIpHtml.Create; // Beware: Will be freed automatically by IpHtmlPanel1
    //debugln(['TForm1.ShowHTML BEFORE SETHTML']);
    IpHtmlPanel1.SetHtml(NewHTML);
    //debugln(['TForm1.ShowHTML BEFORE LOADFROMSTREAM']);
    NewHTML.LoadFromStream(ss);
    //if Anchor <> '' then IpHtmlPanel1.MakeAnchorVisible(Anchor);
  finally
    ss.Free;
  end;
end;

procedure TiProViewer.CreateViewer(AParent, AOwner: TWinControl);
begin
  DataProvider1:=TMyIpHtmlDataProvider.Create(AOwner);
  DataProvider1.Name:='DataProvider1';
  DataProvider1.OnCanHandle:=DataProvider1CanHandle;
  DataProvider1.OnGetHtml:=DataProvider1GetHtml;
  DataProvider1.OnGetImage:=DataProvider1GetImage;
  DataProvider1.OnLeave:=DataProvider1Leave;
  DataProvider1.OnCheckURL:=DataProvider1CheckURL;
  DataProvider1.OnReportReference:=DataProvider1ReportReference;

  IpHtmlPanel1:=TIpHtmlPanel.Create(AOwner);
  IpHtmlPanel1.Name:='IpHtmlPanel1';
  IpHtmlPanel1.Parent:=AParent;
  IpHtmlPanel1.Align:=alClient;
  IpHtmlPanel1.DefaultFontSize:=10;
  IpHtmlPanel1.DataProvider:=DataProvider1;
end;

procedure TiProViewer.LoadFromFile(AFilename: string);
begin

end;

function TiProViewer.GetDocumentTitle: string;
begin
  Result:='';
end;

procedure TiProViewer.SetShowImages(AValue: Boolean);
begin

end;

procedure TiProViewer.HandlePageLoaderTerminated(Sender: TObject);
begin
  inherited HandlePageLoaderTerminated(Sender);

  ShowHTML(MyPageLoader.Contents);
end;

procedure TiProViewer.Reload;
begin
end;

initialization
  SetBrowserViewerClass(TiProViewer);
end.

