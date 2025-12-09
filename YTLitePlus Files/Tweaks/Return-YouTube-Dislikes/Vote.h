#ifndef VOTE_H_
#define VOTE_H_

#import <Foundation/NSCache.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

NSString *formattedLongNumber(NSNumber *number, NSString *error);
NSString *getNormalizedLikes(NSNumber *likeNumber, NSString *error);
NSString *getNormalizedDislikes(NSNumber *dislikeNumber, NSString *error);
NSNumber *getLikeData(NSDictionary <NSString *, NSNumber *> *data);
NSNumber *getDislikeData(NSDictionary <NSString *, NSNumber *> *data);
void getVoteFromVideoWithHandler(NSCache <NSString *, NSDictionary *> *cache, NSString *videoId, int retryCount, void (^handler)(NSDictionary *d, NSString *error));

#define FETCHING @"⌛"
#define FAILED @"❌"

#endif
