@protocol AQTEventProtocol
// FIXME: Add "oneway" later
- (void)processEvent:(bycopy NSString *)event;
- (void)ping;
@end