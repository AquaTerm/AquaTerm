//
// GPTView.m -- part of Aquaterm
//

#import "GPTView.h"
#import "AQTModel.h"
#import "GPTWindowController.h"

@implementation GPTView

// Per, you know the following is unneccesary overriding of methods?
/*
- (id)initWithFrame:(NSRect)frameRect 
{
    // Recursively init superclasses...
    
    if (self = [super initWithFrame:frameRect])
    {
        // If all is well, init own objects...
    }
    // Return the initialized object...
    return self;
}
-(void)dealloc
{
    // Let superclasses do thier own work...
    [super dealloc];
}
*/

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









