{ This maker note reader can handle CANON and CASIO cameras. }

unit fpeMakerNoteCanonCasio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  fpeGlobal, fpeTags, fpeExifReadWrite;

type
  TCanonMakerNoteReader = class(TMakerNoteReader)
  protected
    function AddTag(AStream: TStream; const AIFDRecord: TIFDRecord;
      const AData: TBytes; AParent: TTagID): Integer; override;
    procedure GetTagDefs({%H-}AStream: TStream); override;
  end;

  TCasioMakerNoteReader = class(TMakerNoteReader)
  protected
    FVersion: Integer;
    procedure GetTagDefs({%H-}AStream: TStream); override;
    function Prepare(AStream: TStream): Boolean; override;
  end;


implementation

uses
  fpeStrConsts, fpeUtils, fpeExifData;

resourcestring
  // Canon
  rsCanonAELkup = '0:Normal AE,1:Exposure compensation,2:AE lock,'+
    '3:AE lock + Exposure compensation,4:No AE';
  {
  rsCanonAFLkup = '12288:None (MF),12289:Auto-selected,12290:Right,12291:Center,'+
    '12292:Left';
    }
  rsCanonAFLkup = '$2005:Manual AF point selection,$3000:None (MF),' +
    '$3001:Auto AF point selection,$3002:Right,$3003:Center,$3004:Left,' +
    '$4001:Auto AF point selection,$4006:Face Detect';
  rsCanonAutoRotLkup = '0:None,1:Rotate 90 CW,2:Rotate 180,3:Rotate 270 CW';
  rsCanonBiasLkup = '65472:-2 EV,65484:-1.67 EV,65488:-1.50 EV,65492:-1.33 EV,'+
    '65504:-1 EV,65516:-0.67 EV,65520:-0.50 EV,65524:-0.33 EV,0:0 EV,'+
    '12:0.33 EV,16:0.50 EV,20:0.67 EV,32:1 EV,44:1.33 EV,48:1.50 EV,'+
    '52:1.67 EV,64:2 EV';
  rsCanonCamTypeLkup = '248:EOS High-end,250:Compact,252:EOS Mid-range,255:DV Camera';
  rsCanonEasyLkup = '0:Full Auto,1:Manual,2:Landscape,3:Fast Shutter,4:Slow Shutter,'+
    '5:Night,6:Gray scale,7:Sepia,8:Portrait,9:Sports,10:Macro,11:Black & White,'+
    '12:Pan Focus,13:Vivid,14:Neutral,15:Flash off,16:Long shutter,'+
    '17:Super macro,18:Foliage,19:Indoor,20:Fireworks,21:Beach,22:Underwater,'+
    '23:Snow,24:Kids & Pets,25:Night snapshot,26:Digital macro,27:My colors,'+
    '28:Movie snap,29:Super macro 2,30:Color accent,31:Color swap,32:Aquarium,'+
    '33:ISO3200,34:ISO6400,35:Creative light effect,36:Easy,37:Quick shot,'+
    '38:Creative auto,39:Zoom blur,40:Low light,41:Nostalgic,42:Super vivid,'+
    '43:Poster effect,44:Face self-timer,45:Smile,46:Wink self-timer,'+
    '47:Fisheye effect,48:Miniature effect,49:High-speed burst,'+
    '50:Best image selection,51:High dynamic range,52:Handheld night scene,'+
    '53:Movie digest,54:Live view control,55:Discreet,56:Blur reduction,'+
    '57:Monochrome,58:Toy camera effect,59:Scene intelligent auto,'+
    '60:High-speed burst HQ,61:Smooth skin,62:Soft focus,257:Spotlight,'+
    '258:Night 2,259:Night+,260:Super night,261:Sunset,263:Night scene,'+
    '264:Surface,265:Low light 2';
  rsCanonExposeLkup = '0:Easy shooting,1:Program AE,2:Shutter speed priority AE,'+
    '3:Aperture priority AE,4:Manual,5:Depth-of-field AE,6:M-Dep,7:Bulb';
  rsCanonFlashActLkup = '0:Did not fire,1:Fired';
  rsCanonFlashLkup = '0:Not fired,1:Auto,2:On,3:Red-eye,4:Slow sync,'+
    '5:Auto+red-eye,6:On+red eye,16:External flash';
  rsCanonFocalTypeLkup = '1:Fixed,2:Zoom';
  rsCanonFocTypeLkup = '0:Manual,1:Auto,3:Close-up (macro),8:Locked (pan mode)';
  rsCanonFocusLkup = '0:One-Shot AF,1:AI Servo AF,2:AI Focus AF,3:Manual focus,'+
    '4:Single,5:Continuous,6:Manual focus,16:Pan focus,256:AF+MF,'+
    '512:Movie snap focus,519:Movie servo AF';
  rsCanonGenLkup = '65535:Low,0:Normal,1:High';
  rsCanonImgStabLkup = '0:Off,1:On,2:Shoot only,3:Panning,4:Dynamic,256:Off,'+
    '257:On,258:Shoot only,259:Panning,260:Dynamic';
  rsCanonISOLkup = '0:Not used,15:auto,16:50,17:100,18:200,19:400';
  rsCanonMacroLkup = '1:Macro,2:Normal';
  rsCanonMeterLkup = '0:Default,1:Spot,2:Average,3:Evaluative,4:Partial,'+
    '5:Center-weighted average';
  rsCanonPanDirLkup = '0:Left to right,1:Right to left,2:Bottom to top,'+
    '3:Top to bottom,4:2x2 Matrix (clockwise)';
  rsCanonQualityLkup = '65535:n/a,1:Economy,2:Normal,3:Fine,4:RAW,5:Superfine,'+
    '130:Normal Movie,131:Movie (2)';
  rsCanonRecLkup = '1:JPEG,2:CRW+THM,3:AVI+THM,4:TIF,5:TIF+JPEG,6:CR2,'+
    '7:CR2+JPEG,9:MOV,10:MP4';
  rsCanonSizeLkup = '65535:n/a,0:Large,1:Medium,2:Small,4:5 MPixel,5:2 MPixel,'+
    '6:1.5 MPixel,8:Postcard,9:Widescreen,10:Medium widescreen,14:Small 1,'+
    '15:Small 2,16:Small 3,128:640x480 movie,129:Medium movie,130:Small movie,'+
    '137:128x720 movie,142:1920x1080 movie';
  rsCanonSloShuttLkup = '65535:n/a,0:Off,1:Night scene,2:On,3:None';
  rsCanonWhiteBalLkup = '0:Auto,1:Daylight,2:Cloudy,3:Tungsten,4:Flourescent,'+
    '5:Flash,6:Custom,7:Black & white,8:Shade,9:Manual temperature (Kelvin),'+
    '14:Daylight fluorescent,17:Under water';
  rsCanonZoomLkup = '0:None,1:2x,2:4x,3:Other';

  // Casio
  rsCasioAFMode2Lkup = '0:Off,1:Spot,2:Multi,3:Face detection,4:Tracking,5:Intelligent';
  rsCasioArtMode2Lkup = '0:Normal,8:Silent movie,39:HDR,45:Premium auto,' +
    '47:Painting,49:Crayon drawing,51:Panorama,52:Art HDR,62:High Speed night shot,'+
    '64:Monochrome,67:Toy camera,68:Pop art,69:Light tone';
  rsCasioAutoIso2Lkup = '1:On,2:Off,7:On (high sensitivity),8:On (anti-shake),'+
    '10:High Speed';
  rsCasioCCDSensitivityLkup = '64:Normal,125:+1.0,250:+2.0,244:+3.0,80:Normal,'+
    '100:High';
  rsCasioColorFilter2Lkup = '0:Off,1:Blue,3:Green,4:Yellow,5:Red,6:Purple,7:Pink';
  rsCasioColorMode2Lkup = '0:Off,2:Black & White,3:Sepia';
  rsCasioDigitalZoomLkup = '$10000:Off,$10001:2x Digital zoom,'+
    '$20000:2x digital zoom,$40000:4x digital zoom';
  rsCasioDriveMode2Lkup = '0:Single shot,1:Continuous shooting,'+
    '2:Continuous (2 fps),3:Continuous (3 fps),4:Continuous (4 fps),'+
    '5:Continuous (5 fps),6:Continuous (6 fps),7:Continuous (7 fps),'+
    '10:Continuous (10 fps),12:Continuous (12 fps),15:Continuous (15 fps),'+
    '20:Continuous (20 fps),30:Continuous (30 fps),40:Continuous (40 fps),'+
    '60:Continuous (60 fps),240:Auto-N';
  rsCasioEnhancement2Lkup = '0:Off,1:Scenery,3:Green,5:Underwater,9:Flesh tones';
  rsCasioFlashIntensityLkup = '11:Weak,13:Normal,15:Strong';
  rsCasioFlashModeLkup = '1:Auto,2:On,3:Off,4:Red-eye reduction';
  rsCasioFocusingModeLkup = '2:Macro,3:Auto focus,4:Manual focus,5:Infinity';
  rsCasioFocusMode2Lkup = '0:Normal,1:Macro';
  rsCasioFocusMode22Lkup = '0:Manual,1:Focus lock,2:Macro,3:Single-area auto focus,'+
    '5:Infinity,6:Multi-area auto focus,8:Super macro';
  rsCasioImageSize2Lkup = '0:640 x 480,4:1600 x 1200,5:2048 x 1536,'+
    '20:2288 x 1712,21:2592 x 1944,22:2304 x 1728,36:3008 x 2008';
  rsCasioImageStabilization2Lkup = '0:Off,1:On,2:Best shot,3:Movie anti-shake';
  rsCasioISOSpeed2Lkup = '3 = 50,4:64,6:100,9:200';
  rsCasioLightingMode2Lkup = '0:Off,1:High dynamic range,5:Shadow enhance low,'+
    '6:Shadow enhance high';
  rsCasioPortraitRefiner2Lkup = '0:Off,1:+1,2:+2';
  rsCasioRecordingModeLkup = '1:Single shutter,2:Panorama,3:Night scene,'+
    '4:Portrait,5:Landscape';
  rsCasioRecordMode2Lkup = '2:Program AE,3:Shutter priority,4:Aperture priority,'+
    '5:Manual,6:Best shot,17:Movie,19:Movie (19),20:YouTube Movie';
  rsCasioReleaseMode2Lkup = '1:Normal,3:AE Bracketing,11:WB Bracketing,'+
    '13 = Contrast Bracketing,19:High Speed Burst';
  rsCasioSharpness2Lkup = '0:Soft,1:Normal,2:Hard';
  rsCasioSpecialEffectSetting2Lkup = '0:Off,1:Makeup,2:Mist removal,'+
    '3:Vivid landscape,16:Art shot';
  rsCasioVideoQuality2Lkup = '1:Standard,3:HD (720p),4:Full HD (1080p),5:Low';
  rsCasioWhiteBalanceLkup = '1:Auto,2:Tungsten,3:Daylight,4:Fluorescent,'+
    '5:Shade,129:Manual';
  rsCasioWhiteBalance2Lkup = '0:Auto,1:Daylight,2:Shade,3:Tungsten,4:Fluorescent,5:Manual';
  rsCasioWhiteBalance22Lkup = '0:Manual,1:Daylight,2:Cloudy,3:Shade,4:Flash?,'+
    '6:Fluorescent,9:Tungsten?,10:Tungsten,12:Flash';

