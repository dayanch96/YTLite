#import <UIKit/UIKit.h>
#import "SponsorSegment.h"
#import "SponsorBlockRequest.h"

@interface SponsorSegmentView : UIView
@property (strong, nonatomic) SponsorSegment *sponsorSegment;
@property (nonatomic, assign) BOOL editable;
@property (strong, nonatomic) UILabel *segmentLabel;
@property (strong, nonatomic) UILabel *categoryLabel;
- (instancetype)initWithFrame:(CGRect)frame sponsorSegment:(SponsorSegment *)segment editable:(BOOL)editable;
@end
