#import <Foundation/Foundation.h>
#import "YTMainWindow.h"

@interface YTCommonUtils : NSObject
+ (BOOL)isIPhoneWithNotch; 
+ (BOOL)isIPad;
+ (BOOL)isSmallDevice; // Deprecated
+ (BOOL)isAppRunningInFullScreen;
+ (unsigned int)uniformRandomWithUpperBound:(unsigned int)upperBound;
+ (YTMainWindow *)mainWindow;
+ (NSBundle *)bundleForClass:(Class)cls; // Removed in YouTube 19.26.5
+ (NSBundle *)resourceBundleForModuleName:(NSString *)module appBundle:(NSBundle *)appBundle; // Removed in YouTube 19.30.2
+ (NSString *)hardwareModel; // Removed in YouTube 19.13.1
@end