const
  M = DWord(TAGPARENT_MAKERNOTE);

procedure BuildCanonTagDefs(AList: TTagDefList);
begin
  Assert(AList <> nil);
  with AList do begin
    AddUShortTag(M+$0001, 'ExposureInfo1');
    AddUShortTag(M+$0002, 'Panorama');
    AddUShortTag(M+$0004, 'ExposureInfo2');
    AddStringTag(M+$0006, 'ImageType');
    AddStringTag(M+$0007, 'FirmwareVersion');
    AddULongTag (M+$0008, 'ImageNumber');
    AddStringTag(M+$0009, 'OwnerName');
    AddULongTag (M+$000C, 'CameraSerialNumber');
    AddUShortTag(M+$000F, 'CustomFunctions');
  end;
end;

{ Casio Type 1
  Standard TIFF IFD Data using Casio Type 1 Tags but always uses
  Motorola (Big-Endian) byte alignment
  This makernote has no header - the IFD starts immediately
  Ref.: http://www.ozhiker.com/electronics/pjmt/jpeg_info/casio_mn.html }
procedure BuildCasio1TagDefs(AList: TTagDefList);
begin
  Assert(AList <> nil);
  with AList do begin
    AddUShortTag(M+$0001, 'RecordingMode',  1, '', rsCasioRecordingModeLkup);
    AddUShortTag(M+$0002, 'Quality',        1, '', rsEconomyNormalFine1);
    AddUShortTag(M+$0003, 'FocusingMode',   1, '', rsCasioFocusingModeLkup);
    AddUShortTag(M+$0004, 'FlashMode',      1, '', rsCasioFlashModeLkup);
    AddUShortTag(M+$0005, 'FlashIntensity', 1, '', rsCasioFlashIntensityLkup);
    AddULongTag (M+$0006, 'ObjectDistance', 1, '', '', '%d mm');
    AddUShortTag(M+$0007, 'WhiteBalance',   1, '', rsCasioWhiteBalanceLkup);
    AddULongTag (M+$000A, 'DigitalZoom',    1, '', rsCasioDigitalZoomLkup);
    AddUShortTag(M+$000B, 'Sharpness',      1, '', rsNormalSoftHard);
    AddUShortTag(M+$000C, 'Contrast',       1, '', rsNormalLowHigh);
    AddUShortTag(M+$000D, 'Saturation',     1, '', rsNormalLowHigh);
    AddUShortTag(M+$000A, 'DigitalZoom',    1, '', rsCasioDigitalZoomLkup);
    AddUShortTag(M+$0014, 'CCDSensitivity', 1, '', rsCasioCCDSensitivityLkup);
  end;
end;

{ Case Type 2
  Header: 6 Bytes "QVC\x00\x00\x00"
  IFD Data: Standard TIFF IFD Data using Casio Type 2 Tags but always uses
  Motorola (Big-Endian) Byte Alignment.
  All EXIF offsets are relative to the start of the TIFF header at the
  beginning of the EXIF segment
  Ref.: http://www.ozhiker.com/electronics/pjmt/jpeg_info/casio_mn.html
        http://www.exiv2.org/tags-casio.html
        https://sno.phy.queensu.ca/~phil/exiftool/TagNames/Casio.html#Type2
}
procedure BuildCasio2TagDefs(AList: TTagDefList);
begin
  Assert(AList <> nil);
  with AList do begin
    AddUShortTag   (M+$0002, 'PreviewImageSize', 2);   // width and height, in pixels
    AddULongTag    (M+$0003, 'PreviewImageLength');
    AddULongTag    (M+$0004, 'PreviewImageStart');
    AddUShortTag   (M+$0008, 'QualityMode', 1, '', rsEconomyNormalFine);
    AddUShortTag   (M+$0009, 'ImageSize', 1, '', rsCasioImageSize2Lkup);
    AddUShortTag   (M+$000D, 'FocusMode', 1, '', rsCasioFocusMode2Lkup);
    AddUShortTag   (M+$0014, 'ISOSpeed', 1, '', rsCasioISOSpeed2Lkup);
    AddUShortTag   (M+$0019, 'WhiteBalance', 1, '', rsCasioWhiteBalance2Lkup);
    AddURationalTag(M+$001D, 'FocalLength');
    AddUShortTag   (M+$001F, 'Saturation', 1, '', rsLowNormalHigh);
    AddUShortTag   (M+$0020, 'Contrast', 1, '', rsLowNormalHigh);
    AddUShortTag   (M+$0021, 'Sharpness', 1, '', rsCasioSharpness2Lkup);
    AddBinaryTag   (M+$0E00, 'PrintIM');
    AddBinaryTag   (M+$2000, 'PreviewImage');
    AddStringTag   (M+$2001, 'FirwareDate', 18);
    AddUShortTag   (M+$2011, 'WhiteBalanceBias', 2);
    AddUShortTag   (M+$2012, 'WhiteBalance2', 2, '', rsCasioWhiteBalance22Lkup);
    AddUShortTag   (M+$2021, 'AFPointPosition', 4);
    AddULongTag    (M+$2022, 'ObjectDistance');
    AddUShortTag   (M+$2034, 'FlashDistance');
    AddByteTag     (M+$2076, 'SpecialEffectMode', 3);  // to do: array lkup - should be: '0 0 0' = Off,'1 0 0' = Makeup,'2 0 0' = Mist Removal,'3 0 0' = Vivid Landscape
    AddBinaryTag   (M+$2089, 'FaceInfo');
    AddByteTag     (M+$211C, 'FacesDetected');
    AddUShortTag   (M+$3000, 'RecordMode', 1, '', rsCasioRecordMode2Lkup);
    AddUShortTag   (M+$3001, 'ReleaseMode', 1, '', rsCasioReleaseMode2Lkup);
    AddUShortTag   (M+$3002, 'Quality', 1, '', rsEconomyNormalFine1);
    AddUShortTag   (M+$3003, 'FocusMode2', 1, '', rsCasioFocusMode2Lkup);
    AddStringTag   (M+$3006, 'HometownCity');
    AddUShortTag   (M+$3007, 'BestShotMode');  // Lkup depends severly on camera model
    AddUShortTag   (M+$3008, 'AutoISO', 1, '', rsCasioAutoIso2Lkup);
    AddUShortTag   (M+$3009, 'AFMode', 1, '', rsCasioAFMode2Lkup);
    AddBinaryTag   (M+$3011, 'Sharpness2');
    AddBinaryTag   (M+$3012, 'Contrast2');
    AddBinaryTag   (M+$3013, 'Saturation2');
    AddUShortTag   (M+$3014, 'ISO');
    AddUShortTag   (M+$3015, 'ColorMode', 1, '', rsCasioColorMode2Lkup);
    AddUShortTag   (M+$3016, 'Enhancement', 1, '', rsCasioEnhancement2Lkup);
    AddUShortTag   (M+$3017, 'ColorFilter', 1, '', rsCasioColorFilter2Lkup);
    AddUShortTag   (M+$301B, 'ArtMode', 1, '', rsCasioArtMode2Lkup);
    AddUShortTag   (M+$301C, 'SequenceNumber');
    AddUShortTag   (M+$301D, 'BracketSequence', 2);
    AddUShortTag   (M+$3020, 'ImageStabilization', 1, '', rsCasioImageStabilization2Lkup);
    AddUShortTag   (M+$302A, 'LightingMode', 1, '', rsCasioLightingMode2Lkup);
    AddUShortTag   (M+$302B, 'PortraitRefiner', 1, '', rsCasioPortraitRefiner2Lkup);
    AddUShortTag   (M+$3030, 'SpecialEffectLevel');
    AddUShortTag   (M+$3031, 'SpecialEffectSetting', 1, '', rsCasioSpecialEffectSetting2Lkup);
    AddUShortTag   (M+$3103, 'DriveMode', 1, '', rsCasioDriveMode2Lkup);
    AddBinaryTag   (M+$310B, 'ArtModeParameters', 3);
    AddUShortTag   (M+$4001, 'CaptureFrameRate');
    AddUShortTag   (M+$4003, 'VideoQuality', 1, '', rsCasioVideoQuality2Lkup);

    // to do...
  end;
end;


//==============================================================================
//                         TCanonMakerNoteReader
//==============================================================================

function TCanonMakerNoteReader.AddTag(AStream: TStream;
  const AIFDRecord: TIFDRecord; const AData: TBytes; AParent: TTagID): Integer;
var
  tagDef: TTagDef;
  w: array of Word;
  n,i: Integer;
  t: TTagID;
begin
  Result := -1;

  tagDef := FindTagDef(AIFDRecord.TagID or AParent);
  if (tagDef = nil) then
    exit;

  Result := inherited AddTag(AStream, AIFDRecord, AData, AParent);

  // We only handle 16-bit integer types here for further processing
  if not (tagDef.TagType in [ttUInt16, ttSInt16]) then
    exit;

  // Put binary data into a word array and fix endianness
  n := Length(AData) div TagElementSize[ord(tagDef.TagType)];
  if n = 0 then
    exit;

  if FBigEndian then
    for i:=0 to n-1 do AData[i] := BEtoN(AData[i])
  else
    for i:=0 to n-1 do AData[i] := LEtoN(AData[i]);
  SetLength(w, n);
  Move(AData[0], w[0], Length(AData));

  // This is a special treatment of array tags which will be added as
  // separate "MakerNote" tags.
  t := AIFDRecord.TagID;
  case AIFDRecord.TagID of
    1:   // Exposure Info 1
      with FImgInfo.ExifData do begin
        AddMakerNoteTag( 1, t, 'Macro mode',          w[1],  rsCanonMacroLkup);
        if n = 2 then exit;
        AddMakerNoteTag( 2, t, 'Self-timer',          w[2]/10, '%2:.1f s');
        if n = 3 then exit;
        AddMakerNoteTag( 3, t, 'Quality',             w[3],  rsCanonQualityLkup);
        if n = 4 then exit;
        AddMakerNoteTag( 4, t, 'Flash mode',          w[4],  rsCanonFlashLkup);
        if n = 5 then exit;
        AddMakerNoteTag( 5, t, 'Drive mode',          w[5],  rsSingleContinuous);
        if n = 7 then exit;
        AddMakerNoteTag( 7, t, 'Focus mode',          w[7],  rsCanonFocusLkup);
        if n = 9 then exit;
        AddMakerNoteTag( 9, t, 'Record mode',         w[9],  rsCanonRecLkup);
        if n = 10 then exit;
        AddMakerNoteTag(10, t, 'Image size',          w[10], rsCanonSizeLkup);
        if n = 11 then exit;
        AddMakerNoteTag(11, t, 'Easy shoot',          w[11], rsCanonEasyLkup);
        if n = 12 then exit;
        AddMakerNoteTag(12, t, 'Digital zoom',        w[12], rsCanonZoomLkup);
        if n = 13 then exit;
        AddMakerNoteTag(13, t, 'Contrast',            w[13], rsCanonGenLkup);
        if n = 14 then exit;
        AddMakerNoteTag(14, t, 'Saturation',          w[14], rsCanonGenLkup);
        if n = 15 then exit;
        AddMakerNoteTag(15, t, 'Sharpness',           w[15], rsCanonGenLkup);
        if n = 16 then exit;
        AddMakerNoteTag(16, t, 'CCD ISO',             w[16], rsCanonISOLkup);
        if n = 17 then exit;
        AddMakerNoteTag(17, t, 'Metering mode',       w[17], rsCanonMeterLkup);
        if n = 18 then exit;
        AddMakerNoteTag(18, t, 'Focus type',          w[18], rsCanonFocTypeLkup);
        if n = 19 then exit;
        AddMakerNoteTag(19, t, 'AFPoint',             w[19], rsCanonAFLkup);
        if n = 20 then exit;
        AddMakerNoteTag(20, t, 'Exposure mode',       w[20], rsCanonExposeLkup);
        if n = 24 then exit;
        AddMakerNoteTag(24, t, 'Long focal',          w[24]);
        if n = 25 then exit;
        AddMakerNoteTag(25, t, 'Short focal',         w[25]);
        if n = 26 then exit;
        AddMakerNoteTag(26, t, 'Focal units',         w[26]);
        if n = 28 then exit;
        AddMakerNoteTag(28, t, 'Flash activity',      w[28], rsCanonFlashActLkup);
        if n = 29 then exit;
        AddMakerNoteTag(29, t, 'Flash details',       w[29]);
        if n = 32 then exit;
        AddMakerNoteTag(32, t, 'Focus mode',          w[32], rsSingleContinuous);
        if n = 33 then exit;
        AddMakerNoteTag(33, t, 'AESetting',           w[33], rsCanonAELkup);
        if n = 34 then exit;
        AddMakerNoteTag(34, t, 'Image stabilization', w[34], rsSingleContinuous);
      end;
    2:  // Focal length
      with FImgInfo.ExifData do begin
        AddMakerNoteTag(0, t, 'FocalType',           w[0],  rsCanonFocalTypeLkup);
        if n = 1 then exit;
        AddMakerNoteTag(1, t, 'FocalLength',         w[1]);
      end;
    4:  // ExposureInfo2
      with FImgInfo.ExifData do begin
        if n = 7 then exit;
        AddMakerNoteTag( 7, t, 'WhiteBalance',        w[7], rsCanonWhiteBalLkup);
        if n = 8 then exit;
        AddMakerNoteTag( 8, t, 'Slow shutter',        w[8], rsCanonSloShuttLkup);
        if n = 9 then exit;
        AddMakerNoteTag( 9, t, 'SequenceNumber',      w[9]);
        if n = 11 then exit;
        AddMakerNoteTag(11, t, 'OpticalZoomStep',     w[11]);
        if n = 12 then exit;
        AddMakerNoteTag(12, t, 'Camera temperature',  w[12]);
        if n = 14 then exit;
        AddMakerNoteTag(14, t, 'AFPoint',             w[14]);
        if n = 15 then exit;
        AddMakerNoteTag(15, t, 'FlashBias',           w[15], rsCanonBiasLkup);
        if n = 19 then exit;
        AddMakerNoteTag(19, t, 'Distance',            w[19]);
        if n = 21 then exit;
        AddMakerNoteTag(21, t, 'FNumber',             w[21]);
        if n = 22 then exit;
        AddMakerNoteTag(22, t, 'Exposure time',       w[22]);
        if n = 23 then exit;
        AddMakerNoteTag(23, t, 'Measured EV2',        w[23]);
        if n = 24 then exit;
        AddMakerNoteTag(24, t, 'Bulb duration',       w[24]);
        if n = 26 then exit;
        AddMakerNoteTag(26, t, 'Camera type',         w[26], rsCanonCamTypeLkup);
        if n = 27 then exit;
        AddMakerNoteTag(27, t, 'Auto rotation',       w[27], rsCanonAutoRotLkup);
        if n = 28 then exit;
        AddMakerNoteTag(28, t, 'NDFilter',           w[28], rsCanonGenLkup);
      end;
    5:  // Panorma
      with FImgInfo.ExifData do begin
        if n = 2 then exit;
        AddMakerNoteTag(2, t, 'Panorama frame number', w[2]);
        if n = 5 then exit;
        AddMakerNoteTag(5, t, 'Panorama direction',    w[5], rsCanonPanDirLkup);
      end;
  end;
end;

procedure TCanonMakerNoteReader.GetTagDefs(AStream: TStream);
begin
  if Uppercase(FMake) = 'CANON' then
    BuildCanonTagDefs(FTagDefs);
end;


//==============================================================================
//                            TCasioMakerNoteReader
//==============================================================================

function TCasioMakerNoteReader.Prepare(AStream: TStream): Boolean;
var
  p: Int64;
  hdr: Array[0..5] of ansichar;
begin
  Result := false;

  p := AStream.Position;
  AStream.Read({%H-}hdr[0], SizeOf(hdr));
  if (hdr[0] = 'Q') and (hdr[1] = 'V') and (hdr[2] = 'C') and
     (hdr[3] = #0)  and (hdr[4] = #0)  and (hdr[5] = #0)
  then begin
    FVersion := 2;
    BuildCasio2TagDefs(FTagDefs);
    AStream.Position := p + SizeOf(hdr);
  end else
  begin
    FVersion := 1;
    BuildCasio1TagDefs(FTagDefs);
    AStream.Position := p;
  end;

  FBigEndian := true;
  Result := true;
end;

procedure TCasioMakerNoteReader.GetTagDefs(AStream: TStream);
begin
  if Uppercase(FMake) = 'CASIO' then
    BuildCasio1TagDefs(FTagDefs);
end;


initialization
  RegisterMakerNoteReader(TCanonMakerNoteReader,   'Canon;Casio',   '');

end.

