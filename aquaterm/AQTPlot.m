//
//  AQTPlot.m
//  AquaTerm
//
//  Created by Per Persson on Mon Jul 28 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import "AQTPlot.h"
#import "AQTModel.h"
#import "AQTView.h"
#import "AQTAdapter.h"
#import "AQTPlotBuilder.h"

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
   contentSize = [model canvasSize];
   windowSize = contentSize;
   windowSize.height += TITLEBAR_HEIGHT;
   maxSize = NSMakeSize(2.0*contentSize.width, 2.0*contentSize.height + TITLEBAR_HEIGHT);
   minSize = NSMakeSize(0.5*contentSize.width, 0.5*contentSize.height + TITLEBAR_HEIGHT);
   ratio = windowSize;
/* Fixing content size when resizing requires use of windowDidResize?
   NSLog(@"contentSize:%@", NSStringFromSize(contentSize));
   NSLog(@"windowSize:%@", NSStringFromSize(windowSize));
   NSLog(@"maxSize:%@", NSStringFromSize(maxSize));
   NSLog(@"minSize:%@", NSStringFromSize(minSize));
   NSLog(@"ratio:%@", NSStringFromSize(ratio));
*/
   [canvas setModel:model];
   [canvas setFrameOrigin:NSMakePoint(0.0, 0.0)];
   if (_clientPID != -1)
   {
      [[canvas window] setTitle:[NSString stringWithFormat:@"%@ (%d) %@", _clientName, _clientPID, [model title]]];
   }
   else
   {
      [[canvas window] setTitle:[model title]];
   }
   if (shouldResize)
   {
      [[canvas window] setContentSize:contentSize];
      [[canvas window] setAspectRatio:ratio];
   }
   [[canvas window] setMaxSize:maxSize];
   [[canvas window] setMinSize:minSize];
   [canvas setIsProcessingEvents:_acceptingEvents];
   [[canvas window] setIsVisible:YES];
   [[canvas window] orderFront:self];
   [canvas setNeedsDisplay:YES];
}

-(void)awakeFromNib
{
   if (model)
   {
      [self _aqtSetupViewShouldResize:YES];
   }
   _isWindowLoaded = YES;
}

-(void)dealloc
{
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

-(void)setModel:(AQTModel *)newModel
{
   BOOL viewNeedResize = YES;
   
   [newModel retain];
   if (model)
   {
      NSSize oldSize = [model canvasSize];
      NSSize newSize = [newModel canvasSize];
      if (fabs(oldSize.height/oldSize.width - newSize.height/newSize.width) < 0.001)
      {
         viewNeedResize = NO;
      }
   }
   [model release];		// let go of any temporary model not used (unlikely)
   model = newModel;		// Make it point to new model

   if (_isWindowLoaded)
   {
      [self _aqtSetupViewShouldResize:viewNeedResize];
   }
}

-(BOOL)invalidateClient:(id)aClient
{
   if (_client == aClient)
   {
      // NSLog(@"Invalidating client");
      [self setAcceptingEvents:NO];
      [self setClient:nil];
      [self setClientInfoName:@"No connection" pid:-1];
      [[canvas window] setTitle:[model title]];
      return YES;
   }
   return NO;
}

-(void)setClient:(id)client
{
   [client retain];
   [_client release];		
   _client = client;		
}

-(void)setClientInfoName:(NSString *)name pid:(int)pid
{
   [name retain];
   [_clientName release];		// let go of any temporary model not used (unlikely)
   _clientName = name;		// Make it point to new model
   _clientPID = pid;
}

-(void)setAcceptingEvents:(BOOL)flag
{
   _acceptingEvents = flag; // && (_client != nil);
   if (_isWindowLoaded)
   {
      [canvas setIsProcessingEvents:_acceptingEvents];
   }
}


-(void)processEvent:(NSString *)event
{
   if(_acceptingEvents) // FIXME: redundant!?
   {
      NS_DURING
         [_client processEvent:event];
      NS_HANDLER
         // NSLog([localException name]);
         if ([[localException name] isEqualToString:@"NSObjectInaccessibleException"])
            [self invalidateClient:_client]; // invalidate client
         else
            [localException raise];
      NS_ENDHANDLER
   }
}
#pragma mark === Delegate methods ===
- (BOOL)windowShouldClose:(id)sender
{
   BOOL shouldClose = YES; 
   if (_client)
   {
      [sender orderOut:self];
      shouldClose = NO;
   }
   return shouldClose;
}

- (void)windowWillClose:(NSNotification *)notification
{
   [[NSApp delegate] removePlot:self];
}


-(void)close
{
   NSLog(@"close");
}

#pragma mark === Menu actions ===

- (IBAction)copy:(id)sender
{
   NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
   AQTView *printView;

   printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [model canvasSize].width, [model canvasSize].height)];
   [printView setModel:model];
   //[printView setIsPrinting:YES];
   [pasteboard declareTypes:[NSArray arrayWithObjects:NSPDFPboardType, NSPostScriptPboardType, nil] owner:nil];

   [pasteboard setData:[printView dataWithPDFInsideRect:[printView bounds]] forType:NSPDFPboardType];
   [pasteboard setData:[printView dataWithEPSInsideRect:[printView bounds]] forType:NSPostScriptPboardType];
   [printView release];
}

- (void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success  contextInfo:(AQTView *)printView
{
   //[printView setIsPrinting:NO];
}

-(IBAction)printDocument:(id)sender
{
   AQTView *printView;
   NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo]; // [self printInfo];
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
   //[printView setIsPrinting:YES];

   printOp = [NSPrintOperation printOperationWithView:printView];
   (void)[printOp runOperationModalForWindow:[canvas window]
                                    delegate:self
                              didRunSelector:@selector(printOperationDidRun:success:contextInfo:)
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
    [savePanel setAccessoryView:extendSavePanelView];
   [savePanel beginSheetForDirectory:NSHomeDirectory()
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
   if (NSFileHandlingPanelOKButton == returnCode)
   {
      printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [model canvasSize].width, [model canvasSize].height)];
      [printView setModel:model];
      //[printView setIsPrinting:YES];
      filename = [[theSheet filename] stringByDeletingPathExtension];
       if ([[formatPopUp titleOfSelectedItem] isEqualToString:@"PDF"])
       {
          data = [printView dataWithPDFInsideRect: [printView bounds]];
          [data writeToFile: [filename stringByAppendingPathExtension:@"pdf"] atomically: NO];
       }
       else
       {
          data = [printView dataWithEPSInsideRect: [printView bounds]];
          [data writeToFile: [filename stringByAppendingPathExtension:@"eps"] atomically: NO];
       }

      [printView release];
   }
}
@end
