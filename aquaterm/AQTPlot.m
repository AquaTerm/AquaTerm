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

@implementation AQTPlot
-(id)initWithModel:(AQTModel *)aModel index:(int)index
{
  self = [super init];
  if (self)
  {
    [self setModel:aModel];
    [NSBundle loadNibNamed:@"AQTWindow.nib" owner:self];
    viewIndex = index;
  }
  return self;
}

-(void)_aqtSetupView
{
  NSSize tmpSize = [model canvasSize];
  [viewOutlet setModel:model];
  [viewOutlet setFrameOrigin:NSMakePoint(0.0, 0.0)];
  [[viewOutlet window] setTitle:[model title]];
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
  _isWindowLoaded = TRUE;
}

-(void)dealloc
{
  [super dealloc];
}

/*" Accessor methods for the AQTView instance "*/
-(id)viewOutlet
{
  return viewOutlet;
}

-(int)viewIndex
{
  return viewIndex;
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

- (void)beginMouseInput
{
  _selectedPointIsValid = NO;
  [[self viewOutlet] setMouseIsActive:YES];
}

- (void)mouseDownAt:(NSPoint)pos key:(char)aKey
{
  [[self viewOutlet] setMouseIsActive:NO];
  NSLog(@"Got coord: %@", NSStringFromPoint(pos));
  _selectedPoint = pos;
  _keyPressed = aKey;
  _selectedPointIsValid = YES;
}

- (NSPoint) selectedPoint
{
  return _selectedPoint;
}

-  (BOOL) selectedPointIsValid
{
  return _selectedPointIsValid;
}


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
