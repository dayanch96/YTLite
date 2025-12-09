#import "MLVideoFormatConstraint.h"

@interface MLQuickMenuVideoQualitySettingFormatConstraint : NSObject <MLVideoFormatConstraint>
@property (nonatomic, readonly, assign) int formatSelectionReason;
@property (nonatomic, readonly, assign) BOOL disableTrack;
- (instancetype)initWithVideoQualitySetting:(int)videoQualitySetting formatSelectionReason:(NSInteger)formatSelectionReason qualityLabel:(NSString *)qualityLabel;
- (instancetype)initWithVideoQualitySetting:(int)videoQualitySetting formatSelectionReason:(NSInteger)formatSelectionReason qualityLabel:(NSString *)qualityLabel resolutionCap:(int)resolutionCap;
@end
