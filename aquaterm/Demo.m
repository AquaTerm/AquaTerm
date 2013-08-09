//
//  Demo.m
//  AquaTerm
//
//  Created by Per Persson on Fri Nov 07 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

//
// This file contains an example of what can be done with AquaTerm
//
// This code can be build as a stand-alone executable (tool)
// from the command line:
// gcc -DAQT_STANDALONE -o demo Demo.m -framework AquaTerm -framework Foundation
// _or_
// executed from inside AquaTerm using menu Debug -> Testview. 

#import <Foundation/Foundation.h>
#ifndef AQT_STANDALONE
#import <AppKit/AppKit.h>
#import "AQTController.h"
#endif
#import <AquaTerm/AQTAdapter.h>
#include <tgmath.h>

#ifdef AQT_STANDALONE
void aqtTestview(AQTAdapter *adapter);

int32_t main(void)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  AQTAdapter *adapter = [[AQTAdapter alloc] init];
  aqtTestview(adapter);
  [adapter release];
  return 0;
}
void aqtTestview(AQTAdapter *adapter)
#else
void aqtTestview(id sender)
#endif
{
NSPoint points[128];
  NSPoint pos;
int32_t i;
float f;
double pi = 4.0*atan(1.0);
unsigned char rgbImage[12]={
  255, 0, 0,
  0, 255, 0,
  0, 0, 255,
  0, 0, 0
};

#ifndef AQT_STANDALONE
AQTAdapter *adapter = [sender sharedAdapter];
#endif

[adapter openPlotWithIndex:1];
[adapter setPlotSize:NSMakeSize(620,420)];
[adapter setPlotTitle:@"Testview"];
[adapter setAcceptingEvents:YES];
// Set colormap
[adapter setColormapEntry:0 red:1.0 green:1.0 blue:1.0]; // white
[adapter setColormapEntry:1 red:0.0 green:0.0 blue:0.0]; // black
[adapter setColormapEntry:2 red:1.0 green:0.0 blue:0.0]; // red
[adapter setColormapEntry:3 red:0.0 green:1.0 blue:0.0]; // green
[adapter setColormapEntry:4 red:0.0 green:0.0 blue:1.0]; // blue
[adapter setColormapEntry:5 red:1.0 green:0.0 blue:1.0]; // purple
[adapter setColormapEntry:6 red:1.0 green:1.0 blue:0.5]; // yellow
[adapter setColormapEntry:7 red:0.0 green:0.5 blue:0.5]; // dark green
                                                         // Set color directly
[adapter setColorRed:0.0 green:0.0 blue:0.0];
[adapter setFontname:@"Helvetica"];
[adapter setFontsize:12.0];
[adapter addLabel:@"Testview 620x420 pt" atPoint:NSMakePoint(4,412) angle:0.0 align:AQTAlignLeft];
// Frame plot
[adapter moveToPoint:NSMakePoint(20,20)];
[adapter addLineToPoint:NSMakePoint(600,20)];
[adapter addLineToPoint:NSMakePoint(600,400)];
[adapter addLineToPoint:NSMakePoint(20,400)];
[adapter addLineToPoint:NSMakePoint(20,20)];
[adapter addLabel:@"Frame 600x400 pt" atPoint:NSMakePoint(24,30) angle:0.0 align:AQTAlignLeft];
// Colormap
[adapter addLabel:@"Custom colormap (8 out of 256)" atPoint:NSMakePoint(30, 385) angle:0.0 align:AQTAlignLeft];
// Display the colormap, but first create a background for the white box...
[adapter setColorRed:0.8 green:0.8 blue:0.8];
[adapter addFilledRect:NSMakeRect(28, 348, 24, 24)];
for (i=0; i<8; i++)
{
  [adapter takeColorFromColormapEntry:i];
  [adapter addFilledRect:NSMakeRect(30+i*30, 350, 20, 20)];
  // Print the color index
  [adapter setColorRed:0.5 green:0.5 blue:0.5];
  [adapter addLabel:[NSString stringWithFormat:@"%d", i]
           atPoint:NSMakePoint(40+i*30, 360)
              angle:0.0
              align:AQTAlignCenter];
}
// Contiouos colors
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"\"Any color you like\"" atPoint:NSMakePoint(320, 385) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
for (i=0; i<256; i++)
{
  f = (float)i/255.0;
  [adapter setColorRed:1.0 green:f blue:f/2.0];
  [adapter addFilledRect:NSMakeRect(320+i, 350, 1, 20)];
  [adapter setColorRed:0.0 green:f blue:(1.0-f)];
  [adapter addFilledRect:NSMakeRect(320+i, 328, 1, 20)];
  [adapter setColorRed:(1.0-f) green:(1.0-f) blue:(1.0-f)];
  [adapter addFilledRect:NSMakeRect(320+i, 306, 1, 20)];
}

// Lines
static float pat[4][4]={{4,2,4,2},{4,2,2,2},{8,4,8,4},{2,2,2,2}};

[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Specify linewidth and pattern" atPoint:NSMakePoint(30, 325)];
for (f=1.0; f<13.0; f+=2.0)
{
  float lw = f/2.0;
  [adapter setLinewidth:round(lw-.5)];
  [adapter setLinestylePattern:pat[((int32_t)f)%3] count:4 phase:0.0];
  [adapter moveToPoint:NSMakePoint(30, 200.5+f*10)];
  [adapter addLineToPoint:NSMakePoint(180, 200.5+f*10)];
}
[adapter setLinestyleSolid];

// Clip rect
{
   NSRect r = NSMakeRect(200, 200, 60, 120);
   [adapter addLabel:@"Clip rects" atPoint:NSMakePoint(200, 325)];
   [adapter setColorRed:.9 green:.9 blue:.9];
   [adapter addFilledRect:r];
   [adapter setColorRed:0 green:0 blue:0];
   [adapter setClipRect:r];
   [adapter addLabel:@"Clipped text. Clipped text. Clipped text." atPoint:NSMakePoint(180, 230) angle:30.0 align:(AQTAlignCenter | AQTAlignMiddle)];
   [adapter setLinewidth:1.0];
   for (i=0; i<5; i++)
   {
      double radians=(double)i*pi*0.8, r=30.0;
      points[i]=NSMakePoint(240.0+r*cos(radians), 215.0+r*sin(radians));
   }
   [adapter takeColorFromColormapEntry:3];
   [adapter addPolygonWithVertexPoints:points pointCount:5];
   [adapter takeColorFromColormapEntry:1];
   points[5] = points[0];
   [adapter addPolylineWithPoints:points pointCount:6];
   [adapter addImageWithBitmap:rgbImage size:NSMakeSize(2,2) bounds:NSMakeRect(190, 280, 50, 50)]; // ClipRect demo
   [adapter setDefaultClipRect];
   
   // ***** Reset clip rect! *****
}
// linecap styles
[adapter setFontsize:8.0];
[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTButtLineCapStyle];
[adapter moveToPoint:NSMakePoint(40.5, 170.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 170.5)];
[adapter addLabel:@"AQTButtLineCapStyle" atPoint:NSMakePoint(160.5, 170.5) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40.5, 170.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 170.5)];

[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTRoundLineCapStyle];
[adapter moveToPoint:NSMakePoint(40.5, 150.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 150.5)];
[adapter addLabel:@"AQTRoundLineCapStyle" atPoint:NSMakePoint(160.5, 150.5) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40.5, 150.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 150.5)];

