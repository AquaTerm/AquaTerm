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
-(id)initWithModel:(AQTModel *)aModel 
{
  
  if (self = [super init])
  {
    [self setModel:aModel];
    [self setClientInfoName:@"No connection" pid:-1];
    [NSBundle loadNibNamed:@"AQTWindow.nib" owner:self];
  }
  return self;
}

-(id)init
{
   AQTModel *aModel = [[[AQTModel alloc] init] autorelease];
   return [self initWithModel:aModel]; 
}

-(void)_aqtSetupView
{
  NSSize tmpSize = [model canvasSize];
  [viewOutlet setModel:model];
  [viewOutlet setFrameOrigin:NSMakePoint(0.0, 0.0)];
  if (_clientPID != -1)
  {
    [[viewOutlet window] setTitle:[NSString stringWithFormat:@"%@ (%d) %@", _clientName, _clientPID, [model title]]];
  }
  else
  {
    [[viewOutlet window] setTitle:[model title]];
  }
  [[viewOutlet window] setContentSize:tmpSize];
  [[viewOutlet window] setAspectRatio:tmpSize];
  [[viewOutlet window] setMaxSize:NSMakeSize(tmpSize.width*2, tmpSize.height*2)];
  [[viewOutlet window] setMinSize:NSMakeSize(tmpSize.width/4, tmpSize.height/4)];
  [viewOutlet setNeedsDisplay:YES];
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
  [super dealloc];
}

/*" Accessor methods for the AQTView instance "*/
-(id)viewOutlet
{
  return viewOutlet;
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
   if (_acceptingEvents == YES)
   {
      [_client processEvent:@"Okey-dokey"];
   }
}

- (void)mouseDownAt:(NSPoint)pos key:(char)aKey
{
  NSLog(@"Got coord: %@ and key: %c", NSStringFromPoint(pos), aKey);
  _selectedPoint = pos;
  _keyPressed = aKey;
  if (_acceptingEvents == YES)
  {
     NS_DURING
     [_client processEvent:[NSString stringWithFormat:@"Got coord: %@ and key: %c",NSStringFromPoint(pos), aKey]];
     NS_HANDLER
        NSLog([localException name]);
        if ([[localException name] isEqualToString:@"NSObjectInaccessibleException"])
           [self invalidateClient:_client]; // invalidate client
        else
           [localException raise];
     NS_ENDHANDLER
     
  }
}

- (char)keyPressed
{
  return _keyPressed;
}

- (NSPoint) selectedPoint
{
  return _selectedPoint;
}

#pragma mark === Delegate methods ===
- (void)windowWillClose:(NSNotification *)notification
{
  // FIXME: What to do when a valid client still exists?
  // Quite OK since client still retains AQTPlot instance, will however release it when finished =>
  // => orphaned window

  [[NSApp delegate] removePlot:self];
}


#pragma mark === From client handler ===
 
/*" The following methods applies to the currently selected view "*/
-(NSDictionary *)status
{
  NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:@"Status line" forKey:@"theKey"];
  return tmpDict;
}

-(char)mouseDownInfo:(inout NSPoint *)mouseLoc
{
  *mouseLoc = [self selectedPoint];
  return [self keyPressed];
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
  (void)[printOp runOperationModalForWindow:[viewOutlet window]
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
                               file:[[viewOutlet window] title]
                     modalForWindow:[viewOutlet window]
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
