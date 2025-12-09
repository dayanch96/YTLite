#import "HAMBuildableObject.h"
#import "HAMFormat.h"

@interface HAMFormatDescription : HAMBuildableObject
@property (nonatomic, assign, readonly) id <HAMFormat> format;
@end
