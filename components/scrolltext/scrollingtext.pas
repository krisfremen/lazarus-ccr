{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************
}
unit ScrollingText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, LCLIntf,AboutScrolltextunit;

const
  C_TEXTFILENAME = 'scrolling.txt';
  C_TEXTRESOURCENAME = 'scrolltext'; //Note: LResouces unit needed
  C_VERSION = '1.0.0.0';

type
  TTextSource = (stStringlist, stTextfile, stResource);

  TScrollingText = class(TAboutScrollText)
  private
    FActive: boolean;
    FActiveLine: integer;   //the line over which the mouse hovers
    FBuffer: TBitmap;
    FEndLine: integer;
    FLineHeight: integer;
    FLines: TStrings;
    FNumLines: integer;
    FOffset: integer;
    FStartLine: integer;
    FStepSize: integer;
    FTimer: TTimer;
    FFont: TFont;
    FBackColor: TColor;
    fTextFileName: string;
    fResourceName: string;
    fVersionString: string;
    fTextSource: TTextSource;
    function ActiveLineIsURL: boolean;
    procedure DoTimer(Sender: TObject);
    procedure SetActive(const AValue: boolean);
    procedure Init;
    procedure DrawScrollingText(Sender: TObject);
    procedure SetLines(AValue: TStrings);
    procedure SetFont(AValue: TFont);
  protected
    procedure DoOnChangeBounds; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    // Can be set in design mode. Note URL links are inactive in design mode
    property Active: boolean read FActive write SetActive;
    // Inherited property
    property Align;
    // Inherited property
    property Anchors;
    // Inherited property
    property BiDiMode;
    // Inherited property
    property Constraints;
    // Inherited property
    property Enabled;
    // Inherited property
    property Borderspacing;
    // Can be set in design or runtime mode. (TextSource=stStringlist)
    property Lines: TStrings read FLines write SetLines;
    // Sets the background color of the window
    property BackColor: TColor read fBackColor write fBackColor default clWindow;
    // Sets the font properties of the scrolling text
    property Font: TFont read fFont write SetFont;
    // Source of the text to display.
    // If TextSource=stTextfile 'scrolling.txt' should be in the deployed app folder
    // if TextSource=stResource be sure to add LResources to your uses clause
    property TextSource: TTextSource read fTextSource write fTextSource default
      stStringlist;
    // Read-only property to remind you of the correct file name
    property TextFileName: string read fTextFileName;
    // Read-only property to remind you of the correct resource name
    property TextResourceName: string read fResourceName;
    // Version number of this component
    property Version: string read fVersionString;
  end;


procedure Register;

implementation

procedure Register;
begin
  {$I scrollingtext_icon.lrs}
  RegisterComponents('Additional', [TScrollingText]);
end;

procedure TScrollingText.SetFont(AValue: TFont);
begin
  fFont.Assign(AValue);
end;

procedure TScrollingText.SetLines(AValue: TStrings);
begin
  fLines.Assign(AValue);
end;

procedure TScrollingText.SetActive(const AValue: boolean);
begin
  FActive := AValue;
  if FActive then
  begin
       Init;
       FOffset := FBuffer.Height; // Start at the bottom of the window
  end;
  FTimer.Enabled := Active;
end;

procedure TScrollingText.Init;
var
  r: TLResource;
