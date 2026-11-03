#import "YTLite.h"
#import "Utils/YTLSafeMode.h"
#import <AVFoundation/AVFoundation.h>

static __weak YTPlayerViewController *ytlWatchPlayer;
static const NSInteger kDownloadButtonTag = 998;
static const long long kChunkSize = 10 * 1024 * 1024;

static UIImage *YTLIcon(NSString *name) {
    return [UIImage imageNamed:name inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

static NSString *YTLStringValue(id object, NSString *key) {
    id value = YTLValue(object, key);
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

static BOOL YTLBoolValue(id object, NSString *key) {
    id value = YTLValue(object, key);
    return [value respondsToSelector:@selector(boolValue)] && [value boolValue];
}

static long long YTLLongValue(id object, NSString *key) {
    id value = YTLValue(object, key);
    return [value respondsToSelector:@selector(longLongValue)] ? [value longLongValue] : 0;
}

static id YTLPlayerDetails(YTPlayerViewController *player) {
    id response = YTLValue(player, @"contentPlayerResponse") ?: YTLValue(player, @"playerResponse");
    id data = [response respondsToSelector:@selector(playerData)] ? YTLValue(response, @"playerData") : response;
    return YTLValue(data, @"videoDetails");
}

static NSString *YTLSafeFileName(NSString *name) {
    NSCharacterSet *invalid = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:\n\r\t"];
    NSString *clean = [[name componentsSeparatedByCharactersInSet:invalid] componentsJoinedByString:@" "];
    clean = [clean stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (clean.length > 80) clean = [clean substringToIndex:80];
    return clean.length ? clean : @"video";
}

static NSString *YTLMime(id format) {
    return YTLStringValue(YTLValue(format, @"formatStream"), @"mimeType") ?: [YTLValue(format, @"MIMEType") description] ?: @"";
}

static NSURL *YTLFormatURL(id format) {
    id url = YTLValue(format, @"URL");
    if ([url isKindOfClass:[NSURL class]]) return url;
    NSString *string = YTLStringValue(YTLValue(format, @"formatStream"), @"URL");
    return string.length ? [NSURL URLWithString:string] : nil;
}

static long long YTLFormatLength(id format) {
    return YTLLongValue(YTLValue(format, @"formatStream"), @"contentLength");
}

static NSArray *YTLVideoFormats(YTPlayerViewController *player) {
    NSArray *formats = YTLValue(YTLValue(player, @"activeVideo"), @"selectableVideoFormats");
    NSMutableDictionary <NSString *, id> *byLabel = [NSMutableDictionary dictionary];

    for (id format in [formats isKindOfClass:[NSArray class]] ? formats : @[]) {
        NSString *mime = YTLMime(format);
        NSString *label = YTLStringValue(format, @"qualityLabel");
        if (!label.length || ![mime containsString:@"mp4"] || ![mime containsString:@"avc1"] || !YTLFormatURL(format)) continue;

        id existing = byLabel[label];
        if (!existing || YTLLongValue(format, @"bitrate") > YTLLongValue(existing, @"bitrate")) byLabel[label] = format;
    }

    return [byLabel.allValues sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [@(YTLLongValue(b, @"singleDimensionResolution")) compare:@(YTLLongValue(a, @"singleDimensionResolution"))];
    }];
}

static id YTLAudioFormat(YTPlayerViewController *player) {
    id video = YTLValue(player, @"activeVideo");
    NSArray *formats = YTLValue(video, @"selectableAudioFormats");
    NSString *selectedTrack = YTLStringValue(YTLValue(video, @"selectedAudioFormat"), @"audioTrackID");
    id best = nil;
    NSInteger bestScore = -1;

    for (id format in [formats isKindOfClass:[NSArray class]] ? formats : @[]) {
        NSString *mime = YTLMime(format);
        if (![mime containsString:@"mp4"] || !YTLFormatURL(format)) continue;

        NSInteger score = (NSInteger)(YTLLongValue(format, @"bitrate") / 1000);
        NSString *track = YTLStringValue(format, @"audioTrackID");
        if (selectedTrack.length && [track isEqualToString:selectedTrack]) score += 1000000;
        else if (YTLBoolValue(format, @"isDefaultAudio")) score += 500000;

        if (score > bestScore) {
            bestScore = score;
            best = format;
        }
    }
    return best;
}

@interface YTLDownloadTask : NSObject
@property (nonatomic, strong) UIAlertController *alert;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, assign) long long totalBytes;
@property (nonatomic, assign) long long doneBytes;
@property (nonatomic, copy) NSString *status;
@end

@implementation YTLDownloadTask
- (void)updateProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *percent = self.totalBytes > 0 ? [NSString stringWithFormat:@"%d%%", (int)(100.0 * self.doneBytes / self.totalBytes)] : @"…";
        self.alert.message = [NSString stringWithFormat:@"%@\n%@", self.status ?: @"", percent];
    });
}

