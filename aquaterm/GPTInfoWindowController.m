#import "GPTInfoWindowController.h"

@implementation GPTInfoWindowController
-(id)init
{
    self = [self initWithWindowNibName:@"GPTInfoWindow"];
    return self;
}
-(void)windowDidLoad
{
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self 
        selector:@selector(mainWindowChanged:)
        name:NSWindowDidBecomeMainNotification
        object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
+(id)sharedInfoWindowController
{
    //
    // Singleton
    //
    static GPTInfoWindowController *_sharedInfoWindowController = nil;
    
    if (!_sharedInfoWindowController)
    {
        _sharedInfoWindowController = [[GPTInfoWindowController allocWithZone:[self zone]] init];
    }
    return _sharedInfoWindowController;
}

-(void)mainWindowChanged:(NSNotification *)notification
{
    [infoTextView setStringValue:[[[notification object] windowController] description]];
}
@end
