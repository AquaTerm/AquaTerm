@protocol AQTConnectionProtocol
- (oneway void)ping;
- (void)getServerVersionMajor:(out int *)major minor:(out int *)minor rev:(out int *)rev;
- (id)addAQTClient:(bycopy id)client name:(bycopy NSString *)name pid:(int)procId; 
//- (BOOL)removeAQTClient:(bycopy id)client; 
@end
