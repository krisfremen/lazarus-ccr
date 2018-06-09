unit VpContactGridPainter;

{$I vp.inc}

interface

uses
  LCLType, LCLIntf,
  Types, Classes, Graphics,
  VpConst, VPBase, VpData, VpBasePainter, VpContactGrid;

type
  TVpContactGridPainter = class(TVpBasePainter)
  private
    FContactGrid: TVpContactGrid;
    // local variables of the original TVpContactGrid method
    PhoneLblWidth: Integer;
    StartContact: Integer;
    RealColumnWidth: Integer;
    RealColor: TColor;
    SizingBarColor: TColor;
    BevelDarkShadow: TColor;
    BevelShadow: TColor;
    BevelHighlight: TColor;
    BevelFace: TColor;
    RealBarColor: TColor;
    RealContactHeadAttrColor: TColor;

  protected
    procedure Clear;
    procedure DrawBorders;
    procedure DrawContactLine(ABitmap: TBitmap; AText, ALabel: String;
      var AWholeRect, ATextRect: TRect);
    procedure DrawContacts;
    procedure DrawVerticalBars;
    procedure FixFontHeights;
    procedure InitColors;

  public
    constructor Create(AContactGrid: TVpContactGrid; ARenderCanvas: TCanvas);
    procedure RenderToCanvas(ARenderIn: TRect; AAngle: TVpRotationAngle;
      AScale: Extended; ARenderDate: TDateTime; AStartLine, AStopLine: Integer;
      AUseGran: TVpGranularity; ADisplayOnly: Boolean); override;
  end;


implementation

uses
  StrUtils,
  VpCanvasUtils, VpMisc, VpSR;

type
  TVpContactGridOpener = class(TVpContactGrid);

constructor TVpContactGridPainter.Create(AContactGrid: TVpContactGrid;
  ARenderCanvas: TCanvas);
begin
  inherited Create(ARenderCanvas);
  FContactGrid := AContactGrid;
end;

procedure TVpContactGridPainter.Clear;
var
  I: Integer;
begin
  { clear Client Area }
  RenderCanvas.Brush.Color := RealColor;
  RenderCanvas.FillRect(RenderIn);

  { clear the vertical bar array }
  for I := 0 to pred(MaxColumns) do begin
    with TVpContactGridOpener(FContactGrid) do begin
      if cgBarArray[I].Index = -1 then
        Break;
      cgBarArray[I].Rec := Rect(-1, -1, -1, -1);
      cgBarArray[I].Index := -1;
    end;
  end;

  { initialize the contact array at runtime }
  if not (csDesigning in FContactGrid.ComponentState) and (FContactGrid.DataStore <> nil)
     and (FContactGrid.DataStore.Resource <> nil)
  then
    with TVpContactGridOpener(FContactGrid) do begin
      SetLength(cgContactArray, DataStore.Resource.Contacts.Count);
      for I := 0 to pred(Length(cgContactArray)) do
        with cgContactArray[I] do begin
          Index       := -1;
          Contact     := nil;
          WholeRect   := Rect(-1, -1, -1, -1);
          HeaderRect  := Rect(-1, -1, -1, -1);
          AddressRect := Rect(-1, -1, -1, -1);
          CSZRect     := Rect(-1, -1, -1, -1);
          Phone1Rect  := Rect(-1, -1, -1, -1);
          Phone2Rect  := Rect(-1, -1, -1, -1);
          Phone3Rect  := Rect(-1, -1, -1, -1);
          Phone4Rect  := Rect(-1, -1, -1, -1);
          Phone5Rect  := Rect(-1, -1, -1, -1);
        end;
    end;
end;

procedure TVpContactGridPainter.DrawBorders;
var
  R: TRect;
begin
  R := RenderIn;
  dec(R.Right, 1);
  dec(R.Bottom, 1);
  case FContactGrid.DrawingStyle of
    dsFlat:
      begin  { Draw a simple border rectangle }
        DrawBevelRect(RenderCanvas, R, BevelShadow, BevelShadow);
      end;
    ds3d:
      begin  { Draw a 3d bevel }
        DrawBevelRect(RenderCanvas, R, BevelShadow, BevelHighlight);
        InflateRect(R, -1, -1);
        DrawBevelRect(RenderCanvas, R, BevelDarkShadow, BevelFace);
      end;
  end;
end;

