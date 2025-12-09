#ifndef _YT_LIKESTATUS
#define _YT_LIKESTATUS

#import <Foundation/NSObject.h>

typedef NS_ENUM(int, YTLikeStatus) {
    YTLikeStatusLike = 0,
    YTLikeStatusDislike = 1,
    YTLikeStatusNeutral = 2
};

#endif
