//
//  AQTColorInspector.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GPTWindowController, AQTColorMap, AQTView;

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
    IBOutlet NSTextField *color1Label;		/*" indexed color 1 "*/
    IBOutlet NSTextField *color2Label;		/*" indexed color 2 "*/
    IBOutlet NSTextField *color3Label;		/*" indexed color 3 "*/
    IBOutlet NSTextField *color4Label;		/*" indexed color 4 "*/
    IBOutlet NSTextField *color5Label;		/*" indexed color 5 "*/
    IBOutlet NSTextField *color6Label;		/*" indexed color 6 "*/
    IBOutlet NSTextField *color7Label;		/*" indexed color 7 "*/
    IBOutlet NSTextField *color8Label;		/*" indexed color 8 "*/
    IBOutlet NSPopUpButton *rangePopUp;
    int cRange;
    int colorCount;
    IBOutlet NSTextField *infoText;		
    
    AQTView *currentView;	/*" Keeps track of the AQTView of the front window "*/
    AQTColorMap *localColormap;
}

/*" Accessor methods "*/
- (void)setMainWindow:(NSWindow *)mainWindow;
- (void)setColormap:(AQTColorMap *)newColormap;
/*" IBActions "*/
- (IBAction)applyPressed:(id)sender;
- (IBAction)didSelectRange:(id)sender;
/*" internal methods "*/
- (void)updatePopUp;
- (void)mainWindowChanged:(NSNotification *)notification;
- (void)mainWindowResigned:(NSNotification *)notification;
- (void)updateVisibleState;
- (void)updateColormap;
@end
