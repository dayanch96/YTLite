#import <Foundation/NSObject.h>
#import <UIKit/UIApplication.h>

@protocol YTApplicationNotificationsObserver <NSObject>
- (void)appWillEnterForeground:(UIApplication *)application;
- (void)appWillResignActive:(UIApplication *)application;
- (void)addDidBecomeActive:(UIApplication *)application;
- (void)appDidEnterBackground:(UIApplication *)application;
@end
