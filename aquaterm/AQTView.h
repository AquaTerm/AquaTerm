//
//  AQTView.h
//  AquaTerm
//
//  Created by Per Persson on Wed Apr 17 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//

#import <AppKit/AppKit.h>


@class AQTModel;
@interface AQTView : NSView
{
  AQTModel *model;
  BOOL _isProcessingEvents; /*" Holds state of mouse input."*/
  NSCursor *crosshairCursor;  /*" Holds an alternate cursor for use with mouse input."*/
  BOOL _enableTiming;
}
- (void)setModel:(AQTModel *)newModel;
- (AQTModel *)model;
- (BOOL)isPrinting;
- (BOOL)isProcessingEvents;
- (void)setIsProcessingEvents:(BOOL)flag;

/*" Utility methods "*/
- (NSPoint)convertPointToCanvasCoordinates:(NSPoint)viewPoint;
- (NSRect)convertRectToCanvasCoordinates:(NSRect)viewRect;
- (NSRect)convertRectToViewCoordinates:(NSRect)canvasRect;
@end