procedure TVpContactGridPainter.DrawContactLine(ABitmap: TBitmap;
  AText, ALabel: String; var AWholeRect, ATextRect: TRect);
var
  txtheight: Integer;
  txtColWidth: Integer;
begin
  if AText = '' then begin
    ATextRect := Rect(0, 0, 0, 0);
    exit;
  end;

  txtHeight := ABitmap.Canvas.TextHeight(VpProductName);

  case Angle of
    ra0:
      begin
        ATextRect.Left := TextMargin;
        ATextRect.Top := AWholeRect.Bottom + TextMargin div 2;
        ATextRect.Right := ABitmap.Width;
        ATextRect.Bottom := ATextRect.Top + txtHeight + TextMargin div 2;
        AWholeRect.Bottom := ATextRect.Bottom;
        txtColWidth := ABitmap.Width;
      end;
    ra90:
      begin
        ATextRect.Left := AWholeRect.Left - txtHeight + TextMargin div 2;
        ATextRect.Top := TextMargin;
        ATextRect.Right := AWholeRect.Left - TextMargin div 2;
        ATextRect.Bottom := AWholeRect.Bottom + TextMargin div 2;
        AWholeRect.Left := ATextRect.Left;
        txtColWidth := ABitmap.Height;
      end;
    ra180:
      begin
        ATextRect.Left := AWholeRect.Right - TextMargin * 2;    // Shouldn't this be "div 2" ?
        ATextRect.Top := AWholeRect.Top - txtHeight - TextMargin;
        ATextRect.Right := AWholeRect.Left + TextMargin;
        ATextRect.Bottom := AWholeRect.Top - TextMargin div 2;
        AWholeRect.Top := ATextRect.Top;
        txtColWidth := ABitmap.Width;
      end;
    ra270:
      begin
        ATextRect.Left := AWholeRect.Right;
        ATextRect.Top := AWholeRect.Bottom - TextMargin;
        ATextRect.Right := AWholeRect.Right + txtHeight + TextMargin div 2;
        ATextRect.Bottom := AWholeRect.Top + TextMargin div 2;
        AWholeRect.Right := ATextRect.Right;
        txtColWidth := ABitmap.Height;
      end;
  end;  // case Angle...

  AText := GetDisplayString(ABitmap.Canvas, AText, 2, txtColWidth - TextMargin * 2);

  if ALabel <> '' then begin
    TPSTextOutAtPoint(
      ABitmap.Canvas,
      Angle,
      Rect(0, 0, ABitmap.Width, ABitmap.Height),
      ATextRect.Left + TextMargin,
      ATextRect.Top + TextMargin div 2,
      ALabel
    );

    with ATextRect do
      case Angle of
        ra0   : TopLeft := Point(Left + PhoneLblWidth, Top + TextMargin div 2);
        ra90  : TopLeft := Point(Top + PhoneLblWidth, Left + TextMargin);
        ra180 : TopLeft := Point(Left - PhoneLblWidth, top + TextMargin div 2);
        ra270 : TopLeft := Point(Left + TextMargin div 2, Top - PhoneLblWidth);
      end;
    TPSTextOutAtPoint(
      ABitmap.Canvas,
      Angle,
      Rect(0, 0, ABitmap.Width, ABitmap.Height),
      ATextRect.Left,
      ATextRect.Top,
      AText
    );
  end else
    TPSTextOutAtPoint(
      ABitmap.Canvas,
      Angle,
      Rect(0, 0, ABitmap.Width, ABitmap.Height),
      ATextRect.Left + TextMargin,
      ATextRect.Top + TextMargin div 2,
      AText
    );
end;

procedure TVpContactGridPainter.DrawContacts;
var
  Anchor: TPoint;
  I, J: Integer;
  Str: string;
  TmpBmp: TBitmap;
  TmpCon: TVpContact;
  Col, RecsInCol: Integer;
  HeadRect: TRect;
  WholeRect: TRect;
  TmpBmpRect: TRect;
  TextColWidth: Integer;
  TextXOffset: Integer;
  TextYOffset: Integer;
  oldCol1RecCount: Integer;
  AddrRect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  CSZRect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  CompanyRect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  EMailRect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  Phone1Rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  Phone2Rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  Phone3Rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  Phone4Rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  Phone5Rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  R: TRect;
