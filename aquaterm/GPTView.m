//
// GPTView.m -- part of Aquaterm
//

#import "GPTView.h"
#import "AQTModel.h"
#import "GPTWindowController.h"

@implementation GPTView

-(BOOL)isOpaque
{
    return YES;
}

-(void)drawRect:(NSRect)aRect
{
    //
    // Get the model associated with this view
    //
    AQTGraphic *modelReference = [(GPTWindowController *)[[self window] windowController] model];
    NSRect theBounds = [self bounds];
    //
    // Erase background and draw a stylish line around the view 
    //
    [[NSColor whiteColor] set]; // FIXME - the background color
                                // we should get this value from color inspector pane
    [[NSBezierPath bezierPathWithRect:theBounds] fill];
    [[NSColor blackColor] set];
    [[NSBezierPath bezierPathWithRect:theBounds] stroke];
    //
    // Tell the model to draw itself
    //       
    [modelReference renderInRect:theBounds];
}
@end









