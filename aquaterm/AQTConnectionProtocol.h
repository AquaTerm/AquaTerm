@protocol AQTConnectionProtocol
-(id)addAQTClient:(byref id)client name:(bycopy NSString *)name pid:(int)procId; 
-(BOOL)removeAQTClient:(byref id)client; 
@end
