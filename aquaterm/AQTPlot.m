//
//  AQTPlot.m
//  AquaTerm
//
//  Created by Per Persson on Mon Jul 28 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import "AQTPlot.h"
#import "AQTGraphic.h"
#import "AQTModel.h"
#import "AQTView.h"
#import "AQTGraphicDrawingMethods.h"
#import "AQTModelAdditions.h"
#import "AQTFunctions.h"
#import "AQTPrefController.h"

#import "AQTEventProtocol.h"

#define TITLEBAR_HEIGHT 22.0
#define WINDOW_MIN_WIDTH 200.0
#define WINDOW_MAX_WIDTH 4096.0

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}

#ifdef DEBUG
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif	/* LOGGING */


@implementation AQTPlot
-(id)init
{
   if (self = [super init])
   {
      [self setClientInfoName:@"No connection" pid:-1];
      [self setAcceptingEvents:NO];
      [NSBundle loadNibNamed:@"AQTWindow.nib" owner:self];
   }
   return self;
}

-(void)_aqtSetupViewShouldResize:(BOOL)shouldResize
{
   NSSize contentSize, windowSize, maxSize, minSize, ratio;
   NSRect windowFrame = [[canvas window] frame];
   NSPoint windowTopLeft = NSMakePoint(NSMinX(windowFrame), NSMaxY(windowFrame)); 
   contentSize = [model canvasSize];
   windowSize = contentSize;
   windowSize.height += TITLEBAR_HEIGHT;
   // FIXME: Better handling of min/max size
   maxSize = NSMakeSize(WINDOW_MAX_WIDTH, WINDOW_MAX_WIDTH*contentSize.height/contentSize.width + TITLEBAR_HEIGHT);
   minSize = NSMakeSize(WINDOW_MIN_WIDTH, WINDOW_MIN_WIDTH*contentSize.height/contentSize.width + TITLEBAR_HEIGHT);
   ratio = windowSize;
   
   [canvas setModel:model];
   [canvas setFrameOrigin:NSMakePoint(0.0, 0.0)];
   if (_clientPID != -1)
   {
      NSString *nameString = [preferences integerForKey:@"ShowProcessName"]?[NSString stringWithFormat:@"%@ ", _clientName]:@"";
      NSString *pidString = [preferences integerForKey:@"ShowProcessId"]?[NSString stringWithFormat:@"(%d) ", _clientPID]:@"";
      [[canvas window] setTitle:[NSString stringWithFormat:@"%@%@%@", nameString, pidString, [model title]]];
   }
   else
   {
      [[canvas window] setTitle:[model title]];
   }
   
   if (shouldResize)
   {
      NSRect contentFrame = NSZeroRect;
      contentFrame.size = contentSize;
      [[canvas window] setContentSize:contentSize];
      [[canvas window] setFrameTopLeftPoint:windowTopLeft];      
      [canvas setFrame:contentFrame];
      [[canvas window] setAspectRatio:ratio];
   }
   [[canvas window] setMaxSize:maxSize];   // FIXME: take screen size into account
   [[canvas window] setMinSize:minSize];
   [canvas setIsProcessingEvents:_acceptingEvents];
}

-(void)awakeFromNib
{
   [self cascadeWindowOrderFront:NO];
   if (model)
   {
      [self _aqtSetupViewShouldResize:YES];
      [[canvas window] makeKeyAndOrderFront:self];
   }
   _isWindowLoaded = YES;
}

#ifdef MEM_DEBUG
- (void)release
{
#warning 64BIT: Check formatting arguments
   NSLog(@"in --> %@ %s line %d, rc=%d", NSStringFromSelector(_cmd), __FILE__, __LINE__, [self retainCount]);
   [super release];
}
#endif

-(void)dealloc
{
#ifdef MEM_DEBUG
#warning 64BIT: Check formatting arguments
   NSLog(@"[%@(0x%x) %@] %s:%d", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), __FILE__, __LINE__);
#endif
   [model release];
   [_clientName release];
   [super dealloc];
}

