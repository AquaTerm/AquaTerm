#import "GPTReceiverObject.h"
#import "GPTController.h"
#import "GPTPath.h"
#import "GPTLabel.h"
#import "GPTModel.h"
#import "GPTView.h"
#import "GPTColorExtras.h"


@implementation GPTReceiverObject
    /**" 
    *** GPTReceiverObject is the class controlling the DO connection.
    *** It creates an NSConnection and register the service "gnuplotServer"
    *** with the system. 
    "**/

- (id)initWithListener:(id)listeningObject
{
    if (self = [super init])
    {
        listener = listeningObject;	// set reference to the object listening (GPTController)
        gptModel = [[GPTModel alloc] init];
        currentFigure = 0;
        gptConnection = [[NSConnection defaultConnection] retain];
        [gptConnection setRootObject:self];
        
        if([gptConnection registerName:@"gnuplotServer"] == NO) 
        {
            NSLog(@"Error registering %s\n", @"gnuplotServer");
        }
    }
    return self;
}
- (void)dealloc
{
    [gptConnection release];
    [gptModel release];
    [super dealloc];
}

    /*" Render the current model (graph) in the current window. If the model is part of a multiplot the flag is set to NO. "*/
- (oneway void) gptRenderRelease:(BOOL)shouldRelease
{  
    [listener setModel:gptModel forView:currentFigure];	// the listener (GPTController) will retain this object
    /* 2001-10-09
     * With the current implementation the instance of gptModel _must_ be released
     * even if the data in it should be subsequently used in a multiplot...
     * FIXME: Kludgy??? 
     * 2001-10-10 Is it even true??? 
     * 2001-11-07 Nope.
     */
    if (shouldRelease)
    {
        [gptModel release];
        gptModel = [[GPTModel alloc] init];
    }
/*
    else
    {
        NSMutableArray *tmpModel = [[NSMutableArray arrayWithArray:gptModel] retain];
        [gptModel release];
        gptModel = tmpModel;
    }
*/    
}
    /*" Add a string (label) to the model currently being built. "*/
- (oneway void) gptPutString:(bycopy NSString *)textString AtPoint:(bycopy NSPoint)coord WithJustification:(bycopy int)mode WithLinetype:(bycopy int) linetype
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Times-Roman" size:16.0] /* FIXME, default font... */
                                        forKey:NSFontAttributeName]; 
    GPTLabel *theLabel=[[GPTLabel alloc] initWithLinestyle:linetype 
                                            origin:coord 
                                            justification:mode 
                                            string:textString 
                                            attributes:attrs];
    
    [gptModel addObject:theLabel];
    [theLabel release];
    
}
    /*" Set the font to be used. Not implemented. "*/
- (oneway void) gptSetFont:(bycopy in NSString *)font
{
    NSLog(@"gptSetFont:%@", font);
}

    /*" Add a path to the model currently being built "*/
- (oneway void) gptSetPath:(bycopy NSBezierPath *)aPath WithLinetype:(bycopy int)linetype FillColor:(bycopy double) gray PathIsFilled:(bycopy BOOL)isFilled
{
    GPTPath *thePath=[[GPTPath alloc] initWithLinestyle:linetype
                                      linewidth:1.0			/* FIXME! */ 
                                      isFilled:isFilled 
                                      gray:gray 
                                      path:aPath];	

    [gptModel addObject:thePath];
    [thePath release];
  
}
    /*" FIXME: [wrong =>] Raises (creates if neccessary) window n as given by the command "set term aqua <n>" in gnuplot "*/
- (oneway void) gptCurrentWindow:(int) currentWindow
{
    currentFigure = (unsigned)currentWindow;
    // make window key and front
    // (void)[listener selectWindow:currentFigure];	
    NSLog(@"Current figure is %d\n",  currentFigure);	// FIXME! The window doesn't show until the plot is rendered.
}


// ---- the following two are stubs -----------

- (oneway void) gptPointsize:(double) pointsize
{}
- (oneway void) gptDidSetPointsize:(double) size
{}

@end