@protocol AQTConnectionProtocol
// -(id)addAQTClientWithId:(bycopy NSString *)identifier name:(bycopy NSString *)name pid:(int)procId;
// -(oneway void)removeAQTClientWithId:(bycopy NSString *)identifier;
-(id)addAQTClient:(bycopy id)client name:(bycopy NSString *)name pid:(int)procId; // FIXME: bycopy??? Nooo!!?
-(oneway void)removeAQTClient:(bycopy id)client; // FIXME: bycopy??? Nooo!!?
@end
