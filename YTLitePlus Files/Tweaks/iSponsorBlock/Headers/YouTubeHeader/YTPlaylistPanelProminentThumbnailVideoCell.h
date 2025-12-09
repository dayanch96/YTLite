#import "YTCollectionViewCell.h"

@interface YTPlaylistPanelProminentThumbnailVideoCell : YTCollectionViewCell
- (void)setSwipeButtonTarget:(id)target action:(SEL)action;
- (void)setSwipeButtonActionsViewRightBlock:(void (^)(void))block;
@end
