//
//  AQTView.m
//  AquaTerm
//
//  Created by Per Persson on Wed Apr 17 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//

#import "AQTView.h"
#import "AQTGraphic.h"
#import "AQTModel.h"

// #define AQT_MIN_FONTSIZE 9.0

//#define MAX(a, b) ((a)>(b)?(a):(b))



@implementation AQTView
-(void)awakeFromNib
{
   NSImage *curImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Cross" ofType:@"tiff"]];
   crosshairCursor = [[NSCursor alloc] initWithImage:curImg hotSpot:NSMakePoint(7,7)];
   [curImg release];
   [self setIsProcessingEvents:NO];
}

-(void)dealloc
{
   [crosshairCursor release];
   [super dealloc];
}

-(BOOL)acceptsFirstResponder
{
   return YES;
}

-(void)setModel:(AQTModel *)newModel
{
   model = newModel;
}

- (AQTModel *)model
{
   return model;
}

-(BOOL)isOpaque
{
   return YES;
}

-(BOOL)isPrinting
{
   return ![NSGraphicsContext currentContextDrawingToScreen]; //isPrinting;
}

/*
 -(void)setIsPrinting:(BOOL)flag
 {
    isPrinting = flag;
 }
 */

- (BOOL)isProcessingEvents
{
   return _isProcessingEvents;
}

- (void)setIsProcessingEvents:(BOOL)flag
{
   // NSLog(@"%@ acceptEvents=%@", [model title], flag?@"YES":@"NO");
   _isProcessingEvents = flag;
   [[self window] invalidateCursorRectsForView:self];
}

-(void)resetCursorRects
{
   if ([self isProcessingEvents])
   {
      [self addCursorRect:[self bounds] cursor:crosshairCursor];
   }
}

- (NSPoint)_aqtConvertToCanvasCoordinates:(NSPoint) aPoint
{
   NSAffineTransform *localTransform = [NSAffineTransform transform];
   [localTransform scaleXBy:[model canvasSize].width/NSWidth([self bounds])
                        yBy:[model canvasSize].height/NSHeight([self bounds])];

   return [localTransform transformPoint:aPoint];
}

-(void)_aqtHandleMouseDownAtLocation:(NSPoint)point button:(int)button
{
   if ([self isProcessingEvents])
   {
   point = [self convertPoint:point fromView:nil];
   point = [self _aqtConvertToCanvasCoordinates:point];
   [[[self window] delegate] processEvent:[NSString stringWithFormat:@"1:%@:%d", NSStringFromPoint(point), button]];
   }
}


-(void)mouseDown:(NSEvent *)theEvent
{
      [self _aqtHandleMouseDownAtLocation:[theEvent locationInWindow] button:1];
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
      [self _aqtHandleMouseDownAtLocation:[theEvent locationInWindow] button:2];
}   



-(void)keyDown:(NSEvent *)theEvent
{
   if ([self isProcessingEvents])
   {
      NSString *eventString;
      NSPoint pos = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
      NSRect viewBounds = [self bounds];
      char aKey = [[theEvent characters] UTF8String][0];;
      // NSLog([theEvent characters]);
      if (!NSPointInRect(pos, viewBounds))
      {
         // Just crop it to be inside [self bounds];
         if (pos.x < 0 )
            pos.x = 0;
         else if (pos.x > NSWidth(viewBounds))
            pos.x = NSWidth(viewBounds);
         if (pos.y < 0 )
            pos.y = 0;
         else if (pos.y > NSHeight(viewBounds))
            pos.y = NSHeight(viewBounds);
      }
      eventString = [NSString stringWithFormat:@"2:%@:%c", NSStringFromPoint([self _aqtConvertToCanvasCoordinates:pos]), aKey];
      [[[self window] delegate] processEvent:eventString];
   }
}

-(void)drawRect:(NSRect)aRect // FIXME: Consider dirty rect!!!
{
   AQTColor canvasColor = [model color];
   NSRect scaledBounds = [self bounds];	// Depends on whether we're printing or drawing to screen
   NSAffineTransform *localTransform = [NSAffineTransform transform];
   [localTransform scaleXBy:NSWidth(scaledBounds)/[model canvasSize].width
                        yBy:NSHeight(scaledBounds)/[model canvasSize].height];
   [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone]; // FIXME: user prefs
   [[NSGraphicsContext currentContext] setShouldAntialias:YES]; // FIXME: user prefs
   if (![self isPrinting])
   {
      //
      // Erase by drawing background color
      //
      [[NSColor colorWithCalibratedRed:canvasColor.red green:canvasColor.green blue:canvasColor.blue alpha:1.0] set];
      [[NSBezierPath bezierPathWithRect:scaledBounds] fill];
   }
   //
   // Tell the model to draw itself
   //
   [localTransform set];
   [model renderInRect:scaledBounds];
//   NSLog(@"Window size:%@", NSStringFromSize([[self window] frame].size));
//   NSLog(@"View size:%@", NSStringFromSize([self frame].size));
}

@end


