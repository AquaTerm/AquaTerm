#import "AQTGraphic.h"

@protocol AQTClientProtocol
// FIXME: Add "oneway" later
- (void)setClient:(byref id)aClient;
- (void)setModel:(bycopy id)aModel; // (id)?
- (void)appendModel:(bycopy id)aModel;
- (void)draw;
- (void)removeGraphicsInRect:(AQTRect)aRect; // FIXME: Replace by an AQTErase object?
- (void)setAcceptingEvents:(BOOL)flag;
- (void)close;
// Testing methods 
// FIXME: move into separate protocol?
- (void)timingTestWithTag:(uint32_t)tag;
@end
