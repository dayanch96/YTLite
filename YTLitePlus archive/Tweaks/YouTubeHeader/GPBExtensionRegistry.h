#import "GPBExtensionDescriptor.h"

@interface GPBExtensionRegistry : NSObject
- (void)addExtension:(GPBExtensionDescriptor *)extension;
- (void)addExtensions:(GPBExtensionRegistry *)registry;
@end