-(void)cascadeWindowOrderFront:(BOOL)orderFront
{
   [[NSApp delegate] setWindowPos:[canvas window]];
   if (orderFront)
      [[canvas window] makeKeyAndOrderFront:self];      
}   

-(void)constrainWindowToFrame:(NSRect)tileFrame
{
   NSRect tmpFrame;
   float tileContentHWRatio = (tileFrame.size.height - TITLEBAR_HEIGHT)/tileFrame.size.width;
   float canvasHWRatio = [model canvasSize].height/[model canvasSize].width;
   
   if (canvasHWRatio < tileContentHWRatio) {
      // limited by width
      float height = tileFrame.size.width*canvasHWRatio+TITLEBAR_HEIGHT;
      tmpFrame = NSMakeRect(tileFrame.origin.x, tileFrame.origin.y+(tileFrame.size.height-height), tileFrame.size.width, height);
   } else {
      // limited by height
      tmpFrame = NSMakeRect(tileFrame.origin.x, tileFrame.origin.y, (tileFrame.size.height - TITLEBAR_HEIGHT)/canvasHWRatio, tileFrame.size.height);
   }
   // NSLog(@"%@ --> %@", NSStringFromRect(tileFrame), NSStringFromRect(tmpFrame));
   [[canvas window] setFrame:tmpFrame display:YES];
   [[canvas window] makeKeyAndOrderFront:self];      
}   



/*" Accessor methods for the AQTView instance "*/
-(id)canvas
{
   return canvas;
}

-(AQTModel *)model
{
   return model;
}

- (BOOL)clientValidAndResponding
{
   BOOL validAndResponding = NO;
   if (_client != nil)
   {
      validAndResponding = YES;
      NS_DURING
         [_client ping];
      NS_HANDLER
         validAndResponding = NO;
      NS_ENDHANDLER
   }      
   return validAndResponding;
}

- (BOOL)acceptingEvents;
{
   return _acceptingEvents;
}

#pragma mark === AQTClientProtocol methods ===
-(void)setModel:(AQTModel *)newModel
{
   LOG(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__); 
   LOG([newModel description]);
   BOOL viewNeedResize = YES;
   [newModel retain];
   if (model) {
      // Respect the windowsize set by user
      viewNeedResize = !AQTProportionalSizes([model canvasSize], [newModel canvasSize]);
   }
   [model release];		// let go of any temporary model not used (unlikely)
   model = newModel;		// Make it point to new model
   [model updateBounds];
   
   if (_isWindowLoaded) {
      [self _aqtSetupViewShouldResize:viewNeedResize];
      [model invalidate]; // Invalidate all of canvas
   }
}

