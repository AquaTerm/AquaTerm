//
//  AQTColorInspector.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GPTWindowController, AQTColorMap;

@interface AQTColorInspector : NSWindowController
{
    IBOutlet NSColorWell *axisColor;		/*" color for x,y[,z] axes, tickmarks and labels "*/
    IBOutlet NSColorWell *backgroundColor;	/*" backdrop color "*/
    IBOutlet NSColorWell *gridlineColor;	/*" color for gridlines "*/
    IBOutlet NSColorWell *lineColor1;		/*" indexed color 1 "*/
    IBOutlet NSColorWell *lineColor2;		/*" indexed color 2 "*/
    IBOutlet NSColorWell *lineColor3;		/*" indexed color 3 "*/
    IBOutlet NSColorWell *lineColor4;		/*" indexed color 4 "*/
    IBOutlet NSColorWell *lineColor5;		/*" indexed color 5 "*/
    IBOutlet NSColorWell *lineColor6;		/*" indexed color 6 "*/
    IBOutlet NSColorWell *lineColor7;		/*" indexed color 7 "*/
    IBOutlet NSColorWell *lineColor8;		/*" indexed color 8 "*/
    IBOutlet NSColorWell *lineColor9;		/*" indexed color 9 "*/
    IBOutlet NSColorWell *maxColor;		/*" gradient max color "*/
    IBOutlet NSColorWell *minColor;		/*" gradient min color "*/
    IBOutlet NSImageView *surfaceRampImage;	/*" shows the gradient to the user "*/
    IBOutlet NSColorWell *textColor;		/*" Not implemented, see axisColor "*/
    
    GPTWindowController *frontWindowController; 	/*" Keeps track of the windowController of the front window "*/

    @private
    NSImage *rampImage; 		/*" Preview of the continuos colormap ("coloraxis") "*/
    NSBitmapImageRep *bitmap;		/*" the raw bitmap that used in rampImage "*/
    unsigned char *planes[3]; 		/*" the R, G and B planes for the raw bitmap (each is 1x64 pixels) "*/
    AQTColorMap *localColormap;
}
/*" Accessor methods "*/
- (void)setFrontWindowController:(GPTWindowController *)newWindowController;
- (GPTWindowController *)frontWindowController;
- (void)setColormap:(AQTColorMap *)newColormap;
/*" IBActions "*/
- (IBAction)applyPressed:(id)sender;
- (IBAction)didSetMinColor:(id)sender;
- (IBAction)didSetMaxColor:(id)sender;

/*" internal methods "*/
- (void)updateRampImage;
- (void)mainWindowChanged:(NSNotification *)notification;
- (void)updateState;

@end