begin
  FBuffer.Width := Width;
  FBuffer.Height := Height;
  FLineHeight := FBuffer.Canvas.TextHeight('X');
  FNumLines := FBuffer.Height div FLineHeight;

  if FOffset = -1 then
    FOffset := FBuffer.Height;

  with FBuffer.Canvas do
  begin
    Brush.Color := fBackColor;
    Brush.Style := bsSolid;
    FillRect(0, 0, Width, Height);
  end;
  if (fTextSource = stTextfile) then
    if FileExists('scrolling.txt') then
    begin
      fLines.Clear;
      fLines.LoadFromFile('scrolling.txt');
    end
    else
    begin
      fLines.Clear;
      fLines.Add('The file ''' + C_TEXTFILENAME + ''' is missing.');
      fLines.Add('It should be in the same folder as your application');
    end;
  if (fTextSource = stResource) then

  // Load text from resource string
  begin
    r := LazarusResources.Find(fResourceName);
    if r = nil then
      raise Exception.CreateFmt('Resource ''%s'' is missing',[fResourceName])
    else
    begin
      fLines.Clear;
      fLines.Add(r.Value);
    end;
  end;
  // Are there any lines in the Stringlist?
  if (fLines.Count = 0) then
  begin
    fLines.Add('This is the ScrollingText scrolling window.');
    fLines.Add(' ');
    fLines.Add('This default text is showing because you either:');
    fLines.Add(' ');
    fLines.Add('1) Haven''t set any text in the Lines property. or');
    fLines.Add('2) TextSource is set to stTextfile and the file');
    fLines.Add('''' + C_TEXTFILENAME + ''' is empty.');
    fLines.Add(' ');
    fLines.Add('Note that URL links such as');
    fLines.Add('http://wiki.lazarus.freepascal.org/Main_Page');
    fLines.Add('mailto:bill_gates@microsoft.com');
    fLines.Add('are clickable by the user');
    fLines.Add(' ');
    fLines.Add('TScrollingText is released under the GPL license (See About)');
    fLines.Add('Code is modified from the Lazarus ''AboutFrm'' code');
    fLines.Add(' ');
    fLines.Add('The standalone visual component TScrollingText is available at:');
    fLines.Add('http://www.charcodelvalle.com/scrollingtext/scrollingtext_component.zip');
    fLines.Add(' ');
    fLines.Add('June 2014');
  end;
end;

procedure TScrollingText.DrawScrollingText(Sender: TObject);
begin
  if Active then
    Canvas.Draw(0,0, FBuffer);
end;

procedure TScrollingText.DoTimer(Sender: TObject);
var
  w: integer;
  s: string;
  i: integer;
begin
  if not Active then
    Exit;

  Dec(FOffset, FStepSize);

  if FOffSet < 0 then
    FStartLine := -FOffset div FLineHeight
  else
    FStartLine := 0;

  FEndLine := FStartLine + FNumLines + 1;
  if FEndLine > FLines.Count - 1 then
    FEndLine := FLines.Count - 1;

  FBuffer.Canvas.FillRect(Rect(0, 0, FBuffer.Width, FBuffer.Height));

  for i := FEndLine downto FStartLine do
  begin
    s := Trim(FLines[i]);

    //reset buffer font
    FBuffer.Canvas.Font := fFont;
    FBuffer.Canvas.Font.Style := [];
    FBuffer.Canvas.Font.Color := fFont.Color;// clBlack;

    //skip empty lines
    if Length(s) > 0 then
    begin
      //check for bold format token
      if s[1] = '#' then
      begin
        s := copy(s, 2, Length(s) - 1);
        FBuffer.Canvas.Font.Style := [fsBold];
      end
      else
      begin
        //check for url
        if (Pos('http://', s) = 1) OR  (Pos('mailto:', s) = 1) then
        begin
          if i = FActiveLine then
          begin
            FBuffer.Canvas.Font.Style := [fsUnderline];
            FBuffer.Canvas.Font.Color := clRed;
          end
          else
            FBuffer.Canvas.Font.Color := clBlue;
        end;
      end;

      w := FBuffer.Canvas.TextWidth(s);
      FBuffer.Canvas.TextOut((FBuffer.Width - w) div 2, FOffset + i * FLineHeight, s);
    end;
  end;

  //start showing the list from the start
  if FStartLine > FLines.Count - 1 then
    FOffset := FBuffer.Height;
  Invalidate;
end;

function TScrollingText.ActiveLineIsURL: boolean;
begin
  if (FActiveLine > 0) and (FActiveLine < FLines.Count) then
    Result := (Pos('http://', FLines[FActiveLine]) = 1) OR (Pos('mailto:', FLines[FActiveLine]) = 1)
  else
    Result := False;
end;

procedure TScrollingText.DoOnChangeBounds;
begin
  inherited DoOnChangeBounds;
  Init;
end;

procedure TScrollingText.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  if ActiveLineIsURL then
    OpenURL(FLines[FActiveLine]);
end;

procedure TScrollingText.MouseMove(Shift: TShiftState; X, Y: integer);
begin
  inherited MouseMove(Shift, X, Y);

  //calculate what line is clicked from the mouse position
  FActiveLine := (Y - FOffset) div FLineHeight;

  Cursor := crDefault;

  if (FActiveLine >= 0) and (FActiveLine < FLines.Count) and ActiveLineIsURL then
    Cursor := crHandPoint;
end;

constructor TScrollingText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csOpaque];

  OnPaint := @DrawScrollingText;
  FLines := TStringList.Create;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := @DoTimer;
  FTimer.Interval := 30;
  FBuffer := TBitmap.Create;
  FFont := TFont.Create;
  FFont.Size := 10;
  fBackColor := clWindow;

  FStepSize := 1;
  FStartLine := 0;
  FOffset := -1;
  Width := 100;
  Height := 100;
  fTextFileName := C_TEXTFILENAME;
  fResourceName := C_TEXTRESOURCENAME;
  fVersionString := C_VERSION;
  fTextSource := stStringlist;
  SendToBack;

    // About dialog
  AboutBoxComponentName:='ScrollingText component';
  AboutBoxWidth:=400;
//  AboutBoxHeight (integer)
  AboutBoxDescription:='Component that shows a scrolling window.' + LineEnding +
  'Use Lines property to set text and Active=True' + LineEnding +
  'to use the component';
  AboutBoxBackgroundColor:=clWindow;
  AboutBoxFontName:='Arial';
  AboutBoxFontSize:=10;
  AboutBoxVersion:=C_VERSION;
  AboutBoxAuthorname:='Gordon Bamber';
  AboutBoxOrganisation:='Public Domain';
  AboutBoxAuthorEmail:='minesadorada@charcodelvalle.com';
  AboutBoxLicenseType:='LGPL';

end;

destructor TScrollingText.Destroy;
begin
  FLines.Free;
  FTimer.Free;
  FBuffer.Free;
  FFont.Free;
  inherited Destroy;
end;

end.
