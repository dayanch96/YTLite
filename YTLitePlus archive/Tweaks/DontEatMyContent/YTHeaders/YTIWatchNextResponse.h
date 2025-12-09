#import "YTICommand.h"

@interface YTIWatchNextResponse : NSObject
@property (nonatomic, assign, readwrite) BOOL hasOnUiReady;
@property (nonatomic, strong, readwrite) YTICommand *onUiReady;
@end
