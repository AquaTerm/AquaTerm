//
//  Demo.m
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
// gcc -o demo Demo.m -laqt -Framework Foundation
// _or_
// executed from inside AquaTerm using menu Debug -> Testview. 


#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

#ifndef AQT_APP
void aqtTestview(AQTAdapter *adapter);

int main(void)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  AQTAdapter *adapter = [[AQTAdapter alloc] init];
  aqtTestview(adapter);
  return 0;
}
void aqtTestview(AQTAdapter *adapter)
#else
void aqtTestview(id sender)
#endif
{
NSPoint points[128];
  NSPoint pos;
int i;
float f;
double pi = 4.0*atan(1.0);
unsigned char rgbImage[12]={
  255, 0, 0,
  0, 255, 0,
  0, 0, 255,
  0, 0, 0
};

#ifdef AQT_APP
AQTAdapter *adapter = [sender sharedAdapter];
#endif

[adapter openPlotWithIndex:1];
[adapter setPlotSize:NSMakeSize(620,420)];
[adapter setPlotTitle:@"Testview"];
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
[adapter addLabel:@"Testview 620x420 pt" position:NSMakePoint(4,412) angle:0.0 align:AQTAlignLeft];
// Frame plot
[adapter moveToPoint:NSMakePoint(20,20)];
[adapter addLineToPoint:NSMakePoint(600,20)];
[adapter addLineToPoint:NSMakePoint(600,400)];
[adapter addLineToPoint:NSMakePoint(20,400)];
[adapter addLineToPoint:NSMakePoint(20,20)];
[adapter addLabel:@"Frame 600x400 pt" position:NSMakePoint(24,30) angle:0.0 align:AQTAlignLeft];
// Colormap
[adapter addLabel:@"Custom colormap (8 out of 256)" position:NSMakePoint(30, 390) angle:0.0 align:AQTAlignLeft];
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
           position:NSMakePoint(40+i*30, 360)
              angle:0.0
              align:AQTAlignCenter];
}
// Contiouos colors
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"\"Any color you like\"" position:NSMakePoint(320, 390) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
for (i=0; i<256; i++)
{
  f = (float)i/255.0;
  [adapter setColorRed:1.0 green:f blue:f/2.0];
  [adapter moveToPoint:NSMakePoint(320+i, 370)];
  [adapter addLineToPoint:NSMakePoint(320+i, 350)];
  [adapter setColorRed:0.0 green:f blue:(1.0-f)];
  [adapter moveToPoint:NSMakePoint(320+i, 348)];
  [adapter addLineToPoint:NSMakePoint(320+i, 328)];
  [adapter setColorRed:(1.0-f) green:(1.0-f) blue:(1.0-f)];
  [adapter moveToPoint:NSMakePoint(320+i, 326)];
  [adapter addLineToPoint:NSMakePoint(320+i, 306)];
}

// Lines
[adapter takeColorFromColormapEntry:1];
for (f=1.0; f<13.0; f+=2.0)
{
  float lw = f/2.0;
  [adapter setLinewidth:lw];
  [adapter moveToPoint:NSMakePoint(30, 200.5+f*10)];
  [adapter addLineToPoint:NSMakePoint(200, 200.5+f*10)];
  [adapter addLabel:[NSString stringWithFormat:@"linewidth %3.1f", lw]
           position:NSMakePoint(210, 201.5+f*10)
              angle:0.0
              align:AQTAlignLeft];
}
// linecap styles
[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTButtLineCapStyle];
[adapter moveToPoint:NSMakePoint(40.5, 170.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 170.5)];
[adapter addLabel:@"AQTButtLineCapStyle" position:NSMakePoint(160.5, 170.5) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40.5, 170.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 170.5)];

[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTRoundLineCapStyle];
[adapter moveToPoint:NSMakePoint(40.5, 150.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 150.5)];
[adapter addLabel:@"AQTRoundLineCapStyle" position:NSMakePoint(160.5, 150.5) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40.5, 150.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 150.5)];

[adapter setLinewidth:11.0];
[adapter takeColorFromColormapEntry:1];
[adapter setLineCapStyle:AQTSquareLineCapStyle];
[adapter moveToPoint:NSMakePoint(40.5, 130.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 130.5)];
[adapter addLabel:@"AQTSquareLineCapStyle" position:NSMakePoint(160.5, 130.5) angle:0.0 align:AQTAlignLeft];
[adapter setLinewidth:1.0];
[adapter takeColorFromColormapEntry:6];
[adapter moveToPoint:NSMakePoint(40.5, 130.5)];
[adapter addLineToPoint:NSMakePoint(150.5, 130.5)];