- (void)downloadURL:(NSURL *)url length:(long long)length to:(NSURL *)file completion:(void (^)(NSError *error))completion {
    [[NSFileManager defaultManager] createFileAtPath:file.path contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:file.path];
    if (!handle) {
        completion([NSError errorWithDomain:@"YTLite" code:1 userInfo:@{NSLocalizedDescriptionKey: @"file"}]);
        return;
    }

    __block long long offset = 0;
    __block void (^next)(void);
    __weak typeof(self) weakSelf = self;

    next = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.cancelled) {
            [handle closeFile];
            completion([NSError errorWithDomain:@"YTLite" code:NSUserCancelledError userInfo:nil]);
            next = nil;
            return;
        }

        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSMutableArray *items = [components.queryItems mutableCopy] ?: [NSMutableArray array];
        long long end = length > 0 ? MIN(offset + kChunkSize, length) - 1 : offset + kChunkSize - 1;
        [items addObject:[NSURLQueryItem queryItemWithName:@"range" value:[NSString stringWithFormat:@"%lld-%lld", offset, end]]];
        components.queryItems = items;

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL ?: url];
        request.timeoutInterval = 30;

        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)response).statusCode : 0;
            if (error || (status != 200 && status != 206) || data.length == 0) {
                [handle closeFile];
                completion(error ?: [NSError errorWithDomain:@"YTLite" code:status userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP %ld", (long)status]}]);
                next = nil;
                return;
            }

            [handle writeData:data];
            offset += data.length;
            weakSelf.doneBytes += data.length;
            [weakSelf updateProgress];

            BOOL finished = length > 0 ? offset >= length : (long long)data.length < kChunkSize;
            if (finished) {
                [handle closeFile];
                completion(nil);
                next = nil;
            } else {
                next();
            }
        }] resume];
    };

    next();
}
@end

static NSURL *YTLDownloadsDirectory(void) {
    NSURL *dir = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"YTLiteDownloads" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

static void YTLShareFile(NSURL *file, UIViewController *presenter) {
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[file] applicationActivities:nil];
    activity.completionWithItemsHandler = ^(UIActivityType type, BOOL completed, NSArray *items, NSError *error) {
        if (completed || !type) [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
    };
    if (activity.popoverPresentationController) {
        activity.popoverPresentationController.sourceView = presenter.view;
        activity.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(presenter.view.bounds), CGRectGetMidY(presenter.view.bounds), 0, 0);
        activity.popoverPresentationController.permittedArrowDirections = 0;
    }
    [presenter presentViewController:activity animated:YES completion:nil];
}

static void YTLFinish(YTLDownloadTask *task, UIViewController *presenter, NSURL *file, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [task.alert dismissViewControllerAnimated:YES completion:^{
            if (error) {
                if (error.code != NSUserCancelledError) {
                    NSString *message = [NSString stringWithFormat:@"%@: %@", LOC(@"DownloadFailed"), error.localizedDescription ?: @"?"];
                    [[YTLClass(@"YTToastResponderEvent") eventWithMessage:message firstResponder:presenter] send];
                }
                return;
            }
            YTLShareFile(file, presenter);
        }];
    });
}

