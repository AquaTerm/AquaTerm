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
#import "AQTGraphicDrawingMethods.h"

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
   return ![NSGraphicsContext currentContextDrawingToScreen]; 
}

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
#ifdef DEBUG_BOUNDS
   NSLog(@"viewFrame: %@", NSStringFromRect([self bounds]));
#endif
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

-(void)drawRect:(NSRect)dirtyRect // <--- argument _always_ in view coords
{
   NSRect viewBounds = [self bounds];
   NSSize canvasSize = [model canvasSize];
   NSRect dirtyCanvasRect;
   NSAffineTransform *transform = [NSAffineTransform transform];


   [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone]; // FIXME: user prefs
   [[NSGraphicsContext currentContext] setShouldAntialias:YES]; // FIXME: user prefs
   NSRectClip(dirtyRect);

   // Dirty rect in view coords, clipping rect is set.
   // Need to i) set transform for subsequent operations
   // and ii) transform dirty rect to canvas coords.

   // (i) view transform
   [transform scaleXBy:viewBounds.size.width/canvasSize.width
               yBy:viewBounds.size.height/canvasSize.height];
   [transform concat];

   // (ii) dirty rect transform
   [transform invert];
   dirtyCanvasRect.origin = [transform transformPoint:dirtyRect.origin];
   dirtyCanvasRect.size = [transform transformSize:dirtyRect.size];

   [model renderInRect:dirtyCanvasRect]; // <--- expects aRect in canvas coords, _not_ view coords

#ifdef DEBUG_BOUNDS
   NSLog(@"dirtyRect: %@", NSStringFromRect(dirtyRect));
   NSLog(@"dirtyCanvasRect: %@", NSStringFromRect(dirtyCanvasRect));
#endif
}
@end


