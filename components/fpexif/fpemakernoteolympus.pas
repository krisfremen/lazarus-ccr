unit fpeMakerNoteOlympus;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  fpeGlobal, fpeTags, fpeExifReadWrite;

type
  TOlympusMakerNoteReader = class(TMakerNoteReader)
  protected
    FVersion: Integer;
    procedure GetTagDefs({%H-}AStream: TStream); override;
    function Prepare(AStream: TStream): Boolean; override;
  end;

implementation

uses
  fpeStrConsts, fpeUtils, fpeExifData;

resourcestring
  // Olympus
  rsOlympusCCDScanModeLkup = '0:Interlaced,1:Progressive';
  rsOlympusContrastLkup = '0:High,1:Normal,2:Low';
  rsOlympusFlashDevLkup = '0:None,1:Internal,4:External,5:Internal + External';
  rsOlympusFlashModeLkup = '2:On,3;Off';
  rsOlympusFlashModelLkup = '0:None,1:FL-20,2:FL-50,3:RF-11,4:TF-22,5:FL-36,'+
    '6:FL-50R,7:FL-36R,9:FL-14,11:FL-600R';
  rsOlympusFlashTypeLkup = '0:None,2:Simple E-System,3:E-System';
  rsOlympusJpegQualLkup = '1:SQ,2:HQ,3:SHQ,4:Raw';
  rsOlympusMacroLkup = '0:Off,1:On,2:Super Macro';
  rsOlympusPreviewImgLength = 'Preview image length';
  rsOlympusPreviewImgStart = 'Preview image start';
  rsOlympusPreviewImgValid = 'Preview image valid';
  rsOlympusSharpnessLkup = '0:Normal,1:Hard,2:Soft';
  rsOlympusSceneModeLkup = '0:Normal,1:Standard,2:Auto,3:Intelligent Auto,' +
    '4:Portrait,5:Landscape+Portrait,6:Landscape,7:Night Scene,8:Night+Portrait' +
    '9:Sport,10:Self Portrait,11:Indoor,12:Beach & Snow,13:Beach,14:Snow,' +
    '15:Self Portrait+Self Timer,16:Sunset,17:Cuisine,18:Documents,19:Candle,' +
    '20:Fireworks,21:Available Light,22:Vivid,23:Underwater Wide1,24:Underwater Macro,' +
    '25:Museum,26:Behind Glass,27:Auction,28:Shoot & Select1,29:Shoot & Select2,'+
    '30:Underwater Wide2,31:Digital Image Stabilization,32:Face Portrait,33:Pet,'+
    '34:Smile Shot,35:Quick Shutter,43:Hand-held Starlight,100:Panorama,'+
    '101:Magic Filter,103:HDR';


// Most from https://sno.phy.queensu.ca/~phil/exiftool/TagNames/Olympus.html
// some from dExif
const
   E = $2010 shl 16;  // Equipment version
   C = $2011 shl 16;  // Camera settings

procedure BuildOlympusTagDefs(AList: TTagDefList);
const
  M = DWord(TAGPARENT_MAKERNOTE);
begin
  Assert(AList <> nil);
  with AList do begin
    AddBinaryTag   (M+$0000, 'Version', 4, '', '', '', TVersionTag);

    { Stores all settings which were in effect when taking the picture.
      Details depend on camera. }
    AddBinaryTag   (M+$0001, 'MinoltaCameraSettingsOld'); //, $FFFF, '', '', '', TSubIFDTag, true);
    AddBinaryTag   (M+$0003, 'MinoltaCameraSettings'); //, $FFFF, '', '', '', TSubIFDTag, false);

    // this is the size of the JPEG (compressed) or TIFF or RAW file.
    AddULongTag    (M+$0040, 'CompressedImageSize');

    { Stores the thumbnail image (640×480). It is in normal JFIF format but the
      first byte should be changed to 0xFF. Beware! Sometimes the thumbnail
      is not stored in the file and this tag points beyond the end of the file. }
    AddBinaryTag   (M+$0081, 'ReviewImage');

    { The cameras D7u, D7i and D7Hi no longer store the thumbnail inside the tag.
      It has instead two tags describing the position of the thumbnail in the
      file and its size }
    AddULongTag    (M+$0088, 'PreviewImageStart');
    AddULongTag    (M+$0089, 'PreviewImageLength');

    AddULongTag    (M+$0200, 'SpecialMode',      3);
    AddUShortTag   (M+$0201, 'JpegQuality',      1, '', rsOlympusJpegQualLkup);
    AddUShortTag   (M+$0202, 'Macro',            1, '', rsOlympusMacroLkup);
    AddURationalTag(M+$0204, 'DigitalZoom');
