#import <Foundation/Foundation.h>

@interface YTIVideoDetails : NSObject
@property (nonatomic, assign, readwrite) BOOL allowRatings;
@property (nonatomic, assign, readwrite) float averageRating;
@property (nonatomic, copy, readwrite) NSString *viewCount;
@property (nonatomic, copy, readwrite) NSString *channelId;
@property (nonatomic, copy, readwrite) NSString *videoId;
@end
