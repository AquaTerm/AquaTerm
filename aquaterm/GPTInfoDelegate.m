#import "GPTInfoDelegate.h"
#import "GPTInfoWindowController.h"

@implementation GPTInfoDelegate

- (IBAction)showInfo:(id)sender
{
    [[GPTInfoWindowController sharedInfoWindowController] showWindow:sender];
}

@end
