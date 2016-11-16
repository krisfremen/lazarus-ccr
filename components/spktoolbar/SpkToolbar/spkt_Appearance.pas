unit spkt_Appearance;

{$mode Delphi}

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Appearance.pas                                                   *
*  Opis: Klasy bazowe dla klas wygl¹du elementów toolbara                      *
*  Copyright: (c) 2009 by Spook.                                               *
*  License:   Modified LGPL (with linking exception, like Lazarus LCL)         *
'             See "license.txt" in this installation                           *
*                                                                              *
*******************************************************************************)

interface

uses Graphics, Classes, Forms, SysUtils,
     SpkGUITools, SpkXMLParser, SpkXMLTools,
     spkt_Dispatch, spkt_Exceptions, spkt_Const;

type
  TSpkPaneStyle = (psRectangleFlat, psRectangleEtched, psRectangleRaised,
    psDividerFlat, psDividerEtched, psDividerRaised);

  TSpkElementStyle = (esRounded, esRectangle);

type TSpkTabAppearance = class(TPersistent)
     private
       FDispatch: TSpkBaseAppearanceDispatch;
     protected
       FTabHeaderFont: TFont;
       FBorderColor: TColor;
       FGradientFromColor: TColor;
       FGradientToColor: TColor;
       FGradientType: TBackgroundKind;
       FInactiveHeaderFontColor: TColor;

       // Getter & setter methods
       procedure SetHeaderFont(const Value: TFont);
       procedure SetBorderColor(const Value: TColor);
       procedure SetGradientFromColor(const Value: TColor);
       procedure SetGradientToColor(const Value: TColor);
       procedure SetGradientType(const Value: TBackgroundKind);
       procedure SetInactiveHeaderFontColor(const Value: TColor);

     public
     // *** Konstruktor, destruktor, assign ***
     // <remarks>Appearance musi mieæ assign, bo wystêpuje jako w³asnoœæ
     // opublikowana.</remarks>
       procedure Assign(Source: TPersistent); override;
       constructor Create(ADispatch: TSpkBaseAppearanceDispatch);
       procedure SaveToPascal(AList: TStrings);
       procedure SaveToXML(Node: TSpkXMLNode);
       procedure LoadFromXML(Node: TSpkXMLNode);
       destructor Destroy; override;
       procedure Reset;
     published
       property TabHeaderFont: TFont read FTabHeaderFont write SetHeaderFont;
       property BorderColor: TColor read FBorderColor write SetBorderColor;
       property GradientFromColor: TColor read FGradientFromColor write SetGradientFromColor;
       property GradientToColor: TColor read FGradientToColor write SetGradientToColor;
       property GradientType: TBackgroundKind read FGradientType write SetGradientType;
       property InactiveTabHeaderFontColor: TColor read FInactiveHeaderFontColor write SetInactiveHeaderFontColor;
     end;

type TSpkPaneAppearance = class(TPersistent)
     private
       FDispatch: TSpkBaseAppearanceDispatch;
     protected
       FCaptionFont: TFont;
       FBorderDarkColor: TColor;
       FBorderLightColor: TColor;
       FCaptionBgColor: TColor;
       FGradientFromColor: TColor;
       FGradientToColor: TColor;
       FGradientType: TBackgroundKind;
       FStyle: TSpkPaneStyle;

       procedure SetCaptionBgColor(const Value: TColor);
       procedure SetCaptionFont(const Value: TFont);
       procedure SetBorderDarkColor(const Value: TColor);
       procedure SetBorderLightColor(const Value: TColor);
       procedure SetGradientFromColor(const Value: TColor);
       procedure SetGradientToColor(const Value: TColor);
       procedure SetGradientType(const Value: TBackgroundKind);
       procedure SetStyle(const Value: TSpkPaneStyle);
     public
       constructor Create(ADispatch: TSpkBaseAppearanceDispatch);
       destructor Destroy; override;
       procedure Assign(Source: TPersistent); override;
       procedure SaveToPascal(AList: TStrings);
       procedure SaveToXML(Node: TSpkXMLNode);
       procedure LoadFromXML(Node: TSpkXMLNode);
       procedure Reset;
     published
       property BorderDarkColor: TColor read FBorderDarkColor write SetBorderDarkColor;
       property BorderLightColor: TColor read FBorderLightColor write SetBorderLightColor;
       property CaptionBgColor: TColor read FCaptionBgColor write SetCaptionBgColor;
       property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
       property GradientFromColor: TColor read FGradientFromColor write SetGradientFromColor;
       property GradientToColor: TColor read FGradientToColor write SetGradientToColor;
       property GradientType: TBackgroundKind read FGradientType write SetGradientType;
       property Style: TSpkPaneStyle read FStyle write SetStyle default psRectangleEtched;
     end;

