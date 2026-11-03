#import "YTLite.h"
#import "Utils/YTLSafeMode.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const kSBServer = @"https://sponsor.ajay.app";

static NSMutableDictionary <NSString *, NSArray <NSDictionary *> *> *sbSegments;
static NSMutableSet <NSString *> *sbPending;
static NSMutableSet <NSString *> *sbSkipped;
static NSString *sbLastVideoID;

NSArray <NSString *> *YTLSponsorBlockCategories(void) {
    return @[@"sponsor", @"selfpromo", @"interaction", @"intro", @"outro", @"preview", @"music_offtopic", @"filler"];
}

static NSArray <NSString *> *SBEnabledCategories(void) {
    NSMutableArray *enabled = [NSMutableArray array];
    for (NSString *category in YTLSponsorBlockCategories()) {
        if (ytlBool([@"sb_" stringByAppendingString:category])) [enabled addObject:category];
    }
    return enabled;
}

static NSString *SBHashPrefix(NSString *videoID) {
    NSData *data = [videoID dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    return [NSString stringWithFormat:@"%02x%02x", digest[0], digest[1]];
}

static void SBFetch(NSString *videoID) {
    NSArray *categories = SBEnabledCategories();
    if (categories.count == 0 || [sbPending containsObject:videoID]) return;
    [sbPending addObject:videoID];

    NSData *json = [NSJSONSerialization dataWithJSONObject:categories options:0 error:nil];
    NSString *categoriesParam = [[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/skipSegments/%@?categories=%@&actionType=skip", kSBServer, SBHashPrefix(videoID), [categoriesParam stringByReplacingOccurrencesOfString:@"," withString:@"%2C"]];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [request setValue:@"YTLite" forHTTPHeaderField:@"User-Agent"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *segments = [NSMutableArray array];
        NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)response).statusCode : 0;

        if (data && status == 200) {
            id parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([parsed isKindOfClass:[NSArray class]]) {
                for (NSDictionary *entry in parsed) {
                    if (![entry isKindOfClass:[NSDictionary class]] || ![entry[@"videoID"] isEqual:videoID]) continue;
                    for (NSDictionary *segment in entry[@"segments"]) {
                        if (![segment isKindOfClass:[NSDictionary class]]) continue;
                        NSArray *range = segment[@"segment"];
                        if (![range isKindOfClass:[NSArray class]] || range.count != 2) continue;
                        double start = [range[0] doubleValue], end = [range[1] doubleValue];
                        if (end - start < 0.5) continue;
                        [segments addObject:@{
                            @"start": @(start),
                            @"end": @(end),
                            @"category": segment[@"category"] ?: @"sponsor",
                            @"uuid": segment[@"UUID"] ?: [NSString stringWithFormat:@"%@-%f", videoID, start]
                        }];
                    }
                }
            }
        }

        [segments sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            return [a[@"start"] compare:b[@"start"]];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [sbPending removeObject:videoID];
            if (data || status == 404) sbSegments[videoID] = segments;
        });
    }] resume];
}

static NSString *SBCategoryName(NSString *category) {
    NSString *key = [@"SB_" stringByAppendingString:category];
    NSString *name = LOC(key);
    return [name isEqualToString:key] ? category : name;
}

static void SBHandleTime(YTPlayerViewController *player, double time) {
    if (!ytlBool(@"sponsorBlock")) return;
    if ([YTLValue(player, @"isPlayingAd") boolValue]) return;

    NSString *videoID = player.contentVideoID;
    if (videoID.length == 0) return;

    if (![videoID isEqualToString:sbLastVideoID]) {
        sbLastVideoID = videoID;
        [sbSkipped removeAllObjects];
        if (sbSegments.count > 50) [sbSegments removeAllObjects];
    }

    NSArray *segments = sbSegments[videoID];
    if (!segments) {
        SBFetch(videoID);
        return;
    }

    for (NSDictionary *segment in segments) {
        double start = [segment[@"start"] doubleValue], end = [segment[@"end"] doubleValue];
        if (time < start) break;
        if (time >= end - 0.35 || [sbSkipped containsObject:segment[@"uuid"]]) continue;

        [sbSkipped addObject:segment[@"uuid"]];

        if ([player respondsToSelector:@selector(seekToTime:)]) {
            ((void (*)(id, SEL, CGFloat))objc_msgSend)(player, @selector(seekToTime:), (CGFloat)end);
        } else {
            return;
        }

        if (ytlBool(@"sbNotify")) {
            NSString *message = [NSString stringWithFormat:LOC(@"SBSkipped"), SBCategoryName(segment[@"category"])];
            [[YTLClass(@"YTToastResponderEvent") eventWithMessage:message firstResponder:player] send];
        }
        return;
    }
}

%hook YTPlayerViewController
- (void)potentiallyMutatedSingleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;
    @try {
        SBHandleTime(self, time.time);
    } @catch (NSException *exception) {}
}

- (void)singleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;
    @try {
        SBHandleTime(self, time.time);
    } @catch (NSException *exception) {}
}
%end

%ctor {
    if (YTLSafeModeActive()) return;

    sbSegments = [NSMutableDictionary dictionary];
    sbPending = [NSMutableSet set];
    sbSkipped = [NSMutableSet set];

    %init;
}
