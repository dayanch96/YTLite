#import <YouTubeHeader/YTAppDelegate.h>
#import <YouTubeHeader/YTGlobalConfig.h>
#import <YouTubeHeader/YTColdConfig.h>
#import <YouTubeHeader/YTHotConfig.h>
#import <substrate.h>

NSMutableDictionary <NSString *, NSMutableDictionary <NSString *, NSNumber *> *> *cache;

extern void SearchHook();

extern BOOL tweakEnabled();
extern BOOL groupedSettings();

extern void updateAllKeys();
extern NSString *getKey(NSString *method, NSString *classKey);
extern BOOL getValue(NSString *methodKey);

static BOOL returnFunction(id const self, SEL _cmd) {
    NSString *method = NSStringFromSelector(_cmd);
    NSString *methodKey = getKey(method, NSStringFromClass([self class]));
    return getValue(methodKey);
}

static BOOL getValueFromInvocation(id target, SEL selector) {
    IMP imp = [target methodForSelector:selector];
    BOOL (*func)(id, SEL) = (BOOL (*)(id, SEL))imp;
    return func(target, selector);
}

static NSSet *excludedPrefixes;

static NSMutableArray <NSString *> *getBooleanMethods(Class clz) {
    NSMutableArray *allMethods = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        Method method = methods[i];
        const char *encoding = method_getTypeEncoding(method);
        if (strcmp(encoding, "B16@0:8")) continue;

        NSString *selector = [NSString stringWithUTF8String:sel_getName(method_getName(method))];

        // Check excluded prefixes efficiently
        BOOL excluded = NO;
        for (NSString *prefix in excludedPrefixes) {
            if ([selector hasPrefix:prefix]) {
                excluded = YES;
                break;
            }
        }
        // Also exclude anything containing "Android"
        if (!excluded && [selector rangeOfString:@"Android"].location != NSNotFound) {
            excluded = YES;
        }
        if (excluded) continue;

        if (![allMethods containsObject:selector])
            [allMethods addObject:selector];
    }
    free(methods);
    return allMethods;
}

static void hookClass(NSObject *instance) {
    if (!instance) [NSException raise:@"hookClass Invalid argument exception" format:@"Hooking the class of a non-existing instance"];
    Class instanceClass = [instance class];
    NSMutableArray <NSString *> *methods = getBooleanMethods(instanceClass);
    NSString *classKey = NSStringFromClass(instanceClass);
    NSMutableDictionary *classCache = cache[classKey] = [NSMutableDictionary new];
    for (NSString *method in methods) {
        SEL selector = NSSelectorFromString(method);
        BOOL result = getValueFromInvocation(instance, selector);
        classCache[method] = @(result);
        MSHookMessageEx(instanceClass, selector, (IMP)returnFunction, NULL);
    }
}

%hook YTAppDelegate

- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    if (tweakEnabled()) {
        updateAllKeys();
        YTGlobalConfig *globalConfig;
        YTColdConfig *coldConfig;
        YTHotConfig *hotConfig;
        @try {
            globalConfig = [self valueForKey:@"_globalConfig"];
            coldConfig = [self valueForKey:@"_coldConfig"];
            hotConfig = [self valueForKey:@"_hotConfig"];
        } @catch (id ex) {
            @try {
                id settings = [self valueForKey:@"_settings"];
                globalConfig = [settings valueForKey:@"_globalConfig"];
                coldConfig = [settings valueForKey:@"_coldConfig"];
                hotConfig = [settings valueForKey:@"_hotConfig"];
            } @catch (id ex) {}
        }
        hookClass(globalConfig);
        hookClass(coldConfig);
        hookClass(hotConfig);
        if (!groupedSettings()) {
            SearchHook();
        }
    }
    return %orig;
}

%end

%ctor {
    [[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Frameworks/Module_Framework.framework", [[NSBundle mainBundle] bundlePath]]] load];
    cache = [NSMutableDictionary new];
    excludedPrefixes = [NSSet setWithArray:@[@"android", @"amsterdam", @"kidsClient", @"musicClient", @"musicOfflineClient", @"unplugged"]];
    %init;
}

%dtor {
    [cache removeAllObjects];
}
