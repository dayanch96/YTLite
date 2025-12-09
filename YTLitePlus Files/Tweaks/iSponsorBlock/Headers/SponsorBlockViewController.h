#import <UIKit/UIKit.h>
#import "SponsorSegmentView.h"
#import "iSponsorBlock.h"

@interface SponsorBlockViewController : UIViewController <UIContextMenuInteractionDelegate>
@property (strong, nonatomic) YTPlayerViewController *playerViewController;
@property (strong, nonatomic) UIViewController *previousParentViewController;
@property (strong, nonatomic) YTMainAppControlsOverlayView *overlayView;
@property (strong, nonatomic) UIButton *startEndSegmentButton;
@property (strong, nonatomic) UILabel *segmentsInDatabaseLabel;
@property (strong, nonatomic) UILabel *userSegmentsLabel;
@property (strong, nonatomic) UIButton *submitSegmentsButton;
@property (strong, nonatomic) NSMutableArray <SponsorSegmentView *> *sponsorSegmentViews;
@property (strong, nonatomic) NSMutableArray <SponsorSegmentView *> *userSponsorSegmentViews;
@property (strong, nonatomic) UILabel *whitelistChannelLabel;
- (void)startEndSegmentButtonPressed:(UIButton *)sender;
- (NSMutableArray *)segmentViewsForSegments:(NSArray <SponsorSegment *> *)segments editable:(BOOL)editable;
- (void)setupViews;
@end
