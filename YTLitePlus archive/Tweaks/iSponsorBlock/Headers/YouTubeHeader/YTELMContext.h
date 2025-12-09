#import "YTResponder.h"

@interface YTELMContext : NSObject
- (instancetype)initWithResponder:(id <YTResponder>)responder;
- (id <YTResponder>)parentResponder;
@end
