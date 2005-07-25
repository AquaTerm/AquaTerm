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
// gcc -DAQT_STANDALONE -o bugs Bugs.m -framework AquaTerm -framework Foundation
// _or_
// executed from AquaTerm using menu Debug -> Exercise bugs.

#import <Foundation/Foundation.h>
#ifndef AQT_STANDALONE
#import <AppKit/AppKit.h>
#import "AQTController.h"
#endif
#import <AquaTerm/AQTAdapter.h>

// Testing the use of a callback function to handle errors in the server
static void customEventHandler(int index, NSString *event)
{
  NSLog(@"Custom event handler --- %@ from %d", event, index);
}


#ifdef AQT_STANDALONE
void aqtDebug(AQTAdapter *adapter);

int main(void)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  AQTAdapter *adapter = [[AQTAdapter alloc] init];
  NSLog(@"Hello");
  aqtDebug(adapter);
  [adapter release];
  [pool release];
  return 0;
}
void aqtDebug(AQTAdapter *adapter)
#else
void aqtDebug(id sender)
#endif
{
#ifndef AQT_STANDALONE
  AQTAdapter *adapter = [sender sharedAdapter];
#endif
  if (!adapter)
  {
    NSLog(@"Failed to init adapter");
  }
  [adapter setFontname:@"Times-Roman"];
  NSString *s = [NSString stringWithFormat:@"Unicode: %C %C %C %C%C%C%C%C", 0x2124, 0x2133, 0x5925, 0x2654, 0x2655, 0x2656, 0x2657, 0x2658]; 
  NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:s];
  [as setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"AppleSymbols", @"AQTFontname", nil] range:NSMakeRange(9,11)];
  [as setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"Song Regular", @"AQTFontname", nil] range:NSMakeRange(13,1)];
  [adapter openPlotWithIndex:1];
  [adapter setPlotSize:NSMakeSize(620,420)];
  [adapter setPlotTitle:@"Unicode"];
  [adapter setFontsize:20];
  [adapter addLabel:as atPoint:NSMakePoint(100,100)];
  //[adapter setFontname:@"Song Regular"];
  //[adapter addLabel:[NSString stringWithFormat:@"%C", 0x5925] atPoint:NSMakePoint(100,120)];
  [adapter renderPlot];
  
  float a;
  float a1=40.;
  float a2=20.;
  float x=400., y=200.;
  
  for (a=0.0; a<360.0; a+=30.0)
  {
     [adapter addLabel:@"--- Sheared" atPoint:NSMakePoint(200,200) angle:a shearAngle:a align:AQTAlignLeft | AQTAlignMiddle];
  }
   
  [adapter moveToPoint:NSMakePoint(x-100*cos(3.1415*a1/180.0), y+100+100*sin(3.1415*a1/180.0))];
  [adapter addLineToPoint:NSMakePoint(x-100*cos(3.1415*a1/180.0), y+100*sin(3.1415*a1/180.0))];
  [adapter addLineToPoint:NSMakePoint(x, y)];
  [adapter addLineToPoint:NSMakePoint(x+100*cos(3.1415*a2/180.0), y+100*sin(3.1415*a2/180.0))];
  
  [adapter addLabel:@"---z-axis---" atPoint:NSMakePoint(x-20-100*cos(3.1415*a1/180.0), y+50+100*sin(3.1415*a1/180.0)) 
              angle:90.0 
         shearAngle:a1 
              align:AQTAlignCenter | AQTAlignMiddle];
  
  [adapter addLabel:@"---y-axis---" atPoint:NSMakePoint(x-50*cos(3.1415*a1/180.0), y-20+50*sin(3.1415*a1/180.0)) 
              angle:-a1 
         shearAngle:-a1 
              align:AQTAlignCenter | AQTAlignMiddle];

  [adapter addLabel:@"---x-axis---" atPoint:NSMakePoint(x+50*cos(3.1415*a2/180.0), y-20+50*sin(3.1415*a2/180.0)) 
              angle:a2 
         shearAngle:a2 
              align:AQTAlignCenter | AQTAlignMiddle];
  
  
  [adapter renderPlot];
  
  // Resizing bug
  [adapter openPlotWithIndex:2];
  [adapter setPlotSize:NSMakeSize(200,400)];
  [adapter setPlotTitle:@"Page 1 200x400"];
  [adapter addLabel:@"Hello" atPoint:NSMakePoint(100,100)];
  [adapter renderPlot];
#ifdef AQT_STANDALONE
  [adapter waitNextEvent];
#endif
  [adapter openPlotWithIndex:2];
  [adapter setPlotSize:NSMakeSize(400,200)];
  [adapter setPlotTitle:@"Page 2 400x200"];
  [adapter addLabel:@"World" atPoint:NSMakePoint(100,100)];
  [adapter renderPlot];
  
}
