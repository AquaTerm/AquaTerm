@protocol AQTClientProtocol
// FIXME: Add "oneway" later
- (void)setClient:(byref id)aClient;
- (void)setModel:(bycopy id)aModel; // (id)?
- (void)appendModel:(bycopy id)aModel;
- (void)draw;
- (void)removeGraphicsInRect:(NSRect)aRect;
- (void)setAcceptingEvents:(BOOL)flag;
- (void)close;
@end
