#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

@interface AQTAdapter (AQTAdapterPrivateMethods)
- (BOOL)_connectToServer;
- (BOOL)_launchServer;
- (void)_serverError;
-(void)_processEvent:(NSString *)event;
@end
