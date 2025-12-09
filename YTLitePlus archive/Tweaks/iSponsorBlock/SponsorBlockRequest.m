#import "Headers/SponsorBlockRequest.h"
#import "Headers/Localization.h"

@implementation SponsorBlockRequest
+ (void)getSponsorTimes:(NSString *)videoID completionTarget:(id)target completionSelector:(SEL)sel apiInstance:(NSString *)apiInstance {
    __block NSMutableArray *skipSegments = [NSMutableArray array];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *categories = @"%5B%22sponsor%22%2C%22intro%22%2C%22outro%22%2C%22interaction%22%2C%22selfpromo%22%2C%22music_offtopic%22%2C%22preview%22%2C%22poi_highlight%22%2C%22filler%22%5D";

    //NSString *categories = @"[%22sponsor%22,%20%22intro%22,%20%22outro%22,%20%22interaction%22,%20%22selfpromo%22,%20%22music_offtopic%22,%20%22preview%22,%20%22filler%22]";

    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/skipSegments?videoID=%@&categories=%@", apiInstance, videoID, categories]]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil && error == nil) {
            NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray *segments = [NSMutableArray array];
            for (NSDictionary *dict in jsonData) {
                SponsorSegment *segment = [[SponsorSegment alloc] initWithStartTime:[[dict objectForKey:@"segment"][0] floatValue] endTime:[[dict objectForKey:@"segment"][1] floatValue] category:(NSString *)[dict objectForKey:@"category"] UUID:(NSString *)[dict objectForKey:@"UUID"]];
                [segments addObject:segment];
            }
            skipSegments = [segments sortedArrayUsingComparator:^NSComparisonResult(SponsorSegment *a, SponsorSegment *b) {
                NSNumber *first = @(a.startTime);
                NSNumber *second = @(b.startTime);
                return [first compare:second];
            }].mutableCopy;
            NSMutableArray *seekBarSegments = skipSegments.mutableCopy;
            for (SponsorSegment *segment in skipSegments.copy) {
                NSInteger setting = [[kCategorySettings objectForKey:segment.category] intValue];
                switch (setting) {
                    case 0:
                        [skipSegments removeObject:segment];
                        [seekBarSegments removeObject:segment];
                        break;
                    case 2:
                        [skipSegments removeObject:segment];
                        break;
                        //only leaves the object in seekBarSegments so it appears in the seek bar but doesn't get skipped
                    default:
                        break;
                }
                if (segment.endTime - segment.startTime < kMinimumDuration) {
                    [skipSegments removeObject:segment];
                    [seekBarSegments removeObject:segment];
                }
                
            }
            [target performSelectorOnMainThread:sel withObject:skipSegments waitUntilDone:NO];
            
            if ([target isKindOfClass:objc_getClass("YTPlayerViewController")]) {
                YTPlayerViewController *playerViewController = (YTPlayerViewController *)target;
                YTPlayerView *playerView = (YTPlayerView *)playerViewController.view;
                YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
                if ([overlayView isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayView")]) {
                    id playerBar = overlayView.playerBar.playerBar;
                    if (playerBar) {
                        if ([playerBar isKindOfClass:objc_getClass("YTModularPlayerBarController")]) {
                            YTModularPlayerBarView *view = ((YTModularPlayerBarController *)playerBar).view;
                            [view performSelectorOnMainThread:@selector(setSkipSegments:) withObject:seekBarSegments waitUntilDone:NO];
                        } else {
                            [playerBar performSelectorOnMainThread:@selector(setSkipSegments:) withObject:seekBarSegments waitUntilDone:NO];
                        }
                    }
                    else {
                        [overlayView.playerBar.playerBar performSelectorOnMainThread:@selector(setSkipSegments:) withObject:seekBarSegments waitUntilDone:NO];
                    }
                }
            }
        }
    }];
    [dataTask resume];
}
+ (void)postSponsorTimes:(NSString *)videoID sponsorSegments:(NSArray <SponsorSegment *> *)segments userID:(NSString *)userID withViewController:(UIViewController *)viewController {
    for (SponsorSegment *segment in segments) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&startTime=%f&endTime=%f&category=%@&userID=%@", videoID, segment.startTime, segment.endTime, segment.category, userID]]];
        request.HTTPMethod = @"POST";
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *URLResponse = (NSHTTPURLResponse *)response;
            if (URLResponse.statusCode != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"Error") message:[NSString stringWithFormat:@"%@: %ld %@", LOC(@"ErrorCode"), URLResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:URLResponse.statusCode]] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:LOC(@"OK") style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [viewController presentViewController:alert animated:YES completion:nil];
                });
                return;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"Success") message:LOC(@"SuccessfullySubmittedSegments") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:LOC(@"OK") style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [viewController presentViewController:alert animated:YES completion:nil];
                });
            }
        }];
        [dataTask resume];
    }
}
+ (void)normalVoteForSegment:(SponsorSegment *)segment userID:(NSString *)userID type:(BOOL)type withViewController:(UIViewController *)viewController {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/voteOnSponsorTime?UUID=%@&userID=%@&type=%d", segment.UUID, userID, type]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *URLResponse = (NSHTTPURLResponse *)response;
        NSString *title;
        CGFloat delay;
        if (URLResponse.statusCode != 200) {
            title = [NSString stringWithFormat:@"%@: (%ld %@)", LOC(@"ErrorVoting"), URLResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:URLResponse.statusCode]];
            delay = 3.0f;
        }
        else {
            title = LOC(@"SuccessfullyVoted");
            delay = 1.0f;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = title;
        hud.offset = CGPointMake(0.f, 50);
        [hud hideAnimated:YES afterDelay:delay];
        });
    }];
    [dataTask resume];
}
+ (void)categoryVoteForSegment:(SponsorSegment *)segment userID:(NSString *)userID category:(NSString *)category withViewController:(UIViewController *)viewController {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/voteOnSponsorTime?UUID=%@&userID=%@&category=%@", segment.UUID, userID, category]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *URLResponse = (NSHTTPURLResponse *)response;
        NSString *title;
        CGFloat delay;
        if (URLResponse.statusCode != 200) {
            title = [NSString stringWithFormat:@"%@: (%ld %@)", LOC(@"ErrorVoting"), URLResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:URLResponse.statusCode]];
            delay = 3.0f;
        }
        else {
            title = LOC(@"SuccessfullyVoted");
            delay = 1.0f;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = title;
        hud.offset = CGPointMake(0.f, 50);
        [hud hideAnimated:YES afterDelay:delay];
        });
    }];
    [dataTask resume];
}
+ (void)viewedVideoSponsorTime:(SponsorSegment *)segment {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/viewedVideoSponsorTime?UUID=%@", segment.UUID]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    [dataTask resume];
}
@end
