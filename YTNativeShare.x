/* YouTube Native Share - An iOS Tweak to replace YouTube's share sheet and remove source identifiers.
 * Copyright (C) 2024 YouTube Native Share Contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// Source code can be found here: https://github.com/jkhsjdhjs/youtube-native-share (Thanks to @jkhsjdhjs)

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "Utils/YTLUserDefaults.h"
#import "Utils/YTLSafeMode.h"

#define ytlBool(key) [[YTLUserDefaults standardUserDefaults] boolForKey:key]

typedef NS_ENUM(NSInteger, ShareEntityType) {
    ShareEntityFieldVideo = 1,
    ShareEntityFieldPlaylist = 2,
    ShareEntityFieldChannel = 3,
    ShareEntityFieldClip = 8
};

@interface ELMPBShowActionSheetCommand : NSObject
@end

static id YTLGPBExtensionOfClass(id message, NSString *className, NSUInteger depth) {
    if (!message || depth > 4) return nil;
    if ([NSStringFromClass([message class]) isEqualToString:className]) return message;
    if (![message respondsToSelector:@selector(extensionsCurrentlySet)] || ![message respondsToSelector:@selector(getExtension:)]) return nil;

    NSArray *extensions = nil;
    @try {
        extensions = [message performSelector:@selector(extensionsCurrentlySet)];
    } @catch (NSException *exception) {
        return nil;
    }

    for (id descriptor in extensions) {
        if (![descriptor respondsToSelector:@selector(msgClass)]) continue;
        Class msgClass = ((Class (*)(id, SEL))objc_msgSend)(descriptor, @selector(msgClass));
        if (!msgClass) continue;

        id value = nil;
        @try {
            value = [message performSelector:@selector(getExtension:) withObject:descriptor];
        } @catch (NSException *exception) {
            continue;
        }

        id found = YTLGPBExtensionOfClass(value, className, depth + 1);
        if (found) return found;
    }

    return nil;
}

static BOOL YTLReadVarint(const uint8_t *bytes, NSUInteger length, NSUInteger *offset, uint64_t *value) {
    uint64_t result = 0;
    for (int shift = 0; shift < 64 && *offset < length; shift += 7) {
        uint8_t byte = bytes[(*offset)++];
        result |= (uint64_t)(byte & 0x7F) << shift;
        if (!(byte & 0x80)) {
            *value = result;
            return YES;
        }
    }
    return NO;
}

static NSDictionary <NSNumber *, NSData *> *YTLProtobufStrings(NSData *data) {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    const uint8_t *bytes = data.bytes;
    NSUInteger length = data.length, offset = 0;

    while (offset < length) {
        uint64_t key = 0;
        if (!YTLReadVarint(bytes, length, &offset, &key)) break;

        uint64_t number = key >> 3, value = 0;
        switch (key & 0x7) {
            case 0:
                if (!YTLReadVarint(bytes, length, &offset, &value)) return fields;
                break;
            case 1:
                offset += 8;
                break;
            case 2:
                if (!YTLReadVarint(bytes, length, &offset, &value) || value > length - offset) return fields;
                if (!fields[@(number)]) fields[@(number)] = [data subdataWithRange:NSMakeRange(offset, (NSUInteger)value)];
                offset += (NSUInteger)value;
                break;
            case 5:
                offset += 4;
                break;
            default:
                return fields;
        }
    }

    return fields;
}

static NSData *YTLShareEntityData(NSString *serialized) {
    Class GPBMessageClass = NSClassFromString(@"GPBMessage");
    if ([GPBMessageClass respondsToSelector:@selector(deserializeFromString:)]) {
        @try {
            id message = [GPBMessageClass performSelector:@selector(deserializeFromString:) withObject:serialized];
            if ([message respondsToSelector:@selector(data)]) {
                NSData *data = [message performSelector:@selector(data)];
                if (data.length) return data;
            }
        } @catch (NSException *exception) {}
    }

    NSString *base64 = [serialized stringByRemovingPercentEncoding] ?: serialized;
    base64 = [base64 stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    while (base64.length % 4) base64 = [base64 stringByAppendingString:@"="];
    return [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

static NSString *YTLString(NSData *data) {
    NSString *string = data.length ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
    return string.length ? string : nil;
}

static NSString *YTLShareURL(NSString *serialized) {
    NSData *data = YTLShareEntityData(serialized);
    if (!data.length) return nil;

    NSDictionary <NSNumber *, NSData *> *fields = YTLProtobufStrings(data);

    NSData *clip = fields[@(ShareEntityFieldClip)];
    if (clip) {
        NSString *clipID = YTLString(YTLProtobufStrings(clip)[@1]);
        if (clipID) return [@"https://youtube.com/clip/" stringByAppendingString:clipID];
    }

    NSString *channelID = YTLString(fields[@(ShareEntityFieldChannel)]);
    if (channelID) return [@"https://youtube.com/channel/" stringByAppendingString:channelID];

    NSString *playlistID = YTLString(fields[@(ShareEntityFieldPlaylist)]);
    if (playlistID) {
        if (![playlistID hasPrefix:@"PL"] && ![playlistID hasPrefix:@"FL"])
            playlistID = [playlistID stringByAppendingString:@"&playnext=1"];
        return [@"https://youtube.com/playlist?list=" stringByAppendingString:playlistID];
    }

    NSString *videoID = YTLString(fields[@(ShareEntityFieldVideo)]);
    if (videoID) return [@"https://youtube.com/watch?v=" stringByAppendingString:videoID];

    return nil;
}

static UIViewController *YTLTopViewController(void) {
    Class utils = NSClassFromString(@"YTUIUtils");
    if ([utils respondsToSelector:@selector(topViewControllerForPresenting)]) {
        UIViewController *vc = [utils performSelector:@selector(topViewControllerForPresenting)];
        if (vc) return vc;
    }

    UIViewController *vc = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) vc = window.rootViewController;
        }
    }
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

%hook ELMPBShowActionSheetCommand
- (void)executeWithCommandContext:(id)context handler:(id)handler {
    if (!ytlBool(@"nativeShare"))
        return %orig;

    id onAppear = [self respondsToSelector:@selector(onAppear)] ? [self performSelector:@selector(onAppear)] : nil;
    id shareCommand = YTLGPBExtensionOfClass(onAppear, @"YTIUpdateShareSheetCommand", 0);
    if (![shareCommand respondsToSelector:@selector(serializedShareEntity)])
        return %orig;

    NSString *serialized = [shareCommand performSelector:@selector(serializedShareEntity)];
    NSString *shareURL = serialized.length ? YTLShareURL(serialized) : nil;
    UIViewController *presentingVC = YTLTopViewController();
    if (!shareURL || !presentingVC)
        return %orig;

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:shareURL] ?: shareURL] applicationActivities:nil];
    if (activityViewController.popoverPresentationController) {
        activityViewController.popoverPresentationController.sourceView = presentingVC.view;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(presentingVC.view.bounds), CGRectGetMidY(presentingVC.view.bounds), 0, 0);
        activityViewController.popoverPresentationController.permittedArrowDirections = 0;
    }
    [presentingVC presentViewController:activityViewController animated:YES completion:nil];
}
%end

%ctor {
    if (YTLSafeModeActive()) return;
    %init;
}
