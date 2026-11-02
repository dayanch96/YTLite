#import "NSBundle+YTLite.h"

@implementation NSBundle (YTLite)

+ (NSBundle *)ytl_defaultBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLite" ofType:@"bundle"];
        NSString *kBundlePath = jbroot(@"/Library/Application Support/YTLite.bundle");

        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: kBundlePath] ?: [NSBundle mainBundle];
    });

    return bundle;
}

+ (NSBundle *)ytl_englishBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *path = [[self ytl_defaultBundle] pathForResource:@"en" ofType:@"lproj"];
        bundle = path ? [NSBundle bundleWithPath:path] : nil;
    });

    return bundle;
}

+ (NSString *)ytl_localizedStringForKey:(NSString *)key {
    if (!key) return @"";

    static NSString *const kMissing = @"__ytl_missing__";
    NSBundle *bundle = [self ytl_defaultBundle];

    NSString *value = [bundle localizedStringForKey:key value:kMissing table:nil];
    if (![value isEqualToString:kMissing]) return value;

    value = [bundle localizedStringForKey:key value:kMissing table:@"Fallback"];
    if (![value isEqualToString:kMissing]) return value;

    NSBundle *english = [self ytl_englishBundle];
    for (NSString *table in @[@"Localizable", @"Fallback"]) {
        value = [english localizedStringForKey:key value:kMissing table:table];
        if (value && ![value isEqualToString:kMissing]) return value;
    }

    return key;
}

@end
