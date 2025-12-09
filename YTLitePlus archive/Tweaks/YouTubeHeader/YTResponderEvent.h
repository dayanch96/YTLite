#import "YTResponder.h"

@interface YTResponderEvent : NSObject
+ (void)addEventHandlerForResponder:(id <YTResponder>)responder handlerBlock:(void (^)(void))handlerBlock;
@property (nonatomic, readonly, strong) id <YTResponder> firstResponder;
- (instancetype)initWithFirstResponder:(id <YTResponder>)firstResponder;
- (void)send;
- (void)sendIfEventHandlerAvailable;
- (BOOL)sendWithStrictHandling:(BOOL)strictHandling;
@end
