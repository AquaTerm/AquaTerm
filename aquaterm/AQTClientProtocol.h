@protocol AQTClientProtocol

-(void)selectView:(int)aView;
// The following methods applies to the currently selected view 
-(void)setModel:(bycopy id)aModel; // (id)?
-(NSDictionary *)status; // (id)?
-(BOOL)doCursorFromPoint:(NSPoint)startPoint withOptions:(NSDictionary *)cursorOptions;
-(void)close;

@end
