#import "GPBExtensionDescriptor.h"

@interface GPBRootObject : NSObject
+ (void)globallyRegisterExtension:(GPBExtensionDescriptor *)extension;
@end
