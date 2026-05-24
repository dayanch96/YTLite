#import "NSBundle+YTLite.h"

@implementation NSBundle (YTLite)

+ (NSBundle *)ytl_defaultBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // App bundle root (direct injection)
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLite" ofType:@"bundle"];
        // cyan/pyzule places deb files at their path relative to the app bundle
        NSString *sideloadBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Library/Application Support/YTLite.bundle"];
        // Jailbreak path
        NSString *kBundlePath = jbroot(@"/Library/Application Support/YTLite.bundle");

        bundle = [NSBundle bundleWithPath:tweakBundlePath]
              ?: [NSBundle bundleWithPath:sideloadBundlePath]
              ?: [NSBundle bundleWithPath:kBundlePath];
    });

    return bundle;
}

@end
