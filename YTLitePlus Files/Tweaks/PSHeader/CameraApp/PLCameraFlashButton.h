#import "PLReorientingButton.h"

NS_CLASS_DEPRECATED_IOS(5_0, 6_1)
@interface PLCameraFlashButton : PLReorientingButton

@property (assign, nonatomic, getter=isAutoHidden) BOOL autoHidden;
@property NSInteger flashMode;

- (void)_expandAnimated:(BOOL)animated;
- (void)_collapseAndSetMode:(NSInteger)mode animated:(BOOL)animated;

- (UIView *)delegate;

@end
