@protocol AQTClientProtocol

-(void)selectView:(int)aView;
// The following methods applies to the currently selected view 
-(void)setModel:(bycopy id)aModel; // (id)?
-(NSDictionary *)status; // (id)?
//-(BOOL)doCursorFromPoint:(NSPoint)startPoint withOptions:(NSDictionary *)cursorOptions;
-(void)beginMouse;
-(void)beginMouseWithOptions:(int)opt anchorPoint:(NSPoint)point;
-(BOOL)mouseIsDone;
-(char)mouseDownInfo:(inout NSPoint *)mouseLoc;
-(void)close;

@end
