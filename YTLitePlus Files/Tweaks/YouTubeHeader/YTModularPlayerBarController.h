#import "YTModularPlayerBarView.h"
#import "YTPlayerBarProtocol.h"

@interface YTModularPlayerBarController : NSObject <YTPlayerBarProtocol>
@property (nonatomic, strong, readwrite) YTModularPlayerBarView *view;
@end
