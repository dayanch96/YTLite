#import <Foundation/NSObject.h>
#import "YTSystemNotificationsObserver.h"

@interface YTSystemNotifications : NSObject
- (void)addSystemNotificationsObserver:(id <YTSystemNotificationsObserver>)observer;
- (void)callBlockForEveryObserver:(void (^)(id <YTSystemNotificationsObserver>))block;
@end
