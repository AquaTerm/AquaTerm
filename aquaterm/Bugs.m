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
  if (!adapter)
  {
    NSLog(@"Failed to init adapter");
  }
  [adapter openPlotWithIndex:2];
  [adapter setPlotSize:NSMakeSize(600,400)];
  [adapter setPlotTitle:@"Testing"];
  [adapter setFontsize:24];
  // Some styling is possible
  {
     NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:@"0123456789XXXX"] autorelease];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:1] range:NSMakeRange(1,3)];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-1] range:NSMakeRange(4,2)];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:-1] range:NSMakeRange(7,1)];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:1] range:NSMakeRange(8,2)];
     [adapter addLabel:attrStr position:NSMakePoint(200, 200) angle:0.0 align:AQTAlignLeft];
     [attrStr addAttribute:@"NSSuperScript" value:[NSNumber numberWithInt:0] range:NSMakeRange(0, 11)];
     [attrStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInt:1] range:NSMakeRange(0,3)];
     [attrStr addAttribute:@"NSUnderline" value:[NSNumber numberWithInt:1] range:NSMakeRange(4,1)];
     [adapter addLabel:attrStr position:NSMakePoint(200, 300) angle:0.0 align:AQTAlignLeft];
     [adapter addLabel:attrStr position:NSMakePoint(100, 200) angle:90.0 align:AQTAlignCenter];
  }
  
  [adapter renderPlot];
  [adapter closePlot];
}