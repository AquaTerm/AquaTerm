//
//  AQTController.m
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import "AQTController.h"
#import "AQTPlot.h"
#import <Message/NSMailDelivery.h>
// Needed for testing only:
#import "AQTAdapter.h"

extern void aqtTestview(id sender);

@implementation NSString (AQTRFC2396Support)
- (NSString *)stringByAddingPercentEscapes
{
  return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding)) autorelease];
}
@end

@implementation AQTController
/**"
*** AQTController is the main controller object which coordinates all the
*** action and manages the main DO connection.
"**/

-(id)init
{
  if (self =  [super init])
  {
    handlerList = [[NSMutableArray alloc] initWithCapacity:256];
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
  //[doConnection setIndependentConversationQueueing:YES];	// FAQ: Needed to sync calls!!!!
  [doConnection setRootObject:self];

  if([doConnection registerName:@"aquatermServer"] == NO)
  {
    NSLog(@"Error registering \"aquatermServer\" with defaultConnection");
  }
}

-(void)dealloc
{
  //[handlerList release];
  [super dealloc];
}

- (AQTAdapter *)sharedAdapter
{
  static AQTAdapter *adapter;
  if (adapter == nil)
  {
    adapter = [[AQTAdapter alloc] initWithServer:self];
  }
  return adapter;
}

#pragma mark === AQTConnectionProtocol ===
-(BOOL)ping
{
   return YES;
}

- (void)getServerVersionMajor:(int *)major minor:(int *)minor rev:(int *)rev
{
   *major = 1;
   *minor = 0;
   *rev = 0;
}

-(id)addAQTClient:(id)client name:(NSString *)name pid:(int)procId
{
  id newPlot;
   newPlot = [[AQTPlot alloc] init];
   [newPlot setClient:client];
   [newPlot setClientInfoName:name pid:procId];
   [handlerList addObject:newPlot];
   [newPlot release];

   return newPlot;
}

-(BOOL)removeAQTClient:(id)client
{
  [handlerList makeObjectsPerformSelector:@selector(invalidateClient:) withObject:client];
  return YES;
/*
 NSArray *allWin = [NSApp windows];
   NSEnumerator *enumerator = [allWin objectEnumerator];
   BOOL didRemove = NO;
   id win;
 while ((win = [enumerator nextObject]))
   {
      didRemove = (didRemove || [[win delegate] invalidateClient:client]);
   }
   return didRemove;
*/
}

- (void)removePlot:(id)aPlot
{
  [handlerList removeObject:aPlot];
}


#pragma mark === Actions ===


-(IBAction)showHelp:(id)sender
{
  NSURL *helpURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
  if (helpURL)
  {
    [[NSWorkspace sharedWorkspace] openURL:helpURL];
  }
}

// Testing the use of a callback function to handle errors in the server
void customEventHandler(int index, NSString *event)
{
   NSLog(@"Custom event handler --- %@ from %d", event, index);
}


-(IBAction)debug:(id)sender
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
   int i;
   int x,y;
   if (!adapter)
   {
      NSLog(@"Failed to init adapter");
   }

 [adapter setEventHandler:customEventHandler];
   [adapter openPlotWithIndex:2];// size:NSMakeSize(400,300) title:@"Testing"];
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

   t = [NSAffineTransform transform];
   [t translateXBy:100 yBy:100];
   [t scaleBy:50];
   [t rotateByDegrees:45.0];
   [t translateXBy:-1 yBy:-1];
   ts = [t transformStruct];
   // NSLog(@"ts (m11 m12 m21 m22 tx ty)= (%f %f %f %f %f %f)", ts.m11, ts.m12, ts.m21, ts.m22, ts.tX, ts.tY);
   [adapter openPlotWithIndex:3];
   [adapter setPlotSize:NSMakeSize(200,200)];
   [adapter setPlotTitle:@"Image (trs)"];
   [adapter setImageTransformM11:ts.m11 m12:ts.m12 m21:ts.m21 m22:ts.m22 tX:ts.tX tY:ts.tY];
   [adapter addTransformedImageWithBitmap:bytes size:NSMakeSize(2,2) clipRect:NSMakeRect(50,50,100,100)];
   [adapter renderPlot];
   [adapter closePlot];

   t = [NSAffineTransform transform];
   [t translateXBy:10 yBy:10];
   [t scaleBy:10];
   [t rotateByDegrees:30.0];
   ts = [t transformStruct];
   // NSLog(@"ts (m11 m12 m21 m22 tx ty)= (%f %f %f %f %f %f)", ts.m11, ts.m12, ts.m21, ts.m22, ts.tX, ts.tY);

 [adapter openPlotWithIndex:4];
   [adapter setPlotSize:NSMakeSize(200,200)];
   [adapter setPlotTitle:@"Image (tsr)"];
   [adapter setImageTransformM11:ts.m11 m12:ts.m12 m21:ts.m21 m22:ts.m22 tX:ts.tX tY:ts.tY];
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
-(IBAction)mailBug:(id)sender;
{
  BOOL messageSent = NO;
  NSString *msg = @"Complex text\nwith breaks...";
  NSString *address = @"persquare@users.sourceforge.net";
  NSString *subject = @"AquaTerm bugreport";
  if([NSMailDelivery hasDeliveryClassBeenConfigured])
  {
    messageSent = [NSMailDelivery deliverMessage:[msg stringByAddingPercentEscapes]
                                         subject:[subject stringByAddingPercentEscapes]
                                              to:[address stringByAddingPercentEscapes]];
  }
  if(messageSent == NO)
  {
    NSString *mailto = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", address, subject, msg];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[mailto stringByAddingPercentEscapes]]];
  }
}

-(IBAction)mailFeedback:(id)sender;
{
  NSString *msg = @"Complex text\nwith breaks...";
  NSString *address = @"persquare@users.sourceforge.net";
  NSString *subject = @"AquaTerm feedback";
  NSString *mailto = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", address, subject, msg];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[mailto stringByAddingPercentEscapes]]];
}

-(IBAction)testview:(id)sender;
{
  aqtTestview(self);
}
-(IBAction)stringDrawingTest:(id)sender;
{
}
-(IBAction)lineDrawingTest:(id)sender;
{
}
@end
