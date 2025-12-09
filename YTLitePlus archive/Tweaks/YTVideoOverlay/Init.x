#import <dlfcn.h>
#import "Init.h"

static void initYTVideoOverlay(NSString *tweakKey, NSDictionary *metadata) {
    dlopen([[NSString stringWithFormat:@"%@/Frameworks/YTVideoOverlay.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_LAZY);
    dlopen(PS_ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/YTVideoOverlay.dylib"), RTLD_LAZY);
    [NSClassFromString(@"YTSettingsSectionItemManager") registerTweak:tweakKey metadata:metadata];
}
