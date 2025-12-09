#import "YTGlassContainerView.h"
#import "YTInlinePlayerBarView.h"
#import "YTModularPlayerBarController.h"
#import "YTLabel.h"
#import "YTPlayerBarProtocol.h"
#import "YTQTMButton.h"

@interface YTInlinePlayerBarContainerView : YTGlassContainerView
@property (nonatomic, strong, readwrite) YTInlinePlayerBarView *playerBar; // Replaced by segmentablePlayerBar in newer versions
@property (nonatomic, strong, readwrite) id <YTPlayerBarProtocol> segmentablePlayerBar; // Replaced by modularPlayerBar in newer 19.22.3+
@property (nonatomic, strong, readwrite) YTModularPlayerBarController *modularPlayerBar;
@property (nonatomic, strong, readwrite) UIView *multiFeedElementView;
@property (nonatomic, strong, readwrite) YTLabel *durationLabel;
@property (nonatomic, assign, readwrite) BOOL showOnlyFullscreenButton;
@property (nonatomic, assign, readwrite) int layout;
@property (nonatomic, weak, readwrite) id delegate;
@property (nonatomic, assign, readwrite) BOOL shouldDisplayTimeRemaining;
- (YTQTMButton *)exitFullscreenButton;
- (YTQTMButton *)enterFullscreenButton;
- (UIView *)peekableView;
- (void)setChapters:(NSArray *)chapters;
- (void)didPressScrubber:(id)arg1;
- (void)updateIconVisibilityAndLayout;
- (CGFloat)scrubRangeForScrubX:(CGFloat)arg1;
@end
