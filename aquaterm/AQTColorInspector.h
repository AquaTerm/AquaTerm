//
//  AQTColorInspector.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AQTColorInspector : NSWindowController
{
    IBOutlet NSColorWell *axisColor;		// color for x,y[,z] axes, tickmarks and labels
    IBOutlet NSColorWell *backgroundColor;	// backdrop color
    IBOutlet NSColorWell *gridlineColor;	// color for gridlines
    IBOutlet NSColorWell *lineColor1;
    IBOutlet NSColorWell *lineColor2;
    IBOutlet NSColorWell *lineColor3;
    IBOutlet NSColorWell *lineColor4;
    IBOutlet NSColorWell *lineColor5;
    IBOutlet NSColorWell *lineColor6;
    IBOutlet NSColorWell *lineColor7;
    IBOutlet NSColorWell *lineColor8;
    IBOutlet NSColorWell *lineColor9;
    IBOutlet NSColorWell *maxColor;
    IBOutlet NSColorWell *minColor;
    IBOutlet NSImageView *surfaceRampImage;
    IBOutlet NSColorWell *textColor;		// Not implemented, see axisColor
    
    id theController; // sets itself at init

    @private
	NSImage *rampImage; 			// Preview of the continuos colormap ("coloraxis")
    NSBitmapImageRep *bitmap;		// the raw bitmap that used in rampImage;
    unsigned char *planes[3]; 		// the R, G and B planes for the raw bitmap (each is 1x64 pixels)

}
- (void)updateRampImage;
- (IBAction)didSetMinColor:(id)sender;
- (IBAction)didSetMaxColor:(id)sender;
- (IBAction)applyPressed:(id)sender;
- (void)mainWindowChanged:(NSNotification *)notification;
@end