// line joins
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Line joins:" position:NSMakePoint(40, 90) angle:0.0 align:AQTAlignLeft];
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
[adapter addLabel:@"Polygons" position:NSMakePoint(320, 290) angle:0.0 align:AQTAlignLeft];
for (i=0; i<4; i++)
{
  double radians=(double)i*pi/2.0, r=20.0;
  points[i]=NSMakePoint(340.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:2];
[adapter addPolygonWithPoints:points pointCount:4];
for (i=0; i<5; i++)
{
  double radians=(double)i*pi*0.8, r=20.0;
  points[i]=NSMakePoint(400.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:3];
[adapter addPolygonWithPoints:points pointCount:5];
for (i=0; i<8; i++)
{
  double radians=(double)i*pi/4.0, r=20.0;
  points[i]=NSMakePoint(460.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:4];
[adapter addPolygonWithPoints:points pointCount:8];
for (i=0; i<32; i++)
{
  double radians=(double)i*pi/16.0, r=20.0;
  points[i]=NSMakePoint(520.0+r*cos(radians), 255.0+r*sin(radians));
}
[adapter takeColorFromColormapEntry:5];
[adapter addPolygonWithPoints:points pointCount:32];

// Images
[adapter takeColorFromColormapEntry:1];
[adapter addLabel:@"Images" position:NSMakePoint(320, 220) angle:0.0 align:AQTAlignLeft];
[adapter addImageWithBitmap:rgbImage size:NSMakeSize(2,2) bounds:NSMakeRect(328, 200, 4, 4)];
[adapter addLabel:@"bits" position:NSMakePoint(330, 180) angle:0.0 align:AQTAlignCenter];
[adapter addImageWithBitmap:rgbImage size:NSMakeSize(2,2) bounds:NSMakeRect(360, 190, 40, 15)];
[adapter addLabel:@"fit bounds" position:NSMakePoint(380, 180) angle:0.0 align:AQTAlignCenter];
[adapter addLabel:@"scale, rotate & translate" position:NSMakePoint(500, 180) angle:0.0 align:AQTAlignCenter];

// Text
[adapter takeColorFromColormapEntry:1];
[adapter setFontname:@"Times-Roman"];
[adapter setFontsize:16.0];
[adapter addLabel:@"Times-Roman 16pt" position:NSMakePoint(320, 150) angle:0.0 align:AQTAlignLeft];
[adapter takeColorFromColormapEntry:2];
[adapter setFontname:@"Times-Italic"];
[adapter setFontsize:16.0];
[adapter addLabel:@"Times-Italic 16pt" position:NSMakePoint(320, 130) angle:0.0 align:AQTAlignLeft];
[adapter takeColorFromColormapEntry:4];
[adapter setFontname:@"Zapfino"];
[adapter setFontsize:12.0];
[adapter addLabel:@"Zapfino 12pt" position:NSMakePoint(320, 104) angle:0.0 align:AQTAlignLeft];

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
[adapter addLabel:@"left aligned" position:NSMakePoint(510.5, 150) angle:0.0 align:AQTAlignLeft];
[adapter addLabel:@"centered" position:NSMakePoint(510.5, 130) angle:0.0 align:AQTAlignCenter];
[adapter addLabel:@"right aligned" position:NSMakePoint(510.5, 110) angle:0.0 align:AQTAlignRight];
[adapter setFontname:@"Times-Roman"];
[adapter setFontsize:14.0];
[adapter addLabel:@"-rotate" position:pos angle:90.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" position:pos angle:45.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" position:pos angle:-30.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" position:pos angle:-60.0 align:AQTAlignLeft];
[adapter addLabel:@"-rotate" position:pos angle:-90.0 align:AQTAlignLeft];

// Some styling is possible
{
  NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:@"Underline, Super23- and sub45-script"] autorelease];
  [attrStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInt:1] range:NSMakeRange(0,9)];
  [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:1] range:NSMakeRange(16,1)];
  [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:2] range:NSMakeRange(17,1)];
  [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-1] range:NSMakeRange(27,1)];
  [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-2] range:NSMakeRange(28,1)];
  [adapter addLabel:attrStr position:NSMakePoint(320, 75) angle:0.0 align:AQTAlignLeft];  
}
[adapter takeColorFromColormapEntry:2];
[adapter setLinewidth:0.5];
[adapter moveToPoint:NSMakePoint(320, 45.5)];
[adapter addLineToPoint:NSMakePoint(520, 45.5)];
[adapter takeColorFromColormapEntry:1];
[adapter setFontname:@"Times-Italic"];
[adapter setFontsize:14.0];
[adapter addLabel:@"Top" position:NSMakePoint(330, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignTop)];
[adapter addLabel:@"Bottom" position:NSMakePoint(360, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignBottom)];
[adapter addLabel:@"Middle" position:NSMakePoint(410, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignMiddle)];
[adapter addLabel:@"Baseline" position:NSMakePoint(460, 45.5) angle:0.0 align:(AQTAlignLeft | AQTAlignBaseline)];

[adapter renderPlot];

}