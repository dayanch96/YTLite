#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import <YouTubeHeader/YTLikeStatus.h>
#import <HBLog.h>
#import "Settings.h"
#import "Shared.h"

static NSString *getUserID() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey];
}

static BOOL isRegistered() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:RegistrationConfirmedKey];
}

static int toRYDLikeStatus(YTLikeStatus likeStatus) {
    switch (likeStatus) {
        case YTLikeStatusLike:
            return 1;
        case YTLikeStatusDislike:
            return -1;
        default:
            return 0;
    }
}

static const char *charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

// Ported to objc from RYD browser extension
static NSString *generateUserID() {
    NSString *existingID = getUserID();
    if (existingID) return existingID;
    HBLogDebug(@"%@", @"generateUserID()");
    char userID[36 + 1];
    for (int i = 0; i < 36; ++i)
        userID[i] = charset[arc4random_uniform(62)];
    userID[36] = '\0';
    NSString *result = [NSString stringWithUTF8String:userID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:result forKey:UserIDKey];
    [defaults synchronize];
    return result;
}

// Ported to objc from RYD browser extension
static int countLeadingZeroes(uint8_t *hash) {
    int zeroes = 0;
    int value = 0;
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        value = hash[i];
        if (value == 0)
            zeroes += 8;
        else {
            int count = 1;
            if (value >> 4 == 0) {
                count += 4;
                value <<= 4;
            }
            if (value >> 6 == 0) {
                count += 2;
                value <<= 2;
            }
            zeroes += count - (value >> 7);
            break;
        }
    }
    return zeroes;
}

// Ported to objc from RYD browser extension
static NSString *btoa(NSString *input) {
    NSMutableString *output = [NSMutableString string];
    for (int i = 0; i < input.length; i += 3) {
        int groupsOfSix[4] = { -1, -1, -1, -1 };
        unichar ci = [input characterAtIndex:i];
        groupsOfSix[0] = ci >> 2;
        groupsOfSix[1] = (ci & 0x03) << 4;
        if (input.length > i + 1) {
            unichar ci1 = [input characterAtIndex:i + 1];
            groupsOfSix[1] |= ci1 >> 4;
            groupsOfSix[2] = (ci1 & 0x0f) << 2;
        }
        if (input.length > i + 2) {
            unichar ci2 = [input characterAtIndex:i + 2];
            groupsOfSix[2] |= ci2 >> 6;
            groupsOfSix[3] = ci2 & 0x3f;
        }
        for (int j = 0; j < 4; ++j) {
            if (groupsOfSix[j] == -1)
                [output appendString:@"="];
            else
                [output appendFormat:@"%c", charset[groupsOfSix[j]]];
        }
    }
    return output;
}

void fetch(
    NSString *endpoint,
    NSString *method,
    NSDictionary *body,
    void (^dataHandler)(NSDictionary *data),
    BOOL (^responseCodeHandler)(NSUInteger responseCode),
    void (^networkErrorHandler)(void),
    void (^dataErrorHandler)(void)
) {
    HBLogDebug(@"fetch() (%@, %@)", endpoint, method);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @(API_URL), endpoint]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = method;
    if (body) {
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            if (dataErrorHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    dataErrorHandler();
                });
            }
            return;
        }
        HBLogDebug(@"fetch() POST body: %@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        urlRequest.HTTPBody = data;
    } else
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSUInteger responseCode = [httpResponse statusCode];
        if (responseCodeHandler) {
            if (!responseCodeHandler(responseCode))
                return;
        }
        if (error || responseCode != 200) {
            HBLogDebug(@"fetch() error requesting: %@ (%lu)", error, responseCode);
            if (networkErrorHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    networkErrorHandler();
                });
            }
            return;
        }
        NSError *jsonError;
        NSDictionary *myData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&jsonError];
        if (jsonError) {
            HBLogDebug(@"fetch() error decoding response: %@", jsonError);
            if (dataErrorHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    dataErrorHandler();
                });
            }
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            dataHandler(myData);
        });
    }] resume];
}

