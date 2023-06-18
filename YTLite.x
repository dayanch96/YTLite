#import "YTLite.h"

// YouTube-X (https://github.com/PoomSmart/YouTube-X/)
// Background Playback
%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground { return kBackgroundPlayback ? YES : NO; }
%end

%hook MLVideo
- (BOOL)playableInBackground { return kBackgroundPlayback ? YES : NO; }
%end

// Disable Ads
%hook YTIPlayerResponse
- (BOOL)isMonetized { return kNoAds ? NO : YES; }
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary { return kNoAds ? nil : %orig; }
+ (id)spamSignalsDictionaryWithoutIDFA { return kNoAds ? nil : %orig; }
%end

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!kNoAds) %orig; }
%end

%hook YTAccountScopedAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!kNoAds) %orig; }
%end

BOOL isAd(YTIElementRenderer *self) {
    if (self == nil) return NO;
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData) return YES;
    NSString *description = [self description];
    if (([description containsString:@"brand_promo"]
        || [description containsString:@"product_carousel"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]) && kNoAds)
        return YES;
    return NO;
}

%hook YTSectionListViewController
- (void)loadWithModel:(YTISectionListRenderer *)model {
    if (kNoAds) {
        NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
        NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
            YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
            return firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer || isAd(firstObject.elementRenderer);
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    } %orig;
}
%end

// NOYTPremium (https://github.com/PoomSmart/NoYTPremium)
// Alert
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

// Full-screen
%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromosheetEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

// "Try new features" in settings
%hook YTSettingsSectionItemManager
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)arg1 {}
%end

// Survey
%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

// Statement banner
%hook YTPremiumSeasonCardCellController
- (void)setCell:(id)arg1 { arg1 = NULL; %orig; }
%end

%hook YTPremiumSeasonCardView
- (long long)accessibilityElementCount { return 0; }
%end

// Navbar Stuff
// Disable Cast
%hook MDXPlaybackRouteButtonController
- (BOOL)isPersistentCastIconEnabled { return kNoCast ? NO : YES; }
- (void)updateRouteButton:(id)arg1 { if (!kNoCast) %orig; }
- (void)updateAllRouteButtons { if (!kNoCast) %orig; }
%end

%hook YTSettings
- (void)setDisableMDXDeviceDiscovery:(BOOL)arg1 { %orig(kNoCast); }
%end

// Hide Cast, Notifications and Search Buttons
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig;
    if (kNoCast && self.subviews.count > 1 && [self.subviews[1].accessibilityIdentifier isEqualToString:@"id.mdx.playbackroute.button"]) self.subviews[1].hidden = YES; // Hide icon immediately
    if (kNoNotifsButton) self.notificationButton.hidden = YES;
    if (kNoSearchButton) self.searchButton.hidden = YES;
}
%end

// Remove Tabs
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSDictionary *identifiersToRemove = @{
        @"FEshorts": @(kRemoveShorts),
        @"FEsubscriptions": @(kRemoveSubscriptions),
        @"FEuploads": @(kRemoveUploads),
        @"FElibrary": @(kRemoveLibrary)
    };

    for (NSString *identifier in identifiersToRemove) {
        BOOL shouldRemoveItem = [identifiersToRemove[identifier] boolValue];
        NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            if ([identifier isEqualToString:@"FEuploads"]) {
                return shouldRemoveItem && [[[renderers pivotBarIconOnlyItemRenderer] pivotIdentifier] isEqualToString:identifier];
            } else {
                return shouldRemoveItem && [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:identifier];
            }
        }];

        if (index != NSNotFound) {
            [items removeObjectAtIndex:index];
        }
    } %orig;
}
%end

// Hide Tab Labels
BOOL hasHomeBar = NO;
CGFloat pivotBarViewHeight;

%hook YTPivotBarView
- (void)layoutSubviews {
    %orig;
    pivotBarViewHeight = self.frame.size.height;
}
%end

