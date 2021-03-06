{ This is an autogenerated unit using gobject introspection (gir2pascal). Do not Edit. }
unit cairo1;

{$MODE OBJFPC}{$H+}

{$PACKRECORDS C}
{$MODESWITCH DUPLICATELOCALS+}

{$LINKLIB libcairo-gobject.so.2}
interface
uses
  CTypes;

const
  cairo1_library = 'libcairo-gobject.so.2';


type
  Tcairo_content_t = Integer;
const
  { cairo_content_t }
  CAIRO_CONTENT_COLOR: Tcairo_content_t = 4096;
  CAIRO_CONTENT_ALPHA: Tcairo_content_t = 8192;
  CAIRO_CONTENT_COLOR_ALPHA: Tcairo_content_t = 12288;
type

  PPcairo_t = ^Pcairo_t;
  Pcairo_t = ^Tcairo_t;
  Tcairo_t = object
  end;

  PPcairo_surface_t = ^Pcairo_surface_t;
  Pcairo_surface_t = ^Tcairo_surface_t;
  Tcairo_surface_t = object
  end;

  PPcairo_matrix_t = ^Pcairo_matrix_t;
  Pcairo_matrix_t = ^Tcairo_matrix_t;

  Tcairo_matrix_t = record
  end;



  PPcairo_pattern_t = ^Pcairo_pattern_t;
  Pcairo_pattern_t = ^Tcairo_pattern_t;
  Tcairo_pattern_t = object
  end;

  PPcairo_region_t = ^Pcairo_region_t;
  Pcairo_region_t = ^Tcairo_region_t;
  Tcairo_region_t = object
  end;

  PPcairo_content_t = ^Pcairo_content_t;
  Pcairo_content_t = ^Tcairo_content_t;

  PPcairo_font_options_t = ^Pcairo_font_options_t;
  Pcairo_font_options_t = ^Tcairo_font_options_t;

  Tcairo_font_options_t = record
  end;



  PPcairo_font_type_t = ^Pcairo_font_type_t;
  Pcairo_font_type_t = ^Tcairo_font_type_t;

  Tcairo_font_type_t = record
  end;



  PPcairo_font_face_t = ^Pcairo_font_face_t;
  Pcairo_font_face_t = ^Tcairo_font_face_t;
  Tcairo_font_face_t = object
  end;

  PPcairo_scaled_font_t = ^Pcairo_scaled_font_t;
  Pcairo_scaled_font_t = ^Tcairo_scaled_font_t;
  Tcairo_scaled_font_t = object
  end;

  PPcairo_path_t = ^Pcairo_path_t;
  Pcairo_path_t = ^Tcairo_path_t;

  Tcairo_path_t = record
  end;



  PPcairo_rectangle_int_t = ^Pcairo_rectangle_int_t;
  Pcairo_rectangle_int_t = ^Tcairo_rectangle_int_t;

  Pcint = ^cint;
  Tcairo_rectangle_int_t = object
    x: cint;
    y: cint;
    width: cint;
    height: cint;
  end;

function cairo_gobject_context_get_type: csize_t { TGType }; cdecl; external;
function cairo_gobject_font_face_get_type: csize_t { TGType }; cdecl; external;
function cairo_gobject_pattern_get_type: csize_t { TGType }; cdecl; external;
function cairo_gobject_rectangle_int_get_type: csize_t { TGType }; cdecl; external;
function cairo_gobject_region_get_type: csize_t { TGType }; cdecl; external;
function cairo_gobject_scaled_font_get_type: csize_t { TGType }; cdecl; external;
function cairo_gobject_surface_get_type: csize_t { TGType }; cdecl; external;
procedure cairo_image_surface_create; cdecl; external;
implementation
end.