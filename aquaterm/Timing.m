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
// gcc -o timing Timing.m -laqt -Framework Foundation
// _or_
// executed from AquaTerm using menu Debug -> Timing tests.

#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

#ifndef AQT_APP
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

#ifndef AQT_APP
void aqtStringDrawingTest(AQTAdapter *adapter)
#else
void aqtStringDrawingTest(id sender)
#endif
{
#ifdef AQT_APP
  AQTAdapter *adapter = [sender sharedAdapter];
#endif  
}

#ifndef AQT_APP
void aqtLineDrawingTest(AQTAdapter *adapter)
#else
void aqtLineDrawingTest(id sender)
#endif
{
#ifdef AQT_APP
  AQTAdapter *adapter = [sender sharedAdapter];
#endif  
}
