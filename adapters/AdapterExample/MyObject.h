#import <Cocoa/Cocoa.h>

@interface MyObject : NSObject
{
    IBOutlet id statusOutlet;
    NSDistantObject *server;
}
- (IBAction)connectAction:(id)sender;
- (IBAction)addPathAction:(id)sender;
- (IBAction)addTextAction:(id)sender;
- (IBAction)releaseAction:(id)sender;
float randomNumber(void);
@end
