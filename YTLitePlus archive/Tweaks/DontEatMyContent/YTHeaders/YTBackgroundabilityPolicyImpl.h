#import <Foundation/NSObject.h>

@interface YTBackgroundabilityPolicyImpl : NSObject
@property (nonatomic, readonly, assign, getter=isBackgroundableByUserSettings) BOOL backgroundableByUserSettings;
@property (nonatomic, readonly, assign, getter=isPlayableInPictureInPictureByUserSettings) BOOL playableInPiPByUserSettings;
@end
