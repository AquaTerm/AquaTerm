#import "GPTReceiverObject.h"
#import "GPTController.h"
#import "AQTPath.h"
#import "AQTLabel.h"
#import "AQTModel.h"
#import "GPTView.h"
#import "GPTColorExtras.h"


@implementation GPTReceiverObject
    /**" 
    *** GPTReceiverObject is the class controlling the DO connection.
    *** It creates an NSConnection and register the service "aquatermServer"
    *** with the system. 
    "**/

- (id)initWithListener:(id)listeningObject
{
    if (self = [super init])
    {
        listener = listeningObject;	// set reference to the object listening (GPTController)
        aqtModel = [[AQTModel alloc] init];
        currentFont = [[NSFont fontWithName:@"Times-Roman" size:16.0] retain];
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
    [aqtModel release];
    [currentFont release];
    [super dealloc];
}
- (NSConnection *)connection
{
  return gptConnection;
}
//
// -----------------------------------------------------------------
//                                                                   
// Implementation of the methods listed in the AQTProtocol protocol  
//              
// -----------------------------------------------------------------
//
//

    /*" Return a info about AquaTerm settings "*/
- (bycopy NSDictionary *) getAquaTermInfo
{
    //
    // FiXME: These are _app_ settings, not to be decided here!
    //
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [tmpDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"AQTVersion"];
    [tmpDict setObject:[NSNumber numberWithFloat:AQUA_XMAX] forKey:@"AQTXMax"];                                      
    [tmpDict setObject:[NSNumber numberWithFloat:AQUA_YMAX] forKey:@"AQTYMax"];                                      
    [tmpDict setObject:[NSNumber numberWithFloat: 0.6] forKey:@"AQTFontWHRatio"];  
    [tmpDict setObject:[NSNumber numberWithFloat: 1.0] forKey:@"AQTPixelWHRatio"];                                     
	[tmpDict setObject:@"Times-Roman" forKey:@"AQTDefaultFontName"];                                      
    [tmpDict setObject:[NSNumber numberWithFloat:16.0] forKey:@"AQTDefaultFontSize"];                                      
    //
    [tmpDict setObject:[currentFont fontName] forKey:@"AQTFontName"];                                      
    [tmpDict setObject:[NSNumber numberWithFloat:[currentFont pointSize]] forKey:@"AQTFontSize"];                                              	//
    // Get hold of app settings and return them
    //
    return tmpDict;
}

    /*" Render the current model (graph) in the current window. 
    If the model is part of a multiplot the flag is set to NO. "*/
- (oneway void) renderInViewShouldRelease:(BOOL)release
{  
    [listener setModel:aqtModel forView:currentFigure];	// the listener (GPTController) will retain this object
    if (release)
    {
        [aqtModel release];
        aqtModel = [[AQTModel alloc] init];
    }
}

    /*" Clear part of the rendering area by removing every object completely 
    inside that area. "*/
-(oneway void) clearRect:(NSRect)rect
{
  [aqtModel removeObjectsInRect:rect];
}

    /*" Add a string (label) to the model currently being built. "*/
- (oneway void) addString:(bycopy NSString *)text 
                     atPoint:(bycopy NSPoint)point 
                     withJustification:(bycopy int)justification 
                    atAngle:(bycopy float)angle
                     withIndexedColor:(bycopy int)colorIndex
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObject:currentFont forKey:NSFontAttributeName];

    AQTLabel *theLabel=[[AQTLabel alloc] initWithString:text 
                                             attributes:attrs 
                                               position:point 
                                                  angle:angle 
                                          justification:justification 
                                             colorIndex:colorIndex];
    [aqtModel addObject:theLabel];
    [theLabel release];
    
}
    /*" Set the font to be used. "*/
- (oneway void) setFontWithName:(bycopy NSString *)newFontName size:(bycopy float)newFontSize
{   
    //
    // FIXME: Sanity check here, please!
    //
    NSFont *newFont;
    // NSMutableArray *allFonts = [NSMutableArray arrayWithCapacity:0];
    // [allFonts setArray:[[NSFontManager sharedFontManager] availableFonts]];
    // NSMutableArray *allFonts = [NSMutableArray arrayWithArray:[[NSFontManager sharedFontManager] availableFonts]];
    // if ([allFonts containsObject:newFontName])
    if ([[[NSFontManager sharedFontManager] availableFonts] containsObject:newFontName])
    {
      newFont = [NSFont fontWithName:newFontName size:newFontSize];    
    }
    else
    {
      newFont = [NSFont systemFontOfSize:newFontSize];
    }
    [newFont retain];
    [currentFont release];
    currentFont = newFont;
}

    /*" Add a path to the model currently being built "*/
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex
{
    AQTPath *thePath=[[AQTPath alloc] initWithPolyline:aPath colorIndex:colorIndex];	
    [aqtModel addObject:thePath];
    [thePath release];
}
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color
{
    AQTPath *thePath=[[AQTPath alloc] initWithPolyline:aPath color:color];    
    [aqtModel addObject:thePath];
    [thePath release];

}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex
{
    AQTPath *thePath=[[AQTPath alloc] initWithPolygon:aPath colorIndex:colorIndex];	
    [aqtModel addObject:thePath];
    [thePath release];
}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color
{
    AQTPath *thePath=[[AQTPath alloc] initWithPolygon:aPath color:color];	
    [aqtModel addObject:thePath];
    [thePath release];
}

    /*" FIXME: [wrong =>] Raises (creates if neccessary) window n as given by the command "set term aqua <n>" in gnuplot "*/
- (oneway void) selectModel:(int) currentModel
{
    currentFigure = (unsigned)currentModel;
    //
    // Q: make window key and front? A: NO, just make sure it is shown 
    // 
    // (void)[listener selectWindow:currentFigure];	
}
@end