[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTSquareLineCapStyle];
[adapter moveToPoint:NSMakePoint(40.5, 130.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 130.5)];
[adapter addLabel:@"AQTSquareLineCapStyle" atPoint:NSMakePoint(160.5, 130.5) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40.5, 130.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 130.5)];
[adapter setFontsize:12.0];

// line joins
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Line joins:" atPoint:NSMakePoint(40, 90) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:11.0];
[adapter setLineCapStyle:AQTButtLineCapStyle];
[adapter moveToPoint:NSMakePoint(40, 50)];
[adapter addLineToPoint:NSMakePoint(75, 70)];
[adapter addLineToPoint:NSMakePoint(110, 50)];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40, 50)];
[adapter addLineToPoint:NSMakePoint(75, 70)];
[adapter addLineToPoint:NSMakePoint(110, 50)];

[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter moveToPoint:NSMakePoint(130, 50)];
[adapter addLineToPoint:NSMakePoint(150, 70)];
[adapter addLineToPoint:NSMakePoint(170, 50)];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(130, 50)];
[adapter addLineToPoint:NSMakePoint(150, 70)];
[adapter addLineToPoint:NSMakePoint(170, 50)];

[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTButtLineCapStyle];
[adapter moveToPoint:NSMakePoint(190, 50)];
[adapter addLineToPoint:NSMakePoint(200, 70)];
[adapter addLineToPoint:NSMakePoint(210, 50)];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(190, 50)];
[adapter addLineToPoint:NSMakePoint(200, 70)];
[adapter addLineToPoint:NSMakePoint(210, 50)];