-(void)appendModel:(AQTModel *)newModel
{
   LOG(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   if (!model) {
      LOG(@"No model, passing to setModel:");
      [self setModel:newModel];
   } else {
      LOG([newModel description]);
      BOOL viewNeedResize = !AQTProportionalSizes([model canvasSize], [newModel canvasSize]);
      [model appendModel:newModel];
      if (_isWindowLoaded)
      {
         [self _aqtSetupViewShouldResize:viewNeedResize];
         // FIXME: Why was the next line needed???
         // dirtyRect = backgroundDidChange?AQTRectFromSize([model canvasSize]):AQTUnionRect(dirtyRect, [newModel bounds]);
      }      
   }
}

- (void)draw
{
   LOG(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   [canvas setNeedsDisplayInRect:[canvas convertRectToViewCoordinates:[model dirtyRect]]];
   [[canvas window] makeKeyAndOrderFront:self];
   [model clearDirtyRect];
}

/* This is a "housekeeping" method, to avoid buildup of hidden objects, does not imply redraw(?) */
- (void)removeGraphicsInRect:(NSRect)targetRect
{
   LOG(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   [model removeGraphicsInRect:targetRect];
}

-(void)setAcceptingEvents:(BOOL)flag
{
   LOG(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   _acceptingEvents = flag; // && (_client != nil);
   if (_isWindowLoaded)
   {
      [canvas setIsProcessingEvents:_acceptingEvents];
   }
}

-(void)aqtClosePanelDidEnd:(id)sheet returnCode:(int32_t)retCode contextInfo:(id)contextInfo
{
   LOG(@"", NSStringFromSelector(_cmd));
   if (retCode == NSAlertAlternateReturn) {
      [[canvas window] close];
   }
}

-(void)close
{
   // Check defaults and maybe throw up a modal sheet asking for confirmation
   if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CloseWindowWhenClosingPlot"] == YES) {
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmCloseWindowWhenClosingPlot"] == YES) {
      NSBeginAlertSheet(@"Close window?", 
                        @"Keep", @"Close", 
                        nil, [canvas window], self, 
                        @selector(aqtClosePanelDidEnd:returnCode:contextInfo:), 
                        NULL, nil, 
                        @"The client is finished with the plot (or exiting) and tries to close the window. Do you want to close the window or keep it on screen?");
      } else {
         [[canvas window] close];
      }
   }
}

-(void)setClient:(id)client
{
   LOG(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   [client retain];
   if ([client isProxy]) {
      [client setProtocolForProxy:@protocol(AQTEventProtocol)];
   }
   [_client release];
   _client = client;		
}

#pragma mark === Local methods ===

-(BOOL)invalidateClient //:(id)aClient
{
   [self setAcceptingEvents:NO];
   [self setClient:nil];
   [self setClientInfoName:@"No connection" pid:-1];
   [[canvas window] setTitle:[model title]];
   return YES;
}


-(void)setClientInfoName:(NSString *)name pid:(int32_t)pid
{
   [name retain];
   [_clientName release];
   _clientName = name;	
   _clientPID = pid;
}

-(void)processEvent:(NSString *)event
{
   if(_acceptingEvents) // FIXME: redundant!?
   {
      NS_DURING
         [_client processEvent:event sender:self];
      NS_HANDLER
         if ([[localException name] isEqualToString:NSObjectInaccessibleException])
            [self invalidateClient];//:_client]; // invalidate client
         else
            [localException raise];
      NS_ENDHANDLER
   }
}
#pragma mark === Delegate methods ===
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
   // FIXME: take screen size into account
   NSSize tmpSize = [model canvasSize]; 
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   if (tmpSize.width > tmpSize.height)
   {
      // decide by width
      proposedFrameSize.height = proposedFrameSize.width * ([model canvasSize].height/[model canvasSize].width) + TITLEBAR_HEIGHT;
   }
   else
   {
      // decide by height
      proposedFrameSize.width = (proposedFrameSize.height - TITLEBAR_HEIGHT) * ([model canvasSize].width/[model canvasSize].height);
   }
   return proposedFrameSize;
}

- (BOOL)windowShouldClose:(id)sender
{
   BOOL shouldClose = YES;
   if (_client)
   {
      // Post a notification to check (later) wheter or not the client is still alive, if it isn't the window is closed
      [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"AQTWindowDidCloseNotification" object:self]
                                                 postingStyle:NSPostWhenIdle];
      if ([self acceptingEvents] == NO)
      {
         [sender orderOut:self];
      }
      shouldClose = NO;
   }
   return shouldClose;
}

- (void)windowWillClose:(NSNotification *)notification
{
   [[NSApp delegate] removePlot:self];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
   // FIXME: who should be the delegate of whom?
   [[notification object] invalidateCursorRectsForView:canvas];
}

#pragma mark === Menu actions ===
#ifdef DEBUG_BOUNDS
- (void)toggleShowBounds:(id)sender
{
   [model toggleShouldShowBounds];
   [[model modelObjects] makeObjectsPerformSelector:@selector(toggleShouldShowBounds)];
   [sender setState:[model shouldShowBounds]];
   [canvas setNeedsDisplay:YES];
}
#endif

- (IBAction)copy:(id)sender
{
   NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
   AQTView *printView;
   
   printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [model canvasSize].width, [model canvasSize].height)];
   [printView setModel:model];
   
   [pasteboard declareTypes:[NSArray arrayWithObjects:NSPDFPboardType, NSPostScriptPboardType, nil] owner:nil];
   [pasteboard setData:[printView dataWithPDFInsideRect:[printView bounds]] forType:NSPDFPboardType];
   [pasteboard setData:[printView dataWithEPSInsideRect:[printView bounds]] forType:NSPostScriptPboardType];
   [printView release];
}

