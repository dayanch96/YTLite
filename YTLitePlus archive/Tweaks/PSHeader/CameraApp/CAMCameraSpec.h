NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMCameraSpec : NSObject

+ (instancetype)specForCurrentPlatform;
+ (instancetype)specForPhone;
+ (instancetype)specForPad;

@end
