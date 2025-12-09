#import <Foundation/NSObject.h>

@interface YTBackgroundabilityPolicy : NSObject
@property (nonatomic, readonly, assign, getter=isBackgroundableByUserSettings) BOOL backgroundableByUserSettings;
@property (nonatomic, readonly, assign, getter=isPlayableInPictureInPictureByUserSettings) BOOL playableInPiPByUserSettings;
- (void)addBackgroundabilityPolicyObserver:(id)observer;
@end