static void YTLMux(NSURL *videoFile, NSURL *audioFile, NSURL *output, void (^completion)(NSError *error)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AVURLAsset *video = [AVURLAsset URLAssetWithURL:videoFile options:nil];
    AVURLAsset *audio = [AVURLAsset URLAssetWithURL:audioFile options:nil];
    AVAssetTrack *videoTrack = [[video tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *audioTrack = [[audio tracksWithMediaType:AVMediaTypeAudio] firstObject];
#pragma clang diagnostic pop

    if (!videoTrack || !audioTrack) {
        completion([NSError errorWithDomain:@"YTLite" code:2 userInfo:@{NSLocalizedDescriptionKey: @"tracks"}]);
        return;
    }

    AVMutableComposition *composition = [AVMutableComposition composition];
    NSError *error = nil;
    CMTime duration = CMTimeMinimum(video.duration, audio.duration);
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, CMTIME_IS_VALID(duration) && CMTimeGetSeconds(duration) > 0 ? duration : video.duration);

    AVMutableCompositionTrack *compVideo = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compVideo insertTimeRange:range ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    compVideo.preferredTransform = videoTrack.preferredTransform;
    if (!error) {
        AVMutableCompositionTrack *compAudio = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compAudio insertTimeRange:range ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    }
    if (error) {
        completion(error);
        return;
    }

    [[NSFileManager defaultManager] removeItemAtURL:output error:nil];
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
    export.outputURL = output;
    export.outputFileType = AVFileTypeMPEG4;
    export.shouldOptimizeForNetworkUse = YES;
    [export exportAsynchronouslyWithCompletionHandler:^{
        completion(export.status == AVAssetExportSessionStatusCompleted ? nil : (export.error ?: [NSError errorWithDomain:@"YTLite" code:3 userInfo:@{NSLocalizedDescriptionKey: @"export"}]));
    }];
}

static YTLDownloadTask *YTLStartTask(UIViewController *presenter) {
    YTLDownloadTask *task = [YTLDownloadTask new];
    task.status = LOC(@"Downloading");
    task.alert = [UIAlertController alertControllerWithTitle:LOC(@"Download") message:@"…" preferredStyle:UIAlertControllerStyleAlert];
    __weak YTLDownloadTask *weakTask = task;
    [task.alert addAction:[UIAlertAction actionWithTitle:LOC(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        weakTask.cancelled = YES;
    }]];
    [presenter presentViewController:task.alert animated:YES completion:nil];
    objc_setAssociatedObject(task.alert, @selector(YTLStartTask), task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return task;
}

static void YTLDownloadVideo(YTPlayerViewController *player, id videoFormat, UIViewController *presenter) {
    id audioFormat = YTLAudioFormat(player);
    NSURL *videoURL = YTLFormatURL(videoFormat), *audioURL = YTLFormatURL(audioFormat);
    if (!videoURL || !audioURL) {
        [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"StreamUnavailable") firstResponder:presenter] send];
        return;
    }

    NSString *name = YTLSafeFileName(YTLStringValue(YTLPlayerDetails(player), @"title") ?: player.contentVideoID);
    NSURL *dir = YTLDownloadsDirectory();
    NSURL *videoFile = [dir URLByAppendingPathComponent:@"video.part.mp4"];
    NSURL *audioFile = [dir URLByAppendingPathComponent:@"audio.part.m4a"];
    NSURL *output = [dir URLByAppendingPathComponent:[name stringByAppendingPathExtension:@"mp4"]];

    YTLDownloadTask *task = YTLStartTask(presenter);
    long long videoLength = YTLFormatLength(videoFormat), audioLength = YTLFormatLength(audioFormat);
    task.totalBytes = videoLength + audioLength;

    void (^cleanup)(void) = ^{
        [[NSFileManager defaultManager] removeItemAtURL:videoFile error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:audioFile error:nil];
    };

    [task downloadURL:videoURL length:videoLength to:videoFile completion:^(NSError *error) {
        if (error) { cleanup(); YTLFinish(task, presenter, nil, error); return; }
        [task downloadURL:audioURL length:audioLength to:audioFile completion:^(NSError *error) {
            if (error) { cleanup(); YTLFinish(task, presenter, nil, error); return; }
            task.status = LOC(@"Saving");
            [task updateProgress];
            YTLMux(videoFile, audioFile, output, ^(NSError *error) {
                cleanup();
                YTLFinish(task, presenter, output, error);
            });
        }];
    }];
}

static void YTLDownloadAudio(YTPlayerViewController *player, UIViewController *presenter) {
    id audioFormat = YTLAudioFormat(player);
    NSURL *audioURL = YTLFormatURL(audioFormat);
    if (!audioURL) {
        [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"StreamUnavailable") firstResponder:presenter] send];
        return;
    }

    NSString *name = YTLSafeFileName(YTLStringValue(YTLPlayerDetails(player), @"title") ?: player.contentVideoID);
    NSURL *output = [YTLDownloadsDirectory() URLByAppendingPathComponent:[name stringByAppendingPathExtension:@"m4a"]];
    YTLDownloadTask *task = YTLStartTask(presenter);
    task.totalBytes = YTLFormatLength(audioFormat);

    [task downloadURL:audioURL length:task.totalBytes to:output completion:^(NSError *error) {
        if (error) [[NSFileManager defaultManager] removeItemAtURL:output error:nil];
        YTLFinish(task, presenter, output, error);
    }];
}

