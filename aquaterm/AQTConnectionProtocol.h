@protocol AQTConnectionProtocol
- (oneway void)ping;
- (void)getServerVersionMajor:(out int *)major minor:(out int *)minor rev:(out int *)rev;
- (id)addAQTClient:(byref id)client name:(bycopy NSString *)name pid:(int)procId; 
- (BOOL)removeAQTClient:(byref id)client; 
@end
