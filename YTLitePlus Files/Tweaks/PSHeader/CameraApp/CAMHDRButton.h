#import "CAMButtonLabel.h"

API_AVAILABLE(ios(7.0))
@interface CAMHDRButton : UIButton <NSCoding>
@property (readonly, nonatomic) CAMButtonLabel *_onLabel;
@property (readonly, nonatomic) CAMButtonLabel *_offLabel;
@property (readonly, nonatomic) CAMButtonLabel *_hdrLabel;
@property (nonatomic) NSInteger orientation;
@property (nonatomic, getter=isOn) BOOL on;
- (void)_updateFromOrientationChangeAnimated:(BOOL)animated;
- (void)_updateFrameFromOrientation;
- (CGAffineTransform)_transformForOrientation:(NSInteger)orientation;
- (void)_updateLabelsFromOrientation;
- (void)_updateFromOnState;
- (void)setOrientation:(NSInteger)orientation animated:(BOOL)animated;
- (void)_layoutForLandscapeOrientation;
- (void)_layoutForPortraitOrientation;
- (void)_commonCAMHDRButtonInitialization;
@end