// Ported to objc from RYD browser extension
static NSString *solvePuzzle(NSDictionary *data) {
    NSString *solution = nil;
    NSString *challenge = data[@"challenge"];
    int difficulty = [data[@"difficulty"] intValue];
    NSData *cd = [[NSData alloc] initWithBase64EncodedString:challenge options:0];
    NSString *decoded = [[NSString alloc] initWithData:cd encoding:NSASCIIStringEncoding];
    uint8_t c[decoded.length];
    char *buffer = (char *)calloc(20, sizeof(char));
    uint32_t *uInt32View = (uint32_t *)buffer;
    for (int i = 0; i < decoded.length; ++i)
        c[i] = [decoded characterAtIndex:i];
    int maxCount = (1 << difficulty) * 3;
    for (int i = 4; i < 20; ++i)
        buffer[i] = c[i - 4];
    for (int i = 0; i < maxCount; ++i) {
        uInt32View[0] = i;
        uint8_t hash[CC_SHA512_DIGEST_LENGTH] = {0};
        CC_SHA512(buffer, 20, hash);
        if (countLeadingZeroes(hash) >= difficulty) {
            char chars[4] = { buffer[0], buffer[1], buffer[2], buffer[3] };
            NSString *s = [[NSString alloc] initWithBytes:chars length:4 encoding:NSASCIIStringEncoding];
            solution = btoa(s);
            HBLogDebug(@"solvePuzzle() success (%@)", solution);
            break;
        }
    }
    free(buffer);
    if (!solution)
        HBLogDebug(@"%@", @"solvePuzzle() failed");
    return solution;
}

// Ported to objc from RYD browser extension
static void registerUser() {
    NSString *userId = generateUserID();
    HBLogDebug(@"registerUser() (%@)", userId);
    NSString *puzzleEndpoint = [NSString stringWithFormat:@"/puzzle/registration?userId=%@", userId];
    fetch(
        puzzleEndpoint,
        @"GET",
        nil,
        ^(NSDictionary *data) {
            NSString *solution = solvePuzzle(data);
            if (!solution) {
                HBLogDebug(@"%@", @"registerUser() skipped");
                return;
            }
            fetch(
                puzzleEndpoint,
                @"POST",
                @{ @"solution": solution },
                ^(NSDictionary *data) {
                    if ([data isKindOfClass:[NSNumber class]] && ![(NSNumber *)data boolValue]) {
                        HBLogDebug(@"%@", @"registerUser() failed");
                        return;
                    }
                    if (!isRegistered()) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RegistrationConfirmedKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    HBLogDebug(@"registerUser() success or already registered: %@", data);
                },
                NULL,
                ^() {
                    HBLogDebug(@"%@", @"registerUser() puzzle failed (network)");
                },
                ^() {
                    HBLogDebug(@"%@", @"registerUser() puzzle failed (data)");
                }
            );
        },
        NULL,
        ^() {
            HBLogDebug(@"%@", @"registerUser() failed (network)");
        },
        ^() {
            HBLogDebug(@"%@", @"registerUser() failed (data)");
        }
    );
}

// Ported to objc from RYD browser extension
void _sendVote(NSString *videoId, YTLikeStatus s, int retryCount) {
    if (retryCount <= 0) return;
    NSString *userId = getUserID();
    if (!userId || !isRegistered()) {
        registerUser();
        return;
    }
    int likeStatus = toRYDLikeStatus(s);
    HBLogDebug(@"sendVote(%@, %d)", videoId, likeStatus);
    fetch(
        @"/interact/vote",
        @"POST",
        @{
            @"userId": userId,
            @"videoId": videoId,
            @"value": @(likeStatus)
        },
        ^(NSDictionary *data) {
            NSString *solution = solvePuzzle(data);
            if (!solution) {
                HBLogDebug(@"%@", @"sendVote() skipped");
                return;
            }
            fetch(
                @"/interact/confirmVote",
                @"POST",
                @{
                    @"userId": userId,
                    @"videoId": videoId,
                    @"solution": solution
                },
                ^(NSDictionary *data) {
                    HBLogDebug(@"%@", @"sendVote() success");
                },
                NULL,
                ^() {
                    HBLogDebug(@"%@", @"sendVote() confirm failed (network)");
                },
                ^() {
                    HBLogDebug(@"%@", @"sendVote() confirm failed (data)");
                }
            );
        },
        ^BOOL(NSUInteger responseCode) {
            if (responseCode == 401) {
                HBLogDebug(@"%@", @"sendVote() error 401, trying again");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    registerUser();
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _sendVote(videoId, s, retryCount - 1);
                    });
                });
                return NO;
            }
            return YES;
        },
        ^() {
            HBLogDebug(@"%@", @"sendVote() failed (network)");
        },
        ^() {
            HBLogDebug(@"%@", @"sendVote() failed (data)");
        }
    );
}

void sendVote(NSString *videoId, YTLikeStatus s) {
    _sendVote(videoId, s, maxRetryCount);
}

%ctor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:DidResetUserIDKey]) {
        [defaults setBool:YES forKey:DidResetUserIDKey];
        NSString *userID = [defaults stringForKey:UserIDKey];
        if ([userID containsString:@"+"] || [userID containsString:@"/"]) {
            [defaults removeObjectForKey:UserIDKey];
            [defaults removeObjectForKey:RegistrationConfirmedKey];
        }
        [defaults synchronize];
    }
}
