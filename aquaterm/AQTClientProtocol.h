@protocol AQTClientProtocol
-(void)setModel:(bycopy id)aModel; // (id)?
//-(NSDictionary *)status; // (id)?
- (void)setAcceptingEvents:(BOOL)flag;
- (bycopy NSString *)lastEvent;
-(void)close;
@end
