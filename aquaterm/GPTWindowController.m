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
  NSSize tmpSize = [tempModel canvasSize];
  [viewOutlet setModel:tempModel];
  [viewOutlet setFrameOrigin:NSMakePoint(0.0, 0.0)];
  [viewOutlet setNeedsDisplay:YES];
  [[self window] setTitle:[tempModel title]];
  [[self window] setContentSize:tmpSize];
  [[self window] setAspectRatio:tmpSize];
  [[self window] setMaxSize:NSMakeSize(tmpSize.width*2, tmpSize.height*2)];
  [[self window] setMinSize:NSMakeSize(tmpSize.width/4, tmpSize.height/4)];
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
    NSSize tmpSize = [newModel canvasSize];
    [viewOutlet setModel:newModel];
    [viewOutlet setFrameOrigin:NSMakePoint(0.0, 0.0)];
    [viewOutlet setNeedsDisplay:YES];    
    [[self window] setTitle:[newModel title]];
    [[self window] setContentSize:tmpSize];
    [[self window] setAspectRatio:tmpSize];
    [[self window] setMaxSize:NSMakeSize(tmpSize.width*2, tmpSize.height*2)];
    [[self window] setMinSize:NSMakeSize(tmpSize.width/4, tmpSize.height/4)];
    
    if(![[self window] isVisible])
    {
      [self showWindow:self];
    }
  }
  else
  {
    [newModel retain];
    [tempModel release];		// let go of any temporary model not used (unlikely)
    tempModel = newModel;		// Make it point to new model 
    [self window];				// Load it!
  }
}
@end
