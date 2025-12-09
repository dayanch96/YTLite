//
//  Tweak.m
//  FLEXing
//
//  Created by Tanner Bennett on 2016-07-11
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//


#import "Interfaces.h"
#import <rootless.h>
#import <HBLog.h>

#if TARGET_OS_SIMULATOR
#import <UIKit/UIFunctions.h>
#define realPath(path) [UISystemRootDirectory() stringByAppendingPathComponent:path]
#else
#define realPath(path) path
#endif

BOOL initialized = NO;
id manager = nil;
SEL show = nil;

static NSHashTable *windowsWithGestures = nil;

static id (*FLXGetManager)();
static SEL (*FLXRevealSEL)();
static Class (*FLXWindowClass)();

/// This isn't perfect, but works for most cases as intended
inline bool isLikelyUIProcess() {
    NSString *executablePath = NSProcessInfo.processInfo.arguments[0];
    HBLogInfo(@"FLEXing: executablePath: %@", executablePath);

    return [executablePath hasSuffix:@"CoreServices/SpringBoard.app/SpringBoard"] ||
        [executablePath hasPrefix:realPath(@"/Applications")] ||
#if TARGET_OS_SIMULATOR
        [executablePath containsString:@"/data/Containers/Bundle/Application"];
#else
        [executablePath hasPrefix:@"/var/containers/Bundle/Application"] ||
        [executablePath containsString:@"/procursus/Applications"];
#endif
}

inline bool isSnapchatApp() {
    return [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.toyopagroup.picaboo"];
}

inline BOOL flexAlreadyLoaded() {
    return NSClassFromString(@"FLEXExplorerToolbar") != nil;
}

%ctor {
#if TARGET_OS_SIMULATOR
    NSString *standardPath = realPath(@"/Library/MobileSubstrate/DynamicLibraries/libFLEX.dylib");
    NSString *reflexPath =   realPath(@"/Library/MobileSubstrate/DynamicLibraries/libreflex.dylib");
#else
    NSString *standardPath = ROOT_PATH_NS(@"/Library/MobileSubstrate/DynamicLibraries/libFLEX.dylib");
    NSString *reflexPath =   ROOT_PATH_NS(@"/Library/MobileSubstrate/DynamicLibraries/libreflex.dylib");
#endif
    NSFileManager *disk = NSFileManager.defaultManager;
    NSString *libflex = nil;
    NSString *libreflex = nil;
    void *handle = nil;

    if ([disk fileExistsAtPath:standardPath]) {
        libflex = standardPath;
        if ([disk fileExistsAtPath:reflexPath]) {
            libreflex = reflexPath;
        }
    } else {
        // Check if libFLEX resides in the same folder as me
        NSString *executablePath = NSProcessInfo.processInfo.arguments[0];
        NSString *whereIam = executablePath.stringByDeletingLastPathComponent;
        NSString *possibleFlexPath = [whereIam stringByAppendingPathComponent:@"Frameworks/libFLEX.dylib"];
        NSString *possibleReflexPath = [whereIam stringByAppendingPathComponent:@"Frameworks/libreflex.dylib"];
        if ([disk fileExistsAtPath:possibleFlexPath]) {
            libflex = possibleFlexPath;
            if ([disk fileExistsAtPath:possibleReflexPath]) {
                libreflex = possibleReflexPath;
            }
        } else {
            // libFLEX not found
            // ...
        }
    }

    if (libflex) {
        // Hey Snapchat / Snap Inc devs,
        // This is so users don't get their accounts locked.
        if (isLikelyUIProcess() && !isSnapchatApp()) {
            handle = dlopen(libflex.UTF8String, RTLD_LAZY);
            
            if (libreflex) {
                dlopen(libreflex.UTF8String, RTLD_NOW);
            }

            HBLogInfo(@"FLEXing: Initialized");
        }
    }

    if (handle || flexAlreadyLoaded()) {
        // FLEXing.dylib itself does not hard-link against libFLEX.dylib,
        // instead libFLEX.dylib provides getters for the relevant class
        // objects so that it can be updated independently of THIS tweak.
        FLXGetManager = (id(*)())dlsym(handle, "FLXGetManager");
        FLXRevealSEL = (SEL(*)())dlsym(handle, "FLXRevealSEL");
        FLXWindowClass = (Class(*)())dlsym(handle, "FLXWindowClass");

        if (FLXGetManager && FLXRevealSEL) {
            manager = FLXGetManager();
            show = FLXRevealSEL();

            windowsWithGestures = [NSHashTable weakObjectsHashTable];
            initialized = YES;
        }
    }
}

%hook UIWindow
- (BOOL)_shouldCreateContextAsSecure {
    return (initialized && [self isKindOfClass:FLXWindowClass()]) ? YES : %orig;
}

- (void)becomeKeyWindow {
    %orig;

    if (!initialized) {
        return;
    }

    BOOL needsGesture = ![windowsWithGestures containsObject:self];
    BOOL isFLEXWindow = [self isKindOfClass:FLXWindowClass()];
    BOOL isStatusBar  = [self isKindOfClass:[UIStatusBarWindow class]];
    if (needsGesture && !isFLEXWindow && !isStatusBar) {
        [windowsWithGestures addObject:self];

        // Add 3-finger long-press gesture for apps without a status bar
        UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:manager action:show];
        tap.minimumPressDuration = .5;
        tap.numberOfTouchesRequired = 3;

        [self addGestureRecognizer:tap];
    }
}
%end

%hook UIStatusBarWindow
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    
    if (initialized) {
        // Add long-press gesture to status bar
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:manager action:show]];
    }
    
    return self;
}
%end

%hook FLEXExplorerViewController
- (BOOL)_canShowWhileLocked {
    return YES;
}
%end

%hook _UISheetPresentationController
- (id)initWithPresentedViewController:(id)present presentingViewController:(id)presenter {
    self = %orig;
    if ([present isKindOfClass:%c(FLEXNavigationController)]) {
        // Enable half height sheet
        if ([self respondsToSelector:@selector(_presentsAtStandardHalfHeight)]) {
            self._presentsAtStandardHalfHeight = YES;
        } else {
            self._detents = @[[%c(_UISheetDetent) _mediumDetent], [%c(_UISheetDetent) _largeDetent]];
        }
        // Start fullscreen, 0 for half height
        self._indexOfCurrentDetent = 1;
        // Don't expand unless dragged up
        self._prefersScrollingExpandsToLargerDetentWhenScrolledToEdge = NO;
        // Don't dim first detent
        self._indexOfLastUndimmedDetent = 1;
    }
    
    return self;
}
%end

%hook FLEXManager
%new(@@:@)
+ (NSString *)dlopen:(NSString *)path {
    if (!dlopen(path.UTF8String, RTLD_NOW)) {
        return @(dlerror());
    }
    
    return @"OK";
}
%end

%ctor {
#if TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager performSelector:show];
    });
#endif
}
