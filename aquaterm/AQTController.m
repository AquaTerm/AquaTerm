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

extern void aqtDebug(id sender);
extern void aqtTestview(id sender);
extern void aqtStringDrawingTest(id sender);
extern void aqtLineDrawingTest(id sender);

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
     NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
     handlerList = [[NSMutableArray alloc] initWithCapacity:256];
     cascadingPoint = NSMakePoint(NSMinX(screenFrame), NSMaxY(screenFrame));
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

- (void)setWindowPos:(NSWindow *)plotWindow
{
   cascadingPoint = [plotWindow cascadeTopLeftFromPoint:cascadingPoint];
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

#pragma mark === Debug Actions ===

-(IBAction)debug:(id)sender
{
  aqtDebug(self);
}
-(IBAction)testview:(id)sender;
{
  aqtTestview(self);
}
-(IBAction)stringDrawingTest:(id)sender;
{
  aqtStringDrawingTest(self);
}
-(IBAction)lineDrawingTest:(id)sender;
{
  aqtLineDrawingTest(self);
}
@end
