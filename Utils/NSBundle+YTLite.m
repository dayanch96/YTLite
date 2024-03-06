#import "NSBundle+YTLite.h"

@implementation NSBundle (YTLite)

+ (NSBundle *)ytl_defaultBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLite" ofType:@"bundle"];
        NSString *rootlessBundlePath = ROOT_PATH_NS("/Library/Application Support/YTLite.bundle");

        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: rootlessBundlePath];
    });

    return bundle;
}

@end