#import "YTICommand.h"
#import "YTIIcon.h"
#import "YTIThumbnailDetails.h"

@interface YTIPivotBarItemRenderer : GPBMessage
@property (nonatomic, copy, readwrite) NSString *pivotIdentifier;
@property (nonatomic, copy, readwrite) NSString *targetId;
@property (nonatomic, strong, readwrite) YTICommand *navigationEndpoint;
@property (nonatomic, strong, readwrite) YTICommand *onLongPress;
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, strong, readwrite) YTIThumbnailDetails *thumbnail;
@end