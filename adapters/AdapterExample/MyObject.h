#import <Cocoa/Cocoa.h>

@interface MyObject : NSObject
{
    IBOutlet id statusOutlet;
    IBOutlet NSTextField *fontFieldOutlet;
    NSDistantObject *server;
}
- (IBAction)connectAction:(id)sender;
- (IBAction)addPathAction:(id)sender;
- (IBAction)addTextAction:(id)sender;
- (IBAction)setFontAction:(id)sender;
- (IBAction)releaseAction:(id)sender;
- (void)gotNotification:(NSNotification *)notification;
float randomNumber(void);
@end
