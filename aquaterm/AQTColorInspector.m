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
#import "AQTView.h"
#import "AQTController.h"
#import "GPTWindowController.h"

@implementation AQTColorInspector
/**"
*** AQTColorInspector is the controller class for the Color Inspector nib.
"**/

- (id)init
{
  if (self = [super initWithWindowNibName:@"ColorInspector"])
  {
    localColormap = [[AQTColorMap alloc] init];
  }
  return self;
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [localColormap dealloc];
  [super dealloc];
}

-(void)windowDidLoad
{
  [super windowDidLoad];
  [self setMainWindow:[NSApp mainWindow]];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowChanged:)
                                               name:NSWindowDidBecomeMainNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowResigned:)
                                               name:NSWindowDidResignMainNotification
                                             object:nil];
}

-(void)mainWindowChanged:(NSNotification *)notification
{
  [self setMainWindow:[notification object]];
}

-(void)mainWindowResigned:(NSNotification *)notification
{
  [self setMainWindow:nil];
}

- (void)setMainWindow:(NSWindow *)mainWindow
{
  NSWindowController *controller = [mainWindow windowController];

  if (controller && [controller isKindOfClass:[GPTWindowController class]])
  {
    currentView = [(GPTWindowController *)controller viewOutlet];
    [self setColormap:[[currentView model] colormap]];
  }
  else
  {
    currentView = nil;
    [self setColormap:[[[AQTColorMap alloc] init] autorelease]];
  }
//  [infoText setStringValue:[NSString stringWithFormat:@"%d objects in %f seconds",
//    [[currentView model] count],
//    [[currentView model] timeTaken]]];
  [self updatePopUp];
  [self updateVisibleState];
}

#define specialsCount 4

-(void)setColormap:(AQTColorMap *)newColormap
{
  [localColormap autorelease];
  localColormap = [newColormap copy];
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
  if (currentView)
  {
    [[currentView model] updateColors:localColormap];
    [currentView setNeedsDisplay:YES];
  }
}

@end

