#import <UIKit/UIKit.h>
#import "ASCollectionNode.h"

@interface ASCollectionView : UICollectionView <UICollectionViewDataSource>
@property (nonatomic, weak, readwrite) ASCollectionNode *collectionNode;
@end