static void YTLDownloadThumbnail(NSString *videoID, UIViewController *presenter) {
    NSArray *names = @[@"maxresdefault.jpg", @"sddefault.jpg", @"hqdefault.jpg"];
    __block void (^attempt)(NSUInteger);
    attempt = ^(NSUInteger index) {
        if (index >= names.count) {
            [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"DownloadFailed") firstResponder:presenter] send];
            attempt = nil;
            return;
        }
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/%@", videoID, names[index]]];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            UIImage *image = data ? [UIImage imageWithData:data] : nil;
            NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)response).statusCode : 0;
            if (!image || status != 200 || image.size.width <= 120) {
                attempt(index + 1);
                return;
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = success ? LOC(@"Saved") : [NSString stringWithFormat:@"%@: %@", LOC(@"Error"), error.localizedDescription ?: @"?"];
                    [[YTLClass(@"YTToastResponderEvent") eventWithMessage:message firstResponder:presenter] send];
                });
            }];
            attempt = nil;
        }] resume];
    };
    attempt(0);
}

void YTLPresentDownloadMenu(UIViewController *presenter) {
    YTPlayerViewController *player = ytlWatchPlayer;
    NSString *videoID = player.contentVideoID;
    if (!player || !videoID.length || !presenter) {
        [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"StreamUnavailable") firstResponder:presenter] send];
        return;
    }

    YTDefaultSheetController *sheet = [YTLClass(@"YTDefaultSheetController") sheetControllerWithParentResponder:nil];

    for (id format in YTLVideoFormats(player)) {
        NSString *title = [NSString stringWithFormat:@"%@ %@", LOC(@"DownloadVideo"), YTLStringValue(format, @"qualityLabel")];
        [sheet addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:title iconImage:YTLIcon(@"yt_outline_download_24pt") style:0 handler:^{
            YTLDownloadVideo(player, format, presenter);
        }]];
    }

    [sheet addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:LOC(@"DownloadAudio") iconImage:YTLIcon(@"yt_outline_audio_24pt") style:0 handler:^{
        YTLDownloadAudio(player, presenter);
    }]];

    [sheet addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:LOC(@"DownloadThumbnail") iconImage:YTLIcon(@"yt_outline_image_24pt") style:0 handler:^{
        YTLDownloadThumbnail(videoID, presenter);
    }]];

    [sheet presentFromViewController:presenter animated:YES completion:nil];
}

static void YTLTrackPlayer(YTPlayerViewController *player) {
    if (player.view.window && [player.view.superview isKindOfClass:NSClassFromString(@"YTWatchView")]) ytlWatchPlayer = player;
}

%hook YTPlayerViewController
- (void)potentiallyMutatedSingleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;
    YTLTrackPlayer(self);
}

- (void)singleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;
    YTLTrackPlayer(self);
}
%end

%hook YTEngagementPanelView
- (void)layoutSubviews {
    %orig;

    if (!ytlBool(@"downloadButton") || !self.headerView || [self.headerView viewWithTag:kDownloadButtonTag]) return;
    if (![self.panelIdentifier.identifierString isEqualToString:@"video-description-ep-identifier"]) return;

    YTQTMButton *button = [YTLClass(@"YTQTMButton") iconButton];
    if (!button) return;
    button.tag = kDownloadButtonTag;
    button.accessibilityLabel = LOC(@"Download");
    if ([button respondsToSelector:@selector(enableNewTouchFeedback)]) [button enableNewTouchFeedback];
    [button setImage:YTLIcon(@"yt_outline_download_24pt") forState:UIControlStateNormal];
    [button setTintColor:[UIColor labelColor]];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(ytl_didTapDownload:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:button];

    CGFloat offset = ytlBool(@"copyVideoInfo") ? -88 : -48;
    [NSLayoutConstraint activateConstraints:@[
        [button.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:offset],
        [button.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [button.widthAnchor constraintEqualToConstant:40.0],
        [button.heightAnchor constraintEqualToConstant:40.0]
    ]];
}

%new
- (void)ytl_didTapDownload:(UIButton *)sender {
    UIViewController *presenter = [YTLClass(@"YTUIUtils") topViewControllerForPresenting];
    YTLPresentDownloadMenu(presenter);
}
%end

%ctor {
    if (YTLSafeModeActive()) return;
    %init;
}
