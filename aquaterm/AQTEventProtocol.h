@protocol AQTEventProtocol
- (oneway void)processEvent:(bycopy NSString *)event sender:(id)sender;
- (oneway void)ping;
//- (BOOL)isValidKey:(id)key;
@end