#import "CAMButtonLabel.h"

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMFlashButton : UIButton

@property (assign, nonatomic) NSInteger orientation;
@property NSInteger flashMode;

@property BOOL allowsAutomaticFlash;
@property (getter=isUnavailable) BOOL unavailable;
@property (assign, nonatomic, getter=isAutoHidden) BOOL autoHidden;

@property (readonly) UIImageView *_glyphView;
@property (readonly, assign, nonatomic) UIImageView *_flashIconView;
@property (readonly, assign, nonatomic) UIImageView *_iconView;
@property (readonly, assign, nonatomic) CAMButtonLabel *_offLabel;
@property (readonly, assign, nonatomic) CAMButtonLabel *_onLabel;
@property (readonly, assign, nonatomic) CAMButtonLabel *_autoLabel;

@property (assign, nonatomic) NSUInteger selectedIndex;

- (UIView *)delegate;

- (BOOL)isExpanded;

- (void)collapseMenuAnimated:(BOOL)animated;
- (void)expandMenuAnimated:(BOOL)animated;

- (NSUInteger)indexForMode:(NSInteger)mode;

@end
