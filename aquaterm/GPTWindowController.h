//
// GPTWindowController.h
// Aquaterm
//

#import <Cocoa/Cocoa.h>

@class AQTModel, GPTView;

@interface GPTWindowController : NSWindowController
{
    @private
    IBOutlet id viewOutlet;	/*" Points to the rendering view "*/
    AQTModel	*model;		/*" Holds the model for the view "*/ 
    NSString	*viewTitle;	/*" The title of the model from gnuplot's set term aqua <n> title command "*/
    int 		viewIndex;	/*" The number by which the client refers to the model "*/ 
}

-(id)initWithIndex:(int)index andTitle:(NSString *)title;	
-(id)initWithIndex:(int)index;

-(id)viewOutlet;
-(int)viewIndex;
-(void)setModel:(AQTModel *)newModel;
-(AQTModel *)model;
@end
