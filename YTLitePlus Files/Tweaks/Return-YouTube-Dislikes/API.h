#ifndef API_H_
#define API_H_

#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <YouTubeHeader/YTLikeStatus.h>

void fetch(
    NSString *endpoint,
    NSString *method,
    NSDictionary *body,
    void (^dataHandler)(NSDictionary *data),
    BOOL (^responseCodeHandler)(NSUInteger responseCode),
    void (^networkErrorHandler)(void),
    void (^dataErrorHandler)(void)
);

void sendVote(NSString *videoId, YTLikeStatus s);

#endif
