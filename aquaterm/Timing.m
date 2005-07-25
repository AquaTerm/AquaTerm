//
//  Timing.m
//  AquaTerm
//
//  Created by Per Persson on Fri Nov 07 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

//
// This file contains tests for performance tuning of
// AquaTerm and the corresponding library: libaqt.dylib
//
// This code can be built as a stand-alone executable (tool)
// from the command line:
// gcc -DAQT_STANDALONE -o timing Timing.m -framework AquaTerm -framework Foundation
// _or_
// executed from AquaTerm using menu Debug -> Timing tests.

#import <Foundation/Foundation.h>
#ifndef AQT_STANDALONE
#import <AppKit/AppKit.h>
#import "AQTController.h"
#endif
#import <AquaTerm/AQTAdapter.h>

#ifdef AQT_STANDALONE
void aqtStringDrawingTest(AQTAdapter *adapter);
void aqtLineDrawingTest(AQTAdapter *adapter);

int main(void)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  AQTAdapter *adapter = [[AQTAdapter alloc] init];
  aqtStringDrawingTest(adapter);
  aqtLineDrawingTest(adapter);
  return 0;
}
#endif

#ifdef AQT_STANDALONE
void aqtStringDrawingTest(AQTAdapter *adapter)
#else
void aqtStringDrawingTest(id sender)
#endif
{
#ifndef AQT_STANDALONE
  AQTAdapter *adapter = [sender sharedAdapter];
#endif  
}

#ifdef AQT_STANDALONE
void aqtLineDrawingTest(AQTAdapter *adapter)
#else
void aqtLineDrawingTest(id sender)
#endif
{
#ifndef AQT_STANDALONE
   AQTAdapter *adapter = [sender sharedAdapter];
#endif
   int lineCount = 2;
   int maxLineLength = 64;
   int c, l;
   unsigned int index = 0; 

   // test 1
   for (l = 2; l <= maxLineLength; l *= 2)
   {
      index++;
      int cMax = (64*16)/l;
      [adapter openPlotWithIndex:l];
      [adapter setPlotSize:NSMakeSize(620,420)];
      [adapter setPlotTitle:[NSString stringWithFormat:@"Line test l = %d, cMax = %d", l, cMax]];
      for (c = 0; c < cMax; c++)
      {
         int i;
         [adapter moveToPoint:NSMakePoint(drand48()*600+10, drand48()*400+10)];
         for (i = 1; i <= l; i++)
         {
            [adapter addLineToPoint:NSMakePoint(drand48()*600+10, drand48()*400+10)];
         }
      }
      [adapter renderPlot];
      // Tag bits: 
      // 0-5:   index
      // 6-15:  test
      // 16-23: client
      // 24-31: reserved
      [adapter timingTestWithTag:(index + 1*64 + 1*65536)];
      [adapter closePlot];
   }
   // test 2
   index = 1;
   int x;
   [adapter openPlotWithIndex:1];
   [adapter setPlotSize:NSMakeSize(620,420)];
   [adapter setPlotTitle:@"Test 2"];
   for (x = 10; x < 610; x += 10)
   {
      [adapter moveToPoint:NSMakePoint(x, 10)];
      [adapter addLineToPoint:NSMakePoint(620-x, 410)];
   }
   [adapter renderPlot];
   // Tag bits: 
   // 0-5:   index
   // 6-15:  test
   // 16-23: client
   // 24-31: reserved
   [adapter timingTestWithTag:(index + 2*64 + 1*65536)];
   [adapter closePlot];
  
}
