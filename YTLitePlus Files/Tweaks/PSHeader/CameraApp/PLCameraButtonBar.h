#import "PLCameraButton.h"

NS_CLASS_DEPRECATED_IOS(5_0, 6_1)
@interface PLCameraButtonBar : UIToolbar
@property (retain, nonatomic) PLCameraButton *cameraButton;
- (UIView *)_backgroundView;
- (void)_setVisibility:(BOOL)visible;
@end
