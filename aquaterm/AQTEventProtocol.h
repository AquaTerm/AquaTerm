@protocol AQTEventProtocol
- (void)processEvent:(NSString *)event;
- (oneway void)ping;
@end