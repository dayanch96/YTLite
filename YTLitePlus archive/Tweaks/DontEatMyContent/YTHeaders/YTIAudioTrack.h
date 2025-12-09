#import "GPBMessage.h"

@interface YTIAudioTrack : GPBMessage
@property (nonatomic, copy, readwrite) NSString *displayName;
@property (nonatomic, copy, readwrite) NSString *id_p;
@property (nonatomic, assign, readwrite) BOOL audioIsDefault;
@end
