#import "GPTWindowController.h"
#import "GPTView.h"
#import "AQTModel.h"

@implementation GPTWindowController
    /**"
    *** GPTWindowController is a subclass of NSWindowController
    *** that controls an AquaTerm window. Every instance of a 
    *** GPTWindowController holds a reference to the rendering
    *** GPTView and to the GPTModel received from gnuplot.
    "**/
    
    /**"
    *** The designated initializer
    "**/
 -(id)initWithIndex:(int)index
{
  self = [super initWithWindowNibName:@"GPTWindow"];
  if (self)
  {
    viewIndex = index;
    model = [[AQTModel alloc] init];
  }
  return self;
}

-(void)awakeFromNib
{
	[[self window] setTitle:[model title]];
    [viewOutlet setNeedsDisplay:YES];
}

-(void)dealloc
{   
    [model release];
    [super dealloc];
}

    /*" Describe model. (for debugging) "*/
-(NSString *)description
{
    return [NSString stringWithFormat:@"Plot \"%@\"\nModel: %@", [model title], [model description]];
}

    /*" Accessor methods for the GPTView instance "*/
-(id)viewOutlet
{
    return viewOutlet;
}

-(int)viewIndex
{
    return viewIndex;
}

-(void)setModel:(AQTModel *)newModel
{
  [newModel retain];
  [model release];		// let go of old model
  model = newModel;		// Make it point to new model (FIXME: multiplot requires care! OK)

  // FIXME: Voodo below!  
  // Check if window is has been loaded
    if ([self window])
    {
      if (![[self window] isVisible])
      {
        // The window was hidden (due to e.g. a close action)
        [[self window] orderFront:self];
      }
      [[self window] setTitle:[model title]];
      [viewOutlet setNeedsDisplay:YES];	// Tell view to update itself
    }
}

-(AQTModel *)model
{
    return model;
}
@end
