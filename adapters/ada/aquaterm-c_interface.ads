with Interfaces.C;
with Interfaces.C.Strings;
with System;

package AquaTerm.C_Interface is

   subtype C_CHAR_PTR is Interfaces.C.Strings.chars_ptr;
   subtype C_CONST_CHAR_PTR is Interfaces.C.Strings.chars_ptr;
   subtype C_CONST_VOID_PTR is System.Address;
   subtype C_FLOAT is Interfaces.C.C_float;
   subtype C_FLOAT_PTR is System.Address;
   subtype C_INT is Interfaces.C.int;
   subtype C_PROC_PTR is System.Address;

   C_AQT_EVENTBUF_SIZE : constant := 128;

--  Constants that specify linecap styles. 

   C_AQTButtLineCapStyle : constant := 0;
   C_AQTRoundLineCapStyle : constant := 1;
   C_AQTSquareLineCapStyle : constant := 2;

--  Constants that specify horizontal alignment for labels. 

   C_AQTAlignLeft : constant := 0;
   C_AQTAlignCenter : constant := 1;
   C_AQTAlignRight : constant := 2;

--  Constants that specify vertical alignment for labels. 

   C_AQTAlignMiddle : constant := 0;
   C_AQTAlignBaseline : constant := 4;
   C_AQTAlignBottom : constant := 8;
   C_AQTAlignTop : constant := 16;

--  Class initialization etc.

   function C_aqtInit return C_INT;
   pragma Import (C, C_aqtInit, "aqtInit");
   procedure C_aqtTerminate;
   pragma Import (C, C_aqtTerminate, "aqtTerminate");
   procedure C_aqtSetEventHandler (func : C_PROC_PTR);
   pragma Import (C, C_aqtSetEventHandler, "aqtSetEventHandler");

--  Control operations 

   procedure C_aqtOpenPlot (refNum : C_INT);
   pragma Import (C, C_aqtOpenPlot, "aqtOpenPlot");
   function C_aqtSelectPlot (refNum : C_INT) return C_INT;
   pragma Import (C, C_aqtSelectPlot, "aqtSelectPlot");
   procedure C_aqtSetPlotSize (width : C_FLOAT; height : C_FLOAT);
   pragma Import (C, C_aqtSetPlotSize, "aqtSetPlotSize");
   procedure C_aqtSetPlotTitle (title : C_CONST_CHAR_PTR);
   pragma Import (C, C_aqtSetPlotTitle, "aqtSetPlotTitle");
   procedure C_aqtRenderPlot;
   pragma Import (C, C_aqtRenderPlot, "aqtRenderPlot");
   procedure C_aqtClearPlot;
   pragma Import (C, C_aqtClearPlot, "aqtClearPlot");
   procedure C_aqtClosePlot;
   pragma Import (C, C_aqtClosePlot, "aqtClosePlot");

--  Event handling 

   procedure C_aqtSetAcceptingEvents (flag : C_INT);
   pragma Import (C, C_aqtSetAcceptingEvents, "aqtSetAcceptingEvents");
   function C_aqtGetLastEvent (buffer : C_CHAR_PTR) return C_INT;
   pragma Import (C, C_aqtGetLastEvent, "aqtGetLastEvent");
   function C_aqtWaitNextEvent (buffer : C_CHAR_PTR) return C_INT;
   pragma Import (C, C_aqtWaitNextEvent, "aqtWaitNextEvent");

--  Plotting related commands 


--  Clip rect, applies to all objects 

   procedure C_aqtSetClipRect (originX : C_FLOAT; originY : C_FLOAT; width : C_FLOAT; height : C_FLOAT);
   pragma Import (C, C_aqtSetClipRect, "aqtSetClipRect");
   procedure C_aqtSetDefaultClipRect;
   pragma Import (C, C_aqtSetDefaultClipRect, "aqtSetDefaultClipRect");

--  Colormap (utility) 

   function C_aqtColormapSize return C_INT;
   pragma Import (C, C_aqtColormapSize, "aqtColormapSize");
   procedure C_aqtSetColormapEntry (entryIndex : C_INT; r : C_FLOAT; g : C_FLOAT; b : C_FLOAT);
   pragma Import (C, C_aqtSetColormapEntry, "aqtSetColormapEntry");
   procedure C_aqtGetColormapEntry (entryIndex : C_INT; r : C_FLOAT_PTR; g : C_FLOAT_PTR; b : C_FLOAT_PTR);
   pragma Import (C, C_aqtGetColormapEntry, "aqtGetColormapEntry");
   procedure C_aqtTakeColorFromColormapEntry (index : C_INT);
   pragma Import (C, C_aqtTakeColorFromColormapEntry, "aqtTakeColorFromColormapEntry");
   procedure C_aqtTakeBackgroundColorFromColormapEntry (index : C_INT);
   pragma Import (C, C_aqtTakeBackgroundColorFromColormapEntry, "aqtTakeBackgroundColorFromColormapEntry");

