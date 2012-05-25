program demo;
{
  demo.pp
  AquaTerm

  Created by Karl-Michael Schindler on Tue Jul 07 2010
  based on the C and Fortran examples
  Copyright (c) 2012 The AquaTerm Project. All rights reserved.

  This file contains an example of what can be done with
  AquaTerm and the corresponding AquaTerm framework

  This code can be build as a stand-alone executable (tool)
  from the command line:
      fpc demo.pp

}

{$H+} // This enables easy conversion of strings to Pchar.

uses
  SysUtils,
  ctypes,
  aquaterm;

const
  pi = 3.14152692;

var
  i: integer;
  x, y, f, r: cfloat;
  width, height: cfloat;
  xPtr, yPtr: array [1..128] of cfloat;
  // Declare the image: it will be 2x2 in size.
  rgbImage: array [1..2,1..2,1..3] of byte;

begin
  // image setup
  // Pixel(1,1) RGB (red)
  rgbImage[1,1,1] := 255;
  rgbImage[1,1,2] := 0;
  rgbImage[1,1,3] := 0;
  // Pixel(1,2) RGB (green)
  rgbImage[1,2,1] := 0;
  rgbImage[1,2,2] := 255;
  rgbImage[1,2,3] := 0;
  // Pixel(2,1) RGB (blue)
  rgbImage[2,1,1] := 0;
  rgbImage[2,1,2] := 0;
  rgbImage[2,1,3] := 255;
  // Pixel(2,2) RGB (black)
  rgbImage[2,2,1] := 0;
  rgbImage[2,2,2] := 0;
  rgbImage[2,2,3] := 0;

  // Initialize. Do it or fail miserably...
  aqtInit;
  // Open up a plot for drawing
  aqtOpenPlot(1);
  width  := 620;
  height := 420;
  aqtSetPlotSize(width, height);
  aqtSetPlotTitle('Testview');
  // Set colormap
  aqtSetColormapEntry(0, 1.0, 1.0, 1.0);  // white
  aqtSetColormapEntry(1, 0.0, 0.0, 0.0);  // black
  aqtSetColormapEntry(2, 1.0, 0.0, 0.0);  // red
  aqtSetColormapEntry(3, 0.0, 1.0, 0.0);  // green
  aqtSetColormapEntry(4, 0.0, 0.0, 1.0);  // blue
  aqtSetColormapEntry(5, 1.0, 0.0, 1.0);  // purple
  aqtSetColormapEntry(6, 1.0, 1.0, 0.5);  // yellow
  aqtSetColormapEntry(7, 0.0, 0.5, 0.5);  // dark green

  // Set color explicitly
  aqtSetColor(0.0, 0.0, 0.0);
  aqtSetFontname('Helvetica');
  aqtSetFontsize(12.0);
  aqtAddLabel('Testview 620x420 pt', 4.0, 412.0, 0.0, AQTAlignLeft);
  // Frame plot
  aqtMoveTo   ( 20,  20);
  aqtAddLineTo(600,  20);
  aqtAddLineTo(600, 400);
  aqtAddLineTo( 20, 400);
  aqtAddLineTo( 20,  20);
  aqtAddLabel('Frame 600x400 pt', 24, 30, 0.0, AQTAlignLeft);
  // Colormap
  aqtAddLabel('Custom colormap (showing 8 of 256 entries)', 30, 390, 0.0, AQTAlignLeft);
  // Display the colormap, but first create a background for the white box...
  aqtSetColor(0.8, 0.8, 0.8);
  aqtAddFilledRect(28, 348, 24, 24);
  for i := 0 to 7 do
  begin
     aqtTakeColorFromColormapEntry(i);
     aqtAddFilledRect(30 + i*30, 350, 20, 20);
     // Print the color index
     aqtSetColor(0.5, 0.5, 0.5);
     // Writing with a format to internal character variables
     aqtAddLabel(pchar(IntToStr(i)), 40 + i*30, 360, 0.0, (AQTAlignCenter or AQTAlignMiddle));
  end;
  // Continuous colors
  aqtRenderPlot;
  aqtTakeColorFromColormapEntry(1);
  aqtAddLabel('Continuous colors', 320, 390, 0.0, AQTAlignLeft);
  aqtSetLinewidth(1.0);
  for i := 0 to 255 do
  begin
     f := i/255.0;
     aqtSetColor(1.0,     f,       f/2.0);   aqtAddFilledRect(320 + i, 350, 1, 20);
     aqtSetColor(0.0,     f,       1.0 - f); aqtAddFilledRect(320 + i, 328, 1, 20);
     aqtSetColor(1.0 - f, 1.0 - f, 1.0 - f); aqtAddFilledRect(320 + i, 306, 1, 20);
  end;
  // Lines
  aqtTakeColorFromColormapEntry(1);
  for i := 1 to 6 do
  begin
     aqtSetLinewidth(i);
     aqtMoveTo   ( 30, 200.5 + i*20);
     aqtAddLineTo(200, 200.5 + i*20);
     aqtAddLabel(pchar('linewidth ' + IntToStr(i)), 210, 201.5 + i*20, 0.0, AQTAlignLeft);
  end;
  // linecap styles
  aqtSetLinewidth(11.0);
  aqtTakeColorFromColormapEntry(1);
  aqtSetLineCapStyle(AQTButtLineCapStyle);
  aqtMoveTo   (40.5, 170.5);
  aqtAddLineTo(150.5, 170.5);
  aqtAddLabel('AQTButtLineCapStyle', 160.5, 170.5, 0.0, AQTAlignLeft);
  aqtSetLinewidth(1.0);
  aqtTakeColorFromColormapEntry(6);
  aqtMoveTo   (40.5, 170.5);
  aqtAddLineTo(150.5, 170.5);

  aqtSetLinewidth(11.0);
  aqtTakeColorFromColormapEntry(1);
  aqtSetLineCapStyle(AQTRoundLineCapStyle);
  aqtMoveTo   (40.5, 150.5);
  aqtAddLineTo(150.5, 150.5);
  aqtAddLabel('AQTRoundLineCapStyle', 160.5, 150.5, 0.0, AQTAlignLeft);
  aqtSetLinewidth(1.0);
  aqtTakeColorFromColormapEntry(6);
  aqtMoveTo   (40.5, 150.5);
  aqtAddLineTo(150.5, 150.5);

  aqtSetLinewidth(11.0);
  aqtTakeColorFromColormapEntry(1);
  aqtSetLineCapStyle(AQTSquareLineCapStyle);
  aqtMoveTo   (40.5, 130.5);
  aqtAddLineTo(150.5, 130.5);
  aqtAddLabel('AQTSquareLineCapStyle', 160.5, 130.5, 0.0, AQTAlignLeft);
  aqtSetLinewidth(1.0);
  aqtTakeColorFromColormapEntry(6);
  aqtMoveTo   (40.5, 130.5);
  aqtAddLineTo(150.5, 130.5);

  // line joins
  aqtTakeColorFromColormapEntry(1);
  aqtAddLabel('Line joins:', 40, 90, 0.0, AQTAlignLeft);
  aqtSetLinewidth(11.0);
  aqtSetLineCapStyle(AQTButtLineCapStyle);
  aqtMoveTo   ( 40, 50);
  aqtAddLineTo( 75, 70);
  aqtAddLineTo(110, 50);
  aqtSetLinewidth(1.0);
  aqtTakeColorFromColormapEntry(6);
  aqtMoveTo   ( 40, 50);
  aqtAddLineTo( 75, 70);
  aqtAddLineTo(110, 50);

  aqtSetLinewidth(11.0);
  aqtTakeColorFromColormapEntry(1);
  aqtMoveTo   (130, 50);
  aqtAddLineTo(150, 70);
  aqtAddLineTo(170, 50);
  aqtSetLinewidth(1.0);
  aqtTakeColorFromColormapEntry(6);
  aqtMoveTo   (130, 50);
  aqtAddLineTo(150, 70);
  aqtAddLineTo(170, 50);

  aqtSetLinewidth(11.0);
  aqtTakeColorFromColormapEntry(1);
  aqtSetLineCapStyle(0);
  aqtMoveTo   (190, 50);
  aqtAddLineTo(200, 70);
  aqtAddLineTo(210, 50);
  aqtSetLinewidth(1.0);
  aqtTakeColorFromColormapEntry(6);
  aqtMoveTo   (190, 50);
  aqtAddLineTo(200, 70);
  aqtAddLineTo(210, 50);

  // Polygons
  aqtTakeColorFromColormapEntry(1);
  aqtAddLabel('Polygons', 320, 290, 0.0, AQTAlignLeft);
  f :=  0.0;
  r := 20.0;
  for i := 1 to 4 do
  begin
     xPtr[i] := 340.0 + r*cos(f*pi/2.0);
     yPtr[i] := 255.0 + r*sin(f*pi/2.0);
     f := f + 1.0;
  end;
  aqtTakeColorFromColormapEntry(2);
  aqtAddPolygon(@xPtr, @yPtr, 4);;

  f :=  0.0;
  r := 20.0;
  for i := 1 to 5 do
  begin
     xPtr[i] := 400.0 + r*cos(f*pi*0.8);
     yPtr[i] := 255.0 + r*sin(f*pi*0.8);
     f := f + 1.0;
  end;
  aqtTakeColorFromColormapEntry(3);
  aqtAddPolygon(@xPtr, @yPtr, 5);
  aqtTakeColorFromColormapEntry(1);
  xPtr[6] := xPtr[1];
  yPtr[6] := yPtr[1];
  aqtAddPolyline(@xPtr, @yPtr, 6);  // Overlay a polyline

  // Alternative to polyline:
  f :=  0.0;
  r := 20.0;
  aqtTakeColorFromColormapEntry(4);
  aqtMoveToVertex(460.0 + r, 255.0);
  for i := 1 to 8 do
  begin
     x := 460.0 + r*cos(f*pi/4.0);
     y := 255.0 + r*sin(f*pi/4.0);
     aqtAddEdgeToVertex(x, y);
     f := f + 1.0;
  end;

  f :=  0.0;
  r := 20.0;
  for i := 1 to 32 do
  begin
     xPtr[i] := 520.0 + r*cos(f*pi/16.0);
     yPtr[i] := 255.0 + r*sin(f*pi/16.0);
     f := f + 1.0;
  end;
  aqtTakeColorFromColormapEntry(5);
  aqtAddPolygon(@xPtr, @yPtr, 32);;

  // Images
  aqtTakeColorFromColormapEntry(1);
  aqtAddLabel('Images', 320, 220, 0.0, AQTAlignLeft);
  aqtAddImageWithBitmap(@rgbImage, 2, 2, 328, 200, 4, 4);
  aqtAddLabel('bits', 330, 180, 0.0, AQTAlignCenter);
  aqtAddImageWithBitmap(@rgbImage, 2, 2, 360, 190, 40, 15);
  aqtAddLabel('fit bounds', 380, 180, 0.0, AQTAlignCenter);
  aqtSetImageTransform(9.23880, 3.82683, -3.82683, 9.23880, 494.6, 186.9);
  aqtAddTransformedImageWithBitmap(@rgbImage, 2, 2, 0.0, 0.0, 600.0, 400.0);
  aqtAddLabel('scale, rotate & translate', 500, 180, 0.0, AQTAlignCenter);
  aqtResetImageTransform;

  // Text
  aqtTakeColorFromColormapEntry(1);
  aqtSetFontname('Times-Roman');
  aqtSetFontsize(16.0);
  aqtAddLabel('Times-Roman 16pt', 320, 150, 0.0, AQTAlignLeft);
  aqtTakeColorFromColormapEntry(2);
  aqtSetFontname('Times-Italic');
  aqtSetFontsize(16.0);
  aqtAddLabel('Times-Italic 16pt', 320, 130, 0.0, AQTAlignLeft);
  aqtTakeColorFromColormapEntry(4);
  aqtSetFontname('Zapfino');
  aqtSetFontsize(12.0);
  aqtAddLabel('Zapfino 12pt', 320, 104, 0.0, AQTAlignLeft);

  aqtTakeColorFromColormapEntry(2);
  aqtSetLinewidth(0.5);
  aqtMoveTo   (510.5, 160);
  aqtAddLineTo(510.5, 100);
  x := 540.5;
  y := 75.5;
  aqtMoveTo   (x + 5, y);
  aqtAddLineTo(x - 5, y);
  aqtMoveTo   (x,     y + 5);
  aqtAddLineTo(x,     y - 5);

  aqtTakeColorFromColormapEntry(1);
  aqtSetFontname('Verdana');
  aqtSetFontsize(10.0);
  aqtAddLabel('left aligned',  510.5, 150, 0.0, AQTAlignLeft);
  aqtAddLabel('centered',      510.5, 130, 0.0, AQTAlignCenter);
  aqtAddLabel('right aligned', 510.5, 110, 0.0, AQTAlignRight);
  aqtSetFontname('Times-Roman');
  aqtSetFontsize(14.0);
  aqtAddLabel('-rotate', x, y,  90.0, AQTAlignLeft);
  aqtAddLabel('-rotate', x, y,  45.0, AQTAlignLeft);
  aqtAddLabel('-rotate', x, y, -30.0, AQTAlignLeft);
  aqtAddLabel('-rotate', x, y, -60.0, AQTAlignLeft);
  aqtAddLabel('-rotate', x, y, -90.0, AQTAlignLeft);

  // String styling is _not_ possible from procedural Pascal
  aqtSetFontsize(12.0);
  aqtAddLabel('No underline, sub- or superscript in Pascal', 320, 75, 0.0, AQTAlignLeft);

  aqtTakeColorFromColormapEntry(2);
  aqtSetLinewidth(0.5);
  aqtMoveTo   (320, 45.5);
  aqtAddLineTo(520, 45.5);
  aqtTakeColorFromColormapEntry(1);
  aqtSetFontname('Times-Italic');
  aqtSetFontsize(14.0);
  aqtAddLabel('Top',      330, 45.5, 0.0, (AQTAlignLeft or AQTAlignTop));
  aqtAddLabel('Bottom',   360, 45.5, 0.0, (AQTAlignLeft or AQTAlignBottom));
  aqtAddLabel('Middle',   410, 45.5, 0.0, (AQTAlignLeft or AQTAlignMiddle));
  aqtAddLabel('Baseline', 460, 45.5, 0.0, (AQTAlignLeft or AQTAlignBaseline));

  // Draw it
  aqtRenderPlot;
  // Let go of plot _when done_
  aqtClosePlot;
end.
