@protocol AQTConnectionProtocol
-(id)addAQTClient:(byref id)aClient; // Name? ProcessID?
-(BOOL)removeAQTClient:(byref id)aClient; // Name? ProcessID?
@end
