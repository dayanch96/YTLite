#import <Foundation/Foundation.h>
#import "YTCollectionViewCellProtocol.h"

@interface YTCellController : NSObject
@property (nonatomic, weak, readwrite) UICollectionViewCell <YTCollectionViewCellProtocol> *cell;
@end