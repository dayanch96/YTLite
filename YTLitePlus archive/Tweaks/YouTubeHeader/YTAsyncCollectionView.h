#import "ASCollectionView.h"
#import "YTPageStyling.h"

@interface YTAsyncCollectionView : ASCollectionView
@property (nonatomic, weak, readwrite) id <YTPageStyling> pageStylingDelegate;
@end