// Polygons
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Polygons" atPoint:NSMakePoint(320, 290) angle:0.0 align:AQTAlignLeft];
for (i=0; i<4; i++)
{
  double radians=(double)i*pi/2.0, r=20.0;
  points[i]=NSMakePoint(340.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:2];
[adapter addPolygonWithVertexPoints:points pointCount:4];
for (i=0; i<5; i++)
{
  double radians=(double)i*pi*0.8, r=20.0;
  points[i]=NSMakePoint(400.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:3];
[adapter addPolygonWithVertexPoints:points pointCount:5];
[adapter takeColorFromColormapEntry:1];
points[5] = points[0];
[adapter addPolylineWithPoints:points pointCount:6];

for (i=0; i<8; i++)
{
  double radians=(double)i*pi/4.0, r=20.0;
  points[i]=NSMakePoint(460.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:4];
[adapter addPolygonWithVertexPoints:points pointCount:8];

// Circles with alpha transparency
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Alpha channel" atPoint:NSMakePoint(530, 290) angle:0.0 align:AQTAlignCenter];
{
   float x[] = {520.0, 540.0, 540.0};
   float y[] = {255.0, 245.0, 265.0};
   float red[] = {1.0, 0.0, 0.0};
   float green[] = {0.0, 1.0, 0.0};
   float blue[] = {0.0, 0.0, 1.0};
   int j;
   
   for (j=0; j<3; j++) {
      for (i=0; i<32; i++) {
         double radians=(double)i*pi/16.0, r=20.0;
         points[i]=NSMakePoint(x[j]+r*cos(radians), y[j]+r*sin(radians));
      }
      [adapter setColorRed:red[j] green:green[j] blue:blue[j] alpha:0.5];
      [adapter addPolygonWithVertexPoints:points pointCount:32];
   }
}
// Images
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Images" atPoint:NSMakePoint(320, 220) angle:0.0 align:AQTAlignLeft];
[adapter addImageWithBitmap:rgbImage size:NSMakeSize(2,2) bounds:NSMakeRect(328, 200, 4, 4)];
[adapter addLabel:@"bits" atPoint:NSMakePoint(330, 180) angle:0.0 align:AQTAlignCenter];
[adapter addImageWithBitmap:rgbImage size:NSMakeSize(2,2) bounds:NSMakeRect(360, 190, 40, 15)];
[adapter addLabel:@"fit bounds" atPoint:NSMakePoint(380, 180) angle:0.0 align:AQTAlignCenter];
[adapter setImageTransformM11:9.23880 m12:3.82683 m21:-3.82683 m22:9.23880 tX:494.6 tY:186.9];
[adapter addTransformedImageWithBitmap:rgbImage size:NSMakeSize(2,2) clipRect:NSMakeRect(0, 0, 600, 400)];
[adapter addLabel:@"scale, rotate & translate" atPoint:NSMakePoint(500, 180) angle:0.0 align:AQTAlignCenter];
[adapter resetImageTransform]; // clean up


// Text
[adapter setFontname:@"Times-Roman"];
NSString *s = [NSString stringWithFormat:@"Unicode: %C %C %C %C%C%C%C%C", (unichar)0x2124, (unichar)0x2133, (unichar)0x5925, (unichar)0x2654, (unichar)0x2655, (unichar)0x2656, (unichar)0x2657, (unichar)0x2658]; 
NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:s];
[as setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"AppleSymbols", @"AQTFontname", nil] range:NSMakeRange(9,11)];
[as setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"STSong", @"AQTFontname", nil] range:NSMakeRange(13,1)];


[adapter takeColorFromColormapEntry:1];
[adapter setFontname:@"Times-Roman"];
[adapter setFontsize:12.0];
[adapter addLabel:as atPoint:NSMakePoint(320,150)];
//[adapter addLabel:@"Times-Roman 16pt" atPoint:NSMakePoint(320, 150) angle:0.0 align:AQTAlignLeft];
[adapter takeColorFromColormapEntry:2];
[adapter setFontname:@"Times-Italic"];
[adapter setFontsize:16.0];
[adapter addLabel:@"Times-Italic 16pt" atPoint:NSMakePoint(320, 130) angle:0.0 align:AQTAlignLeft];
[adapter takeColorFromColormapEntry:4];
[adapter setFontname:@"Zapfino"];
[adapter setFontsize:12.0];
[adapter addLabel:@"Zapfino 12pt" atPoint:NSMakePoint(320, 104) angle:0.0 align:AQTAlignLeft];

[adapter takeColorFromColormapEntry:2];
[adapter setLinewidth:0.5];
[adapter moveToPoint:NSMakePoint(510.5, 160)];
[adapter addLineToPoint:NSMakePoint(510.5, 100)];
pos = NSMakePoint(540.5, 75.5);
[adapter moveToPoint:NSMakePoint(pos.x+5, pos.y)];
[adapter addLineToPoint:NSMakePoint(pos.x-5, pos.y)];
[adapter moveToPoint:NSMakePoint(pos.x, pos.y+5)];
[adapter addLineToPoint:NSMakePoint(pos.x, pos.y-5)];

