#import "GPTWindowController.h"
#import "AQTView.h"
#import "AQTModel.h"

@implementation GPTWindowController
    /**"
    *** GPTWindowController is a subclass of NSWindowController
    *** that controls an AquaTerm window. Every instance of a 
    *** GPTWindowController holds a reference to the rendering
    *** AQTView. GPTWindowController assists in setting the model
    *** for the view by assuring that the window nib is loaded before
    *** the model received from the AQTBuilder object is handed to the view.
    "**/
    
    /**"
    *** The designated initializer
    "**/
 -(id)initWithIndex:(int)index
{
  self = [super initWithWindowNibName:@"AQTWindow"];
  if (self)
  {
    viewIndex = index;
    tempModel = nil;
  }
  return self;
}

 -(void)awakeFromNib
{
  [viewOutlet setModel:tempModel];
  [[self window] setTitle:[tempModel title]];
  [tempModel release];
  tempModel = nil;
}

-(void)dealloc
{   
    [super dealloc];
}

    /*" Accessor methods for the AQTView instance "*/
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
  
  if ([self isWindowLoaded])
  {
    [viewOutlet setModel:newModel];
    [[self window] setTitle:[newModel title]];
    [viewOutlet setNeedsDisplay:YES];    
    if(![[self window] isVisible])
    {
      [self showWindow:self];
    }
  }
  else
  {
    [newModel retain];
    [tempModel release];		// let go of any temporary model not used (unlikely)
    tempModel = newModel;		// Make it point to new model (FIXME: multiplot requires care! OK)
    [self window];				// Load it!
  }
}
@end
