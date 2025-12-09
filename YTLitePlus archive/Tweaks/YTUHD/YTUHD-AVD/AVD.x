#import <IOKit/IOKitLib.h>
#import <dlfcn.h>

%hookf(kern_return_t, IOServiceGetMatchingServices, mach_port_t mainPort, CFDictionaryRef matching, io_iterator_t *existing) {
    if (CFDictionaryGetValue(matching, CFSTR("AppleAVD")))
        return 0;
    return %orig(mainPort, matching, existing);
}

%hookf(BOOL, AppleAVDCheckPlatform) {
    return YES;
}

%ctor {
    const char *avdPath = "/System/Library/VideoDecoders/AVD.videodecoder";
    void *avd = dlopen(avdPath, RTLD_LAZY);
    MSImageRef ref = MSGetImageByName(avdPath);
    void *AppleAVDCheckPlatform_p = MSFindSymbol(ref, "_AppleAVDCheckPlatform");
    HBLogDebug(@"AVD open: %d, pointer: %d", avd != NULL, AppleAVDCheckPlatform_p != NULL);
    %init(AppleAVDCheckPlatform = (void *)AppleAVDCheckPlatform_p);
}
