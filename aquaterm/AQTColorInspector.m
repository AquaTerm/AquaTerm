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
    if (self = [super init]) {
/*
        // perhaps we don't need this
        theController = [[NSApplication sharedApplication] delegate]; // don't retain
                                                                // because it owns us
*/    
    // we should set the colors of each of the color wells by reading in prefs here
    
    // do we show our window here? or wait for a command to do so?
    
    }
    return self;
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

    [inspectedModel updateColors:[tempColormap autorelease]];
}

@end

