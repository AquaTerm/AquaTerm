//
//  AQTController.m
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import "AQTController.h"
#import "AQTPrefController.h"

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

+ (void)initialize{
   NSUserDefaults *defaults = preferences;
   NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:NSHomeDirectory(), @"PDF", [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil] 
                                                           forKeys:[NSArray arrayWithObjects:@"CurrentSaveFolder", @"CurrentSaveFormat", @"ShowProcessName", @"ShowProcessId", @"limitMinimumLinewidth", @"ShouldAntialiasDrawing", @"ImageInterpolationLevel", nil]];
   [defaults registerDefaults:appDefaults];
}

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

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**"
*** The name of the DO connection registered is 'aquatermServer'.
"**/
-(void)awakeFromNib
{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidClose:) name:@"AQTWindowDidCloseNotification" object:nil];
  //
  // Set up a DO connection:
  //
  NSConnection * doConnection = [NSConnection defaultConnection];
  [doConnection setRootObject:self];

  if([doConnection registerName:@"aquatermServer"] == NO)
  {
    int retCode = NSRunCriticalAlertPanel(@"Could not establish service",
                                       @"Another application has already registered the service \"aquatermServer\".\nYou may leave AquaTerm running by pressing Cancel, but no clients will be able to use it.\nPress Quit to close this copy of AquaTerm.",
                                       @"Quit", @"Cancel", nil);
    if (retCode == NSAlertDefaultReturn)
       [NSApp terminate:self];
    else
       NSLog(@"Error registering \"aquatermServer\" with defaultConnection"); 
  }
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

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
   // Warn if active clients and refuse(?) if events are active
   int terminateDecision = NSTerminateNow;
   BOOL validClients = NO;
   BOOL eventsActive = NO;
   NSEnumerator *enumObjects = [handlerList objectEnumerator];
   AQTPlot *aHandler;
   while (aHandler = [enumObjects nextObject])
   {
      if ([aHandler clientValidAndResponding])
      {
         validClients = YES;
         if ([aHandler acceptingEvents])
         {
            eventsActive = YES;
         }
      }
   }

   if(validClients)
   {
      int retCode;
      if(eventsActive)
      {
         retCode = NSRunCriticalAlertPanel(@"Clients still awaiting events",
                                           @"There are still clients connected to AquaTerm awaiting events and quitting now may leave them in an infinite loop.\nYou can leave AquaTerm running by pressing Cancel or confirm quitting by pressing Quit.",
                                           @"Cancel",
                                           @"Quit", nil);
      }
      else
      {
         retCode = NSRunAlertPanel(@"Clients still connected",
                                   @"There are still clients connected to AquaTerm and quitting now may disrupt them.\nYou can leave AquaTerm running by pressing Cancel or confirm quitting by pressing Quit.",
                                   @"Cancel",
                                   @"Quit", nil);
      }
      terminateDecision = (retCode == NSAlertDefaultReturn)?NSTerminateCancel:NSTerminateNow;
   }
   return terminateDecision;
}
- (void)applicationWillTerminate:(NSNotification *)notification
{
   // FIXME: inform clients?
   // NSLog(@"Implement %@, %s:%d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
}

#pragma mark === AQTConnectionProtocol ===
-(void)ping
{
   return;
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
   // [newPlot setPlotKey:client];
   [newPlot setClientInfoName:name pid:procId];
   [handlerList addObject:newPlot];
   [newPlot release];

   return newPlot;
}

/*
 -(BOOL)removeAQTClient:(id)client
{
  [handlerList makeObjectsPerformSelector:@selector(invalidateClient:) withObject:client];
  return YES;
}
*/
- (void)removePlot:(id)aPlot
{
  [handlerList removeObject:aPlot];
}

- (void)windowDidClose:(NSNotification *)aNotification
{
   // NSLog(@"in %@, %s:%d\nnotification %@", NSStringFromSelector(_cmd), __FILE__, __LINE__, [aNotification description]);

   AQTPlot *aPlot = [aNotification object]; 
   if ([aPlot clientValidAndResponding] == NO)
   {
      [[[aPlot canvas] window] close];
      [self removePlot:aPlot];
   }
}

#pragma mark === Actions ===
-(IBAction)showPrefs:(id)sender;
{
   [[AQTPrefController sharedPrefController] showPrefs];    
}

 -(IBAction)tileWindows:(id)sender;
{
   /* FIXME: This algorithm just divides the screen into N equally size tiles and fits the 
      windows into the tiles trying to maximize screen usage. Could be improved... */ 
   NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
   NSSize tileSize;
   NSPoint tileOrigin;
   
   int i, row, col, nRow, nCol;
   int n = [handlerList count];
   
   if (n==0)
      return;
   
   nRow = nCol = 1 + (int)sqrt(n-1);
   tileSize = NSMakeSize((int)screenFrame.size.width/nCol, (int)screenFrame.size.height/nRow);
   tileOrigin = NSMakePoint(NSMinX(screenFrame), NSMaxY(screenFrame)-tileSize.height);
   for(i=0;i<[handlerList count];i++) {
      row = i/nCol;
      col = i%nRow;
      // NSLog(@"(row, col)=(%d, %d)", row, col);
      NSRect tmpFrame = NSMakeRect(tileOrigin.x+col*tileSize.width, tileOrigin.y-row*tileSize.height, tileSize.width, tileSize.height);
      [[handlerList objectAtIndex:i] constrainWindowToFrame:tmpFrame];
   }
}

