#import "CAMCameraSpec.h"

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMApplicationSpec : CAMCameraSpec

+ (instancetype)specForPhone;
+ (instancetype)specForPad;

@property (readonly) NSInteger modeDialOrientation;
@property (readonly) NSInteger bottomBarOrientation;

@end