- (void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success  contextInfo:(AQTView *)printView
{
}

-(IBAction)printDocument:(id)sender
{
   AQTView *printView;
   NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo]; 
   NSSize paperSize = [printInfo paperSize];
   NSPrintOperation *printOp;
   
   paperSize.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
   paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
   if ([printInfo orientation] == NSPortraitOrientation)
   {
      paperSize.height = ([model canvasSize].height * paperSize.width) / [model canvasSize].width;
   }
   else
   {
      paperSize.width = ([model canvasSize].width * paperSize.height) / [model canvasSize].height;
   }
   
   printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height)];
   [printView setModel:model];
   
   printOp = [NSPrintOperation printOperationWithView:printView];
   (void)[printOp runOperationModalForWindow:[canvas window]
                                    delegate:self
                              didRunSelector:nil // @selector(printOperationDidRun:success:contextInfo:)
                                 contextInfo:printView];
   [printView release];
}

- (IBAction)saveDocumentAs:(id)sender
{
   NSSavePanel *savePanel = [NSSavePanel savePanel];
   
   if (![NSBundle loadNibNamed:@"ExtendSavePanel" owner:self])
   {
      NSLog(@"Failed to load ExtendSavePanel.nib");
      return;
   }
   [saveFormatPopUp selectItemWithTitle:[preferences objectForKey:@"CurrentSaveFormat"]];
   [savePanel setAccessoryView:extendSavePanelView];
   [savePanel beginSheetForDirectory:[preferences objectForKey:@"CurrentSaveFolder"] 
                                file:[model title]
                      modalForWindow:[canvas window]
                       modalDelegate:self
                      didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
                         contextInfo:saveFormatPopUp
      ];
}

- (void)savePanelDidEnd:(NSSavePanel *)theSheet returnCode:(int32_t)returnCode contextInfo:(NSPopUpButton *)formatPopUp
{
   NSData *data;
   NSString *filename;
   AQTView *printView;
   if (NSFileHandlingPanelOKButton == returnCode) {
      printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [model canvasSize].width, [model canvasSize].height)];
      [printView setModel:model];
      filename = [[theSheet filename] stringByDeletingPathExtension];
      if ([[formatPopUp titleOfSelectedItem] isEqualToString:@"PDF"]) {
         data = [printView dataWithPDFInsideRect: [printView bounds]];
         [data writeToFile:[filename stringByAppendingPathExtension:@"pdf"] atomically: NO];
      } else {
         data = [printView dataWithEPSInsideRect: [printView bounds]];
         [data writeToFile:[filename stringByAppendingPathExtension:@"eps"] atomically: NO];
      }
      [preferences setObject:[filename stringByDeletingLastPathComponent] forKey:@"CurrentSaveFolder"];
      [preferences setObject:[formatPopUp titleOfSelectedItem] forKey:@"CurrentSaveFormat"];
      [printView release];
   }
}


- (void)runPageLayout:(id)sender 
{
   [NSApp runPageLayout:(id)sender];
}

- (IBAction)refreshView:(id)sender
{
   [canvas setNeedsDisplay:YES];
   [model clearDirtyRect];
}

#pragma mark ==== Testing methods ====
- (void)timingTestWithTag:(uint32_t)tag
{
   static float totalTime = 0.0;
   float thisTime;
   NSDate *startTime;
   NSRect viewRect = NSMakeRect(0.0, 0.0, [model canvasSize].width, [model canvasSize].height);
   AQTView *testView = [self canvas];
   [testView setModel:model];
   if ([testView lockFocusIfCanDraw]) {
      startTime = [NSDate date];   
      [testView drawRect:viewRect];
      thisTime = -[startTime timeIntervalSinceNow];
      totalTime += thisTime;
      NSLog(@"tag:%d time: %f for %d objects.", tag, thisTime, [[model modelObjects] count]);
      [testView unlockFocus];
   } else {
      NSLog(@"Can't draw for tag:%d", tag);
   }
}
@end
