# YTUHD

Unlocks 1440p (2K) and 2160p (4K) resolutions in iOS YouTube app.

## Backstory

For a few years, YouTube had been testing 2K/4K resolutions on iOS as A/B (Alpha/Beta testing). The first group of users will see 2K/4K options while the others won't.
There are certain prerequisites for those options to show:

1. Whether the iOS device support VP9 video decoding, which implies on Apple's end to be at least on iOS 14, and later YouTube says iOS 15 is the minimum requirement.
2. Whether YouTube decides on their end to include those options for that particular iOS device. The obviously slow devices are excluded.

YTUHD attempts to bypass those restrictions for all 64-bit devices running iOS 11 or higher.

## VP9

Hardware accelerated VP9 decoder is technically added as of iOS 14 and YouTube has been utilizing it through a private entitlement `com.apple.coremedia.allow-alternate-video-decoder-selection` (All apps are equal is a lie).
This decoder handles up to 4K, but only for A12 devices and later.

Those old devices don't get `AppleAVD` driver (`/System/Library/Extensions/AppleAVD.kext`) which is essential for VP9 decoding to work.
The driver availability is checked inside `/System/Library/VideoDecoders/AVD.videodecoder`.
Provided that you can extract a functional `AVD.videodecoder` binary from a dyld shared cache, you will still encounter the error `AVDRegister - AppleAVDCheckPlatform() returned FALSE` trying to load it.

Fortunately, YouTube app has a fallback to software decoding, which is not as efficient as hardware, but it works.
It can be utilized by disabling server ABR, which will be explained below.

## Server ABR

If you look at the source code, there is an enforcement to not use server ABR. The author is not sure what ABR stands for (Maybe **A**daptive **B**it**R**ate?) but its purpose is to fetch the available formats (resolutions) of a video.
It is unknown how YouTube exactly decides which formats to serve when the server ABR is enabled.
YTUHD has no control over that and has to disable it and relies on the client code that reliably allows for 2K/4K formats.
More specifically, it enables the VP9 software streaming filter so that those formats will not be filtered out.

## iOS version

The history has shaped YTUHD to spoof the device as iOS 15 (or higher) for those running lower. The user agent gets changed from spoofing for YouTube server to respond with VP9 formats and all the goodies.

## Sideloading

It's been reported that the sideloaded version of YouTube will not get 2K/4K even with YTUHD included. This is because of a big reason: VP9.
Normally when an app is sideloaded, the private entitlements get removed (including `com.apple.coremedia.allow-alternate-video-decoder-selection`) and the app won't be allowed to access the hardware VP9 decoder. There is no known solution to bypass this, unless you use [TrollStore](https://github.com/opa334/TrollStore) which allows for practically any entitlements, including the aforementioned, to be in your sideloaded app.
