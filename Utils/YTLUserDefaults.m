#import "YTLUserDefaults.h"
#import <Security/Security.h>

@implementation YTLUserDefaults

static NSString *const kDefaultsSuiteName = @"com.dvntm.ytlite";
static NSString *const kBackupService = @"com.dvntm.ytlite.settings";
static NSString *const kBackupAccount = @"backup";
static BOOL backupPending = NO;

+ (YTLUserDefaults *)standardUserDefaults {
    static dispatch_once_t onceToken;
    static YTLUserDefaults *defaults = nil;

    dispatch_once(&onceToken, ^{
        defaults = [[self alloc] initWithSuiteName:kDefaultsSuiteName];
        [defaults restoreFromBackupIfNeeded];
        [defaults registerDefaults];
        [[NSNotificationCenter defaultCenter] addObserver:defaults selector:@selector(defaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:defaults];
        [[NSNotificationCenter defaultCenter] addObserver:defaults selector:@selector(flushBackup) name:@"UIApplicationWillResignActiveNotification" object:nil];
    });

    return defaults;
}

- (void)reset {
    [self removePersistentDomainForName:kDefaultsSuiteName];
    [self deleteBackup];
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

#pragma mark - Keychain backup

- (NSDictionary *)backupQuery {
    return @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kBackupService,
        (__bridge id)kSecAttrAccount: kBackupAccount
    };
}

- (void)restoreFromBackupIfNeeded {
    if ([self persistentDomainForName:kDefaultsSuiteName].count > 0) return;

    NSMutableDictionary *query = [[self backupQuery] mutableCopy];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &result) != errSecSuccess || !result) return;

    NSData *data = (__bridge_transfer NSData *)result;
    NSDictionary *settings = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];
    if (![settings isKindOfClass:[NSDictionary class]] || settings.count == 0) return;

    [self setPersistentDomain:settings forName:kDefaultsSuiteName];
}

- (void)defaultsDidChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        backupPending = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveBackup) object:nil];
        [self performSelector:@selector(saveBackup) withObject:nil afterDelay:1.0];
    });
}

- (void)flushBackup {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!backupPending) return;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveBackup) object:nil];
        [self saveBackup];
    });
}

- (void)saveBackup {
    backupPending = NO;
    NSDictionary *settings = [self persistentDomainForName:kDefaultsSuiteName];
    if (settings.count == 0) {
        [self deleteBackup];
        return;
    }

    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settings format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    if (!data) return;

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSDictionary *query = [self backupQuery];
        NSDictionary *attributes = @{
            (__bridge id)kSecValueData: data,
            (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        };

        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
        if (status == errSecItemNotFound) {
            NSMutableDictionary *item = [query mutableCopy];
            [item addEntriesFromDictionary:attributes];
            SecItemAdd((__bridge CFDictionaryRef)item, NULL);
        }
    });
}

- (void)deleteBackup {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveBackup) object:nil];
    SecItemDelete((__bridge CFDictionaryRef)[self backupQuery]);
}

@end