//    AddUShortTag   (M+$0207, 'Firmware');
    AddStringTag   (M+$9207, 'CameraType');
    AddStringTag   (M+$0208, 'PictureInfo');
    AddStringTag   (M+$0209, 'CameraID');
    AddUShortTag   (M+$020B, 'EpsonImageWidth');
    AddUShortTag   (M+$020C, 'EpsonImageHeight');
    AddStringTag   (M+$020D, 'EpsonSoftware');
    AddUShortTag   (M+$0403, 'SceneMode',        1, '', rsOlympusSceneModeLkup);
    AddStringTag   (M+$0404, 'SerialNumber');
    AddStringTag   (M+$0405, 'Firmware');
    AddSRationalTag(M+$1000, 'ShutterSpeedValue');
    AddSRationalTag(M+$1001, 'ISOValue');
    AddSRationalTag(M+$1002, 'ApertureValue');
    AddSRationalTag(M+$1003, 'BrightnessValue');
    AddUShortTag   (M+$1004, 'FlashMode',        1, '', rsOlympusFlashModeLkup);
    AddUShortTag   (M+$1005, 'FlashDevice',      1, '', rsOlympusFlashDevLkup);
    AddURationalTag(M+$1006, 'Bracket');
    AddSShortTag   (M+$1007, 'SensorTemperature');
    AddSShortTag   (M+$1008, 'LensTemperature');
    AddUShortTag   (M+$100B, 'FocusMode',        1, '', rsAutoManual);
    AddURationalTag(M+$100C, 'FocusDistance');
    AddUShortTag   (M+$100D, 'ZoomStepCount');
    AddUShortTag   (M+$100E, 'FocusStepCount');
    AddUShortTag   (M+$100F, 'Sharpness',        1, '', rsOlympusSharpnessLkup);
    AddUShortTag   (M+$1010, 'FlashChargeLevel');
    AddUShortTag   (M+$1011, 'ColorMatrix',      9);
    AddUShortTag   (M+$1012, 'BlackLevel',       4);
    AddUShortTag   (M+$1015, 'WhiteBalanceMode', 2);
    AddUShortTag   (M+$1017, 'RedBalance',       2);
    AddUShortTag   (M+$1018, 'BlueBalance',      2);
    AddStringTag   (M+$101A, 'SerialNumber');
    AddURationalTag(M+$1023, 'FlashBias');
    AddUShortTag   (M+$1029, 'Contrast',         1, '', rsOlympusContrastLkup);
    AddUShortTag   (M+$102A, 'SharpnessFactor');
    AddUShortTag   (M+$102B, 'ColorControl',     6);
    AddUShortTag   (M+$102C, 'ValidBits',        2);
    AddUShortTag   (M+$102D, 'CoringFilter');
    AddULongTag    (M+$102E, 'FinalWidth');
    AddULongTag    (M+$102F, 'FinalHeight');
    AddUShortTag   (M+$1030, 'SceneDetect');
    AddULongTag    (M+$1031, 'SceneArea',        8);
    AddURationalTag(M+$1034, 'CompressionRatio');
    AddUShortTag   (M+$1038, 'AFResult');
    AddUShortTag   (M+$1039, 'CCDScanMode',      1, '', rsOlympusCCDScanModeLkup);
    AddUShortTag   (M+$103A, 'NoiseReduction',   1, '', rsOffOn);
    AddUShortTag   (M+$103B, 'FocusStepInfinity');
    AddUShortTag   (M+$103C, 'FocusStepNear');
    AddSRationalTag(M+$103D, 'LightValueCenter');
    AddSRationalTag(M+$103E, 'LightValuePeriphery');
    AddIFDTag      (M+$2010, 'Equipment',        '', TSubIFDTag);
    AddIFDTag      (M+$2011, 'CameraSettings',   '', TSubIFDTag);

    // Olympus Equipment Tags
    AddBinaryTag   (E+$0000, 'EquipmentVersion', 4, '', '', '', TVersionTag);
    AddStringTag   (E+$0100, 'CameraType', 6);
    AddStringTag   (E+$0101, 'SerialNumber', 32);
    AddStringTag   (E+$0102, 'InternalSerialNumber', 32);
    AddURationalTag(E+$0103, 'FocalPlaneDiagonal');
    AddULongTag    (E+$0104, 'BodyFirmwareVersion');
    AddByteTag     (E+$0201, 'LensType', 6);
    AddStringTag   (E+$0202, 'LensSerialNumber', 32);
    AddStringTag   (E+$0203, 'LensModel');
    AddULongTag    (E+$0204, 'LensFirmwareVersion');
    AddUShortTag   (E+$0205, 'MaxApertureAtMinFocal');
    AddUShortTag   (E+$0206, 'MaxApertureAtMaxFocal');
    AddUShortTag   (E+$0207, 'MinFocalLength');
    AddUShortTag   (E+$0208, 'MaxFocalLength');
    AddUShortTag   (E+$020A, 'MaxAperture');
    AddUShortTag   (E+$020B, 'LensProperties');
    AddByteTag     (E+$0301, 'Extender', 6);
    AddStringTag   (E+$0302, 'ExtenderSerialNumber', 32);
    AddStringTag   (E+$0303, 'ExtenderModel');
    AddULongTag    (E+$0304, 'ExtenderFirmwareVersion');
    AddStringTag   (E+$0403, 'ConversionLens');
    AddUShortTag   (E+$1000, 'FlashType', 1, '', rsOlympusFlashTypeLkup);
    AddUShortTag   (E+$1001, 'FlashModel', 1, '', rsOlympusFlashModelLkup);
    AddULongTag    (E+$1002, 'FlashFirmwareVersion');
    AddStringTag   (E+$1003, 'FlashSerialNumber', 32);

    // Olympus camera settings tags
    AddBinaryTag   (C+$0000, 'CameraSettingsVersion', 4, '', '', '', TVersionTag);
    AddULongTag    (C+$0100, 'PreviewImageValid', 1, rsOlympusPreviewImgValid, rsOffOn);
    AddULongTag    (C+$0101, 'PreviewImageStart', 1, rsOlympusPreviewImgStart);
    AddULongTag    (C+$0102, 'PreviewImageLength', 1, rsOlympusPreviewImgLength);

  end;