-(IBAction)cascadeWindows:(id)sender
{
   // FIXME: Cascading point should be reset (moved) when a window hits screen bottom
   int i;
   NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
   cascadingPoint = NSMakePoint(NSMinX(screenFrame), NSMaxY(screenFrame));
   for(i=0;i<[handlerList count];i++) {
      [[handlerList objectAtIndex:i] cascadeWindowOrderFront:YES];
   }
}

-(IBAction)showHelp:(id)sender
{
  NSURL *helpURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
  if (helpURL)
  {
    [[NSWorkspace sharedWorkspace] openURL:helpURL];
  }
}

-(IBAction)showAvailableFonts:(id)sender
{
   int row = 10;
   int col = 10;
   NSFontManager *fontManager = [NSFontManager sharedFontManager];
   NSString *systemFont = [[NSFont systemFontOfSize:10.0] fontName];
   NSMutableArray *allFontnames = [NSMutableArray arrayWithCapacity:1024];

   // Set up Aquaterm
   AQTAdapter *adapter = [self sharedAdapter];
   [adapter openPlotWithIndex:1];
   [adapter setPlotTitle:@"Available fonts"];
   [adapter setPlotSize:NSMakeSize(1000, 700)];
   [adapter setFontsize:8.0];

   // Collect all fontnames
   NSArray *allFontFamilies = [fontManager availableFontFamilies];
   NSEnumerator *fontFamilyEnumerator = [allFontFamilies objectEnumerator];
   NSString *familyName;
   
   while (familyName = [fontFamilyEnumerator nextObject]) {
      NSArray *allFonts = [fontManager availableMembersOfFontFamily:familyName];
      NSEnumerator *fontEnumerator = [allFonts objectEnumerator];
      NSArray *variation;
      while (variation = [fontEnumerator nextObject]) {
         [allFontnames addObject:[variation objectAtIndex:0]];
      }
   }
   
   // Display them in alphabetical order
   [allFontnames sortUsingSelector:@selector(caseInsensitiveCompare:)];
   NSEnumerator *fontEnumerator = [allFontnames objectEnumerator];
   NSString *fontname;
   
   while (fontname = [fontEnumerator nextObject]) {
      [adapter setFontname:systemFont];
      [adapter setColorRed:0.0 green:0.0 blue:0.0];
      [adapter addLabel:fontname
                atPoint:NSMakePoint(row, 700-col)
                  angle:0.0
                  align:0];
      [adapter setFontname:fontname];
      [adapter setColorRed:0.0 green:0.0 blue:1.0];
      [adapter addLabel:@"ABC abc"
                atPoint:NSMakePoint(row+140, 700-col)
                  angle:0.0
                  align:0];
      col += 12;
      if (col > 688) {
         col = 10;
         row += 200;
      }
   }
   [adapter renderPlot];
   [adapter closePlot];   

}

#define NSAppKitVersionNumber10_0 577
#define NSAppKitVersionNumber10_1 620
#define NSAppKitVersionNumber10_2 663

-(NSString *)_aqtSystemConfigString
{
//   APPKIT_EXTERN double NSAppKitVersionNumber;
   NSString *version = @"";   
   NSString *location = [[NSBundle mainBundle] bundlePath];
   
   // Get a system version or system info for >= 10.3
   if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_0) {
      /* On a 10.0.x or earlier system */
      version = @"10.0";
   } else if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_1) {
      /* On a 10.1 - 10.1.x system */
      version = @"10.1";
   } else if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_2) {
      /* On a 10.2 - 10.2.x system */
      version = @"10.2";
   } else {
      /* 10.3 or later system */
      version = @"10.3";
   }
   
   return [NSString stringWithFormat:@"Mac OS X %@\nInstall location: %@", version, location];
}

-(NSString *)_aqtBugMsg
{
    NSString *bugString = @"Bug report for AquaTerm 1.0.b3\n\n\
Description:\n-----------------------\n\n\
*\tPlease replace this item with a detailed description of the \n\
\tproblem.  Suggestions or general comments are also welcome.\n\n\
Repeat-By:\n-----------------------\n\n\
*\tPlease replace this item with a description of the sequence of\n\
\tevents that causes the problem to occur.\n\n\
Fix:\n-----------------------\n\n\
*\tIf possible, replace this item with a description of how to\n\
\tfix the problem (if you don't have a fix for the problem, don't\n\
\tinclude this section, but please do submit your report anyway).\n\n\
Configuration (please do not edit this section):\n\
-----------------------------------------------\n";
   
   return [NSString stringWithFormat:@"%@%@\n\n", bugString, [self _aqtSystemConfigString]];
}

-(IBAction)mailBug:(id)sender;
{
  NSString *msg = [self _aqtBugMsg];
  NSString *address = @"persquare@users.sourceforge.net";
  NSString *subject = @"AquaTerm bugreport";
  NSString *mailto = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", address, subject, msg]; 
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[mailto stringByAddingPercentEscapes]]];
}

-(NSString *)_aqtMailMsg
{
    return @"Feedback report for AquaTerm 1.0.b3\n\n\
Feedback:\n-----------------------\n\n\
*\tPlease replace this item with suggestions or general comments.\n\n";
}

-(IBAction)mailFeedback:(id)sender;
{
  NSString *msg = [self _aqtMailMsg];
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