--  Color handling 

   procedure C_aqtSetColor (r : C_FLOAT; g : C_FLOAT; b : C_FLOAT);
   pragma Import (C, C_aqtSetColor, "aqtSetColor");
   procedure C_aqtSetBackgroundColor (r : C_FLOAT; g : C_FLOAT; b : C_FLOAT);
   pragma Import (C, C_aqtSetBackgroundColor, "aqtSetBackgroundColor");
   procedure C_aqtGetColor (r : C_FLOAT_PTR; g : C_FLOAT_PTR; b : C_FLOAT_PTR);
   pragma Import (C, C_aqtGetColor, "aqtGetColor");
   procedure C_aqtGetBackgroundColor (r : C_FLOAT_PTR; g : C_FLOAT_PTR; b : C_FLOAT_PTR);
   pragma Import (C, C_aqtGetBackgroundColor, "aqtGetBackgroundColor");

--  Text handling 

   procedure C_aqtSetFontname (newFontname : C_CONST_CHAR_PTR);
   pragma Import (C, C_aqtSetFontname, "aqtSetFontname");
   procedure C_aqtSetFontsize (newFontsize : C_FLOAT);
   pragma Import (C, C_aqtSetFontsize, "aqtSetFontsize");
   procedure C_aqtAddLabel (text : C_CONST_CHAR_PTR; x : C_FLOAT; y : C_FLOAT; angle : C_FLOAT; align : C_INT);
   pragma Import (C, C_aqtAddLabel, "aqtAddLabel");
   procedure C_aqtAddShearedLabel (text : C_CONST_CHAR_PTR; x : C_FLOAT; y : C_FLOAT; angle : C_FLOAT; shearAngle : C_FLOAT; align : C_INT);
   pragma Import (C, C_aqtAddShearedLabel, "aqtAddShearedLabel");

--  Line handling 

   procedure C_aqtSetLinewidth (newLinewidth : C_FLOAT);
   pragma Import (C, C_aqtSetLinewidth, "aqtSetLinewidth");
   procedure C_aqtSetLinestylePattern (newPattern : C_FLOAT_PTR; newCount : C_INT; newPhase : C_FLOAT);
   pragma Import (C, C_aqtSetLinestylePattern, "aqtSetLinestylePattern");
   procedure C_aqtSetLinestyleSolid;
   pragma Import (C, C_aqtSetLinestyleSolid, "aqtSetLinestyleSolid");
   procedure C_aqtSetLineCapStyle (capStyle : C_INT);
   pragma Import (C, C_aqtSetLineCapStyle, "aqtSetLineCapStyle");
   procedure C_aqtMoveTo (x : C_FLOAT; y : C_FLOAT);
   pragma Import (C, C_aqtMoveTo, "aqtMoveTo");
   procedure C_aqtAddLineTo (x : C_FLOAT; y : C_FLOAT);
   pragma Import (C, C_aqtAddLineTo, "aqtAddLineTo");
   procedure C_aqtAddPolyline (x : C_FLOAT_PTR; y : C_FLOAT_PTR; pointCount : C_INT);
   pragma Import (C, C_aqtAddPolyline, "aqtAddPolyline");

--  Rect and polygon handling

   procedure C_aqtMoveToVertex (x : C_FLOAT; y : C_FLOAT);
   pragma Import (C, C_aqtMoveToVertex, "aqtMoveToVertex");
   procedure C_aqtAddEdgeToVertex (x : C_FLOAT; y : C_FLOAT);
   pragma Import (C, C_aqtAddEdgeToVertex, "aqtAddEdgeToVertex");
   procedure C_aqtAddPolygon (x : C_FLOAT_PTR; y : C_FLOAT_PTR; pointCount : C_INT);
   pragma Import (C, C_aqtAddPolygon, "aqtAddPolygon");
   procedure C_aqtAddFilledRect (originX : C_FLOAT; originY : C_FLOAT; width : C_FLOAT; height : C_FLOAT);
   pragma Import (C, C_aqtAddFilledRect, "aqtAddFilledRect");
   procedure C_aqtEraseRect (originX : C_FLOAT; originY : C_FLOAT; width : C_FLOAT; height : C_FLOAT);
   pragma Import (C, C_aqtEraseRect, "aqtEraseRect");

--  Image handling 

   procedure C_aqtSetImageTransform (m11 : C_FLOAT; m12 : C_FLOAT; m21 : C_FLOAT; m22 : C_FLOAT; tX : C_FLOAT; tY : C_FLOAT);
   pragma Import (C, C_aqtSetImageTransform, "aqtSetImageTransform");
   procedure C_aqtResetImageTransform;
   pragma Import (C, C_aqtResetImageTransform, "aqtResetImageTransform");
   procedure C_aqtAddImageWithBitmap (bitmap : C_CONST_VOID_PTR; pixWide : C_INT; pixHigh : C_INT; destX : C_FLOAT; destY : C_FLOAT; destWidth : C_FLOAT; destHeight : C_FLOAT);
   pragma Import (C, C_aqtAddImageWithBitmap, "aqtAddImageWithBitmap");
   procedure C_aqtAddTransformedImageWithBitmap (bitmap : C_CONST_VOID_PTR; pixWide : C_INT; pixHigh : C_INT; clipX : C_FLOAT; clipY : C_FLOAT; clipWidth : C_FLOAT; clipHeight : C_FLOAT);
   pragma Import (C, C_aqtAddTransformedImageWithBitmap, "aqtAddTransformedImageWithBitmap");
end;
