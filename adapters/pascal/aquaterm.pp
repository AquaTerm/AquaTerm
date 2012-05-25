unit aquaterm;

{
  aquaterm.h
  AquaTerm

  Created by Per Persson on Sat Jul 12 2003.
  Copyright (c) 2003-2012 The AquaTerm Team.

  Automatically converted by H2Pas 1.0.0 from aquaterm.h
  The following command line parameters were used:
    -C
    -d
    aquaterm.h
}

{$LINKFRAMEWORK AquaTerm}

interface

uses
  ctypes;

  type
  Pcfloat  = ^cfloat;

{$IFDEF FPC}
  {$PACKRECORDS C}
{$ENDIF}

  const
    AQT_EVENTBUF_SIZE = 128;

  var

{ Constants that specify linecap styles. }
(* Const before type ignored *)
    AQTButtLineCapStyle: cint; cvar; external;
(* Const before type ignored *)
    AQTRoundLineCapStyle: cint; cvar; external;
(* Const before type ignored *)
    AQTSquareLineCapStyle: cint; cvar; external;

{ Constants that specify horizontal alignment for labels. }
(* Const before type ignored *)
    AQTAlignLeft: cint; cvar; external;
(* Const before type ignored *)
    AQTAlignCenter: cint; cvar; external;
(* Const before type ignored *)
    AQTAlignRight: cint; cvar; external;

{ Constants that specify vertical alignment for labels. }
(* Const before type ignored *)
    AQTAlignMiddle: cint; cvar; external;
(* Const before type ignored *)
    AQTAlignBaseline: cint; cvar; external;
(* Const before type ignored *)
    AQTAlignBottom: cint; cvar; external;
(* Const before type ignored *)
    AQTAlignTop: cint; cvar; external;

{ Class initialization etc. }
  function aqtInit: cint; cdecl; external;
  procedure aqtTerminate; cdecl; external;

{ The event handler callback functionality should be used with caution, it may
   not be safe to use in all circumstances. It is certainly _not_ threadsafe.
   If in doubt, use aqtWaitNextEvent() instead.  }
(* Const before type ignored *)
  type
    TCallBackFunction = procedure (ref: cint; event: pchar); cdecl;
  procedure aqtSetEventHandler(func: TCallBackFunction); cdecl; external;

{ Control operations }
  procedure aqtOpenPlot(refNum: cint); cdecl; external;
  function aqtSelectPlot(refNum: cint): cint; cdecl; external;
  procedure aqtSetPlotSize(width, height: cfloat); cdecl; external;
(* Const before type ignored *)
  procedure aqtSetPlotTitle(title: pchar); cdecl; external;
  procedure aqtRenderPlot; cdecl; external;
  procedure aqtClearPlot; cdecl; external;
  procedure aqtClosePlot; cdecl; external;

{ Event handling }
  procedure aqtSetAcceptingEvents(flag: cint); cdecl; external;
  function aqtGetLastEvent (buffer: pchar): cint; cdecl; external;
  function aqtWaitNextEvent(buffer: pchar): cint; cdecl; external;

{ Plotting related commands }
{ Clip rect, applies to all objects }
  procedure aqtSetClipRect(originX, originY, width, height: cfloat); cdecl; external;
  procedure aqtSetDefaultClipRect; cdecl; external;

{ Colormap utility }
  function aqtColormapSize: cint; cdecl; external;
  procedure aqtSetColormapEntryRGBA(entryIndex: cint; r, g, b, a: cfloat); cdecl; external;
  procedure aqtGetColormapEntryRGBA(entryIndex: cint; r, g, b, a: Pcfloat); cdecl; external;
  procedure aqtSetColormapEntry(entryIndex: cint; r, g, b: cfloat); cdecl; external;
  procedure aqtGetColormapEntry(entryIndex: cint; r, g, b: Pcfloat); cdecl; external;
  procedure aqtTakeColorFromColormapEntry(index: cint); cdecl; external;
  procedure aqtTakeBackgroundColorFromColormapEntry(index: cint); cdecl; external;

{ Color handling }
  procedure aqtSetColorRGBA          (r, g, b, a: cfloat); cdecl; external;
  procedure aqtSetBackgroundColorRGBA(r, g, b, a: cfloat); cdecl; external;
  procedure aqtGetColorRGBA          (r, g, b, a: Pcfloat); cdecl; external;
  procedure aqtGetBackgroundColorRGBA(r, g, b, a: Pcfloat); cdecl; external;
  procedure aqtSetColor          (r, g, b: cfloat); cdecl; external;
  procedure aqtSetBackgroundColor(r, g, b: cfloat); cdecl; external;
  procedure aqtGetColor          (r, g, b: Pcfloat); cdecl; external;
  procedure aqtGetBackgroundColor(r, g, b: Pcfloat); cdecl; external;

{ Text handling }
(* Const before type ignored *)
  procedure aqtSetFontname(newFontname: pchar); cdecl; external;
  procedure aqtSetFontsize(newFontsize: cfloat); cdecl; external;
(* Const before type ignored *)
  procedure aqtAddLabel(text: pchar; x, y, angle: cfloat;
                        align: cint); cdecl; external;
(* Const before type ignored *)
  procedure aqtAddShearedLabel(text: pchar; x, y, angle, shearAngle: cfloat;
                               align: cint); cdecl; external;

{ Line handling }
  procedure aqtSetLinewidth(newLinewidth: cfloat); cdecl; external;
  procedure aqtSetLinestylePattern(newPattern: Pcfloat; newCount: cint;
                                   newPhase: cfloat); cdecl; external;
  procedure aqtSetLinestyleSolid; cdecl; external;
  procedure aqtSetLineCapStyle(capStyle: cint); cdecl; external;
  procedure aqtMoveTo   (x, y: cfloat); cdecl; external;
  procedure aqtAddLineTo(x, y: cfloat); cdecl; external;
  procedure aqtAddPolyline(x, y: Pcfloat; pointCount: cint); cdecl; external;

{ Rect and polygon handling }
  procedure aqtMoveToVertex   (x, y: cfloat); cdecl; external;
  procedure aqtAddEdgeToVertex(x, y: cfloat); cdecl; external;
  procedure aqtAddPolygon(x, y: Pcfloat; pointCount: cint); cdecl; external;
  procedure aqtAddFilledRect(originX, originY, width, height: cfloat); cdecl; external;
  procedure aqtEraseRect    (originX, originY, width, height: cfloat); cdecl; external;

{ Image handling }
  procedure aqtSetImageTransform(m11, m12, m21, m22, tX, tY: cfloat); cdecl; external;
  procedure aqtResetImageTransform; cdecl; external;
(* Const before type ignored *)
  procedure aqtAddImageWithBitmap(bitmap: pointer; pixWide, pixHigh: cint;
                                  destX, destY, destWidth, destHeight: cfloat); cdecl; external;
(* Const before type ignored *)
  procedure aqtAddTransformedImageWithBitmap(bitmap: pointer; pixWide, pixHigh: cint;
                                             clipX, clipY, clipWidth, clipHeight: cfloat); cdecl; external;

implementation

end.
