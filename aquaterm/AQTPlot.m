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
#import "AQTFunctions.h"
#import "AQTPrefController.h"

#import "AQTEventProtocol.h"

#define TITLEBAR_HEIGHT 22.0

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
   maxSize = NSMakeSize(2.0*contentSize.width, 2.0*contentSize.height + TITLEBAR_HEIGHT);
   minSize = NSMakeSize(0.5*contentSize.width, 0.5*contentSize.height + TITLEBAR_HEIGHT);
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
   [[NSApp delegate] setWindowPos:[canvas window]];
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
   NSLog(@"in --> %@ %s line %d, rc=%d", NSStringFromSelector(_cmd), __FILE__, __LINE__, [self retainCount]);
   [super release];
}
#endif

-(void)dealloc
{
#ifdef MEM_DEBUG
   NSLog(@"[%@(0x%x) %@] %s:%d", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), __FILE__, __LINE__);
#endif
   [model release];
   [_clientName release];
   [super dealloc];
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

/*
 -(void)setPlotKey:(id)key
 {
    [key retain];
    [_plotKey release];
    _plotKey = key;
 }
 */
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
   BOOL viewNeedResize = YES;
   NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);   
   [newModel retain];
   if (model)
   {
      // Respect the windowsize set by user
      NSSize oldSize = [model canvasSize];
      NSSize newSize = [newModel canvasSize];
      if (fabs(oldSize.height/oldSize.width - newSize.height/newSize.width) < 0.001)
      {
         viewNeedResize = NO;
      }
   }
   [model release];		// let go of any temporary model not used (unlikely)
   model = newModel;		// Make it point to new model
   [model updateBounds];
   
   if (_isWindowLoaded)
   {
      [self _aqtSetupViewShouldResize:viewNeedResize];
      dirtyRect = AQTRectFromSize([model canvasSize]); // Invalidate all of canvas
   }
}

-(void)appendModel:(AQTModel *)newModel
{
   BOOL backgroundDidChange; // FIXME
   NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   if (!model)
   {
      [self setModel:newModel];
      return;
   }
   backgroundDidChange = !AQTEqualColors([model color], [newModel color]);
   //[model appendModel:newModel]; // expanded here:
   [model setTitle:[newModel title]];
   [model setColor:[newModel color]];
   [model setBounds:AQTUnionRect([model bounds], [newModel updateBounds])];
   [model addObjectsFromArray:[newModel modelObjects]];
   
#ifdef DEBUG_BOUNDS
   NSLog(@"oldBounds = %@", NSStringFromRect([model bounds]));
   NSLog(@"addedBounds = %@", NSStringFromRect([newModel bounds]));
#endif
   
   if (_isWindowLoaded)
   {
      [self _aqtSetupViewShouldResize:NO];
      dirtyRect = AQTUnionRect(dirtyRect, backgroundDidChange?AQTRectFromSize([model canvasSize]):[newModel bounds]);
      
#ifdef DEBUG_BOUNDS
      NSLog(@"dirtyRect = %@", NSStringFromRect(dirtyRect));
#endif
   }
}

- (void)draw
{
   [canvas setNeedsDisplayInRect:[canvas convertRectToViewCoordinates:dirtyRect]];
   [[canvas window] makeKeyAndOrderFront:self];
}

/* This is a "housekeeping" method, to avoid buildup of hidden objects, does not imply redraw(?) */
- (void)removeGraphicsInRect:(NSRect)targetRect
{
   // FIXME: Where does this belong? Here, category or in model proper (not functional in client)
   NSRect testRect;
   NSRect clipRect = AQTRectFromSize([model canvasSize]);
   NSRect newBounds = NSZeroRect;
   int i;
   int  objectCount = [model count];
   NSArray *modelObjects = [model modelObjects];
   
   // check for nothing to remove or disjoint modelBounds <--> targetRect
   if (objectCount == 0 || AQTIntersectsRect(targetRect, [model bounds]) == NO)
      return;
   
   // Apply clipRect (=canvasRect) to graphic bounds before comparing.
   if (AQTContainsRect(targetRect, NSIntersectionRect([model bounds], clipRect)))
   {
      [model removeAllObjects];
   }
   else
   {
      for (i = objectCount - 1; i >= 0; i--)
      {
         testRect = [[modelObjects objectAtIndex:i] bounds];
         if (AQTContainsRect(targetRect, NSIntersectionRect(testRect, clipRect)))
         {
            [model removeObjectAtIndex:i];
         }
         else
         {
            newBounds = AQTUnionRect(newBounds, testRect);
         }
      }
   }
   [model setBounds:newBounds];
   // NSLog(@"Removed %d objs, new bounds: %@", objectCount - [modelObjects count], [self description]);
   dirtyRect = AQTUnionRect(dirtyRect, targetRect);
}

-(void)setAcceptingEvents:(BOOL)flag
{
   _acceptingEvents = flag; // && (_client != nil);
   if (_isWindowLoaded)
   {
      [canvas setIsProcessingEvents:_acceptingEvents];
   }
}

-(void)close
{
   NSLog(@"close");
}

-(BOOL)invalidateClient //:(id)aClient
{
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);   
   //   if (_client == aClient)
   //   {
   // NSLog(@"invalidating %d", _client);
   [self setAcceptingEvents:NO];
   [self setClient:nil];
   [self setClientInfoName:@"No connection" pid:-1];
   [[canvas window] setTitle:[model title]];
   return YES;
   //   }
   //   return NO;
}

-(void)setClient:(id)client
{
   [client retain];
   if ([client isProxy])
   {
      NSLog(@"Setting prot for client proxy");
      [client setProtocolForProxy:@protocol(AQTEventProtocol)];
   }
   [_client release];
   _client = client;		
}

-(void)setClientInfoName:(NSString *)name pid:(int)pid
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
   // FIXME: Check for presence of client, it may have been release w/o invalidating itself
   // and this class will leak until app quits.
   // QUE?! If client goes away, retain count is automagically decreased???
   
   // NSLog(@"in --> %@ %s line %d, rc=%d", NSStringFromSelector(_cmd), __FILE__, __LINE__, [self retainCount]);
   if (_client)
   {
      NS_DURING
         [_client ping];
         // NSLog(@"in --> %@ %s line %d, rc=%d", NSStringFromSelector(_cmd), __FILE__, __LINE__, [self retainCount]);
      NS_HANDLER
         [self invalidateClient];//:_client];
                                 // FIXME: Tell controller to check all connections?
         NS_ENDHANDLER   
   } 
   if (_client)
   {
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

- (void)savePanelDidEnd:(NSSavePanel *)theSheet returnCode:(int)returnCode contextInfo:(NSPopUpButton *)formatPopUp
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
}
@end
