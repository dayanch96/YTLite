#import "GPBMessage.h"

@interface YTIStringRun : GPBMessage
@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, assign, readwrite) unsigned int textColor;
@end
