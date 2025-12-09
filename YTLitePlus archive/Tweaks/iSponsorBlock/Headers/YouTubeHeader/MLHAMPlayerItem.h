#import "MLABRPolicy.h"
#import "MLFormat.h"
#import "MLInnerTubePlayerConfig.h"
#import "MLVideoFormatConstraint.h"

@interface MLHAMPlayerItem : NSObject
@property (nonatomic, readonly, strong) MLInnerTubePlayerConfig *config;
@property (nonatomic, strong, readwrite) id <MLVideoFormatConstraint> videoFormatConstraint;
- (void)ABRPolicy:(MLABRPolicy *)policy selectableFormatsDidChange:(NSArray <MLFormat *> *)formats;
- (NSArray <MLFormat *> *)selectableVideoFormats;
@end