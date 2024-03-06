#import "YTLUserDefaults.h"

@implementation YTLUserDefaults

static NSString *const kDefaultsSuiteName = @"com.dvntm.ytlite";

+ (YTLUserDefaults *)standardUserDefaults {
    static dispatch_once_t onceToken;
    static YTLUserDefaults *defaults = nil;

    dispatch_once(&onceToken, ^{
        defaults = [[self alloc] initWithSuiteName:kDefaultsSuiteName];
        [defaults registerDefaults];
    });

    return defaults;
}

- (void)reset {
    [self removePersistentDomainForName:kDefaultsSuiteName];
}

- (void)registerDefaults {
    [self registerDefaults:@{
        @"noAds": @YES,
        @"backgroundPlayback": @YES,
        @"removeUploads": @YES,
        @"speedIndex": @1,
        @"autoSpeedIndex": @3,
        @"wiFiQualityIndex": @0,
        @"cellQualityIndex": @0,
        @"pivotIndex": @0
    }];
}

+ (void)resetUserDefaults {
    [[self standardUserDefaults] reset];
}

@end
