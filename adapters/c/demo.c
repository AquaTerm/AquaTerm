//
//  demo.c
//  AquaTerm
//
//  Created by Per Persson on Fri Nov 07 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

//
// This file contains an example of what can be done with
// AquaTerm and the corresponding library: libaqt.dylib
//
// This code can be build as a stand-alone executable (tool)
// from the command line:
// gcc -o demo demo.c -laquaterm -lobjc

#include "aquaterm/aquaterm.h"
#include <math.h>

int main(void)
{
   int i;
   char strBuf[256];
   float xPtr[128], yPtr[128];
   float x, y, f;
   double pi = 4.0*atan(1.0);
   unsigned char rgbImage[12]={
      255, 0, 0,
      0, 255, 0,
      0, 0, 255,
      0, 0, 0
   };

   // Initialize. Do it or fail miserably...
   aqtInit();
   // Open up a plot for drawing
   aqtOpenPlot(1);
   aqtSetPlotSize(620,420);
   aqtSetPlotTitle("Testview");
   // Set colormap
   aqtSetColormapEntry(0, 1.0, 1.0, 1.0); // white
   aqtSetColormapEntry(1, 0.0, 0.0, 0.0); // black
   aqtSetColormapEntry(2, 1.0, 0.0, 0.0); // red
   aqtSetColormapEntry(3, 0.0, 1.0, 0.0); // green
   aqtSetColormapEntry(4, 0.0, 0.0, 1.0); // blue
   aqtSetColormapEntry(5, 1.0, 0.0, 1.0); // purple
   aqtSetColormapEntry(6, 1.0, 1.0, 0.5); // yellow
   aqtSetColormapEntry(7, 0.0, 0.5, 0.5); // dark green
   // Set color explicitly
   aqtSetColor(0.0, 0.0, 0.0);
   aqtSetFontname("Helvetica");
   aqtSetFontsize(12.0);
   aqtAddLabel("Testview 620x420 pt", 4.0, 412.0, 0.0, AQTAlignLeft);
   // Frame plot
   aqtMoveTo(20, 20);
   aqtAddLineTo(600,20);
   aqtAddLineTo(600,400);
   aqtAddLineTo(20,400);
   aqtAddLineTo(20,20);
   aqtAddLabel("Frame 600x400 pt", 24, 30, 0.0, AQTAlignLeft);
   // Colormap
   aqtAddLabel("Custom colormap (8 out of 256)", 30, 390, 0.0, AQTAlignLeft);
   // Display the colormap, but first create a background for the white box...
   aqtSetColor(0.8, 0.8, 0.8);
   aqtAddFilledRect(28, 348, 24, 24);
   for (i=0; i<8; i++)
   {
      aqtTakeColorFromColormapEntry(i);
      aqtAddFilledRect(30+i*30, 350, 20, 20);
      // Print the color index
      aqtSetColor(0.5, 0.5, 0.5);
      sprintf(strBuf, "%d", i);
      aqtAddLabel(strBuf, 40+i*30, 360, 0.0, (AQTAlignCenter | AQTAlignMiddle));
   }
   // Continuos colors
   aqtTakeColorFromColormapEntry(1);
   aqtAddLabel("\"Any color you like\"", 320, 390, 0.0, AQTAlignLeft);
   aqtSetLinewidth(1.0);
   for (i=0; i<256; i++)
   {
      f = (float)i/255.0;
      aqtSetColor(1.0, f, f/2.0);
      aqtMoveTo(320+i, 370);
      aqtAddLineTo(320+i, 350);
      aqtSetColor(0.0, f, (1.0-f));
      aqtMoveTo(320+i, 348);
      aqtAddLineTo(320+i, 328);
      aqtSetColor((1.0-f), (1.0-f), (1.0-f));
      aqtMoveTo(320+i, 326);
      aqtAddLineTo(320+i, 306);
   }
   // Lines
   aqtTakeColorFromColormapEntry(1);
   for (f=1.0; f<13.0; f+=2.0)
   {
      float lw = f/2.0;
      aqtSetLinewidth(lw);
      aqtMoveTo(30, 200.5+f*10);
      aqtAddLineTo(200, 200.5+f*10);
      sprintf(strBuf, "linewidth %3.1f", lw);
      aqtAddLabel(strBuf, 210, 201.5+f*10, 0.0, AQTAlignLeft);
   }
   // linecap styles
   aqtSetLinewidth(11.0);
   aqtTakeColorFromColormapEntry(1);
   aqtSetLineCapStyle(AQTButtLineCapStyle);
   aqtMoveTo(40.5, 170.5);
   aqtAddLineTo(150.5, 170.5);
   aqtAddLabel("AQTButtLineCapStyle", 160.5, 170.5, 0.0, AQTAlignLeft);
   aqtSetLinewidth(1.0);
   aqtTakeColorFromColormapEntry(6);
   aqtMoveTo(40.5, 170.5);
   aqtAddLineTo(150.5, 170.5);

   aqtSetLinewidth(11.0);
   aqtTakeColorFromColormapEntry(1);
   aqtSetLineCapStyle(AQTRoundLineCapStyle);
   aqtMoveTo(40.5, 150.5);
   aqtAddLineTo(150.5, 150.5);
   aqtAddLabel("AQTRoundLineCapStyle", 160.5, 150.5, 0.0, AQTAlignLeft);
   aqtSetLinewidth(1.0);
   aqtTakeColorFromColormapEntry(6);
   aqtMoveTo(40.5, 150.5);
   aqtAddLineTo(150.5, 150.5);

   aqtSetLinewidth(11.0);
   aqtTakeColorFromColormapEntry(1);
   aqtSetLineCapStyle(AQTSquareLineCapStyle);
   aqtMoveTo(40.5, 130.5);
   aqtAddLineTo(150.5, 130.5);
   aqtAddLabel("AQTSquareLineCapStyle", 160.5, 130.5, 0.0, AQTAlignLeft);
   aqtSetLinewidth(1.0);
   aqtTakeColorFromColormapEntry(6);
   aqtMoveTo(40.5, 130.5);
   aqtAddLineTo(150.5, 130.5);

   // line joins
   aqtTakeColorFromColormapEntry(1);
   aqtAddLabel("Line joins:", 40, 90, 0.0, AQTAlignLeft);
   aqtSetLinewidth(11.0);
   aqtSetLineCapStyle(AQTButtLineCapStyle);
   aqtMoveTo(40, 50);
   aqtAddLineTo(75, 70);
   aqtAddLineTo(110, 50);
   aqtSetLinewidth(1.0);
   aqtTakeColorFromColormapEntry(6);
   aqtMoveTo(40, 50);
   aqtAddLineTo(75, 70);
   aqtAddLineTo(110, 50);

   aqtSetLinewidth(11.0);
   aqtTakeColorFromColormapEntry(1);
   aqtMoveTo(130, 50);
   aqtAddLineTo(150, 70);
   aqtAddLineTo(170, 50);
   aqtSetLinewidth(1.0);
   aqtTakeColorFromColormapEntry(6);
   aqtMoveTo(130, 50);
   aqtAddLineTo(150, 70);
   aqtAddLineTo(170, 50);

   aqtSetLinewidth(11.0);
   aqtTakeColorFromColormapEntry(1);
   aqtSetLineCapStyle(AQTButtLineCapStyle);
   aqtMoveTo(190, 50);
   aqtAddLineTo(200, 70);
   aqtAddLineTo(210, 50);
   aqtSetLinewidth(1.0);
   aqtTakeColorFromColormapEntry(6);
   aqtMoveTo(190, 50);
   aqtAddLineTo(200, 70);
   aqtAddLineTo(210, 50);

   // Polygons
   aqtTakeColorFromColormapEntry(1);
   aqtAddLabel("Polygons", 320, 290, 0.0, AQTAlignLeft);
   for (i=0; i<4; i++)
   {
      double radians=(double)i*pi/2.0, r=20.0;
      xPtr[i] = 340.0+r*cos(radians);
      yPtr[i] = 255.0+r*sin(radians);
   }
   aqtTakeColorFromColormapEntry(2);
   aqtAddPolygon(xPtr, yPtr, 4);

   for (i=0; i<5; i++)
   {
      double radians=(double)i*pi*0.8, r=20.0;
      xPtr[i] = 400.0+r*cos(radians);
      yPtr[i] = 255.0+r*sin(radians);
   }
   aqtTakeColorFromColormapEntry(3);
   aqtAddPolygon(xPtr, yPtr, 5);

   aqtTakeColorFromColormapEntry(1);
   xPtr[5] = xPtr[0];
   yPtr[5] = yPtr[0];
   aqtAddPolyline(xPtr, yPtr, 6);   // Overlay a polyline

   for (i=0; i<8; i++)
   {
      double radians=(double)i*pi/4.0, r=20.0;
      xPtr[i] = 460.0+r*cos(radians);
      yPtr[i] = 255.0+r*sin(radians);
   }
   aqtTakeColorFromColormapEntry(4);
   aqtAddPolygon(xPtr, yPtr, 8);

   for (i=0; i<32; i++)
   {
      double radians=(double)i*pi/16.0, r=20.0;
      xPtr[i] = 520.0+r*cos(radians);
      yPtr[i] = 255.0+r*sin(radians);
   }
   aqtTakeColorFromColormapEntry(5);
   aqtAddPolygon(xPtr, yPtr, 32);

   // Images
   aqtTakeColorFromColormapEntry(1);
   aqtAddLabel("Images", 320, 220, 0.0, AQTAlignLeft);
   aqtAddImageWithBitmap(rgbImage, 2, 2, 328, 200, 4, 4);
   aqtAddLabel("bits", 330, 180, 0.0, AQTAlignCenter);
   aqtAddImageWithBitmap(rgbImage, 2,2, 360, 190, 40, 15);
   aqtAddLabel("fit bounds", 380, 180, 0.0, AQTAlignCenter);
   aqtSetImageTransform(9.23880, 3.82683, -3.82683, 9.23880, 494.6, 186.9);
   aqtAddTransformedImageWithBitmap(rgbImage, 2,2, 0., 0., 600., 400.);
   aqtAddLabel("scale, rotate & translate", 500, 180, 0.0, AQTAlignCenter);
   aqtResetImageTransform();

   // Text
   aqtTakeColorFromColormapEntry(1);
   aqtSetFontname("Times-Roman");
   aqtSetFontsize(16.0);
   aqtAddLabel("Times-Roman 16pt", 320, 150, 0.0, AQTAlignLeft);
   aqtTakeColorFromColormapEntry(2);
   aqtSetFontname("Times-Italic");
   aqtSetFontsize(16.0);
   aqtAddLabel("Times-Italic 16pt", 320, 130, 0.0, AQTAlignLeft);
   aqtTakeColorFromColormapEntry(4);
   aqtSetFontname("Zapfino");
   aqtSetFontsize(12.0);
   aqtAddLabel("Zapfino 12pt", 320, 104, 0.0, AQTAlignLeft);

   aqtTakeColorFromColormapEntry(2);
   aqtSetLinewidth(0.5);
   aqtMoveTo(510.5, 160);
   aqtAddLineTo(510.5, 100);
   x = 540.5;
   y = 75.5;
   aqtMoveTo(x+5, y);
   aqtAddLineTo(x-5, y);
   aqtMoveTo(x, y+5);
   aqtAddLineTo(x, y-5);

   aqtTakeColorFromColormapEntry(1);
   aqtSetFontname("Verdana");
   aqtSetFontsize(10.0);
   aqtAddLabel("left aligned", 510.5, 150, 0.0, AQTAlignLeft);
   aqtAddLabel("centered", 510.5, 130, 0.0, AQTAlignCenter);
   aqtAddLabel("right aligned", 510.5, 110, 0.0, AQTAlignRight);
   aqtSetFontname("Times-Roman");
   aqtSetFontsize(14.0);
   aqtAddLabel("-rotate", x, y, 90.0, AQTAlignLeft);
   aqtAddLabel("-rotate", x, y, 45.0, AQTAlignLeft);
   aqtAddLabel("-rotate", x, y, -30.0, AQTAlignLeft);
   aqtAddLabel("-rotate", x, y, -60.0, AQTAlignLeft);
   aqtAddLabel("-rotate", x, y, -90.0, AQTAlignLeft);

   // String styling is _not_ possible from pure C
   aqtSetFontsize(12.0);
   aqtAddLabel("No underline, sub- or superscript from \"C\"", 320, 75, 0.0, AQTAlignLeft);
   
   aqtTakeColorFromColormapEntry(2);
   aqtSetLinewidth(0.5);
   aqtMoveTo(320, 45.5);
   aqtAddLineTo(520, 45.5);
   aqtTakeColorFromColormapEntry(1);
   aqtSetFontname("Times-Italic");
   aqtSetFontsize(14.0);
   aqtAddLabel("Top", 330, 45.5, 0.0, (AQTAlignLeft | AQTAlignTop));
   aqtAddLabel("Bottom", 360, 45.5, 0.0, (AQTAlignLeft | AQTAlignBottom));
   aqtAddLabel("Middle", 410, 45.5, 0.0, (AQTAlignLeft | AQTAlignMiddle));
   aqtAddLabel("Baseline", 460, 45.5, 0.0, (AQTAlignLeft | AQTAlignBaseline));

   // Draw it
   aqtRenderPlot();
   // Let go of plot _when done_
   aqtClosePlot();
}
