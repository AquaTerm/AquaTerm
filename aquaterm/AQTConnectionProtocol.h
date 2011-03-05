@protocol AQTConnectionProtocol
- (oneway void)ping;
- (void)getServerVersionMajor:(out int32_t *)major minor:(out int32_t *)minor rev:(out int32_t *)rev;
- (id)addAQTClient:(bycopy id)client name:(bycopy NSString *)name pid:(int32_t)procId; 
//- (BOOL)removeAQTClient:(bycopy id)client; 
@end
