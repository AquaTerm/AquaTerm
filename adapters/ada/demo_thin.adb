with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Aquaterm.C_Interface;
with Interfaces.C;
with Interfaces.C.Strings;

procedure Demo_Thin is

-- Thin translation, by Marius Amado-Alves, of "demo.c" by Per Persson.
-- Original text reproduced in comments of the form --: ...
-- Executable built with: gnatmake demo_thin -largs -laquaterm

--:  demo.c
--:  AquaTerm
--:
--:  Created by Per Persson on Fri Nov 07 2003.
--:  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
--:
--:
--: This file contains an example of what can be done with
--: AquaTerm and the corresponding library: libaqt.dylib
--:
--: This code can be build as a stand-alone executable (tool)
--: from the command line:
--: gcc -o demo demo.c -laquaterm -lobjc

-- No, don't use the -objc option (or the executable will burst)

--: #include "aquaterm/aquaterm.h"
--: #include <math.h>

   use AquaTerm.C_Interface;
   use type Interfaces.C.int;
   use type Interfaces.C.C_Float;
   use Interfaces.C.Strings;
   
   function "+" (Str : in String) return chars_ptr is
      Z : String := Str & Character'Val(0);
   begin
      return Interfaces.C.Strings.New_String (Z);
   end;

   function Img (X : Natural) return String is
      Z : String := Natural'Image(X);
   begin
      return Z (2 .. Z'Last);
   end;
   
   i : C_INT; --: int i;
   --: char strBuf[256]; (not needed in Ada)
   xPtr, yPtr : array (0 .. 127) of C_FLOAT; --: float xPtr[128], yPtr[128];
   x, y, f : C_FLOAT;
   --: double pi = 4.0*atan(1.0); (not needed; using Ada's pi)
   rgbImage : array (0 .. 11) of Interfaces.C.unsigned_char :=
     ( 255,   0,   0,
         0, 255,   0,
         0,   0, 255,
         0,   0,   0  );
   --: unsigned char rgbImage[12]={
   --:    --: 255, 0, 0,
   --:    --: 0, 255, 0,
   --:    --: 0, 0, 255,
   --:    --: 0, 0, 0
   --: };

begin
   --: --: Initialize. Do it or fail miserably...
   i := C_aqtInit; --: aqtInit();
   --: --: Open up a plot for drawing
   C_aqtOpenPlot(1);
   C_aqtSetPlotSize(620.0,420.0);
   C_aqtSetPlotTitle(+"Testview");
   --: --: Set colormap
   C_aqtSetColormapEntry(0, 1.0, 1.0, 1.0); --: white
   C_aqtSetColormapEntry(1, 0.0, 0.0, 0.0); --: black
   C_aqtSetColormapEntry(2, 1.0, 0.0, 0.0); --: red
   C_aqtSetColormapEntry(3, 0.0, 1.0, 0.0); --: green
   C_aqtSetColormapEntry(4, 0.0, 0.0, 1.0); --: blue
   C_aqtSetColormapEntry(5, 1.0, 0.0, 1.0); --: purple
   C_aqtSetColormapEntry(6, 1.0, 1.0, 0.5); --: yellow
   C_aqtSetColormapEntry(7, 0.0, 0.5, 0.5); --: dark green
   --: --: Set color explicitly
   C_aqtSetColor(0.0, 0.0, 0.0);
   C_aqtSetFontname(+"Helvetica");
   C_aqtSetFontsize(12.0);
   C_aqtAddLabel(+"Testview 620x420 pt", 4.0, 412.0, 0.0, C_AQTAlignLeft);
   --: --: Frame plot
   C_aqtMoveTo(20.0, 20.0);
   C_aqtAddLineTo(600.0,20.0);
   C_aqtAddLineTo(600.0,400.0);
   C_aqtAddLineTo(20.0,400.0);
   C_aqtAddLineTo(20.0,20.0);
   C_aqtAddLabel(+"Frame 600x400 pt", 24.0, 30.0, 0.0, C_AQTAlignLeft);
   --: --: Colormap
   C_aqtAddLabel(+"Custom colormap (8 out of 256)", 30.0, 390.0, 0.0, C_AQTAlignLeft);
   --: --: Display the colormap, but first create a background for the white box...
   C_aqtSetColor(0.8, 0.8, 0.8);
   C_aqtAddFilledRect(28.0, 348.0, 24.0, 24.0);
   for i in 0 .. 7 loop --: for (i=0; i<8; i++)
      C_aqtTakeColorFromColormapEntry(C_INT(i));
      C_aqtAddFilledRect(C_FLOAT(30+i*30), 350.0, 20.0, 20.0);
      --:    --: --: Print the color index
      C_aqtSetColor(0.5, 0.5, 0.5);
      --:    --: sprintf(strBuf, "%d", i);
      --:    --: aqtAddLabel(strBuf, 40+i*30, 360, 0.0, (AQTAlignCenter | AQTAlignMiddle));
      C_aqtAddLabel(New_String(Img(i)), C_FLOAT(40+i*30), 360.0, 0.0, C_AQTAlignCenter + C_AQTAlignMiddle);
   end loop;
   --: --: Continuos colors
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtAddLabel(+"""Any color you like""", 320.0, 390.0, 0.0, C_AQTAlignLeft);
   C_aqtSetLinewidth(1.0);
   for i in 0 .. 255 loop --: for (i=0; i<256; i++)
      f := C_FLOAT(i)/255.0; --:    --: f = (float)i/255.0;
      C_aqtSetColor(1.0, f, f/2.0);
      C_aqtAddFilledRect(C_FLOAT(320+i), 350.0, 1.0, 20.0);
      C_aqtSetColor(0.0, f, (1.0-f));
      C_aqtAddFilledRect(C_FLOAT(320+i), 328.0, 1.0, 20.0);
      C_aqtSetColor((1.0-f), (1.0-f), (1.0-f));
      C_aqtAddFilledRect(C_FLOAT(320+i), 306.0, 1.0, 20.0);
   end loop;
   --: --: Lines
   C_aqtTakeColorFromColormapEntry(1);
   f := 1.0;
   while f < 13.0 loop --: for (f=1.0; f<13.0; f+=2.0)
      declare
         lw : C_FLOAT := f/2.0;
         type Decimal is delta 0.1 digits 4;
      begin
         C_aqtSetLinewidth(lw);
         C_aqtMoveTo(30.0, 200.5+f*10.0);
         C_aqtAddLineTo(200.0, 200.5+f*10.0);
         --: sprintf(strBuf, "linewidth %3.1f", lw);
         --: aqtAddLabel(strBuf, 210, 201.5+f*10, 0.0, AQTAlignLeft);
         C_aqtAddLabel(+Decimal'Image(Decimal(lw)), 210.0, 201.5+f*10.0, 0.0, C_AQTAlignLeft);
      end;
      f := f + 2.0;
   end loop;
   --: --: linecap styles
   C_aqtSetLinewidth(11.0);
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetLineCapStyle(C_AQTButtLineCapStyle);
   C_aqtMoveTo(40.5, 170.5);
   C_aqtAddLineTo(150.5, 170.5);
   C_aqtAddLabel(+"AQTButtLineCapStyle", 160.5, 170.5, 0.0, C_AQTAlignLeft);
   C_aqtSetLinewidth(1.0);
   C_aqtTakeColorFromColormapEntry(6);
   C_aqtMoveTo(40.5, 170.5);
   C_aqtAddLineTo(150.5, 170.5);

   C_aqtSetLinewidth(11.0);
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetLineCapStyle(C_AQTRoundLineCapStyle);
   C_aqtMoveTo(40.5, 150.5);
   C_aqtAddLineTo(150.5, 150.5);
   C_aqtAddLabel(+"AQTRoundLineCapStyle", 160.5, 150.5, 0.0, C_AQTAlignLeft);
   C_aqtSetLinewidth(1.0);
   C_aqtTakeColorFromColormapEntry(6);
   C_aqtMoveTo(40.5, 150.5);
   C_aqtAddLineTo(150.5, 150.5);

   C_aqtSetLinewidth(11.0);
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetLineCapStyle(C_AQTSquareLineCapStyle);
   C_aqtMoveTo(40.5, 130.5);
   C_aqtAddLineTo(150.5, 130.5);
   C_aqtAddLabel(+"AQTSquareLineCapStyle", 160.5, 130.5, 0.0, C_AQTAlignLeft);
   C_aqtSetLinewidth(1.0);
   C_aqtTakeColorFromColormapEntry(6);
   C_aqtMoveTo(40.5, 130.5);
   C_aqtAddLineTo(150.5, 130.5);

   --: --: line joins
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtAddLabel(+"Line joins:", 40.0, 90.0, 0.0, C_AQTAlignLeft);
   C_aqtSetLinewidth(11.0);
   C_aqtSetLineCapStyle(C_AQTButtLineCapStyle);
   C_aqtMoveTo(40.0, 50.0);
   C_aqtAddLineTo(75.0, 70.0);
   C_aqtAddLineTo(110.0, 50.0);
   C_aqtSetLinewidth(1.0);
   C_aqtTakeColorFromColormapEntry(6);
   C_aqtMoveTo(40.0, 50.0);
   C_aqtAddLineTo(75.0, 70.0);
   C_aqtAddLineTo(110.0, 50.0);

   C_aqtSetLinewidth(11.0);
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtMoveTo(130.0, 50.0);
   C_aqtAddLineTo(150.0, 70.0);
   C_aqtAddLineTo(170.0, 50.0);
   C_aqtSetLinewidth(1.0);
   C_aqtTakeColorFromColormapEntry(6);
   C_aqtMoveTo(130.0, 50.0);
   C_aqtAddLineTo(150.0, 70.0);
   C_aqtAddLineTo(170.0, 50.0);

   C_aqtSetLinewidth(11.0);
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetLineCapStyle(C_AQTButtLineCapStyle);
   C_aqtMoveTo(190.0, 50.0);
   C_aqtAddLineTo(200.0, 70.0);
   C_aqtAddLineTo(210.0, 50.0);
   C_aqtSetLinewidth(1.0);
   C_aqtTakeColorFromColormapEntry(6);
   C_aqtMoveTo(190.0, 50.0);
   C_aqtAddLineTo(200.0, 70.0);
   C_aqtAddLineTo(210.0, 50.0);

   --: --: Polygons
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtAddLabel(+"Polygons", 320.0, 290.0, 0.0, C_AQTAlignLeft);
   declare
      use Interfaces.C;
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;
      radians : double;
      r : double := 20.0;
   begin
      for i in 0 .. 3 loop --: for (i=0; i<4; i++)
         --: double radians=(double)i*pi/2.0, r=20.0;
         --: xPtr[i] = 340.0+r*cos(radians);
         --: yPtr[i] = 255.0+r*sin(radians);
         radians := double(i)*pi/2.0;
         xPtr (i) := AquaTerm.C_Interface.C_FLOAT (340.0+Float(r)*cos(Float(radians)));
         yPtr (i) := AquaTerm.C_Interface.C_FLOAT (255.0+Float(r)*sin(Float(radians)));
      end loop;
      C_aqtTakeColorFromColormapEntry(2);
      C_aqtAddPolygon(xPtr(0)'Address, yPtr(0)'Address, 4);
      --
      for i in 0 .. 4 loop --: for (i=0; i<5; i++)
         --: double radians=(double)i*pi*0.8, r=20.0;
         --: xPtr[i] = 400.0+r*cos(radians);
         --: yPtr[i] = 255.0+r*sin(radians);
         radians := double(i)*pi*0.8;
         xPtr (i) := AquaTerm.C_Interface.C_FLOAT (400.0+Float(r)*cos(Float(radians)));
         yPtr (i) := AquaTerm.C_Interface.C_FLOAT (255.0+Float(r)*sin(Float(radians)));
      end loop;
      C_aqtTakeColorFromColormapEntry(3);
      C_aqtAddPolygon(xPtr(0)'Address, yPtr(0)'Address, 5);
      --
      C_aqtTakeColorFromColormapEntry(1);
      xPtr(5) := xPtr(0);
      yPtr(5) := yPtr(0);
      C_aqtAddPolyline(xPtr(0)'Address, yPtr(0)'Address, 6);   --: --: Overlay a polyline
      --
      for i in 0 .. 7 loop --: for (i=0; i<8; i++)
         --: double radians=(double)i*pi/4.0, r=20.0;
         --: xPtr[i] = 460.0+r*cos(radians);
         --: yPtr[i] = 255.0+r*sin(radians);
         radians := double(i)*pi/4.0;
         xPtr (i) := AquaTerm.C_Interface.C_FLOAT (460.0+Float(r)*cos(Float(radians)));
         yPtr (i) := AquaTerm.C_Interface.C_FLOAT (255.0+Float(r)*sin(Float(radians)));
      end loop;
      C_aqtTakeColorFromColormapEntry(4);
      C_aqtAddPolygon(xPtr(0)'Address, yPtr(0)'Address, 8);
      --
      for i in 0 .. 31 loop --: for (i=0; i<32; i++)
         --: double radians=(double)i*pi/16.0, r=20.0;
         --: xPtr[i] = 520.0+r*cos(radians);
         --: yPtr[i] = 255.0+r*sin(radians);
         radians := double(i)*pi/16.0;
         xPtr (i) := AquaTerm.C_Interface.C_FLOAT (520.0+Float(r)*cos(Float(radians)));
         yPtr (i) := AquaTerm.C_Interface.C_FLOAT (255.0+Float(r)*sin(Float(radians)));
      end loop;
      C_aqtTakeColorFromColormapEntry(5);
      C_aqtAddPolygon(xPtr(0)'Address, yPtr(0)'Address, 32);
   end;

   --: --: Images
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtAddLabel(+"Images", 320.0, 220.0, 0.0, C_AQTAlignLeft);

   C_aqtAddImageWithBitmap(rgbImage(0)'Address, 2, 2, 328.0, 200.0, 4.0, 4.0);
   C_aqtAddLabel(+"bits", 330.0, 180.0, 0.0, C_AQTAlignCenter);
   
   C_aqtAddImageWithBitmap(rgbImage(0)'Address, 2,2, 360.0, 190.0, 40.0, 15.0);
   C_aqtAddLabel(+"fit bounds", 380.0, 180.0, 0.0, C_AQTAlignCenter);

   C_aqtSetImageTransform(9.23880, 3.82683, -3.82683, 9.23880, 494.6, 186.9);
   C_aqtAddTransformedImageWithBitmap(rgbImage(0)'Address, 2,2, 0.0, 0.0, 600.0, 400.0);
   C_aqtAddLabel(+"scale, rotate & translate", 500.0, 180.0, 0.0, C_AQTAlignCenter);

   C_aqtResetImageTransform;

   --: --: Text
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetFontname(+"Times-Roman");
   C_aqtSetFontsize(16.0);
   C_aqtAddLabel(+"Times-Roman 16pt", 320.0, 150.0, 0.0, C_AQTAlignLeft);
   C_aqtTakeColorFromColormapEntry(2);
   C_aqtSetFontname(+"Times-Italic");
   C_aqtSetFontsize(16.0);
   C_aqtAddLabel(+"Times-Italic 16pt", 320.0, 130.0, 0.0, C_AQTAlignLeft);
   C_aqtTakeColorFromColormapEntry(4);
   C_aqtSetFontname(+"Zapfino");
   C_aqtSetFontsize(12.0);
   C_aqtAddLabel(+"Zapfino 12pt", 320.0, 104.0, 0.0, C_AQTAlignLeft);

   C_aqtTakeColorFromColormapEntry(2);
   C_aqtSetLinewidth(0.5);
   C_aqtMoveTo(510.5, 160.0);
   C_aqtAddLineTo(510.5, 100.0);
   x := 540.5;
   y := 75.5;
   C_aqtMoveTo(x+5.0, y);
   C_aqtAddLineTo(x-5.0, y);
   C_aqtMoveTo(x, y+5.0);
   C_aqtAddLineTo(x, y-5.0);

   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetFontname(+"Verdana");
   C_aqtSetFontsize(10.0);
   C_aqtAddLabel(+"left aligned", 510.5, 150.0, 0.0, C_AQTAlignLeft);
   C_aqtAddLabel(+"centered", 510.5, 130.0, 0.0, C_AQTAlignCenter);
   C_aqtAddLabel(+"right aligned", 510.5, 110.0, 0.0, C_AQTAlignRight);
   C_aqtSetFontname(+"Times-Roman");
   C_aqtSetFontsize(14.0);
   C_aqtAddLabel(+"-rotate", x, y, 90.0, C_AQTAlignLeft);
   C_aqtAddLabel(+"-rotate", x, y, 45.0, C_AQTAlignLeft);
   C_aqtAddLabel(+"-rotate", x, y, -30.0, C_AQTAlignLeft);
   C_aqtAddLabel(+"-rotate", x, y, -60.0, C_AQTAlignLeft);
   C_aqtAddLabel(+"-rotate", x, y, -90.0, C_AQTAlignLeft);

   --: --: String styling is _not_ possible from pure C
   C_aqtSetFontsize(12.0);
   C_aqtAddLabel(+"No underline, sub- or superscript from ""C""", 320.0, 75.0, 0.0, C_AQTAlignLeft);
   
   C_aqtTakeColorFromColormapEntry(2);
   C_aqtSetLinewidth(0.5);
   C_aqtMoveTo(320.0, 45.5);
   C_aqtAddLineTo(520.0, 45.5);
   C_aqtTakeColorFromColormapEntry(1);
   C_aqtSetFontname(+"Times-Italic");
   C_aqtSetFontsize(14.0);
   C_aqtAddLabel(+"Top", 330.0, 45.5, 0.0, (C_AQTAlignLeft + C_AQTAlignTop));
   C_aqtAddLabel(+"Bottom", 360.0, 45.5, 0.0, (C_AQTAlignLeft + C_AQTAlignBottom));
   C_aqtAddLabel(+"Middle", 410.0, 45.5, 0.0, (C_AQTAlignLeft + C_AQTAlignMiddle));
   C_aqtAddLabel(+"Baseline", 460.0, 45.5, 0.0, (C_AQTAlignLeft + C_AQTAlignBaseline));

   --: --: Draw it
   C_aqtRenderPlot;
   --: --: Let go of plot _when done_
   C_aqtClosePlot;
   C_aqtTerminate;
end;
-- (C) 2008 Marius Amado-Alves