begin
  oldCol1RecCount := TVpContactGridOpener(FContactGrid).cgCol1RecCount;
  TVpContactGridOpener(FContactGrid).FVisibleContacts := 0;
  TVpContactGridOpener(FContactGrid).cgCol1RecCount := 0;
  TextXOffset := 0;
  TextYOffset := 0;

  { if the component is sufficiently small then no sense in painting it }
  if (FContactGrid.Height < 20) then exit;

  { don't paint contacts at designtime or if the data connection is invalid }
  if (csDesigning in FContactGrid.ComponentState) or
     (FContactGrid.DataStore = nil) or
     (FContactGrid.DataStore.Resource = nil)
  then
    Exit;

  { create a temporary bitmap for painting the items }
  TmpBmp := TBitmap.Create;
  try
    if (Angle = ra0) or (Angle = ra180) then begin
      TmpBmp.Width  := RealColumnWidth - TextMargin * 4 + 4;    // wp:+4
      TmpBmp.Height := RealHeight - TextMargin * 2;
      TextColWidth := TmpBmp.Width;
    end else begin
      TmpBmp.Height := RealColumnWidth - TextMargin * 4 + 4;   // wp: +4
      TmpBmp.Width  := RealHeight - TextMargin * 2;
      TextColWidth := TmpBmp.Height;
    end;
    TmpBmpRect := Rect(0, 0, TmpBmp.Width, TmpBmp.Height);
    TmpBmp.Canvas.Font.Assign(FContactGrid.Font);
    {$IF VP_LCL_SCALING = 0}
    TmpBmp.Canvas.Font.Size := ScaleY(TmpBmp.Canvas.Font.Size, DesignTimeDPI);
    {$ENDIF}

    { Calculate Phone Lbl Width }
    PhoneLblWidth := TmpBmp.Canvas.TextWidth(RSEmail);
    for I := 0 to 7 do begin
      Str := PhoneLabel(TVpPhoneType(I)) + ':       ';
      J := TmpBmp.Canvas.TextWidth(Str);
      if J > PhoneLblWidth then
        PhoneLblWidth := J;
    end;

    Col := 1;

    { clear the bitmap }
    TmpBmp.Canvas.FillRect(Rect(0, 0, TmpBmp.Width, TmpBmp.Height));

    { sort the records }
    FContactGrid.DataStore.Resource.Contacts.Sort;     // wp: why sort here?

    { Set the anchor starting point }
    case Angle of
      ra0:
        Anchor := Point(2 + TextMargin * 2, 2 + TextMargin * 2);
      ra90:
        Anchor := Point(2 + TextMargin * 2, 2 + TextMargin * 2);
      ra180:
        Anchor := Point(
          RenderIn.Right - RenderIn.Left - TmpBmp.Width - 2 - TextMargin * 2,
          TmpBmp.Height - 2 - TextMargin * 2
        );
      ra270:
        Anchor := Point(
          2 + TextMargin * 2,
          RenderIn.Bottom - RenderIn.Top - TmpBmp.Height - 2 - TextMargin * 2
        );
    end;
    RecsInCol := 0;

    for I := StartContact to pred(FContactGrid.DataStore.Resource.Contacts.Count) do begin
      TmpCon := FContactGrid.DataStore.Resource.Contacts.GetContact(I);
      if (TmpCon <> nil) then begin
        { Clear bmp canvas }
        TmpBmp.Canvas.Brush.Color := RealColor;
        TmpBmp.Canvas.FillRect(Rect(0, 0, TmpBmp.Width, TmpBmp.Height));

        TVpContactGridOpener(FContactGrid).cgContactArray[I].Contact := TmpCon;

        { start building the WholeRect and build the HeaderRect}
        TmpBmp.Canvas.Pen.Color := BevelDarkShadow;
        TmpBmp.Canvas.Brush.Style := bsSolid;
        TmpBmp.Canvas.Font.Assign(FContactGrid.ContactHeadAttributes.Font);
        {$IF VP_LCL_SCALING = 0}
        TmpBmp.Canvas.Font.Size := ScaleY(TmpBmp.Canvas.Font.Size, DesignTimeDPI);
        {$ENDIF}
        if FContactGrid.Focused and (TmpCon = FContactGrid.ActiveContact) then
          TmpBmp.Canvas.Font.Style := [fsBold];
        case Angle of
          ra0:
            begin
              WholeRect.TopLeft := Point(0, 0);
//              HeadRect.TopLeft := Point(TextMargin, TextMargin div 2);
//              HeadRect.TopLeft := Point(TextMargin, 0);
              HeadRect.TopLeft := Point(0, 0);
              HeadRect.BottomRight := Point(
                TmpBmp.Width,
                HeadRect.Top + TmpBmp.Canvas.TextHeight(VpProductName) + TextMargin div 2
              );
              WholeRect.BottomRight := HeadRect.BottomRight;
            end;
          ra90:                                         // TO DO: CHECK THE USAGE OF TextMargin HERE !!!!!!!!!
            begin
              HeadRect.TopLeft := Point(
                TmpBmpRect.Right - TextMargin - TmpBmp.Canvas.TextHeight(VpProductName) + TextMargin div 2,
                0
              );
              HeadRect.BottomRight := Point(TmpBmpRect.Right, TmpBmp.Height);
              WholeRect.TopLeft := HeadRect.TopLeft;
              WholeRect.BottomRight := HeadRect.BottomRight;
            end;
          ra180:
            begin
              WholeRect.BottomRight := Point(TmpBmp.Width, TmpBmp.Height);
              HeadRect.TopLeft := Point(
                TextMargin,
                TmpBmpRect.Bottom - TmpBmp.Canvas.TextHeight(VpProductName) - TextMargin
              );
              HeadRect.BottomRight := Point(
                TmpBmp.Width,
                TmpBmp.Height - TextMargin div 2
              );
              WholeRect.TopLeft := HeadRect.TopLeft;
            end;
          ra270:
            begin
              WholeRect.TopLeft := Point(0, 0);
              HeadRect.TopLeft := Point(0, TextMargin);
              HeadRect.BottomRight := Point(
                TextMargin + TmpBmp.Canvas.TextHeight(VpProductName) + TextMargin div 2,
                TmpBmp.Height
              );
              WholeRect.BottomRight := HeadRect.BottomRight;
            end;
        end;

        { assemble the header string }
        Str := AssembleName(TmpCon);

        { if the name isn't empty then paint all of the contact information }
        if Str > '' then begin
          { paint the header cell's background }
          if (Angle = ra0) or (Angle = ra180) then
            Str := GetDisplayString(TmpBmp.Canvas, Str, 2, WidthOf(HeadRect) - TextMargin)
          else
            Str := GetDisplayString(TmpBmp.Canvas, Str, 2, HeightOf(HeadRect) - TextMargin);
          TmpBmp.Canvas.Brush.Color := RealContactHeadAttrColor;
          TmpBmp.Canvas.FillRect(HeadRect);
          { paint the header cell's border }
          if FContactGrid.ContactHeadAttributes.Bordered and (FContactGrid.DrawingStyle <> dsNoBorder)
          then begin
            TmpBmp.Canvas.Pen.Style := psSolid;
            {$IFDEF VERSION5}
            TmpBmp.Canvas.Rectangle(HeadRect);
            {$ELSE}
            TmpBmp.Canvas.Rectangle(HeadRect.Left, HeadRect.Top, HeadRect.Right, HeadRect.Bottom);
            {$ENDIF}
          end;
          { paint the header cell's text }
          case Angle of
            ra90:
              begin
                TextXOffset := WidthOf(HeadRect) - TextMargin div 2;
                TextYOffset := TextMargin div 3;
              end;
            ra180:
              begin
                TextXOffset := WidthOf(HeadRect) - TextMargin;
                TextYOffset := HeightOf(HeadRect) - TextMargin div 3;
              end;
            ra270:
              begin
                TextXOffset := TextMargin div 2;
                TextYOffset := HeightOf(HeadRect) - TextMargin div 3;
              end;
          end;
          TPSTextOutAtPoint(
            TmpBmp.Canvas,
            Angle,
            TmpBmpRect,
            HeadRect.Left + TextMargin div 2 + TextXOffset,
            HeadRect.Top + TextMargin div 3 + TextYOffset,
            Str
          );

          { restore font and colors }
          TmpBmp.Canvas.Font.Assign(FContactGrid.Font);
          {$IF VP_LCL_SCALING = 0}
          TmpBmp.Canvas.Font.Size := ScaleY(TmpBmp.Canvas.Font.Size, DesignTimeDPI);
          {$ENDIF}
          TmpBmp.Canvas.Brush.Color := RealColor;
          TmpBmp.Canvas.Pen.Color := BevelDarkShadow;
          TmpBmp.Canvas.Pen.Style := psSolid;

          { do Company }
          DrawContactLine(TmpBmp, TmpCon.Company, '', WholeRect, CompanyRect);

          { do address... }
          DrawContactLine(TmpBmp, TmpCon.Address1, '', WholeRect, AddrRect);

          { do City, State, Zip }
          Str := AssembleCSZ(TmpCon, 1, FContactGrid.GetCityStateZipFormat);
          DrawContactLine(TmpBmp, Str, '', WholeRect, CSZRect);

          { do Phone1 }
          Str := PhoneLabel(TVpPhoneType(TmpCon.PhoneType1)) + ': ';
          DrawContactLine(TmpBmp, TmpCon.Phone1, Str, WholeRect, Phone1Rect);

          { do Phone2 }
          Str := PhoneLabel(TVpPhoneType(TmpCon.PhoneType2)) + ': ';
          DrawContactLine(TmpBmp, TmpCon.Phone2, Str, WholeRect, Phone2Rect);

          { do Phone3 }
          Str := PhoneLabel(TVpPhoneType(TmpCon.PhoneType3)) + ': ';
          DrawContactLine(TmpBmp, TmpCon.Phone3, Str, WholeRect, Phone3Rect);

          { do Phone4 }
          Str := PhoneLabel(TVpPhoneType(TmpCon.PhoneType4)) + ': ';
          DrawContactLine(TmpBmp, TmpCon.Phone4, Str, WholeRect, Phone4Rect);

          { do Phone5 }
          Str := PhoneLabel(TVpPhoneType(TmpCon.PhoneType5)) + ': ';
          DrawContactLine(TmpBmp, TmpCon.Phone5, Str, WholeRect, Phone5Rect);

          { do EMail }
          Str := TVpContactGridOpener(FContactGrid).GetDisplayEMailValue(TmpCon);
          DrawContactLine(TmpBmp, Str, RSEmail + ': ', WholeRect, EMailRect);

          { if this record's too big to fit in the remaining area of this }
          { column, then slide over to the top of the next column }
          case Angle of
            ra0 : begin
              if (RenderIn.Top + Anchor.y + WholeRect.Bottom >= RenderIn.Bottom - TextMargin * 3) and
                 (RecsInCol > 0)
              then begin
                Anchor := Point(
                  Anchor.x + WholeRect.Right + FContactGrid.BarWidth + 1 + TextMargin * 3,
                  2 + TextMargin * 2
                );
                if Col = 1 then
                  TVpContactGridOpener(FContactGrid).cgCol1RecCount := RecsInCol;
                Inc(Col);
                RecsInCol := 0;
                if DisplayOnly and (Anchor.X + TextColWidth >= RenderIn.Right) then
                  Exit;
              end;
            end;
            ra90 : begin
              if (Anchor.x + RenderIn.Left + WholeRect.Right - WholeRect.Left > RenderIn.Right - TextMargin * 3) and
                 (RecsInCol > 0)
              then begin
                Anchor.x := 2 + TextMargin * 2;
                Anchor.y := Anchor.y + WholeRect.Bottom + FContactGrid.BarWidth + 1 + TextMargin * 3;
                if Col = 1 then
                  TVpContactGridOpener(FContactGrid).cgCol1RecCount := RecsInCol;
                Inc(Col);
                RecsInCol := 0;
                if DisplayOnly and (Anchor.y + TextColWidth >= RenderIn.Bottom) then
                  Exit;
              end;
            end;
            ra180 : begin
              if (Anchor.y + RenderIn.Top - WholeRect.Bottom - WholeRect.Top <= RenderIn.Top + TextMargin * 3) and
                 (RecsInCol > 0) then
              begin
                Anchor.x := Anchor.x - (WholeRect.Right + FContactGrid.BarWidth + 1 + TextMargin * 3);
                Anchor.y := TmpBmp.Height - 2 - TextMargin * 2;
                if Col = 1 then
                  TVpContactGridOpener(FContactGrid).cgCol1RecCount := RecsInCol;
                Inc(Col);
                RecsInCol := 0;
                if DisplayOnly and (Anchor.x + TextColWidth < RenderIn.Left) then
                  Exit;
              end;
            end;
            ra270 : begin
              if (Anchor.x + RenderIn.Left + (WholeRect.Right - WholeRect.Left) >= RenderIn.Right - TextMargin * 3) and
                 (RecsInCol > 0) then
              begin
                Anchor.x := 2 + TextMargin * 2;
                Anchor.y := Anchor.y - (WholeRect.Bottom + FContactGrid.BarWidth + 1 + TextMargin * 3);
                if Col = 1 then
                  TVpContactGridOpener(FContactGrid).cgCol1RecCount := RecsInCol;
                Inc(Col);
                RecsInCol := 0;
                if DisplayOnly and (Anchor.y + TextColWidth <= RenderIn.Top) then
                  Exit;
              end;
            end;
          end;

          { add a little spacing between records }
          case Angle of
            ra0   : WholeRect.Bottom := WholeRect.Bottom + TextMargin * 2;
            ra90  : WholeRect.Left := WholeRect.Left - TextMargin * 2;
            ra180 : WholeRect.Top := WholeRect.Top - TextMargin * 2;
            ra270 : WholeRect.Right := WholeRect.Right + TextMargin * 2;
          end;

          { Update Array Rects }
          with TVpContactGridOpener(FContactGrid) do begin
            cgContactArray[I].WholeRect := MoveRect(WholeRect, Anchor);
            cgContactArray[I].HeaderRect := MoveRect(HeadRect, Anchor);
            cgContactArray[I].AddressRect := MoveRect(AddrRect, Anchor);
            cgContactArray[I].CSZRect := MoveRect(CSZRect, Anchor);
            cgContactArray[I].CompanyRect := MoveRect(CompanyRect, Anchor);
            cgContactArray[I].EMailRect := MoveRect(EMailRect, Anchor);
            cgContactArray[I].Phone1Rect := MoveRect(Phone1Rect, Anchor);
            cgContactArray[I].Phone2Rect := MoveRect(Phone2Rect, Anchor);
            cgContactArray[I].Phone3Rect := MoveRect(Phone3Rect, Anchor);
            cgContactArray[I].Phone4Rect := MoveRect(Phone4Rect, Anchor);
            cgContactArray[I].Phone5Rect := MoveRect(Phone5Rect, Anchor);
          end;

          { move the drawn record from the bitmap to the component canvas }
          case Angle of
            ra0   :
              RenderCanvas.CopyRect (Rect (Anchor.X + WholeRect.Left + RenderIn.Left,
                                           Anchor.Y + WholeRect.Top + RenderIn.Top,
                                           Anchor.X + TmpBmp.Width + RenderIn.Left,
                                           Anchor.Y + WholeRect.Bottom + RenderIn.Top),
                                     TmpBmp.Canvas, WholeRect);
            ra90  :
              RenderCanvas.CopyRect (Rect (WholeRect.Left + RenderIn.Left - Anchor.X,
                                           Anchor.Y + WholeRect.Top + RenderIn.Top,
                                           WholeRect.Right + RenderIn.Left - Anchor.X,
                                           Anchor.Y + WholeRect.Bottom + RenderIn.Top),
                                     TmpBmp.Canvas,
                                     Rect (WholeRect.Left,
                                           WholeRect.Top,
                                           WholeRect.Right,
                                           WholeRect.Bottom));

            ra180 :
              RenderCanvas.CopyRect (Rect (Anchor.X + WholeRect.Left + RenderIn.Left,
                                           Anchor.Y - (WholeRect.Bottom - WholeRect.Top) + RenderIn.Top,
                                           Anchor.X + TmpBmp.Width + RenderIn.Left,
                                           Anchor.Y + RenderIn.Top),
                                     TmpBmp.Canvas, WholeRect);

            ra270 :
              RenderCanvas.CopyRect (Rect (Anchor.X + RenderIn.Left,
                                           Anchor.Y + RenderIn.Top,
                                           Anchor.X + RenderIn.Left + (WholeRect.Right - WholeRect.Left),
                                           Anchor.Y + RenderIn.Top + (WholeRect.Bottom - WholeRect.Top)),
                                     TmpBmp.Canvas, WholeRect);
          end;

          { draw focusrect around selected record }
          if FContactGrid.Focused and (TmpCon = FContactGrid.ActiveContact) then begin
            with TVpContactGridOpener(FContactGrid).cgContactArray[I] do begin
              R := WholeRect;
              InflateRect(R, 3, 3);
              dec(R.Bottom, 2*3);
              RenderCanvas.DrawFocusRect(R);
              {
              RenderCanvas.DrawFocusRect(Rect(WholeRect.Left, WholeRect.Top - 3,
                WholeRect.Right + TextMargin, WholeRect.Bottom - 2));
              }
            end;
          end;

          { slide anchor down for the next record }
          case Angle of
            ra0   : Anchor.Y := Anchor.Y + WholeRect.Bottom;
            ra90  : Anchor.X := Anchor.X + (WholeRect.Right - WholeRect.Left);
            ra180 : Anchor.Y := Anchor.Y - (WholeRect.Bottom - WholeRect.Top);
            ra270 : Anchor.X := Anchor.X + WholeRect.Right;
          end;
          Inc(RecsInCol);
        end;
      end;

      if not DisplayOnly then
        case Angle of
          ra0 :
            with TVpContactGridOpener(FContactGrid) do
              if (Anchor.X > RenderIn.Right) and (I < DataStore.Resource.Contacts.Count)
              then begin
                { we have filled in the visible area }
                FContactsAfter := DataStore.Resource.Contacts.Count - I;
                FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact - FContactsAfter;
                Break;
              end else begin
                FContactsAfter := 0;
                FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact;
              end;
          ra90 :
            with TVpContactGridOpener(FContactGrid) do
              if (Anchor.Y > RenderIn.Bottom) and (I < DataStore.Resource.Contacts.Count)
              then begin
                { we have filled in the visible area }
                FContactsAfter := DataStore.Resource.Contacts.Count - I;
                FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact - FContactsAfter;
                Break;
              end else begin
                FContactsAfter := 0;
                FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact;
              end;
          ra180 :
            with TVpContactGridOpener(FContactGrid) do begin
              if (Anchor.X < RenderIn.Left) and (I < DataStore.Resource.Contacts.Count)
              then begin
                { we have filled in the visible area }
                FContactsAfter := DataStore.Resource.Contacts.Count - I;
                FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact - FContactsAfter;
                Break;
              end else
                FContactsAfter := 0;
              FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact;
            end;
          ra270 :
            with TVpContactGridOpener(FContactGrid) do begin
              if (Anchor.Y < RenderIn.Top) and (I < DataStore.Resource.Contacts.Count)
              then begin
                { we have filled in the visible area }
                FContactsAfter := DataStore.Resource.Contacts.Count - I;
                FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact - FContactsAfter;
                Break;
              end else
                FContactsAfter := 0;
              FVisibleContacts := DataStore.Resource.Contacts.Count - StartContact;
            end;
        end;
    end;
  finally
    TmpBmp.Free;
  end;

  with TVpContactGridOpener(FContactGrid) do begin
    if FContactsAfter = 0 then
      FLastPrintLine := -2
    else
      FLastPrintLine := FContactsAfter;

    if (oldCol1RecCount > 0) and (cgCol1RecCount = 0) then
      cgCol1RecCount := oldCol1RecCount;
  end;
end;

procedure TVpContactGridPainter.DrawVerticalBars;
var
  BarPos, BarCount, I: Integer;
begin
  { if the component is sufficiently small then no sense in painting it }
  if (FContactGrid.Height < 20) then exit;

  { draw vertical bars }
  RenderCanvas.Pen.Color := RealBarColor;
  RenderCanvas.Pen.Style := psSolid;
  BarPos := RealLeft + 2 + RealColumnWidth + ExtraBarWidth;
  BarCount := 0;
  while (BarPos < RealRight) and (BarCount < Pred(MaxColumns)) do begin
    TVpContactGridOpener(FContactGrid).cgBarArray[BarCount].Rec := Rect(
      BarPos - ExtraBarWidth,
      RealTop,
      BarPos + ExtraBarWidth + FContactGrid.BarWidth,
      RealBottom
    );

    TVpContactGridOpener(FContactGrid).cgBarArray[BarCount].Index := BarCount;
    for I := 1 to FContactGrid.BarWidth do begin
      TPSMoveTo(RenderCanvas, Angle, RenderIn, BarPos, RealTop + 2 + TextMargin * 2);
      TPSLineTo(RenderCanvas, Angle, RenderIn, BarPos, RealBottom - TextMargin * 2);
      Inc(BarPos);
    end;
    Inc(BarPos, RealColumnWidth);
    Inc(BarCount);
  end;

  { if the columns are being resized, then draw the temporary resizing bars }
  if TVpContactGridOpener(FContactGrid).cgGridState = gsColSizing then begin
    { clear sizing bar array }
    for I := 0 to pred(MaxColumns) do
      with TVpContactGridOpener(FContactGrid) do begin
        if cgResizeBarArray[I].Index = -1 then
          Break;
        cgResizeBarArray[I].Rec := Rect(-1, -1, -1, -1);
        cgResizeBarArray[I].Index := -1;
      end;
    { draw sizing bars }
    RenderCanvas.Pen.Color := SizingBarColor;
    RenderCanvas.Pen.Style := psDash;
    BarPos := RealLeft + 2 + TVpContactGridOpener(FContactGrid).cgNewColWidth + ExtraBarWidth;
    BarCount := 0;
    while (BarPos < FContactGrid.Width) and (BarCount < pred(MaxColumns)) do begin
      TVpContactGridOpener(FContactGrid).cgResizeBarArray[BarCount].Index := BarCount;
      TVpContactGridOpener(FContactGrid).cgResizeBarArray[BarCount].Rec := Rect(
        BarPos - ExtraBarWidth,
        RealTop,
        BarPos - ExtraBarWidth + FContactGrid.BarWidth,
        RealBottom
      );
      for I := 1 to FContactGrid.BarWidth do begin
        TPSMoveTo(
          RenderCanvas, Angle, RenderIn,
          RealLeft + BarPos,
          RealTop + 2 + TextMargin * 2
        );
        TPSLineTo(
          RenderCanvas, Angle, RenderIn,
          RealLeft + BarPos,
          RealBottom - TextMargin * 2
        );
        Inc(BarPos);
      end;
      Inc(BarPos, TVpContactGridOpener(FContactGrid).cgNewColWidth);
      Inc(BarCount);
    end;
    RenderCanvas.Pen.Style := psSolid;
  end;
end;

procedure TVpContactGridPainter.FixFontHeights;
begin
  {$IF VP_LCL_SCALING = 0}
  with FContactGrid do begin
    ContactHeadAttributes.Font.Height := GetRealFontHeight(ContactHeadAttributes.Font);
    Font.Height := GetRealFontHeight(Font);
  end;
  {$ENDIF}
end;

procedure TVpContactGridPainter.InitColors;
begin
  if DisplayOnly then begin
    RealColor := clWhite;
    SizingBarColor := clBlack;
    BevelDarkShadow := clBlack;
    BevelShadow := clBlack;
    BevelHighlight := clBlack;
    BevelFace := clBlack;
    RealBarColor := clBlack;
    RealContactHeadAttrColor := clSilver;
  end else begin
    RealColor := FContactGrid.Color;
    SizingBarColor := clBlack;
    BevelDarkShadow := cl3dDkShadow;
    BevelShadow := clBtnShadow;
    BevelHighlight := clBtnHighlight;
    BevelFace := clBtnFace;
    RealBarColor := FContactGrid.BarColor;
    RealContactHeadAttrColor := FContactGrid.ContactHeadAttributes.Color;
  end;
end;

procedure TVpContactGridPainter.RenderToCanvas(ARenderIn: TRect;
  AAngle: TVpRotationAngle; AScale: Extended; ARenderDate: TDateTime;
  AStartLine, AStopLine: Integer; AUseGran: TVpGranularity; ADisplayOnly: Boolean);
var
  nc: Integer;
begin
  inherited;

  InitColors;
  SavePenBrush;
  InitPenBrush;
  if ADisplayOnly then FixFontHeights;

  Rgn := CreateRectRgn(RenderIn.Left, RenderIn.Top, RenderIn.Right, RenderIn.Bottom);
  try
    SelectClipRgn(RenderCanvas.Handle, Rgn);

    if StartLine = -1 then
      StartContact := TVpContactGridOpener(FContactGrid).FContactsBefore
    else
      StartContact := StartLine;

    SetMeasurements;

    nc := FContactGrid.PrintNumColumns;
    if DisplayOnly and (nc > 0) then
      RealColumnWidth := (RealWidth - (2 + ExtraBarWidth) * (nc - 1)) div nc
    else
      RealColumnWidth := FContactGrid.ColumnWidth;

    { clear the control }
    Clear;

    { draw the contacts }
    if StartLine <> -2 then
      DrawContacts;

    { draw the vertical bars }
    DrawVerticalBars;

    { draw the borders }
    DrawBorders;

    TVpContactGridOpener(FContactGrid).SetHScrollPos;

  finally
    SelectClipRgn(RenderCanvas.Handle, 0);
    DeleteObject(Rgn);
  end;

  { reinstate canvas settings }
  RestorePenBrush;
end;

end.
