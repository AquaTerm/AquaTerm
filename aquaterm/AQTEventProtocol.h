@protocol AQTEventProtocol
- (oneway void)processEvent:(bycopy NSString *)event;
- (oneway void)ping;
@end
