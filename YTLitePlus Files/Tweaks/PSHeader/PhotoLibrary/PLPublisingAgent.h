#import "PLManagedAsset.h"

@interface PLPublishingAgent : NSObject
@property BOOL enableHDUpload;
@property BOOL mediaIsHDVideo;
@property NSInteger remakerMode;
@property NSInteger selectedOption;
+ (instancetype)publishingAgentForBundleNamed:(NSString *)name toPublishMedia:(PLManagedAsset *)media;
- (NSInteger)_remakerModeForSelectedOption;
- (void)_transcodeVideo:(PLManagedAsset *)asset;
@end
