#import <VideoToolbox/VideoToolbox.h>

extern BOOL UseVP9();

#ifdef SIDELOADED

typedef struct OpaqueVTVideoDecoder VTVideoDecoderRef;
extern OSStatus VTSelectAndCreateVideoDecoderInstance(CMVideoCodecType codecType, CFAllocatorRef allocator, CFDictionaryRef videoDecoderSpecification, VTVideoDecoderRef *decoderInstanceOut);

#endif

%ctor {
#ifdef SIDELOADED
    CFMutableDictionaryRef payload = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (payload) {
        CFDictionarySetValue(payload, CFSTR("RequireHardwareAcceleratedVideoDecoder"), kCFBooleanTrue);
        CFDictionarySetValue(payload, CFSTR("AllowAlternateDecoderSelection"), kCFBooleanTrue);
        VTSelectAndCreateVideoDecoderInstance(kCMVideoCodecType_VP9, kCFAllocatorDefault, payload, NULL);
        CFRelease(payload);
    }
#endif
}