%hook YTPivotBarItemView
- (void)layoutSubviews {
    %orig;

    CGFloat pivotBarAccessibilityControlWidth;

    if (kRemoveLabels) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"YTPivotBarItemViewAccessibilityControl")]) {
                pivotBarAccessibilityControlWidth = CGRectGetWidth(subview.frame);
                break;
            }
        }

        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"YTQTMButton")]) {
                for (UIView *buttonSubview in subview.subviews) {
                    if ([buttonSubview isKindOfClass:[UILabel class]]) {
                        [buttonSubview removeFromSuperview];
                        break;
                    }
                }

                UIImageView *imageView = nil;
                for (UIView *buttonSubview in subview.subviews) {
                    if ([buttonSubview isKindOfClass:[UIImageView class]]) {
                        imageView = (UIImageView *)buttonSubview;
                        break;
                    }
                }

                if (imageView) {
                    CGFloat imageViewHeight = imageView.image.size.height;
                    CGFloat imageViewWidth = imageView.image.size.width;
                    CGRect buttonFrame = subview.frame;

                    if (@available(iOS 13.0, *)) {
                        UIWindowScene *mainWindowScene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
                        if (mainWindowScene) {
                            UIEdgeInsets safeAreaInsets = mainWindowScene.windows.firstObject.safeAreaInsets;
                            if (safeAreaInsets.bottom > 0) {
                                hasHomeBar = YES;
                            }
                        }
                    }

                    CGFloat yOffset = hasHomeBar ? 15.0 : 0.0;
                    CGFloat xOffset = (pivotBarAccessibilityControlWidth - imageViewWidth) / 2.0;

                    buttonFrame.origin.y = (pivotBarViewHeight - imageViewHeight - yOffset) / 2.0;
                    buttonFrame.origin.x = xOffset;

                    buttonFrame.size.height = imageViewHeight;
                    buttonFrame.size.width = imageViewWidth;

                    subview.frame = buttonFrame;
                    subview.bounds = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
                }
            }
        }
    }
}
%end

static void reloadPrefs() {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"YTLite.plist"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];

    kNoAds = (prefs[@"noAds"] != nil) ? [prefs[@"noAds"] boolValue] : YES;
    kBackgroundPlayback = (prefs[@"backgroundPlayback"] != nil) ? [prefs[@"backgroundPlayback"] boolValue] : YES;
    kNoCast = [prefs[@"noCast"] boolValue] ?: NO;
    kNoNotifsButton = [prefs[@"removeNotifsButton"] boolValue] ?: NO;
    kNoSearchButton = [prefs[@"removeSearchButton"] boolValue] ?: NO;
    kRemoveLabels = [prefs[@"removeLabels"] boolValue] ?: NO;
    kRemoveShorts = [prefs[@"removeShorts"] boolValue] ?: NO;
    kRemoveSubscriptions = [prefs[@"removeSubscriptions"] boolValue] ?: NO;
    kRemoveUploads = (prefs[@"removeUploads"] != nil) ? [prefs[@"removeUploads"] boolValue] : YES;
    kRemoveLibrary = [prefs[@"removeLibrary"] boolValue] ?: NO;

    NSDictionary *newSettings = @{
        @"noAds" : @(kNoAds),
        @"backgroundPlayback" : @(kBackgroundPlayback),
        @"noCast" : @(kNoCast),
        @"removeNotifsButton" : @(kNoNotifsButton),
        @"removeSearchButton" : @(kNoSearchButton),
        @"removeLabels" : @(kRemoveLabels),
        @"removeShorts" : @(kRemoveShorts),
        @"removeSubscriptions" : @(kRemoveSubscriptions),
        @"removeUploads" : @(kRemoveUploads),
        @"removeLibrary" : @(kRemoveLibrary)
    };

    if (![newSettings isEqualToDictionary:prefs]) [newSettings writeToFile:path atomically:NO];
}

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    reloadPrefs();
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.dvntm.ytlite.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    reloadPrefs();
    %init;
}
