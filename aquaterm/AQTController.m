//
//  AQTController.m
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import "AQTController.h"
#import "AQTPlot.h"
// Needed for testing only:
#import "AQTAdapter.h"
#import "AQTAdapterPrivateMethods.h"

@implementation AQTController
/**"
*** AQTController is the main controller object which coordinates all the
*** action and manages the main DO connection.
"**/

-(id)init
{
  if (self =  [super init])
  {
    handlerList = [[NSMutableDictionary alloc] initWithCapacity:256];
  }
  return self;
}

/**"
*** The name of the DO connection registered is 'aquatermServer'.
"**/
-(void)awakeFromNib
{
  //
  // Set up a DO connection:
  //   
  doConnection = [[NSConnection defaultConnection] retain];
  [doConnection setIndependentConversationQueueing:YES];	// FAQ: Needed to sync calls!!!!
  [doConnection setRootObject:self];

  if([doConnection registerName:@"aquatermServer"] == NO)
  {
    NSLog(@"Error registering \"aquatermServer\" with defaultConnection");
  }
}

-(void)dealloc
{
  [handlerList release];
  [super dealloc];
}
//
// Methods from AQTConnectionProtocol
//
-(id)addAQTClient:(id)client name:(NSString *)name pid:(int)procId
{
  id newHandler;
/*
 if ([handlerList objectForKey:identifier])
  {
    newHandler = nil; // handler already exists 
    NSLog(@"*** Error - handler already exists ***");
  }
  else
  {
*/
    newHandler = [[AQTPlot alloc] init];
    [newHandler setClient:client];
    //[newHandler setOwner:self];
//    [handlerList setObject:newHandler forKey:identifier];
//    [newHandler release];
//  }
  return newHandler;
}

-(void)removeAQTClient:(id)client
{
  //
  // FIXME: The handler should be allowed to remain until final plot window is closed
  //
/*
 if ([handlerList objectForKey:identifier])
  {
    NSLog(@"Removing client!");
    NSLog(@"handler rc: %d", [handlerList objectForKey:identifier]);
    [handlerList removeObjectForKey:identifier];
  }
  else
  {
    NSLog(@"Not found!");
  }
 */
}

-(IBAction)showHelp:(id)sender
{
  NSURL *helpURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
  if (helpURL)
  {
    [[NSWorkspace sharedWorkspace] openURL:helpURL];
  }
}

// Testing the use of a callback function to handle errors in the server
void customEventHandler(NSString *event)
{
   NSLog(@"Custom event handler --- %@", event);
}


-(IBAction)test:(id)sender
{
  NSAffineTransform *t;
  NSAffineTransformStruct ts;
   AQTAdapter *adapter = [[AQTAdapter alloc] initWithServer:self];
  NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString:@"Fancy string! yaddadaddadadadda"];
//   NSPoint polygon[5];
   unsigned char bytes[12]={
      255, 0, 0,
      0, 255, 0,
      0, 0, 255,
      0, 0, 0
   };
//   float xf=0.0;
//   int i;
//   int x,y;
   if (!adapter)
   {
      NSLog(@"Failed to init adapter");
   }
   [adapter setEventHandler:customEventHandler];
   [adapter openPlotIndex:2];// size:NSMakeSize(400,300) title:@"Testing"];
   [adapter setPlotSize:NSMakeSize(400,300)];
   [adapter setPlotTitle:@"Testing"];
   [adapter addLabel:@"Left" position:NSMakePoint(200,160) angle:0.0 justification:0];
   [adapter addLabel:@"Center" position:NSMakePoint(200,150) angle:0.0 justification:1];
   [adapter addLabel:@"Right" position:NSMakePoint(200,170) angle:0.0 justification:2];
   [tmpStr addAttribute:@"AQTFancyAttribute" value:@"superscript" range:NSMakeRange(3,2)];
   [tmpStr addAttribute:@"NSSuperscriptAttributeName" value:[NSNumber numberWithInt:1] range:NSMakeRange(7,2)];
   [tmpStr addAttribute:@"NSSuperscriptAttributeName" value:[NSNumber numberWithInt:0] range:NSMakeRange(9,2)];
   [tmpStr addAttribute:@"NSUnderlineStyleAttributeName" value:[NSNumber numberWithInt:1] range:NSMakeRange(11,3)];
   [adapter addLabel:tmpStr position:NSMakePoint(100,100) angle:0.0 justification:0];
   [adapter setAcceptingEvents:YES];
//   [adapter setAcceptingEvents:NO];
   [adapter closePlot];

   t = [NSAffineTransform transform];
   [t translateXBy:10 yBy:10];
   [t rotateByDegrees:30.0];
   [t scaleBy:10];
   ts = [t transformStruct];
   NSLog(@"ts (m11 m12 m21 m22 tx ty)= (%f %f %f %f %f %f)", ts.m11, ts.m12, ts.m21, ts.m22, ts.tX, ts.tY);
   [adapter openPlotIndex:3];
   [adapter setPlotSize:NSMakeSize(200,200)];
   [adapter setPlotTitle:@"Image (trs)"];
   [adapter setImageTransformM11:ts.m11 m12:ts.m12 m21:ts.m21 m22:ts.m22 tX:ts.tX tY:ts.tY];
   [adapter addImageWithBitmap:bytes size:NSMakeSize(2,2) bounds:NSMakeRect(50,50,100,100)];
   [adapter closePlot];

   t = [NSAffineTransform transform];
   [t translateXBy:10 yBy:10];
   [t scaleBy:10];
   [t rotateByDegrees:30.0];
   ts = [t transformStruct];
   NSLog(@"ts (m11 m12 m21 m22 tx ty)= (%f %f %f %f %f %f)", ts.m11, ts.m12, ts.m21, ts.m22, ts.tX, ts.tY);
   [adapter openPlotIndex:4];
   [adapter setPlotSize:NSMakeSize(200,200)];
   [adapter setPlotTitle:@"Image (tsr)"];
   [adapter setImageTransformM11:ts.m11 m12:ts.m12 m21:ts.m21 m22:ts.m22 tX:ts.tX tY:ts.tY];
   [adapter addImageWithBitmap:bytes size:NSMakeSize(2,2) bounds:NSMakeRect(50,50,100,100)];
   [adapter setAcceptingEvents:YES];
   [adapter closePlot];

   
/*
 for(i=0; i<1000; i++)
   {
      [adapter setColorRed:drand48() green:drand48() blue:drand48()];
      x = random() % 360 + 20;
      y = random() % 260 + 20;
      [adapter addLineAtPoint:NSMakePoint(x, y)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
   }
   [adapter addLineAtPoint:NSMakePoint(0, 149.5)];
   [adapter appendLineToPoint:NSMakePoint(399, 149.5)];
   [adapter addLineAtPoint:NSMakePoint(199.5, 0)];
   [adapter appendLineToPoint:NSMakePoint(199.5, 299)];
   [adapter addLineAtPoint:NSMakePoint(0, 0)]; // Force end of line
 
   [adapter closePlot];

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
@end
