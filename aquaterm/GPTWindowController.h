//
// GPTWindowController.h
// Aquaterm
//

#import <Cocoa/Cocoa.h>

@class AQTModel, AQTView;

@interface GPTWindowController : NSWindowController
{
    @private
    IBOutlet id viewOutlet;	/*" Points to the rendering view "*/
    AQTModel	*tempModel;		/*" Holds the model for the view "*/ 
    int 		viewIndex;	/*" The number by which the client refers to the model "*/ 
}

-(id)initWithIndex:(int)index;

-(id)viewOutlet;
-(int)viewIndex;
-(void)setModel:(AQTModel *)newModel;
@end
