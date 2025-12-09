#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AVPlayerController : UIResponder
@end

@interface AVPictureInPictureControllerContentSource (Private)
@property (assign) bool hasInitialRenderSize;
@end

@interface AVPictureInPictureController (Private)
@property (nonatomic, strong) AVPictureInPictureControllerContentSource *contentSource API_AVAILABLE(ios(15.0));
@property (nonatomic, assign) BOOL canStartAutomaticallyWhenEnteringBackground API_AVAILABLE(ios(14.0));
- (instancetype)initWithContentSource:(AVPictureInPictureControllerContentSource *)contentSource API_AVAILABLE(ios(15.0));
- (void)sampleBufferDisplayLayerRenderSizeDidChangeToSize:(CGSize)renderSize;
- (void)sampleBufferDisplayLayerDidAppear;
- (void)sampleBufferDisplayLayerDidDisappear;
@end
