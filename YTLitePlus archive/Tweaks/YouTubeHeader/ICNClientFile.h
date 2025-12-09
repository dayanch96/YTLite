#import "GPBMessage.h"

@interface ICNClientFile : GPBMessage
@property (nonatomic, copy, readwrite) NSString *fileId;
@property (nonatomic, copy, readwrite) NSString *fileUri;
@end
