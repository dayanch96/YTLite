NS_CLASS_AVAILABLE_IOS(10_0)
@interface CAMCaptureConfiguration : NSObject

- (NSInteger)videoConfiguration;
- (NSInteger)audioConfiguration;
- (NSInteger)previewConfiguration;
- (NSInteger)mode;
- (NSInteger)device;

@end
