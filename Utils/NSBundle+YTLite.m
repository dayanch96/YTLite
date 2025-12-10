#import "NSBundle+YTLite.h"

@implementation NSBundle (YTLite)

+ (NSBundle *)ytl_defaultBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLite" ofType:@"bundle"];
        #if __has_include(<roothide.h>)
        NSString *kBundlePath = jbroot(@"/Library/Application Support/YTLite.bundle");
        #else
        NSString *kBundlePath = @"/Library/Application Support/YTLite.bundle";
        #endif

        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: kBundlePath];
    });

    return bundle;
}

@end
