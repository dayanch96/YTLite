#import "GPBExtensionDescriptor.h"
#import "GPBMessage.h"

@interface YTIVideoQualityPickerEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *videoId;
@property (nonatomic, assign, readwrite) BOOL enableAdvancedMenuOption;
+ (GPBExtensionDescriptor *)videoQualityPickerEndpoint;
@end
