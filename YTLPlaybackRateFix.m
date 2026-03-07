// YTLPlaybackRateFix.m
// Adds missing playbackRate/setPlaybackRate: to YTSingleVideoController
// so the official YTLite dylib's speed overlay works on YouTube 21.07+

#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- Getter: playbackRate ---
// Returns the rate from the new activePlaybackRateModel.activeRate API
static float ytl_playbackRate(id self, SEL _cmd) {
    SEL modelSel = sel_registerName("activePlaybackRateModel");
    if (![self respondsToSelector:modelSel]) return 1.0f;

    id model = ((id(*)(id, SEL))objc_msgSend)(self, modelSel);
    if (!model) return 1.0f;

    SEL rateSel = sel_registerName("activeRate");
    if (![model respondsToSelector:rateSel]) return 1.0f;

    float rate = ((float(*)(id, SEL))objc_msgSend)(model, rateSel);
    return rate > 0 ? rate : 1.0f;
}

// --- Setter: setPlaybackRate: ---
// Forwards to YTPlayerViewController which still has this method
static void ytl_setPlaybackRate(id self, SEL _cmd, float rate) {
    Class playerVCClass = objc_getClass("YTPlayerViewController");
    if (!playerVCClass) return;

    // Walk the VC hierarchy to find YTPlayerViewController
    UIWindow *keyWindow = nil;
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *window in scene.windows) {
                if (window.isKeyWindow) { keyWindow = window; break; }
            }
            if (keyWindow) break;
        }
    }
    UIViewController *rootVC = keyWindow.rootViewController;
    if (!rootVC) return;

    NSMutableArray *queue = [NSMutableArray arrayWithObject:rootVC];
    while (queue.count > 0) {
        UIViewController *vc = queue.firstObject;
        [queue removeObjectAtIndex:0];

        if ([vc isKindOfClass:playerVCClass]) {
            SEL sel = sel_registerName("setPlaybackRate:");
            if ([vc respondsToSelector:sel]) {
                ((void(*)(id, SEL, float))objc_msgSend)(vc, sel, rate);
            }
            return;
        }

        for (UIViewController *child in vc.childViewControllers) {
            [queue addObject:child];
        }
        if (vc.presentedViewController) {
            [queue addObject:vc.presentedViewController];
        }
    }
}

__attribute__((constructor))
static void ytlPlaybackRateFixInit(void) {
    Class cls = objc_getClass("YTSingleVideoController");
    if (!cls) return;

    SEL getSel = sel_registerName("playbackRate");
    SEL setSel = sel_registerName("setPlaybackRate:");

    if (!class_respondsToSelector(cls, getSel)) {
        class_addMethod(cls, getSel, (IMP)ytl_playbackRate, "f@:");
    }
    if (!class_respondsToSelector(cls, setSel)) {
        class_addMethod(cls, setSel, (IMP)ytl_setPlaybackRate, "v@:f");
    }
}
