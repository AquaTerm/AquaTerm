//
// GPTView.m -- part of Aquaterm
//

#import "GPTView.h"
#import "AQTModel.h"
#import "AQTColorMap.h"
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
    AQTModel *modelReference = [(GPTWindowController *)[[self window] windowController] model];
    NSRect theBounds = [self bounds];
    //
    // Erase by drawing background color and draw a stylish line around the view 
    //
    [[(AQTColorMap *)[modelReference colormap] colorForIndex:-4] set]; 
    [[NSBezierPath bezierPathWithRect:theBounds] fill];
    [[NSColor blackColor] set];
    [[NSBezierPath bezierPathWithRect:theBounds] stroke];
    //
    // Tell the model to draw itself
    //       
    [modelReference renderInRect:theBounds];
}
@end









