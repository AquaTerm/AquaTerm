//
//  AQTColorInspector.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import "AQTColorInspector.h"
#import "AQTColorMap.h"
#import "AQTModel.h"
#import "GPTController.h"
#import "GPTWindowController.h"

@implementation AQTColorInspector
/**"
*** AQTColorInspector is the controller class for the Color Inspector nib.
"**/

- (id)init
{
  AQTColorMap *tempColormap;
  NSWindow *frontWindow = [[[NSApplication sharedApplication] delegate] frontWindow];
  if (self = [super initWithWindowNibName:@"ColorInspector"])
  {
    // User could open inspector panel before opening a graph window
    if(frontWindow)
    {
      // Read colormap from front window
      [self setFrontWindowController:[frontWindow windowController]];
      tempColormap = [[[[frontWindowController viewOutlet] model] colormap] copy]; // Copy implicitly retains object
    }
    else
    {
      // FIXME: should read default colormap since there is no graph window open
      tempColormap = [[AQTColorMap alloc] init];
    }
    [self setColormap:tempColormap];
    [tempColormap release];
  }
  return self;
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)awakeFromNib
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowChanged:)
                                               name:NSWindowDidBecomeMainNotification
                                             object:nil];

  [self updatePopUp];
  [self updateVisibleState];
}

- (void)setFrontWindowController:(GPTWindowController *)newWindowController
{
  AQTColorMap *tempColormap;
  AQTModel *model;
  // First check that it is an actual update
  if (newWindowController != frontWindowController)
  {
    frontWindowController = newWindowController;
    if (frontWindowController)
    {
      model = [[frontWindowController viewOutlet] model];
      tempColormap = [[model colormap] copy]; 
      [self setColormap:tempColormap];
      [tempColormap release];

      [infoText setStringValue:[NSString stringWithFormat:@"%d objects in %f seconds", [model count], [model timeTaken]]];
      [self updatePopUp];
      [self updateVisibleState];
    }
  }
}

#define specialsCount 4

-(void)setColormap:(AQTColorMap *)newColormap
{
  [newColormap retain];
  [localColormap release];
  localColormap = newColormap;
  colorCount = [[localColormap colorList] count] - specialsCount;
}

- (void)updatePopUp
{
  int i, items = (colorCount-1)/8 + 1;
  [rangePopUp removeAllItems];
  for (i=0; i<items;i++)
  {
    [rangePopUp insertItemWithTitle:[NSString stringWithFormat:@"Color %d É %d", i*8+1, (i+1)*8] atIndex:i];
  }
  [rangePopUp setAutoenablesItems:YES];
}

- (void)updateVisibleState
{
  [backgroundColor setColor:[localColormap colorForIndex: -4]];
  [axisColor setColor:[localColormap colorForIndex: -2]];
  [gridlineColor setColor:[localColormap colorForIndex: -1]];
  [lineColor1 setColor:[localColormap colorForIndex: cRange + 0]];
  [lineColor2 setColor:[localColormap colorForIndex: cRange + 1]];
  [lineColor3 setColor:[localColormap colorForIndex: cRange + 2]];
  [lineColor4 setColor:[localColormap colorForIndex: cRange + 3]];
  [lineColor5 setColor:[localColormap colorForIndex: cRange + 4]];
  [lineColor6 setColor:[localColormap colorForIndex: cRange + 5]];
  [lineColor7 setColor:[localColormap colorForIndex: cRange + 6]];
  [lineColor8 setColor:[localColormap colorForIndex: cRange + 7]];
  [color1Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 1]];
  [color2Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 2]];
  [color3Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 3]];
  [color4Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 4]];
  [color5Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 5]];
  [color6Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 6]];
  [color7Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 7]];
  [color8Label setStringValue:[NSString  stringWithFormat:@"Color %d", cRange + 8]];
}

- (IBAction)didSelectRange:(id)sender
{
  int rangeBase = -1;
  if ([sender indexOfSelectedItem] != -1)
  {
    rangeBase = [sender indexOfSelectedItem];
    if (rangeBase != cRange)
    {
      [self updateColormap];
      cRange = (rangeBase*8);
      [self updateVisibleState];
    }
  }
}

-(void)updateColormap
{
  // Get the state from the panel...
  [localColormap setColor:[backgroundColor color] forIndex: -4];
  [localColormap setColor:[axisColor color] forIndex: -2];
  [localColormap setColor:[gridlineColor color] forIndex: -1];
  [localColormap setColor:[lineColor1 color] forIndex: cRange + 0];
  [localColormap setColor:[lineColor2 color] forIndex: cRange + 1];
  [localColormap setColor:[lineColor3 color] forIndex: cRange + 2];
  [localColormap setColor:[lineColor4 color] forIndex: cRange + 3];
  [localColormap setColor:[lineColor5 color] forIndex: cRange + 4];
  [localColormap setColor:[lineColor6 color] forIndex: cRange + 5];
  [localColormap setColor:[lineColor7 color] forIndex: cRange + 6];
  [localColormap setColor:[lineColor8 color] forIndex: cRange + 7];
  
}

- (IBAction)applyPressed:(id)sender
  /*" create new AQTColorMap from the current settings, and update the active AQTModel "*/
{
  [self updateColormap];

  if (!frontWindowController) {
    // could be one of two things, either there really is no window
    // or it just hasn't been properly set yet
    NSWindow *frontWindow = [[[NSApplication sharedApplication] delegate] frontWindow];
    if(frontWindow)
    {
      [self setFrontWindowController:[frontWindow windowController]];
    }
  }
  [[[frontWindowController viewOutlet] model] updateColors:localColormap];
  [[frontWindowController viewOutlet] setNeedsDisplay:YES];
}

-(void)mainWindowChanged:(NSNotification *)notification
{
  if([[[notification object] windowController] isKindOfClass:[GPTWindowController class]])
  {
    // Store a ref to the windowController rather than the model since we need access to the view as well. PP
    [self setFrontWindowController:[[notification object] windowController]];
  }
}
@end