type TSpkElementAppearance = class(TPersistent)
     private
       FDispatch: TSpkBaseAppearanceDispatch;
       FCaptionFont: TFont;
       FIdleFrameColor: TColor;
       FIdleGradientFromColor: TColor;
       FIdleGradientToColor: TColor;
       FIdleGradientType: TBackgroundKind;
       FIdleInnerLightColor: TColor;
       FIdleInnerDarkColor: TColor;
       FIdleCaptionColor: TColor;
       FHotTrackFrameColor: TColor;
       FHotTrackGradientFromColor: TColor;
       FHotTrackGradientToColor: TColor;
       FHotTrackGradientType: TBackgroundKind;
       FHotTrackInnerLightColor: TColor;
       FHotTrackInnerDarkColor: TColor;
       FHotTrackCaptionColor: TColor;
       FActiveFrameColor: TColor;
       FActiveGradientFromColor: TColor;
       FActiveGradientToColor: TColor;
       FActiveGradientType: TBackgroundKind;
       FActiveInnerLightColor: TColor;
       FActiveInnerDarkColor: TColor;
       FActiveCaptionColor: TColor;
       FStyle: TSpkElementStyle;
       procedure SetActiveCaptionColor(const Value: TColor);
       procedure SetActiveFrameColor(const Value: TColor);
       procedure SetActiveGradientFromColor(const Value: TColor);
       procedure SetActiveGradientToColor(const Value: TColor);
       procedure SetActiveGradientType(const Value: TBackgroundKind);
       procedure SetActiveInnerDarkColor(const Value: TColor);
       procedure SetActiveInnerLightColor(const Value: TColor);
       procedure SetCaptionFont(const Value: TFont);
       procedure SetHotTrackCaptionColor(const Value: TColor);
       procedure SetHotTrackFrameColor(const Value: TColor);
       procedure SetHotTrackGradientFromColor(const Value: TColor);
       procedure SetHotTrackGradientToColor(const Value: TColor);
       procedure SetHotTrackGradientType(const Value: TBackgroundKind);
       procedure SetHotTrackInnerDarkColor(const Value: TColor);
       procedure SetHotTrackInnerLightColor(const Value: TColor);
       procedure SetIdleCaptionColor(const Value: TColor);
       procedure SetIdleFrameColor(const Value: TColor);
       procedure SetIdleGradientFromColor(const Value: TColor);
       procedure SetIdleGradientToColor(const Value: TColor);
       procedure SetIdleGradientType(const Value: TBackgroundKind);
       procedure SetIdleInnerDarkColor(const Value: TColor);
       procedure SetIdleInnerLightColor(const Value: TColor);
       procedure SetStyle(const Value: TSpkElementStyle);
     public
       constructor Create(ADispatch: TSpkBaseAppearanceDispatch);
       destructor Destroy; override;
       procedure Assign(Source: TPersistent); override;
       procedure SaveToPascal(AList: TStrings);
       procedure SaveToXML(Node: TSpkXMLNode);
       procedure LoadFromXML(Node: TSpkXMLNode);
       procedure Reset;
     published
       property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
       property IdleFrameColor: TColor read FIdleFrameColor write SetIdleFrameColor;
       property IdleGradientFromColor: TColor read FIdleGradientFromColor write SetIdleGradientFromColor;
       property IdleGradientToColor: TColor read FIdleGradientToColor write SetIdleGradientToColor;
       property IdleGradientType: TBackgroundKind read FIdleGradientType write SetIdleGradientType;
       property IdleInnerLightColor: TColor read FIdleInnerLightColor write SetIdleInnerLightColor;
       property IdleInnerDarkColor: TColor read FIdleInnerDarkColor write SetIdleInnerDarkColor;
       property IdleCaptionColor: TColor read FIdleCaptionColor write SetIdleCaptionColor;
       property HotTrackFrameColor: TColor read FHotTrackFrameColor write SetHotTrackFrameColor;
       property HotTrackGradientFromColor: TColor read FHotTrackGradientFromColor write SetHotTrackGradientFromColor;
       property HotTrackGradientToColor: TColor read FHotTrackGradientToColor write SetHotTrackGradientToColor;
       property HotTrackGradientType: TBackgroundKind read FHotTrackGradientType write SetHotTrackGradientType;
       property HotTrackInnerLightColor: TColor read FHotTrackInnerLightColor write SetHotTrackInnerLightColor;
       property HotTrackInnerDarkColor: TColor read FHotTrackInnerDarkColor write SetHotTrackInnerDarkColor;
       property HotTrackCaptionColor: TColor read FHotTrackCaptionColor write SetHotTrackCaptionColor;
       property ActiveFrameColor: TColor read FActiveFrameColor write SetActiveFrameColor;
       property ActiveGradientFromColor: TColor read FActiveGradientFromColor write SetActiveGradientFromColor;
       property ActiveGradientToColor: TColor read FActiveGradientToColor write SetActiveGradientToColor;
       property ActiveGradientType: TBackgroundKind read FActiveGradientType write SetActiveGradientType;
       property ActiveInnerLightColor: TColor read FActiveInnerLightColor write SetActiveInnerLightColor;
       property ActiveInnerDarkColor: TColor read FActiveInnerDarkColor write SetActiveInnerDarkColor;
       property ActiveCaptionColor: TColor read FActiveCaptionColor write SetActiveCaptionColor;
       property Style: TSpkElementStyle read FStyle write SetStyle;
     end;

type TSpkToolbarAppearance = class;

     TSpkToolbarAppearanceDispatch = class(TSpkBaseAppearanceDispatch)
     private
       FToolbarAppearance: TSpkToolbarAppearance;
     protected
     public
       constructor Create(AToolbarAppearance: TSpkToolbarAppearance);
       procedure NotifyAppearanceChanged; override;
     end;

     TSpkToolbarAppearance = class(TPersistent)
     private
       FAppearanceDispatch: TSpkToolbarAppearanceDispatch;
     protected
       FTab: TSpkTabAppearance;
       FPane: TSpkPaneAppearance;
       FElement: TSpkElementAppearance;
       FDispatch: TSpkBaseAppearanceDispatch;
       procedure SetElementAppearance(const Value: TSpkElementAppearance);
       procedure SetPaneAppearance(const Value: TSpkPaneAppearance);
       procedure SetTabAppearance(const Value: TSpkTabAppearance);
     public
       constructor Create(ADispatch: TSpkBaseAppearanceDispatch); reintroduce;
       destructor Destroy; override;
       procedure Assign(Source: TPersistent); override;
       procedure NotifyAppearanceChanged;
       procedure Reset;
       procedure SaveToPascal(AList: TStrings);
       procedure SaveToXML(Node: TSpkXMLNode);
       procedure LoadFromXML(Node: TSpkXMLNode);
     published
       property Tab: TSpkTabAppearance read FTab write SetTabAppearance;
       property Pane: TSpkPaneAppearance read FPane write SetPaneAppearance;
       property Element: TSpkElementAppearance read FElement write SetElementAppearance;
     end;

     procedure SetDefaultFont(AFont: TFont);