[adapter takeColorFromColormapEntry:1];
[adapter setFontname:@"Verdana"];
[adapter setFontsize:10.0];
[adapter addLabel:@"left align" atPoint:NSMakePoint(510.5, 150) angle:0.0 align:AQTAlignLeft];
[adapter addLabel:@"centered" atPoint:NSMakePoint(510.5, 130) angle:0.0 align:AQTAlignCenter];
[adapter addLabel:@"right align" atPoint:NSMakePoint(510.5, 110) angle:0.0 align:AQTAlignRight];
[adapter setFontname:@"Times-Roman"];
[adapter setFontsize:14.0];
[adapter addLabel:@"-rotate" atPoint:pos angle:90.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" atPoint:pos angle:45.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" atPoint:pos angle:-30.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" atPoint:pos angle:-60.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" atPoint:pos angle:-90.0 align:AQTAlignLeft];
// Shear
[adapter setFontname:@"Arial"];
[adapter setFontsize:12.0];
[adapter addLabel:@"Rotate & shear" atPoint:NSMakePoint(430, 105) angle:45.0 shearAngle:45.0 align:AQTAlignLeft];


// Some styling is possible
{
  NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:@"Underline, super- and subscript123"] autorelease];
  [attrStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInteger:1] range:NSMakeRange(0,9)];
  [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:-1] range:NSMakeRange(31,1)];
  [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:1] range:NSMakeRange(32,2)];
  [adapter addLabel:attrStr atPoint:NSMakePoint(320, 75) angle:0.0 align:AQTAlignLeft];  
}
[adapter takeColorFromColormapEntry:2];
[adapter setLinewidth:0.5];
[adapter moveToPoint:NSMakePoint(320, 45.5)];
[adapter addLineToPoint:NSMakePoint(520, 45.5)];
[adapter takeColorFromColormapEntry:1];
[adapter setFontname:@"Times-Italic"];
[adapter setFontsize:14.0];
[adapter addLabel:@"Top" atPoint:NSMakePoint(330, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignTop)];
[adapter addLabel:@"Bottom" atPoint:NSMakePoint(360, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignBottom)];
[adapter addLabel:@"Middle" atPoint:NSMakePoint(410, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignMiddle)];
[adapter addLabel:@"Baseline" atPoint:NSMakePoint(460, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignBaseline)];

// Equations
{
   NSMutableAttributedString *attrStr;
   [adapter setFontname:@"Helvetica"];
   [adapter setFontsize:12.0];
   [adapter addLabel:@"Equation style" atPoint:NSMakePoint(260, 95) angle:0.0 align:AQTAlignCenter];

   [adapter setFontname:@"Times-Roman"];
   [adapter setFontsize:14.0];

   attrStr = [[[NSMutableAttributedString alloc] initWithString:@"e-ip+1= 0"] autorelease];
   [attrStr addAttribute:@"AQTFontname" value:@"Symbol" range:NSMakeRange(3,1)]; // Greek
   [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:1] range:NSMakeRange(1,3)]; // eponent
   [attrStr addAttribute:@"AQTFontsize" value:[NSNumber numberWithDouble:6.0] range:NSMakeRange(7,1)]; // extra spacing
   
   [adapter addLabel:attrStr atPoint:NSMakePoint(260, 75) angle:0.0 align:AQTAlignCenter];

   attrStr = [[[NSMutableAttributedString alloc] initWithString:@"mSke-wk2"] autorelease];
   [attrStr addAttribute:@"AQTFontname" value:@"Symbol" range:NSMakeRange(0,2)];
   [attrStr addAttribute:@"AQTFontsize" value:[NSNumber numberWithDouble:20.0] range:NSMakeRange(1,1)];
   [attrStr addAttribute:@"AQTBaselineAdjust" value:[NSNumber numberWithDouble:-0.25] range:NSMakeRange(1,1)]; // Lower symbol 25%
   [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:-1] range:NSMakeRange(2,1)];
   [attrStr addAttribute:@"AQTFontname" value:@"Times-Roman" range:NSMakeRange(3,1)];
   [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:1] range:NSMakeRange(4,2)];
   [attrStr addAttribute:@"AQTFontname" value:@"Symbol" range:NSMakeRange(5,1)];
   [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:-2] range:NSMakeRange(6,1)];
   [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInteger:2] range:NSMakeRange(7,1)];

   [adapter addLabel:attrStr atPoint:NSMakePoint(260, 45) angle:0.0 align:AQTAlignCenter];

}

[adapter renderPlot];
// [NSException raise:@"AQTFatalException" format:@"Testing"];

[adapter closePlot];
}
