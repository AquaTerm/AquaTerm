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
#import "AQTController.h"
#endif
#import <aquaterm/AQTAdapter.h>

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
#ifdef AQT_APP
  AQTAdapter *adapter = [sender sharedAdapter];
#endif
  if (!adapter)
  {
    NSLog(@"Failed to init adapter");
  }
  [adapter openPlotWithIndex:2];
  [adapter setPlotSize:NSMakeSize(600,400)];
  [adapter setPlotTitle:@"Testing"];
  [adapter setFontsize:24];
  [adapter setFontname:@"Symbol"];
  // Some styling is possible
  {
     NSData *unicode = [NSData dataWithBytes:"\x03\xb1\x03\xb1\x03\xb1" length:6];
     NSString *uStr = [[NSString alloc] initWithData:unicode encoding:NSUnicodeStringEncoding];
     NSString *greek = [[NSString alloc] initWithFormat:@"%S", "\x03\xb1\x03\xb1\x03\xb1"];
//     NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:@"YaddaYaddaYaddaYaddaYadda"] autorelease];
     [adapter addLabel:uStr atPoint:NSMakePoint(200, 200) angle:0.0 align:AQTAlignCenter];
/*
 [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:1] range:NSMakeRange(1,3)];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-1] range:NSMakeRange(4,2)];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-1] range:NSMakeRange(7,1)];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:1] range:NSMakeRange(8,2)];
     [adapter addLabel:attrStr atPoint:NSMakePoint(200, 200) angle:0.0 align:AQTAlignLeft];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:0] range:NSMakeRange(0, 11)];
     [attrStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInt:1] range:NSMakeRange(0,3)];
     [attrStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInt:1] range:NSMakeRange(4,1)];
     [adapter addLabel:attrStr atPoint:NSMakePoint(200, 300) angle:0.0 align:AQTAlignLeft];
     [adapter addLabel:attrStr atPoint:NSMakePoint(100, 200) angle:90.0 align:AQTAlignCenter];
*/
  }
  
  [adapter setColorRed:1.0 green:0.0 blue:0.0];
  [adapter addFilledRect:NSMakeRect(200, 100, 20, 20)];
  [adapter setColorRed:0.0 green:1.0 blue:0.0];
  [adapter addFilledRect:NSMakeRect(200, 120, 20, 20)];
  [adapter setColorRed:0.0 green:0.0 blue:1.0];
  [adapter addFilledRect:NSMakeRect(220, 100, 20, 20)];
  [adapter setColorRed:1.0 green:1.0 blue:0.0];
  [adapter addFilledRect:NSMakeRect(220, 120, 20, 20)];

  [adapter setColorRed:1.0 green:0.0 blue:0.0];
  [adapter addFilledRect:NSMakeRect(250.0, 100.0, 20.0, 20.0)];
  [adapter setColorRed:0.0 green:1.0 blue:0.0];
  [adapter addFilledRect:NSMakeRect(250.0, 120.0, 20.0, 20.0)];
  [adapter setColorRed:0.0 green:0.0 blue:1.0];
  [adapter addFilledRect:NSMakeRect(270.0, 100.0, 20.0, 20.0)];
  [adapter setColorRed:1.0 green:1.0 blue:0.0];
  [adapter addFilledRect:NSMakeRect(270.0, 120.0, 20.0, 20.0)];
  
  [adapter setColorRed:0.0 green:0.0 blue:0.0];
  [adapter moveToPoint:NSMakePoint(0,0)];
  [adapter addLineToPoint:NSMakePoint(599,0)];
  [adapter addLineToPoint:NSMakePoint(599,399)];
  [adapter addLineToPoint:NSMakePoint(0,399)];
  [adapter addLineToPoint:NSMakePoint(0,0)];

  // Fontname bug (#1015888)
  [adapter setFontname:@"Times"];
  [adapter addLabel:@"Times" atPoint:NSMakePoint(200, 100) angle:0.0 align:AQTAlignLeft];
  [adapter setFontname:@"Crash"];
  [adapter addLabel:@"Crash" atPoint:NSMakePoint(300, 100) angle:0.0 align:AQTAlignLeft];

  
  [adapter renderPlot];
  //[adapter closePlot];
}