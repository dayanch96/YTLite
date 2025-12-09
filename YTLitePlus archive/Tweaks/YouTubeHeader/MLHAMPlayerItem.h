#import "MLABRPolicy.h"
#import "MLFormat.h"
#import "MLInnerTubeCaptionController.h"
#import "MLInnerTubeCaptionTrack.h"
#import "MLInnerTubePlayerConfig.h"
#import "MLVideoFormatConstraint.h"

@interface MLHAMPlayerItem : NSObject
@property (nonatomic, assign, readwrite) BOOL peggedToLive;
@property (nonatomic, strong, readonly) MLInnerTubeCaptionController *captionController;
@property (nonatomic, strong, readonly) MLInnerTubeCaptionTrack *activeCaptionTrack;
@property (nonatomic, strong, readonly) MLInnerTubePlayerConfig *config;
@property (nonatomic, strong, readwrite) id <MLVideoFormatConstraint> videoFormatConstraint;
- (void)ABRPolicy:(MLABRPolicy *)policy selectableFormatsDidChange:(NSArray <MLFormat *> *)formats;
- (NSArray <MLFormat *> *)selectableVideoFormats;
@end