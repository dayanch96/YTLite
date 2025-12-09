#import "YTCollectionViewCellProtocol.h"
#import "YTResponder.h"

@interface YTCellController : NSObject <YTResponder>
- (id <YTCollectionViewCellProtocol> *)cell;
- (id)entry;
@end
