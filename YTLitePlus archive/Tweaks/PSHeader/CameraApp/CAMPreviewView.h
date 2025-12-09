#import <AVFoundation/AVFoundation.h>

NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMPreviewView : UIView

@property (retain, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property CGFloat dimmingStrength;

- (void)setDimmingStrength:(CGFloat)strength duration:(NSTimeInterval)duration;

@end
