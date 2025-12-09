#ifndef _PS
#define _PS

#import "iOSVersions.h"
#import "Misc.h"

#define PS_DONATE_URL @"https://poomsmart.github.io/repo/"
#define PS_TWITTER_URL @"https://x.com/PoomSmart"

#ifdef CHECK_TARGET

#import <HBLog.h>

typedef NS_ENUM(NSUInteger, TargetType) {
    TargetTypeApps = 1 << 0,
    TargetTypeGenericExtensions = 1 << 1,
    TargetTypeKeyboardExtensions = 1 << 2
};

#ifdef CHECK_TARGET_LEGACY
FOUNDATION_EXPORT char ***_NSGetArgv();
#else
extern int _NSGetExecutablePath(char* buf, uint32_t* bufsize);
#endif

static BOOL _isTarget(NSUInteger type, NSArray <NSString *> *whitelist, NSArray <NSString *> *blacklist) {
#ifdef CHECK_TARGET_LEGACY
    char *executablePathC = **_NSGetArgv();
#else
    char *executablePathC = (char *)malloc(1024);
	uint32_t size = 1024;
	if (_NSGetExecutablePath(executablePathC, &size) != 0) {
		free(executablePathC);
		return NO;
	}
#endif
    NSString *executablePath = [NSString stringWithUTF8String:executablePathC];
    if (executablePath) {
        HBLogDebug(@"Executable path: %@", executablePath);
        BOOL isExtension = [executablePath rangeOfString:@"appex"].location != NSNotFound;
        if (type & TargetTypeGenericExtensions && isExtension) {
            HBLogDebug(@"Injected: extension");
            return YES;
        }
        NSString *processName = [executablePath lastPathComponent];
#ifdef CHECK_BLACKLIST
        if (blacklist.count) {
            BOOL disallow = [blacklist containsObject:processName];
            NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
            if (!disallow && bundleIdentifier)
                disallow = [blacklist containsObject:bundleIdentifier];
            if (disallow)
                return NO;
        }
#endif
#ifdef CHECK_WHITELIST
        if (whitelist.count) {
            BOOL allow = [whitelist containsObject:processName];
            NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
            if (!allow && bundleIdentifier)
                allow = [whitelist containsObject:bundleIdentifier];
            if (allow) {
                HBLogDebug(@"Injected: whitelist");
                return YES;
            }
        }
#endif
        BOOL isSpringBoard = NSStringEqual(processName, @"SpringBoard");
        BOOL isExtensionOrApp = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
        BOOL isUILike = isSpringBoard || isExtensionOrApp;
        if (type & TargetTypeApps && isUILike && !isExtension) {
            HBLogDebug(@"Injected: app");
            return YES;
        }
        if (type & TargetTypeKeyboardExtensions && isExtension) {
            id val = NSBundle.mainBundle.infoDictionary[@"NSExtension"][@"NSExtensionPointIdentifier"];
            BOOL isKeyboardExtension = val ? NSStringEqual(val, @"com.apple.keyboard-service") : NO;
            if (isKeyboardExtension)
                HBLogDebug(@"Injected: keyboard extension");
            return isKeyboardExtension;
        }
    }
    return NO;
}

#define isTarget(type) _isTarget(type, nil, nil)

#ifdef CHECK_TARGET_GUI

static void *observer = NULL;
static void lateLoad(void);

static void appLoaded(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    lateLoad();
}

static void appLoadedCallback() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), &observer, appLoaded, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
}

#endif

#endif

#ifdef KILL_PROCESS

#include <spawn.h>

void killProcess(const char *name) {
    pid_t pid;
    int status;
    const char *args[] = {
        "killall", "-9", name, NULL
    };
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
    waitpid(pid, &status, WEXITED);
}

#endif

#endif
