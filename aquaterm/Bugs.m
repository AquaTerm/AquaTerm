//
//  Bugs.m
//  AquaTerm
//
//  Created by Per Persson on Fri Nov 07 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

//
// This file contains tests for current bugs and issues in
// AquaTerm and the corresponding library: libaqt.dylib
//
// This code can be build as a stand-alone executable (tool)
// from the command line:
// gcc -o bugs Bugs.m -laqt -Framework Foundation
// _or_
// executed from AquaTerm using menu Debug -> Exercise bugs.

#import <Foundation/Foundation.h>
#ifdef AQT_APP
#import <AppKit/AppKit.h>
#endif
#import "AQTAdapter.h"

// Testing the use of a callback function to handle errors in the server
static void customEventHandler(int index, NSString *event)
{
  NSLog(@"Custom event handler --- %@ from %d", event, index);
}


#ifndef AQT_APP
void aqtDebug(AQTAdapter *adapter);

int main(void)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  AQTAdapter *adapter = [[AQTAdapter alloc] init];
  aqtDebug(adapter);
  return 0;
}
void aqtDebug(AQTAdapter *adapter)
#else
void aqtDebug(id sender)
#endif
{
#ifdef AQT_APP
  AQTAdapter *adapter = [sender sharedAdapter];
#endif
  NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString:@"Fancy string! yaddadaddadadadda"];
  //   NSPoint polygon[5];
  unsigned char bytes[12]={
    255, 0, 0,
    0, 255, 0,
    0, 0, 255,
    0, 0, 0
  };
  //   float xf=0.0;
  int i;
  int x,y;
  if (!adapter)
  {
    NSLog(@"Failed to init adapter");
  }

  [adapter setEventHandler:customEventHandler];
  [adapter openPlotWithIndex:2];
  [adapter setPlotSize:NSMakeSize(400,300)];
  [adapter setPlotTitle:@"Testing"];
  [adapter addLabel:@"Leftandlong" position:NSMakePoint(100,50) angle:0.0 align:0];
  [adapter addLabel:@"Leftandlong" position:NSMakePoint(100,150) angle:30.0 align:0];
  [adapter addLabel:@"Leftandlong" position:NSMakePoint(100,250) angle:45.0 align:0];
  [adapter addLabel:@"Centerandlong" position:NSMakePoint(200,150) angle:0.0 align:1];
  [adapter addLabel:@"Centerandlong" position:NSMakePoint(200,150) angle:30.0 align:1];
  [adapter addLabel:@"Centerandlong" position:NSMakePoint(200,150) angle:45.0 align:1];
  [adapter addLabel:@"Rightandlong" position:NSMakePoint(300,50) angle:0.0 align:2];
  [adapter addLabel:@"Rightandlong" position:NSMakePoint(300,150) angle:30.0 align:2];
  [adapter addLabel:@"Rightandlong" position:NSMakePoint(300,250) angle:45.0 align:2];
  //[tmpStr addAttribute:@"AQTFancyAttribute" value:@"superscript" range:NSMakeRange(3,2)];
  [tmpStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:1] range:NSMakeRange(7,2)];
  [tmpStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-1] range:NSMakeRange(9,2)];
  [tmpStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInt:1] range:NSMakeRange(11,3)];
  [adapter addLabel:tmpStr position:NSMakePoint(50,10) angle:0.0 align:0];
  [adapter setAcceptingEvents:YES];
  //   [adapter setAcceptingEvents:NO];
  //   [adapter clearPlot];
  [adapter renderPlot];

  //[t translateXBy:100 yBy:100];
  //[t scaleBy:50];
  //[t rotateByDegrees:45.0];
  //[t translateXBy:-1 yBy:-1];
  // (35.355339 35.355339 -35.355339 35.355339 100.000000 29.289322)
  [adapter openPlotWithIndex:3];
  [adapter setPlotSize:NSMakeSize(200,200)];
  [adapter setPlotTitle:@"Image (trs)"];
  [adapter setImageTransformM11:35.355339 m12:35.355339 m21:-35.355339 m22:35.355339 tX:100.0 tY:29.289322];
  [adapter addTransformedImageWithBitmap:bytes size:NSMakeSize(2,2) clipRect:NSMakeRect(50,50,100,100)];
  [adapter renderPlot];
  [adapter closePlot];

  //[t translateXBy:10 yBy:10];
  //[t scaleBy:10];
  //[t rotateByDegrees:30.0];
  //(8.660254 5.000000 -5.000000 8.660254 10.000000 10.000000)

  [adapter openPlotWithIndex:4];
  [adapter setPlotSize:NSMakeSize(200,200)];
  [adapter setPlotTitle:@"Image (tsr)"];
  [adapter setImageTransformM11:8.660254 m12:5.0 m21:-5.0 m22:8.660254 tX:10.0 tY:10.0];
  [adapter addImageWithBitmap:bytes size:NSMakeSize(2,2) bounds:NSMakeRect(50,50,100,100)]; // discards transform
  [adapter setAcceptingEvents:YES];
  [adapter renderPlot];

  [adapter openPlotWithIndex:5];
  [adapter setPlotSize:NSMakeSize(400,300)];
  [adapter setPlotTitle:@"Lines"];

  for(i=0; i<100; i++)
  {
    [adapter setColorRed:drand48() green:drand48() blue:drand48()];
    x = random() % 360 + 20;
    y = random() % 260 + 20;
    [adapter moveToPoint:NSMakePoint(x, y)];
    [adapter addLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
    [adapter addLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
    [adapter addLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
    [adapter addLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
  }
  [adapter moveToPoint:NSMakePoint(0, 149.5)];
  [adapter addLineToPoint:NSMakePoint(399, 149.5)];
  [adapter moveToPoint:NSMakePoint(199.5, 0)];
  [adapter addLineToPoint:NSMakePoint(199.5, 299)];
  [adapter moveToPoint:NSMakePoint(0, 0)]; // Force end of line

  [adapter renderPlot];

  /*

   [adapter openPlotIndex:3 size:NSMakeSize(200,200) title:@"Image"];
   [adapter addImageWithBitmap:bytes size:NSMakeSize(2,2) bounds:NSMakeRect(50,50,100,100)];
   [adapter closePlot];

   [adapter openPlotIndex:4 size:NSMakeSize(200,200) title:@"Patch"];
   polygon[0]=NSMakePoint(xf+10.0, 10.0);
   polygon[1]=NSMakePoint(xf+20., 10.);
   polygon[2]=NSMakePoint(xf+20., 20.);
   polygon[3]=NSMakePoint(xf+10., 20.);
   polygon[4]=NSMakePoint(xf+10., 10.);
   [adapter addPolygonWithPoints:polygon pointCount:5];
   xf=10.0;
   polygon[0]=NSMakePoint(xf+10.0, 10.0);
   polygon[1]=NSMakePoint(xf+20., 10.);
   polygon[2]=NSMakePoint(xf+20., 20.);
   polygon[3]=NSMakePoint(xf+10., 20.);
   polygon[4]=NSMakePoint(xf+10., 10.);
   [adapter addPolygonWithPoints:polygon pointCount:5];

   [adapter closePlot];
   */
}