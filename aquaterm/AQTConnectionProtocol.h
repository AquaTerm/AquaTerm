@protocol AQTConnectionProtocol
-(id)addAQTClientWithId:(bycopy NSString *)identifier name:(bycopy NSString *)name pid:(int)procId;
-(oneway void)removeAQTClientWithId:(bycopy NSString *)identifier;
@end
