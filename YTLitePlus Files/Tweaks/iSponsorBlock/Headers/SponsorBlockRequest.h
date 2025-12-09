#import <UIKit/UIKit.h>
#import "iSponsorBlock.h"
#import <objc/runtime.h>

@interface SponsorBlockRequest : NSObject
+(void)getSponsorTimes:(NSString *)videoID completionTarget:(id)target completionSelector:(SEL)sel apiInstance:(NSString *)apiInstance;
+(void)postSponsorTimes:(NSString *)videoID sponsorSegments:(NSArray <SponsorSegment *> *)segments userID:(NSString *)userID withViewController:(UIViewController *)viewController;
+(void)normalVoteForSegment:(SponsorSegment *)segment userID:(NSString *)userID type:(BOOL)type withViewController:(UIViewController *)viewController;
+(void)categoryVoteForSegment:(SponsorSegment *)segment userID:(NSString *)userID category:(NSString *)category withViewController:(UIViewController *)viewController;
+(void)viewedVideoSponsorTime:(SponsorSegment *)segment;
@end