end;


//==============================================================================
//                        TOlympusMakerNoteReader
//==============================================================================

procedure TOlympusMakerNoteReader.GetTagDefs(AStream: TStream);
const
  SIGNATURE_V1 = 'OLYMP'#00#01#00;
  SIGNATURE_V2 = 'OLYMP'#00#02#00;
  SIGNATURE_V3I = 'OLYMPUS'#00'II'#3;
  SIGNATURE_V3M = 'OLYMPUS'#00'MM'#3;
var
  hdr: array of byte;
  p: Int64;
begin
  p := AStream.Position;
  SetLength(hdr, 11);
  AStream.Read(hdr[0], 11);
  AStream.Position := p;

  if (PosInBytes(SIGNATURE_V1, hdr) <> 0) and
     (PosInBytes(SIGNATURE_V2, hdr) <> 0) and
     (PosInBytes(SIGNATURE_V3I, hdr) <> 0) and
     (PosInBytes(SIGNATURE_V3M, hdr) <> 0) then exit;

  BuildOlympusTagDefs(FTagDefs);
end;

{ Read the header and determine the version of the olympus makernotes:
  - version 1: header OLYMP#0#1+0, offsets relative to EXIF
  - version 2: header OLYMP#0#2#0, offsets relative to EXIF
  - version 3: header OLYMPUS#0 + BOM (II or MM) + version (#3#0)
               offsets relative to maker notes !!!! }
function TOlympusMakerNoteReader.Prepare(AStream: TStream): Boolean;
var
  p: Int64;
  hdr: packed array[0..11] of ansichar;
begin
  Result := false;

  // Remember begin of makernotes tag.
  p := AStream.Position;

  // Read header
  AStream.Read(hdr{%H-}, 12);

  // The first 5 bytes must be 'OLYMP'; this is common to all versions
  if not ((hdr[0] = 'O') and (hdr[1] = 'L') and (hdr[2] = 'Y') and (hdr[3] = 'M') and (hdr[4] = 'P')) then
    exit;

  FVersion := 0;
  // Version 1 or 2 if a #0 follows after the 'OLYMP'
  if (hdr[5] = #0) then begin
    if (hdr[6] = #1) and (hdr[7] = #0) then
      FVersion := 1
    else
    if (hdr[6] = #2) and (hdr[7] = #0) then
      FVersion := 2;
  end else
  // Version 3 if the first 8 bytes are 'OLYMPUS'#0
  if (hdr[5] = 'U') and (hdr[6] = 'S') and (hdr[7] = #0) then begin
    // Endianness marker, like in standard EXIF: 'II' or 'MM'
    if (hdr[8] = 'I') and (hdr[9] = 'I') then
      FBigEndian := false
    else
    if (hdr[8] = 'M') and (hdr[9] = 'M') then
      FBigEndian := true;
    if (hdr[10] = #3) then
      FVersion := 3;
    FStartPosition := p;  // Offsets are relative to maker notes
  end;

  // Jump to begin of IFD
  case FVersion of
    1, 2: AStream.Position := p + 8;
    3   : AStream.Position := p + 12;
    else  exit;
  end;

  BuildOlympusTagDefs(FTagDefs);
  Result := true;
end;


initialization
  RegisterMakerNoteReader(TOlympusMakerNoteReader, 'Olympus', '');

end.

