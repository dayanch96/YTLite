#import "../YTLitePlus.h"

typedef struct {
    int version;
    NSString *appVersion;
} VersionMapping;

static VersionMapping versionMappings[] = {
    {0, @"19.49.7"}, // Last v19 App Version
    {1, @"19.28.1"}, // New 2024 Thin Outline Icons
    {2, @"19.26.5"}, // Restore 2020's Thin Outline Icons
    {3, @"18.49.3"}, // Last v18 App Version
    {4, @"18.35.4"}, // Oldest Supported App Version (v18) - this is a replacement of v17.33.2.
    {5, @"18.34.5"}, // Brings back Library Tab - Deprecated/Unsupported
    {6, @"18.33.3"}, // Removes Playables in Explore - Deprecated/Unsupported
    {7, @"18.18.2"}, // Fixes YTClassicVideoQuality + YTSpeed - Deprecated/Unsupported
    {8, @"18.01.2"}, // First v18 App Version - Deprecated/Unsupported
    {9, @"17.49.6"}, // Last v17 App Version - Deprecated/Unsupported
    {10, @"17.38.10"}, // Fixes LowContrastMode + No Rounded Thumbnails - Deprecated/Unsupported
    {11, @"17.33.2"} // Oldest Supported App Version (v17) - Deprecated/Unsupported
};

static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}

static BOOL isVersionSpooferEnabled() {
    return IS_ENABLED(@"enableVersionSpoofer_enabled");
}

static NSString* getAppVersionForSpoofedVersion(int spoofedVersion) {
    for (int i = 0; i < sizeof(versionMappings) / sizeof(versionMappings[0]); i++) {
        if (versionMappings[i].version == spoofedVersion) {
            return versionMappings[i].appVersion;
        }
    }
    return nil;
}

%hook YTVersionUtils
+ (NSString *)appVersion {
    if (!isVersionSpooferEnabled()) {
        return %orig;
    }
    int spoofedVersion = appVersionSpoofer();
    NSString *appVersion = getAppVersionForSpoofedVersion(spoofedVersion);
    return appVersion ? appVersion : %orig;
}
%end
