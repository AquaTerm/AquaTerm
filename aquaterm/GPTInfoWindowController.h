#import <Cocoa/Cocoa.h>

@interface GPTInfoWindowController : NSWindowController
{
    IBOutlet NSTextField *infoTextView;
}
+(id)sharedInfoWindowController;
@end