implementation

uses
  LCLIntf, LCLType, typinfo;

procedure SaveFontToPascal(AList: TStrings; AFont: TFont; AName: String);
var
  sty: String;
begin
  sty := '';
  if fsBold in AFont.Style then sty := sty + 'fsBold,';
  if fsItalic in AFont.Style then sty := sty + 'fsItalic,';
  if fsUnderline in AFont.Style then sty := sty + 'fsUnderline,';
  if fsStrikeout in AFont.Style then sty := sty + 'fsStrikeout,';
  if sty <> '' then Delete(sty, Length(sty), 1);
  with AList do begin
    Add(AName + '.Name := ''' + AFont.Name + ''';');
    Add(AName + '.Size := ' + IntToStr(AFont.Size) + ';');
    Add(AName + '.Style := [' + sty + '];');
    Add(AName + '.Color := $' + IntToHex(AFont.Color, 8) + ';');
  end;
end;

{ TSpkBaseToolbarAppearance }

procedure TSpkTabAppearance.Assign(Source: TPersistent);
var
  SrcAppearance: TSpkTabAppearance;
begin
  if Source is TSpkTabAppearance then
  begin
     SrcAppearance:=TSpkTabAppearance(Source);
     FTabHeaderFont.Assign(SrcAppearance.TabHeaderFont);
     FBorderColor:=SrcAppearance.BorderColor;
     FGradientFromColor:=SrcAppearance.GradientFromColor;
     FGradientToColor:=SrcAppearance.GradientToColor;
     FGradientType:=SrcAppearance.GradientType;
     FInactiveHeaderFontColor := SrcAppearance.InactiveTabHeaderFontColor;

     if FDispatch<>nil then
        FDispatch.NotifyAppearanceChanged;
  end else
    raise AssignException.create('TSpkToolbarAppearance.Assign: Nie mogê przypisaæ obiektu '+Source.ClassName+' do TSpkToolbarAppearance!');
end;

constructor TSpkTabAppearance.Create(
  ADispatch: TSpkBaseAppearanceDispatch);
begin
  inherited Create;
  FDispatch:=ADispatch;

  FTabHeaderFont:=TFont.Create;

  Reset;
end;

destructor TSpkTabAppearance.Destroy;
begin
  FTabHeaderFont.Free;
  inherited;
end;

procedure TSpkTabAppearance.LoadFromXML(Node: TSpkXMLNode);
var
  Subnode : TSpkXMLNode;
begin
  if not(assigned(Node)) then
    exit;

  Subnode:=Node['TabHeaderFont',false];
  if Assigned(Subnode) then
    TSpkXMLTools.Load(Subnode, FTabHeaderFont);

  Subnode:=Node['BorderColor',false];
  if assigned(Subnode) then
    FBorderColor:=Subnode.TextAsColor;

  Subnode:=Node['GradientFromColor',false];
  if assigned(Subnode) then
    FGradientFromColor:=Subnode.TextAsColor;

  Subnode:=Node['GradientToColor',false];
  if assigned(Subnode) then
    FGradientToColor:=Subnode.TextAsColor;

  Subnode:=Node['GradientType',false];
  if assigned(Subnode) then
    FGradientType:=TBackgroundKind(Subnode.TextAsInteger);

  Subnode := Node['InactiveTabHeaderFontColor', false];
  if Assigned(Subnode) then
    FInactiveHeaderFontColor := Subnode.TextAsColor;
end;

procedure TSpkTabAppearance.Reset;
begin
  SetDefaultFont(FTabHeaderFont);
  FTabHeaderFont.Size := FTabHeaderFont.Size + 1;
  FBorderColor := rgb(141, 178, 227);
  FGradientFromColor := rgb(222, 232, 245);
  FGradientToColor := rgb(199, 216, 237);
  FGradientType := bkConcave;
  FInactiveHeaderFontColor := FTabHeaderFont.Color;
end;

procedure TSpkTabAppearance.SaveToPascal(AList: TStrings);
begin
  with AList do begin
    Add('  with Tab do begin');
    SaveFontToPascal(AList, FTabHeaderFont, '    TabHeaderFont');
    Add('    BorderColor := $' + IntToHex(FBorderColor, 8) + ';');
    Add('    GradientFromColor := $' + IntToHex(FGradientFromColor, 8) + ';');
    Add('    GradientToColor := $' + IntToHex(FGradientToColor, 8) + ';');
    Add('    GradientType := ' + GetEnumName(TypeInfo(TBackgroundKind), ord(FGradientType)) + ';');
    Add('    InactiveTabHeaderFontColor := $' + IntToHex(FInactiveHeaderFontColor, 8) + ';');
    Add('  end;');
  end;
end;

procedure TSpkTabAppearance.SaveToXML(Node: TSpkXMLNode);
var
  Subnode: TSpkXMLNode;
begin
  if not(assigned(Node)) then
    exit;

  Subnode:=Node['TabHeaderFont',true];
  TSpkXMLTools.Save(Subnode, FTabHeaderFont);

  Subnode:=Node['BorderColor',true];
  Subnode.TextAsColor:=FBorderColor;

  Subnode:=Node['GradientFromColor',true];
  Subnode.TextAsColor:=FGradientFromColor;

  Subnode:=Node['GradientToColor',true];
  Subnode.TextAsColor:=FGradientToColor;

  Subnode:=Node['GradientType',true];
  Subnode.TextAsInteger:=integer(FGradientType);

  Subnode := Node['InactiveTabHeaderFontColor', true];
  Subnode.TextAsColor := FInactiveHeaderFontColor;
end;

procedure TSpkTabAppearance.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkTabAppearance.SetGradientFromColor(const Value: TColor);
begin
  FGradientFromColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkTabAppearance.SetGradientToColor(const Value: TColor);
begin
  FGradientToColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkTabAppearance.SetGradientType(const Value: TBackgroundKind);
begin
  FGradientType := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkTabAppearance.SetHeaderFont(const Value: TFont);
begin
  FTabHeaderFont.assign(Value);
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkTabAppearance.SetInactiveHeaderFontColor(const Value: TColor);
begin
  FInactiveHeaderFontColor := Value;
  if FDispatch <> nil then
    FDispatch.NotifyAppearanceChanged;
end;



{ TSpkPaneAppearance }

procedure TSpkPaneAppearance.Assign(Source: TPersistent);
var
  SrcAppearance : TSpkPaneAppearance;
begin
  if Source is TSpkPaneAppearance then
  begin
     SrcAppearance:=TSpkPaneAppearance(Source);

     FCaptionFont.assign(SrcAppearance.CaptionFont);
     FBorderDarkColor := SrcAppearance.BorderDarkColor;
     FBorderLightColor := SrcAppearance.BorderLightColor;
     FCaptionBgColor := SrcAppearance.CaptionBgColor;
     FGradientFromColor := SrcAppearance.GradientFromColor;
     FGradientToColor := SrcAppearance.GradientToColor;
     FGradientType := SrcAppearance.GradientType;
     FStyle := SrcAppearance.Style;

     if FDispatch<>nil then
        FDispatch.NotifyAppearanceChanged;
     end else
         raise AssignException.create('TSpkPaneAppearance.Assign: Nie mogê przypisaæ obiektu '+Source.ClassName+' do TSpkPaneAppearance!');
end;

constructor TSpkPaneAppearance.Create(ADispatch: TSpkBaseAppearanceDispatch);
begin
  inherited Create;
  FDispatch:=ADispatch;
  FCaptionFont:=TFont.Create;
  FStyle := psRectangleEtched;
  Reset;
end;

destructor TSpkPaneAppearance.Destroy;
begin
  FCaptionFont.Free;
  inherited Destroy;
end;

procedure TSpkPaneAppearance.LoadFromXML(Node: TSpkXMLNode);
var
  Subnode: TSpkXMLNode;
begin
  if not(Assigned(Node)) then
    exit;

  Subnode := Node['CaptionFont', false];
  if Assigned(Subnode) then
    TSpkXMLTools.Load(Subnode, FCaptionFont);

  Subnode := Node['BorderDarkColor', false];
  if Assigned(Subnode) then
    FBorderDarkColor := Subnode.TextAsColor;

  Subnode := Node['BorderLightColor', false];
  if Assigned(Subnode) then
    FBorderLightColor := Subnode.TextAsColor;

  Subnode := Node['CaptionBgColor', false];
  if Assigned(Subnode) then
    FCaptionBgColor := Subnode.TextAsColor;

  Subnode := Node['GradientFromColor', false];
  if Assigned(Subnode) then
    FGradientFromColor := Subnode.TextAsColor;

  Subnode := Node['GradientToColor', false];
  if Assigned(Subnode) then
    FGradientToColor := Subnode.TextAsColor;

  Subnode := Node['GradientType', false];
  if assigned(Subnode) then
    FGradientType := TBackgroundKind(Subnode.TextAsInteger);

  Subnode := Node['Style', false];
  if Assigned(Subnode) then
    FStyle := TSpkPaneStyle(SubNode.TextAsInteger);
end;

procedure TSpkPaneAppearance.Reset;
begin
  SetDefaultFont(FCaptionFont);
  FBorderDarkColor := rgb(158, 190, 218);
  FBorderLightColor := rgb(237, 242, 248);
  FCaptionBgColor := rgb(194, 217, 241);
  FGradientFromColor := rgb(222, 232, 245);
  FGradientToColor := rgb(199, 216, 237);
  FGradientType := bkConcave;
  FStyle := psRectangleEtched;
end;

procedure TSpkPaneAppearance.SaveToPascal(AList: TStrings);
begin
  with AList do begin
    Add('  with Pane do begin');
    SaveFontToPascal(AList, FCaptionFont, '    CaptionFont');
    Add('    BorderDarkColor := $' + IntToHex(FBorderDarkColor, 8) + ';');
    Add('    BorderLightColor := $' + IntToHex(FBorderLightColor, 8) + ';');
    Add('    CaptionBgColor := $' + IntToHex(FcaptionBgColor, 8) + ';');
    Add('    GradientFromColor := $' + IntToHex(FGradientFromColor, 8) + ';');
    Add('    GradientToColor := $' + IntToHex(FGradientToColor, 8) + ';');
    Add('    GradientType := ' + GetEnumName(TypeInfo(TBackgroundKind), ord(FGradientType)) + ';');
    Add('    Style := ' + GetEnumName(TypeInfo(TSpkPaneStyle), ord(FStyle)));
    Add('  end;');
  end;
end;

procedure TSpkPaneAppearance.SaveToXML(Node: TSpkXMLNode);
var
  Subnode: TSpkXMLNode;
begin
  if not Assigned(Node) then
    exit;

  Subnode := Node['CaptionFont',true];
  TSpkXMLTools.Save(Subnode, FCaptionFont);

  Subnode := Node['BorderDarkColor',true];
  Subnode.TextAsColor := FBorderDarkColor;

  Subnode := Node['BorderLightColor',true];
  Subnode.TextAsColor := FBorderLightColor;

  Subnode := Node['CaptionBgColor',true];
  Subnode.TextAsColor := FCaptionBgColor;

  Subnode := Node['GradientFromColor',true];
  Subnode.TextAsColor := FGradientFromColor;

  Subnode := Node['GradientToColor',true];
  Subnode.TextAsColor := FGradientToColor;

  Subnode := Node['GradientType',true];
  Subnode.TextAsInteger := integer(FGradientType);

  Subnode := Node['Style', true];
  Subnode.TextAsInteger := integer(FStyle);
end;

procedure TSpkPaneAppearance.SetBorderDarkColor(const Value: TColor);
begin
FBorderDarkColor:=Value;
if assigned(FDispatch) then
   FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetBorderLightColor(const Value: TColor);
begin
  FBorderLightColor:=Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetCaptionBgColor(const Value: TColor);
begin
  FCaptionBgColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetGradientFromColor(const Value: TColor);
begin
  FGradientFromColor:=Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetGradientToColor(const Value: TColor);
begin
  FGradientToColor:=Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetGradientType(const Value: TBackgroundKind);
begin
  FGradientType:=Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetCaptionFont(const Value: TFont);
begin
  FCaptionFont.assign(Value);
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkPaneAppearance.SetStyle(const Value: TSpkPaneStyle);
begin
  FStyle := Value;
  if FDispatch <> nil then
    FDispatch.NotifyAppearanceChanged;
end;


{ TSpkElementAppearance }

procedure TSpkElementAppearance.Assign(Source: TPersistent);
var
  SrcAppearance: TSpkElementAppearance;
begin
  if Source is TSpkElementAppearance then
  begin
    SrcAppearance := TSpkElementAppearance(Source);

    FCaptionFont.Assign(SrcAppearance.CaptionFont);
    FIdleFrameColor := SrcAppearance.IdleFrameColor;
    FIdleGradientFromColor := SrcAppearance.IdleGradientFromColor;
    FIdleGradientToColor := SrcAppearance.IdleGradientToColor;
    FIdleGradientType := SrcAppearance.IdleGradientType;
    FIdleInnerLightColor := SrcAppearance.IdleInnerLightColor;
    FIdleInnerDarkColor := SrcAppearance.IdleInnerDarkColor;
    FIdleCaptionColor := SrcAppearance.IdleCaptionColor;
    FHotTrackFrameColor := SrcAppearance.HotTrackFrameColor;
    FHotTrackGradientFromColor := SrcAppearance.HotTrackGradientFromColor;
    FHotTrackGradientToColor := SrcAppearance.HotTrackGradientToColor;
    FHotTrackGradientType := SrcAppearance.HotTrackGradientType;
    FHotTrackInnerLightColor := SrcAppearance.HotTrackInnerLightColor;
    FHotTrackInnerDarkColor := SrcAppearance.HotTrackInnerDarkColor;
    FHotTrackCaptionColor := SrcAppearance.HotTrackCaptionColor;
    FActiveFrameColor := SrcAppearance.ActiveFrameColor;
    FActiveGradientFromColor := SrcAppearance.ActiveGradientFromColor;
    FActiveGradientToColor := SrcAppearance.ActiveGradientToColor;
    FActiveGradientType := SrcAppearance.ActiveGradientType;
    FActiveInnerLightColor := SrcAppearance.ActiveInnerLightColor;
    FActiveInnerDarkColor := SrcAppearance.ActiveInnerDarkColor;
    FActiveCaptionColor := SrcAppearance.ActiveCaptionColor;
    FStyle := SrcAppearance.Style;

    if FDispatch <> nil then
      FDispatch.NotifyAppearanceChanged;
  end else
    raise AssignException.create('TSpkElementAppearance.Assign: Nie mogê przypisaæ obiektu '+Source.ClassName+' do TSpkElementAppearance!');
end;

constructor TSpkElementAppearance.Create(ADispatch: TSpkBaseAppearanceDispatch);
begin
  inherited Create;
  FDispatch := ADispatch;
  FCaptionFont := TFont.Create;
  Reset;
end;

destructor TSpkElementAppearance.Destroy;
begin
  FCaptionFont.Free;
  inherited Destroy;
end;

procedure TSpkElementAppearance.LoadFromXML(Node: TSpkXMLNode);
var
  Subnode: TSpkXMLNode;
begin
  if not Assigned(Node) then
    exit;

  Subnode := Node['CaptionFont', false];
  if Assigned(Subnode) then
    TSpkXMLTools.Load(Subnode, FCaptionFont);

  // Idle
  Subnode := Node['IdleFrameColor', false];
  if Assigned(Subnode) then
    FIdleFrameColor := Subnode.TextAsColor;

  Subnode := Node['IdleGradientFromColor', false];
  if Assigned(Subnode) then
    FIdleGradientFromColor := Subnode.TextAsColor;

  Subnode := Node['IdleGradientToColor', false];
  if Assigned(Subnode) then
    FIdleGradientToColor := Subnode.TextAsColor;

  Subnode := Node['IdleGradientType', false];
  if Assigned(Subnode) then
    FIdleGradientType := TBackgroundKind(Subnode.TextAsInteger);

  Subnode := Node['IdleInnerLightColor', false];
  if Assigned(Subnode) then
    FIdleInnerLightColor := Subnode.TextAsColor;

  Subnode := Node['IdleInnerDarkColor', false];
  if Assigned(Subnode) then
    FIdleInnerDarkColor := Subnode.TextAsColor;

  Subnode := Node['IdleCaptionColor', false];
  if Assigned(Subnode) then
    FIdleCaptionColor := Subnode.TextAsColor;

  // Hottrack
  Subnode := Node['HottrackFrameColor', false];
  if Assigned(Subnode) then
    FHottrackFrameColor := Subnode.TextAsColor;

  Subnode := Node['HottrackGradientFromColor', false];
  if Assigned(Subnode) then
    FHottrackGradientFromColor := Subnode.TextAsColor;

  Subnode := Node['HottrackGradientToColor', false];
  if Assigned(Subnode) then
    FHottrackGradientToColor := Subnode.TextAsColor;

  Subnode := Node['HottrackGradientType', false];
  if Assigned(Subnode) then
    FHottrackGradientType := TBackgroundKind(Subnode.TextAsInteger);

  Subnode := Node['HottrackInnerLightColor', false];
  if Assigned(Subnode) then
    FHottrackInnerLightColor := Subnode.TextAsColor;

  Subnode := Node['HottrackInnerDarkColor', false];
  if Assigned(Subnode) then
    FHottrackInnerDarkColor := Subnode.TextAsColor;

  Subnode := Node['HottrackCaptionColor', false];
  if Assigned(Subnode) then
    FHottrackCaptionColor := Subnode.TextAsColor;

  // Active
  Subnode := Node['ActiveFrameColor', false];
  if Assigned(Subnode) then
    FActiveFrameColor := Subnode.TextAsColor;

  Subnode := Node['ActiveGradientFromColor', false];
  if Assigned(Subnode) then
    FActiveGradientFromColor := Subnode.TextAsColor;

  Subnode := Node['ActiveGradientToColor', false];
  if Assigned(Subnode) then
    FActiveGradientToColor := Subnode.TextAsColor;

  Subnode := Node['ActiveGradientType', false];
  if Assigned(Subnode) then
    FActiveGradientType := TBackgroundKind(Subnode.TextAsInteger);

  Subnode := Node['ActiveInnerLightColor', false];
  if Assigned(Subnode) then
    FActiveInnerLightColor := Subnode.TextAsColor;

  Subnode := Node['ActiveInnerDarkColor', false];
  if Assigned(Subnode) then
    FActiveInnerDarkColor := Subnode.TextAsColor;

  Subnode := Node['ActiveCaptionColor', false];
  if Assigned(Subnode) then
    FActiveCaptionColor := Subnode.TextAsColor;

  // Other
  Subnode := Node['Style', false];
  if Assigned(SubNode) then
    FStyle := TSpkElementStyle(Subnode.TextAsInteger);
end;

procedure TSpkElementAppearance.Reset;
begin
  SetDefaultFont(FCaptionFont);
  FCaptionFont.Size := FCaptionFont.Size - 1;
  FIdleFrameColor := rgb(155, 183, 224);
  FIdleGradientFromColor := rgb(200, 219, 238);
  FIdleGradientToColor := rgb(188, 208, 233);
  FIdleGradientType := bkConcave;
  FIdleInnerLightColor := rgb(213, 227, 241);
  FIdleInnerDarkColor := rgb(190, 211, 236);
  FIdleCaptionColor := rgb(86, 125, 177);
  FHotTrackFrameColor := rgb(221, 207, 155);
  FHotTrackGradientFromColor := rgb(255, 252, 218);
  FHotTrackGradientToColor := rgb(255, 215, 77);
  FHotTrackGradientType := bkConcave;
  FHotTrackInnerLightColor := rgb(255, 241, 197);
  FHotTrackInnerDarkColor := rgb(216, 194, 122);
  FHotTrackCaptionColor := rgb(111, 66, 135);
  FActiveFrameColor := rgb(139, 118, 84);
  FActiveGradientFromColor := rgb(254, 187, 108);
  FActiveGradientToColor := rgb(252, 146, 61);
  FActiveGradientType := bkConcave;
  FActiveInnerLightColor := rgb(252, 169, 14);
  FActiveInnerDarkColor := rgb(252, 169, 14);
  FActiveCaptionColor := rgb(110, 66, 128);
  FStyle := esRounded;
end;

procedure TSpkElementAppearance.SaveToPascal(AList: TStrings);
begin
  with AList do begin
    Add('  with Element do begin');
    SaveFontToPascal(AList, FCaptionFont, '    CaptionFont');

    Add('    IdleFrameColor := $' + IntToHex(FIdleFrameColor, 8) + ';');
    Add('    IdleGradientFromColor := $' + IntToHex(FIdleGradientFromColor, 8) + ';');
    Add('    IdleGradientToColor := $' + IntToHex(FIdleGradientToColor, 8) + ';');
    Add('    IdleGradientType := ' + GetEnumName(TypeInfo(TBackgroundKind), ord(FIdleGradientType)) + ';');
    Add('    IdleInnerDarkColor := $' + IntToHex(FIdleInnerDarkColor, 8) + ';');
    Add('    IdleInnerLightColor := $' + IntToHex(FIdleInnerLightColor, 8) + ';');
    Add('    IdleCaptionColor := $' + IntToHex(FIdleCaptionColor, 8) + ';');

    Add('    HotTrackFrameColor := $' + IntToHex(FHotTrackFrameColor, 8) + ';');
    Add('    HotTrackGradientFromColor := $' + IntToHex(FHotTrackGradientFromColor, 8) + ';');
    Add('    HotTrackGradientToColor := $' + IntToHex(FHotTrackGradientToColor, 8) + ';');
    Add('    HotTrackGradientType := ' + GetEnumName(TypeInfo(TBackgroundKind), ord(FHotTrackGradientType)) + ';');
    Add('    HotTrackInnerDarkColor := $' + IntToHex(FHotTrackInnerDarkColor, 8) + ';');
    Add('    HotTrackInnerLightColor := $' + IntToHex(FHotTrackInnerLightColor, 8) + ';');
    Add('    HotTrackCaptionColor := $' + IntToHex(FHotTrackCaptionColor, 8) + ';');

    Add('    ActiveFrameColor := $' + IntToHex(FActiveFrameColor, 8) + ';');
    Add('    ActiveGradientFromColor := $' + IntToHex(FActiveGradientFromColor, 8) + ';');
    Add('    ActiveGradientToColor := $' + IntToHex(FActiveGradientToColor, 8) + ';');
    Add('    ActiveGradientType := ' + GetEnumName(TypeInfo(TBackgroundKind), ord(FActiveGradientType)) + ';');
    Add('    ActiveInnerDarkColor := $' + IntToHex(FActiveInnerDarkColor, 8) + ';');
    Add('    ActiveInnerLightColor := $' + IntToHex(FActiveInnerLightColor, 8) + ';');
    Add('    ActiveCaptionColor := $' + IntToHex(FActiveCaptionColor, 8) + ';');

    Add('    Style := ' + GetEnumName(TypeInfo(TSpkElementStyle), ord(FStyle)) + ';');
    Add('  end;');
  end;
end;

procedure TSpkElementAppearance.SaveToXML(Node: TSpkXMLNode);
var
  Subnode: TSpkXMLNode;
begin
  if not Assigned(Node) then
    exit;

  Subnode := Node['CaptionFont', true];
  TSpkXMLTools.Save(Subnode, FCaptionFont);

  // *** Idle ***
  Subnode := Node['IdleFrameColor', true];
  Subnode.TextAsColor := FIdleFrameColor;

  Subnode := Node['IdleGradientFromColor', true];
  Subnode.TextAsColor := FIdleGradientFromColor;

  Subnode := Node['IdleGradientToColor', true];
  Subnode.TextAsColor := FIdleGradientToColor;

  Subnode := Node['IdleGradientType', true];
  Subnode.TextAsInteger := integer(FIdleGradientType);

  Subnode := Node['IdleInnerLightColor', true];
  Subnode.TextAsColor := FIdleInnerLightColor;

  Subnode := Node['IdleInnerDarkColor', true];
  Subnode.TextAsColor := FIdleInnerDarkColor;

  Subnode := Node['IdleCaptionColor', true];
  Subnode.TextAsColor := FIdleCaptionColor;

  // *** Hottrack ***
  Subnode := Node['HottrackFrameColor', true];
  Subnode.TextAsColor := FHottrackFrameColor;

  Subnode := Node['HottrackGradientFromColor', true];
  Subnode.TextAsColor := FHottrackGradientFromColor;

  Subnode := Node['HottrackGradientToColor', true];
  Subnode.TextAsColor := FHottrackGradientToColor;

  Subnode := Node['HottrackGradientType', true];
  Subnode.TextAsInteger := integer(FHottrackGradientType);

  Subnode := Node['HottrackInnerLightColor', true];
  Subnode.TextAsColor := FHottrackInnerLightColor;

  Subnode := Node['HottrackInnerDarkColor', true];
  Subnode.TextAsColor := FHottrackInnerDarkColor;

  Subnode := Node['HottrackCaptionColor', true];
  Subnode.TextAsColor := FHottrackCaptionColor;

  // *** Active ***
  Subnode := Node['ActiveFrameColor', true];
  Subnode.TextAsColor := FActiveFrameColor;

  Subnode := Node['ActiveGradientFromColor', true];
  Subnode.TextAsColor := FActiveGradientFromColor;

  Subnode := Node['ActiveGradientToColor', true];
  Subnode.TextAsColor := FActiveGradientToColor;

  Subnode := Node['ActiveGradientType', true];
  Subnode.TextAsInteger := integer(FActiveGradientType);

  Subnode := Node['ActiveInnerLightColor', true];
  Subnode.TextAsColor := FActiveInnerLightColor;

  Subnode := Node['ActiveInnerDarkColor', true];
  Subnode.TextAsColor := FActiveInnerDarkColor;

  Subnode := Node['ActiveCaptionColor', true];
  Subnode.TextAsColor := FActiveCaptionColor;

  Subnode := Node['Style', true];
  Subnode.TextAsInteger := integer(FStyle);
end;

procedure TSpkElementAppearance.SetActiveCaptionColor(const Value: TColor);
begin
  FActiveCaptionColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetActiveFrameColor(const Value: TColor);
begin
  FActiveFrameColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetActiveGradientFromColor(const Value: TColor);
begin
  FActiveGradientFromColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetActiveGradientToColor(const Value: TColor);
begin
  FActiveGradientToColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetActiveGradientType(const Value: TBackgroundKind);
begin
  FActiveGradientType := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetActiveInnerDarkColor(const Value: TColor);
begin
  FActiveInnerDarkColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetActiveInnerLightColor(const Value: TColor);
begin
  FActiveInnerLightColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetCaptionFont(const Value: TFont);
begin
  FCaptionFont.assign(Value);
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackCaptionColor(const Value: TColor);
begin
  FHotTrackCaptionColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackFrameColor(const Value: TColor);
begin
  FHotTrackFrameColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackGradientFromColor(const Value: TColor);
begin
  FHotTrackGradientFromColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackGradientToColor(const Value: TColor);
begin
  FHotTrackGradientToColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackGradientType(const Value: TBackgroundKind);
begin
  FHotTrackGradientType := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackInnerDarkColor(const Value: TColor);
begin
  FHotTrackInnerDarkColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetHotTrackInnerLightColor(const Value: TColor);
begin
  FHotTrackInnerLightColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleCaptionColor(const Value: TColor);
begin
  FIdleCaptionColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleFrameColor(const Value: TColor);
begin
  FIdleFrameColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleGradientFromColor(const Value: TColor);
begin
  FIdleGradientFromColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleGradientToColor(const Value: TColor);
begin
  FIdleGradientToColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleGradientType(const Value: TBackgroundKind);
begin
  FIdleGradientType := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleInnerDarkColor(const Value: TColor);
begin
  FIdleInnerDarkColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetIdleInnerLightColor(const Value: TColor);
begin
  FIdleInnerLightColor := Value;
  if FDispatch<>nil then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkElementAppearance.SetStyle(const Value: TSpkElementStyle);
begin
  FStyle := Value;
  if FDispatch <> nil then
    FDispatch.NotifyAppearanceChanged;
end;

{ TSpkToolbarAppearanceDispatch }

constructor TSpkToolbarAppearanceDispatch.Create(
  AToolbarAppearance: TSpkToolbarAppearance);
begin
inherited Create;
FToolbarAppearance:=AToolbarAppearance;
end;

procedure TSpkToolbarAppearanceDispatch.NotifyAppearanceChanged;
begin
if FToolbarAppearance<>nil then
   FToolbarAppearance.NotifyAppearanceChanged;
end;

{ TSpkToolbarAppearance }

procedure TSpkToolbarAppearance.Assign(Source: TPersistent);

var Src : TSpkToolbarAppearance;

begin
  if Source is TSpkToolbarAppearance then
     begin
     Src:=TSpkToolbarAppearance(Source);

     self.FTab.assign(Src.Tab);
     self.FPane.assign(Src.Pane);
     self.FElement.Assign(Src.Element);

     if FDispatch<>nil then
        FDispatch.NotifyAppearanceChanged;
     end else
         raise AssignException.create('TSpkToolbarAppearance.Assign: Nie mogê przypisaæ obiektu '+Source.ClassName+' do TSpkToolbarAppearance!');
end;

constructor TSpkToolbarAppearance.Create(ADispatch : TSpkBaseAppearanceDispatch);
begin
  inherited Create;
  FDispatch:=ADispatch;
  FAppearanceDispatch:=TSpkToolbarAppearanceDispatch.Create(self);
  FTab:=TSpkTabAppearance.Create(FAppearanceDispatch);
  FPane:=TSpkPaneAppearance.create(FAppearanceDispatch);
  FElement:=TSpkElementAppearance.create(FAppearanceDispatch);
end;

destructor TSpkToolbarAppearance.Destroy;
begin
  FElement.Free;
  FPane.Free;
  FTab.Free;
  FAppearanceDispatch.Free;
  inherited;
end;

procedure TSpkToolbarAppearance.LoadFromXML(Node: TSpkXMLNode);

var Subnode : TSpkXMLNode;

begin
Tab.Reset;
Pane.Reset;
Element.Reset;

if not(assigned(Node)) then
   exit;

Subnode:=Node['Tab',false];
if assigned(Subnode) then
   Tab.LoadFromXML(Subnode);

Subnode:=Node['Pane',false];
if assigned(Subnode) then
   Pane.LoadFromXML(Subnode);

Subnode:=Node['Element',false];
if assigned(Subnode) then
   Element.LoadFromXML(Subnode);
end;

procedure TSpkToolbarAppearance.NotifyAppearanceChanged;
begin
  if assigned(FDispatch) then
     FDispatch.NotifyAppearanceChanged;
end;

procedure TSpkToolbarAppearance.Reset;
begin
  FTab.Reset;
  FPane.Reset;
  FElement.Reset;
  if assigned(FAppearanceDispatch) then
     FAppearanceDispatch.NotifyAppearanceChanged;
end;

procedure TSpkToolbarAppearance.SaveToPascal(AList: TStrings);
begin
  AList.Add('with Appearance do begin');
  FTab.SaveToPascal(AList);
  FPane.SaveToPascal(AList);
  FElement.SaveToPascal(AList);
  AList.ADd('end;');
end;

procedure TSpkToolbarAppearance.SaveToXML(Node: TSpkXMLNode);
var
  Subnode: TSpkXMLNode;
begin
  Subnode:=Node['Tab',true];
  FTab.SaveToXML(Subnode);

  Subnode:=Node['Pane',true];
  FPane.SaveToXML(Subnode);

  Subnode:=Node['Element',true];
  FElement.SaveToXML(Subnode);
end;

procedure TSpkToolbarAppearance.SetElementAppearance(
  const Value: TSpkElementAppearance);
begin
  FElement.assign(Value);
end;

procedure TSpkToolbarAppearance.SetPaneAppearance(const Value: TSpkPaneAppearance);
begin
  FPane.assign(Value);
end;

procedure TSpkToolbarAppearance.SetTabAppearance(const Value: TSpkTabAppearance);
begin
  FTab.assign(Value);
end;

procedure SetDefaultFont(AFont: TFont);
begin
  AFont.Assign(Screen.MenuFont);
  {
  if Screen.Fonts.IndexOf('Calibri') >= 0 then
  begin
    AFont.Name := 'Calibri';
    AFont.Size := 9;
  end
  else if Screen.Fonts.IndexOf('Verdana') >= 0 then
  begin
    AFont.Name := 'Verdana';
    AFont.Size := 8;
  end else
  begin
    AFont.Name := 'Arial';
    AFont.Size := 8;
  end;
  AFont.Style := [];
  AFont.Charset := DEFAULT_CHARSET;
  AFont.Orientation := 0;
  AFont.Pitch := fpDefault;
  }
  AFont.Color := rgb(21, 66, 139);
end;

end.
