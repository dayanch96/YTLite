#import <Foundation/Foundation.h>

@interface YTIIosMediaHotConfig : NSObject
@property (nonatomic, assign, readwrite) BOOL enablePictureInPicture;
@property (nonatomic, assign, readwrite) BOOL enablePipForNonBackgroundableContent;
@property (nonatomic, assign, readwrite) BOOL enablePipForNonPremiumUsers;
@end