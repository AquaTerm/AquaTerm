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
        
        if([gptConnection registerName:@"aquatermServer"] == NO) 
        {
            NSLog(@"Error registering %s\n", @"aquatermServer");
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

//
// -----------------------------------------------------------------
//                                                                   
// Implementation of the methods listed in the AQTProtocol protocol  
//              
// -----------------------------------------------------------------
//

    /*" Render the current model (graph) in the current window. 
    If the model is part of a multiplot the flag is set to NO. "*/
- (oneway void) renderInViewShouldRelease:(BOOL)release
{  
    [listener setModel:gptModel forView:currentFigure];	// the listener (GPTController) will retain this object
    if (release)
    {
        [gptModel release];
        gptModel = [[GPTModel alloc] init];
    }
}
    /*" Add a string (label) to the model currently being built. "*/
- (oneway void) addString:(bycopy NSString *)text 
                     atPoint:(bycopy NSPoint)point 
                     withJustification:(bycopy int)justification 
                     withIndexedColor:(bycopy int)colorIndex
{
	NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Times-Roman" size:16.0] forKey:NSFontAttributeName];
	//
	// FIXME: The current attributes should be stored locally and [currentAttrs copy] used for last arg. below
	// 
    GPTLabel *theLabel=[[GPTLabel alloc] initWithLinestyle:colorIndex 
                                            origin:point 
                                            justification:justification 
                                            string:text 
                                            attributes:attrs];
    
    [gptModel addObject:theLabel];
    [theLabel release];
    
}
    /*" Set the font to be used. Not implemented. "*/
- (oneway void) setFontWithName:(bycopy NSString *)fontName size:(bycopy float)fontSize;
{
    NSLog(@"Not implemented: setFontWithName:%@ size:%f 4.1", fontName, fontSize);
}

    /*" Add a path to the model currently being built "*/
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex
{
    GPTPath *thePath=[[GPTPath alloc] initWithLinestyle:colorIndex
                                      linewidth:1.0			/* FIXME! */ 
                                      isFilled:NO 
                                      gray:0 
                                      path:aPath];	

    [gptModel addObject:thePath];
    [thePath release];
}
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color
{
  //
  // FIXME: The GPTPath methods does not live up to the needs of
  // 		the methods declared in AQTProtocol.h  
  //
  GPTPath *thePath=[[GPTPath alloc] initWithLinestyle:0
                                      linewidth:1.0			/* FIXME! */ 
                                      isFilled:NO 
                                      gray:color 
                                      path:aPath];	

    [gptModel addObject:thePath];
    [thePath release];

}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex
{
  //
  // FIXME: The GPTPath methods does not live up to the needs of
  // 		the methods declared in AQTProtocol.h  
  //
    GPTPath *thePath=[[GPTPath alloc] initWithLinestyle:colorIndex
                                      linewidth:1.0			/* FIXME! */ 
                                      isFilled:YES 
                                      gray:0 
                                      path:aPath];	

    [gptModel addObject:thePath];
    [thePath release];
}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color
{
    GPTPath *thePath=[[GPTPath alloc] initWithLinestyle:0
                                      linewidth:1.0			/* FIXME! */ 
                                      isFilled:YES 
                                      gray:color 
                                      path:aPath];	

    [gptModel addObject:thePath];
    [thePath release];
}

    /*" FIXME: [wrong =>] Raises (creates if neccessary) window n as given by the command "set term aqua <n>" in gnuplot "*/
- (oneway void) selectModel:(int) currentModel;
{
    currentFigure = (unsigned)currentModel;
    //
    // Q: make window key and front? A: NO, just make sure it is shown 
    // 
    // (void)[listener selectWindow:currentFigure];	
    NSLog(@"Current figure is %d\n",  currentModel);	// FIXME! The window doesn't show until the plot is rendered.
}
@end