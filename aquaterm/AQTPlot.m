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

@implementation AQTPlot
-(id)init
{
   if (self = [super init])
   {
      [self setClientInfoName:@"No connection" pid:-1];
      [self setAcceptingEvents:NO];
      [self setLastEvent:@"0"];
      [NSBundle loadNibNamed:@"AQTWindow.nib" owner:self];
   }
   return self;
}

-(void)_aqtSetupView
{
   NSSize tmpSize = [model canvasSize];
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
   [[canvas window] setContentSize:tmpSize];
   [[canvas window] setAspectRatio:tmpSize];
   [[canvas window] setMaxSize:NSMakeSize(tmpSize.width*2, tmpSize.height*2)];
   [[canvas window] setMinSize:NSMakeSize(tmpSize.width/4, tmpSize.height/4)];
   [canvas setNeedsDisplay:YES];
   [[canvas window] setIsVisible:YES];
}

-(void)awakeFromNib
{
   if (model)
   {
      [self _aqtSetupView];
   }
   _isWindowLoaded = YES;
}

-(void)dealloc
{
   NSLog(@"Over and out from AQTPlot!");
   [model release];
   [_clientName release];
   [lastEvent release];
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
   [newModel retain];
   [model release];		// let go of any temporary model not used (unlikely)
   model = newModel;		// Make it point to new model

   if (_isWindowLoaded)
   {
      [self _aqtSetupView];
   }
}

-(BOOL)invalidateClient:(id)aClient
{
   if (_client == aClient)
   {
      NSLog(@"Invalidating client");
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
   [_client release];		// let go of any temporary model not used (unlikely)
   _client = client;		// Make it point to new model
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
   _acceptingEvents = flag && (_client != nil);
   [canvas setIsProcessingEvents:_acceptingEvents];
   [self setLastEvent:@"0"];
}

- (NSString *)lastEvent
{
   return lastEvent;
}

-(void)setLastEvent:(NSString *)event
{
   [event retain];
   [lastEvent autorelease];
   lastEvent = event;
   // Also inform client
   if(_acceptingEvents)
   {
      NS_DURING
         [_client processEvent:event];
      NS_HANDLER
         NSLog([localException name]);
         if ([[localException name] isEqualToString:@"NSObjectInaccessibleException"])
            [self invalidateClient:_client]; // invalidate client
         else
            [localException raise];
      NS_ENDHANDLER
   }
}

#pragma mark === Delegate methods ===
- (void)windowWillClose:(NSNotification *)notification
{
   // FIXME: What to do when a valid client still exists?
   // Quite OK since client still retains AQTPlot instance, will however release it when finished =>
   // => orphaned window ?

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
   NSLog(@"Hello from save");
   /*
    if (![NSBundle loadNibNamed:@"ExtendSavePanel" owner:self])
    {
       NSLog(@"Failed to load ExtendSavePanel.nib");
       return;
    }
    [savePanel setAccessoryView:extendSavePanelView];
    */
   [savePanel beginSheetForDirectory:NSHomeDirectory()
                                file:[[canvas window] title]
                      modalForWindow:[canvas window]
                       modalDelegate:self
                      didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
                         contextInfo:nil //saveFormatPopup
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
      /*
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
       */
      data = [printView dataWithPDFInsideRect: [printView bounds]];
      [data writeToFile: [filename stringByAppendingPathExtension:@"pdf"] atomically: NO];

      [printView release];
   }
}
@end
