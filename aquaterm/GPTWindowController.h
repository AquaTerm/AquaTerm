#import <Cocoa/Cocoa.h>
// #import "GPTModel.h"
// #import "GPTView.h"

@class GPTModel, GPTView;

@interface GPTWindowController : NSWindowController
{
    @private
    IBOutlet id viewOutlet;	/*" Points to the rendering view "*/
    GPTModel	*model;		/*" Holds the model for the view "*/ 
    NSString	*viewTitle;	/*" The title of the model from gnuplot's set term aqua <n> title command "*/
    int 	viewIndex;	/*" The number by which gnuplot refers to the model "*/ 
}

-(id)initWithIndex:(unsigned)index andTitle:(NSString *)title;	// Designated init
-(id)initWithIndex:(unsigned)index;

-(id)viewOutlet;
-(unsigned)viewIndex;
-(void)setModel:(GPTModel *)newModel;
-(GPTModel *)model;
@end
