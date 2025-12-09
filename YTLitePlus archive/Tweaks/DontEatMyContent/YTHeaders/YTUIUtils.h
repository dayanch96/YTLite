#import <UIKit/UIKit.h>

@interface YTUIUtils : NSObject
+ (BOOL)canOpenURL:(NSURL *)url;
+ (BOOL)openURL:(NSURL *)url;
+ (CGFloat)appPortraitWidth;
+ (CGFloat)appPortraitHeight;
+ (NSInteger)horizontalSizeClass;
+ (NSInteger)verticalSizeClass;
+ (UIViewController *)topViewControllerForPresenting;
+ (NSString *)localizedCount:(NSUInteger)count;
@end
