#import "GPBMessage.h"

@class YTICommand;

@interface YTICommandExecutorCommand : GPBMessage
@property (nonatomic, strong, readwrite) NSMutableArray <YTICommand *> *commandsArray;
@end
