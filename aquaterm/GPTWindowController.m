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
-(id)initWithIndex:(unsigned)index andTitle:(NSString *)title
{   
    self = [super initWithWindowNibName:@"GPTWindow"];
    if (self)
    {
        model = [[AQTModel alloc] init];
        viewTitle = [[NSString stringWithString:title] retain];
        [[self window] setTitle:viewTitle];
        viewIndex = index;	
        // [viewOutlet setControllerReference:self];
        // Let the view have a ref to its controller (FAQ: is this kosher? NO)
        // I don't think there is anything wrong with it, if there is a reason
        // for the view to contact the w-controller, but it could be done
        // easilly in IB so why do it here? <BS>
    }
    return self;
}

    /**"
    *** The title is optional and this init, controls the default title
    *** which is Figure <index>  
    "**/
-(id)initWithIndex:(unsigned)index
{   
    return [self initWithIndex:(unsigned)index andTitle:[NSString stringWithFormat:@"Figure %d", index]];
}

-(void)dealloc
{   
    [viewTitle release];
    [model release];
    [super dealloc];
}

    /*" Describe model. (for debugging) "*/
-(NSString *)description
{
    return [NSString stringWithFormat:@"Plot #%d, \"%@\"\nModel: %@", viewIndex, viewTitle, [model description]];
}

    /*" Accessor methods for the GPTView instance "*/
-(id)viewOutlet
{
    return viewOutlet;
}

-(unsigned)viewIndex
{
    return viewIndex;
}

-(void)setModel:(AQTModel *)newModel
{
    [model release];			// let go of old model 
    model = [newModel retain];		// Make it point to new model (FIXME: multiplot requires care! OK)
    // [viewOutlet setModelReference:model];	// Let the view have a ref to it as well (FAQ: is this kosher? NO!)
    [viewOutlet setNeedsDisplay:YES];	// Tell view to update itself
}

-(AQTModel *)model
{
    return model;
}
@end
