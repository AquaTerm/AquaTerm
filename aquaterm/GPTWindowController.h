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
    int 	viewIndex;	/*" The number by which gnuplot refers to the model "*/ 
}

-(id)initWithIndex:(unsigned)index andTitle:(NSString *)title;	// Designated init
-(id)initWithIndex:(unsigned)index;

-(id)viewOutlet;
-(unsigned)viewIndex;
-(void)setModel:(AQTModel *)newModel;
-(AQTModel *)model;
@end