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
    IBOutlet NSColorWell *axisColor;
    IBOutlet NSColorWell *backgroundColor;
    IBOutlet NSColorWell *borderColor;
    IBOutlet NSColorWell *lineColor1;
    IBOutlet NSColorWell *lineColor2;
    IBOutlet NSColorWell *lineColor3;
    IBOutlet NSColorWell *lineColor4;
    IBOutlet NSColorWell *lineColor5;
    IBOutlet NSColorWell *lineColor6;
    IBOutlet NSColorWell *lineColor7;
    IBOutlet NSColorWell *lineColor8;
    IBOutlet NSColorWell *maxColor;
    IBOutlet NSColorWell *minColor;
    IBOutlet NSImageView *surfaceRampImage;
    IBOutlet NSColorWell *textColor;
    
    id theController; // sets itself at init
}
- (IBAction)applyPressed:(id)sender;
@end
