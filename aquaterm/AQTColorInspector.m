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
#import "GPTWindowController.h"

@implementation AQTColorInspector

- (id)init
{
  if (self = [super initWithWindowNibName:@"ColorInspector"]) {

    // we should set the colors of each of the color wells by 
    // a) reading from the front window if it exists or
    // b) reading in the default colormap prefs

    // Set up the rampImage
    // This is somewhat primitive, but it does work! PP 
    planes[0] = (unsigned char*)malloc(1 * 64); // red 
    planes[1] = (unsigned char*)malloc(1 * 64); // green
    planes[2] = (unsigned char*)malloc(1 * 64); // blue
    
    rampImage = [[NSImage alloc] initWithSize:NSMakeSize(1, 64)];
    [rampImage setFlipped:YES];	// Needed since colorscale runs in opposite direction
    bitmap = [[NSBitmapImageRep alloc]
      initWithBitmapDataPlanes:planes
                    pixelsWide:1 pixelsHigh:64 bitsPerSample:8
               samplesPerPixel:3 hasAlpha:NO isPlanar:YES
                colorSpaceName:NSCalibratedRGBColorSpace
                   bytesPerRow:1 bitsPerPixel:8];
    [rampImage addRepresentation:bitmap];
  }
  return self;
}
-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [rampImage release];
  [bitmap release];
  free(planes[0]);
  free(planes[1]);
  free(planes[2]);
}


-(void)awakeFromNib
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowChanged:)
                                               name:NSWindowDidBecomeMainNotification
                                             object:nil];

    // This is not possible to do in the init!
    [self updateRampImage];
}

- (IBAction)didSetMinColor:(id)sender
{
  [self updateRampImage];
}
- (IBAction)didSetMaxColor:(id)sender
{
  [self updateRampImage];
}
-(void)updateRampImage
{
  int x;
  // Get the RGB components for minColor
  float   r=[[minColor color] redComponent],
          g=[[minColor color] greenComponent],
          b=[[minColor color] blueComponent];
  // Compute the RGB distance to maxColor
  float   zr = [[maxColor color] redComponent]-r,
          zg= [[maxColor color] greenComponent]-g,
          zb= [[maxColor color] blueComponent]-b;
  // Set the ramp!
  for (x=0;x<64;x++)
  {
    planes[0][x] = (unsigned char)(r*255 + (zr*255*x)/63);
    planes[1][x] = (unsigned char)(g*255 + (zg*255*x)/63);
    planes[2][x] = (unsigned char)(b*255 + (zb*255*x)/63);
  }

  [surfaceRampImage setImage:rampImage];	// Why is this neccessary?!
  // Tell the view to update
  [surfaceRampImage setNeedsDisplay:YES];
}

- (IBAction)applyPressed:(id)sender
{
    AQTColorMap *tempColormap;
    NSDictionary *colorDICT;
    AQTModel * inspectedModel = [(GPTWindowController *)[[NSApplication sharedApplication] delegate] model];
    
    // create a temporary colormap from the panel
    colorDICT = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:
                            [backgroundColor color], // -4
                            [NSColor yellowColor], // -3 /* Reserved for now */
                            [axisColor color], // -2
                            [gridlineColor color], // -1
                            [lineColor1 color], // 0
                            [lineColor2 color], // 1
                            [lineColor3 color], // 2
                            [lineColor4 color], // 3
                            [lineColor5 color], // 4
                            [lineColor6 color], // 5
                            [lineColor7 color], // 6
                            [lineColor8 color], // 7
                            [lineColor9 color], // 8
                             nil]
                forKeys: [NSArray arrayWithObjects:
                            @"-4", // backgroundColor
                            @"-3", // xor-color for markers /* Reserved use for now */
                            @"-2", // axisColor
                            @"-1", // gridlineColor
                            @"0", // lineColor1
                            @"1", // lineColor2
                            @"2", // lineColor3
                            @"3", // lineColor4
                            @"4", // lineColor5
                            @"5", // lineColor6
                            @"6", // lineColor7
                            @"7", // lineColor8
                            @"8", // lineColor9
                            nil] ];
                            
    tempColormap = [[AQTColorMap alloc] initWithColorDict:colorDICT
                                                 rampFrom:[minColor color]
                                                       to:[maxColor color]];
    [inspectedModel updateColors:tempColormap];
    [tempColormap release];
}
-(void)mainWindowChanged:(NSNotification *)notification
{	    
  // NSLog(@"mainWindowChanged");
  // Should read the colormap from the new model and
  // update inspector window accordingly
}
@end

