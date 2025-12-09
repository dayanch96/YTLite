#ifndef _PS_CAMMACRO
#define _PS_CAMMACRO

#import <dlfcn.h>
#import "Misc.h"

#define CAMERAUI "/System/Library/PrivateFrameworks/CameraUI.framework/CameraUI"
#define openCamera10() dlopen(realPath2(@CAMERAUI), RTLD_NOW)
#define openCamera9() openCamera10()
#define CAMERAKIT "/System/Library/PrivateFrameworks/CameraKit.framework/CameraKit"
#define openCamera8() dlopen(realPath2(@CAMERAKIT), RTLD_NOW)
#define PHOTOLIBRARY "/System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary"
#define openCamera7() dlopen(realPath2(@PHOTOLIBRARY), RTLD_NOW)
#define openCamera6() openCamera7()
#define openCamera5() openCamera7()

#endif
