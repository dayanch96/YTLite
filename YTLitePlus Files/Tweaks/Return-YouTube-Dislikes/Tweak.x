#import <HBLog.h>
#import <UIKit/UIKit.h>
#import "API.h"
#import "Settings.h"
#import "Shared.h"
#import "Tweak.h"
#import "TweakSettings.h"
#import "Vote.h"

static NSCache <NSString *, NSDictionary *> *cache;

extern NSBundle *RYDBundle();

%hook YTReelWatchLikesController

- (void)updateLikeButtonWithRenderer:(YTILikeButtonRenderer *)renderer {
    %orig;
    if (!TweakEnabled()) return;
    YTQTMButton *dislikeButton = self.dislikeButton;
    [dislikeButton setTitle:FETCHING forState:UIControlStateNormal];
    [dislikeButton setTitle:FETCHING forState:UIControlStateSelected];
    YTLikeStatus likeStatus = renderer.likeStatus;
    getVoteFromVideoWithHandler(cache, renderer.target.videoId, maxRetryCount, ^(NSDictionary *data, NSString *error) {
        NSString *formattedDislikeCount = getNormalizedDislikes(getDislikeData(data), error);
        NSString *formattedToggledDislikeCount = getNormalizedDislikes(@([getDislikeData(data) unsignedIntegerValue] + 1), error);
        YTIFormattedString *formattedText = [%c(YTIFormattedString) formattedStringWithString:formattedDislikeCount];
        YTIFormattedString *formattedToggledText = [%c(YTIFormattedString) formattedStringWithString:formattedToggledDislikeCount];
        if (renderer.hasDislikeCountText)
            renderer.dislikeCountText = formattedText;
        if (renderer.hasDislikeCountWithDislikeText)
            renderer.dislikeCountWithDislikeText = formattedToggledText;
        if (renderer.hasDislikeCountWithUndislikeText)
            renderer.dislikeCountWithUndislikeText = formattedText;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (likeStatus == YTLikeStatusDislike) {
                [dislikeButton setTitle:[renderer.dislikeCountWithUndislikeText stringWithFormattingRemoved] forState:UIControlStateNormal];
                [dislikeButton setTitle:[renderer.dislikeCountText stringWithFormattingRemoved] forState:UIControlStateSelected];
            } else {
                [dislikeButton setTitle:[renderer.dislikeCountText stringWithFormattingRemoved] forState:UIControlStateNormal];
                [dislikeButton setTitle:[renderer.dislikeCountWithDislikeText stringWithFormattingRemoved] forState:UIControlStateSelected];
            }
        });
        if ((ExactLikeNumber() || UseRYDLikeData()) && error == nil) {
            YTQTMButton *likeButton = self.likeButton;
            NSString *formattedLikeCount = getNormalizedLikes(getLikeData(data), nil);
            NSString *formattedToggledLikeCount = getNormalizedDislikes(@([getLikeData(data) unsignedIntegerValue] + 1), nil);
            YTIFormattedString *formattedText = [%c(YTIFormattedString) formattedStringWithString:formattedLikeCount];
            YTIFormattedString *formattedToggledText = [%c(YTIFormattedString) formattedStringWithString:formattedToggledLikeCount];
            if (renderer.hasLikeCountText)
                renderer.likeCountText = formattedText;
            if (renderer.hasLikeCountWithLikeText)
                renderer.likeCountWithLikeText = formattedToggledText;
            if (renderer.hasLikeCountWithUnlikeText)
                renderer.likeCountWithUnlikeText = formattedText;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (likeStatus == YTLikeStatusLike) {
                    [likeButton setTitle:[renderer.likeCountWithUnlikeText stringWithFormattingRemoved] forState:UIControlStateNormal];
                    [likeButton setTitle:[renderer.likeCountText stringWithFormattingRemoved] forState:UIControlStateSelected];
                } else {
                    [likeButton setTitle:[renderer.likeCountText stringWithFormattingRemoved] forState:UIControlStateNormal];
                    [likeButton setTitle:[renderer.likeCountWithLikeText stringWithFormattingRemoved] forState:UIControlStateSelected];
                }
            });
        }
    });
}

%end

%hook YTLikeService

- (void)notifyVideoLikeStatus:(YTLikeStatus)likeStatus withID:(NSString *)videoId {
    if (TweakEnabled() && VoteSubmissionEnabled())
        sendVote(videoId, likeStatus);
    %orig;
}

- (void)notifyPlaylistLikeStatus:(YTLikeStatus)likeStatus withID:(NSString *)playlistId {
    if (TweakEnabled() && VoteSubmissionEnabled())
        sendVote(playlistId, likeStatus);
    %orig;
}

%end

%hook YTLikeServiceImpl

- (void)notifyVideoLikeStatus:(YTLikeStatus)likeStatus withID:(NSString *)videoId {
    if (TweakEnabled() && VoteSubmissionEnabled())
        sendVote(videoId, likeStatus);
    %orig;
}

- (void)notifyPlaylistLikeStatus:(YTLikeStatus)likeStatus withID:(NSString *)playlistId {
    if (TweakEnabled() && VoteSubmissionEnabled())
        sendVote(playlistId, likeStatus);
    %orig;
}

%end

int overrideNodeCreation = 0;

static BOOL isVideoScrollableActionBar(ASCollectionView *collectionView) {
    return [collectionView.accessibilityIdentifier isEqualToString:@"id.video.scrollable_action_bar"];
}

__strong ELMTextNode *likeTextNode = nil;
__strong YTRollingNumberNode *likeRollingNumberNode = nil;
__strong ELMTextNode *dislikeTextNode = nil;
__strong YTRollingNumberNode *dislikeRollingNumberNode = nil;
__strong NSMutableAttributedString *mutableDislikeText = nil;

static NSString *getVideoId(ASDisplayNode *containerNode) {
    UIViewController *vc = [containerNode closestViewController];
    if (![vc isKindOfClass:%c(YTWatchNextResultsViewController)]) return nil;
    YTPlayerViewController *pvc;
    NSObject *wc;
    @try {
        wc = [vc valueForKey:@"_metadataPanelStateProvider"];
    } @catch (id ex) {
        wc = [vc valueForKey:@"_ngwMetadataPanelStateProvider"];
    }
    @try {
        YTWatchPlaybackController *wpc = ((YTWatchController *)wc).watchPlaybackController;
        pvc = [wpc valueForKey:@"_playerViewController"];
    } @catch (id ex) {
        pvc = [wc valueForKey:@"_playerViewController"];
    }
    return [pvc contentVideoID];
}

static void getVoteAndModifyButtons(
    NSString *videoId,
    int pairMode,
    void (^likeHandler)(NSString *likeCount, NSNumber *likeNumber),
    void (^dislikeHandler)(NSString *dislikeCount, NSNumber *dislikeNumber)
) {
    getVoteFromVideoWithHandler(cache, videoId, maxRetryCount, ^(NSDictionary *data, NSString *error) {
        HBLogDebug(@"RYD: Vote data for video %@: %@", videoId, data);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ((ExactLikeNumber() || UseRYDLikeData()) && error == nil) {
                NSNumber *likeNumber = getLikeData(data);
                NSString *likeCount = getNormalizedLikes(likeNumber, nil);
                if (likeCount && likeHandler) {
                    HBLogDebug(@"RYD: Set like count for %@ to %@", videoId, likeCount);
                    likeHandler(likeCount, likeNumber);
                }
            }
            NSNumber *dislikeNumber = getDislikeData(data);
            NSString *dislikeCount = getNormalizedDislikes(dislikeNumber, error);
            if (dislikeHandler) {
                HBLogDebug(@"RYD: Set dislike count for %@ to %@", videoId, dislikeCount);
                dislikeHandler(dislikeCount, dislikeNumber);
            }
        });
    });
}

static YTCommonColorPalette *currentColorPalette() {
    Class YTPageStyleControllerClass = %c(YTPageStyleController);
    if (YTPageStyleControllerClass)
        return [YTPageStyleControllerClass currentColorPalette];
    YTAppDelegate *delegate = (YTAppDelegate *)[UIApplication sharedApplication].delegate;
    YTAppViewController *appViewController = [delegate valueForKey:@"_appViewController"];
    NSInteger pageStyle = [appViewController pageStyle];
    Class YTCommonColorPaletteClass = %c(YTCommonColorPalette);
    if (YTCommonColorPaletteClass)
        return pageStyle == 1 ? [YTCommonColorPaletteClass darkPalette] : [YTCommonColorPaletteClass lightPalette];
    return [%c(YTColorPalette) colorPaletteForPageStyle:pageStyle];
}

static void setTextColor(NSMutableAttributedString *text) {
    if (text == nil) return;
    UIColor *color = [currentColorPalette() textPrimary];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length)];
}

%hook ASCollectionView

- (ELMCellNode *)nodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ELMCellNode *node = %orig;
    if (isVideoScrollableActionBar(self) && TweakEnabled()) {
        int pairMode = -1;
        BOOL isDislikeButtonModified = NO;
        ASDisplayNode *containerNode = node;
        ELMContainerNode *likeNode;
        
        if (![containerNode isKindOfClass:%c(ELMCellNode)]) return node;
        
        do {
            containerNode = [containerNode.yogaChildren firstObject];
            if (containerNode.yogaChildren.count == 2)
                containerNode = containerNode.yogaChildren[1];
        } while (containerNode.yogaChildren.count == 1);
        
        likeNode = [containerNode.yogaChildren firstObject];
        if (![likeNode.accessibilityIdentifier isEqualToString:@"id.video.like.button"]) {
            HBLogDebug(@"RYD: Like button not found, instead found %@", likeNode.accessibilityIdentifier);
            return node;
        }
        NSString *videoId = getVideoId(containerNode);
        if (videoId == nil) return node;
        if (likeNode.yogaChildren.count == 2) {
            ELMContainerNode *dislikeNode = [containerNode.yogaChildren lastObject];
            isDislikeButtonModified = dislikeNode.yogaChildren.count == 2;
            id targetNode = likeNode.yogaChildren[1];
            if ([targetNode isKindOfClass:%c(YTRollingNumberNode)]) {
                likeRollingNumberNode = (YTRollingNumberNode *)targetNode;
                if (isDislikeButtonModified)
                    dislikeRollingNumberNode = dislikeNode.yogaChildren[1];
                else {
                    id elementContext = [likeRollingNumberNode valueForKey:@"_context"];
                    overrideNodeCreation = 1;
                    dislikeRollingNumberNode = [[%c(ELMNodeFactory) sharedInstance] nodeWithElement:likeRollingNumberNode.element materializationContext:&elementContext];
                    overrideNodeCreation = 0;
                    dislikeRollingNumberNode.updatedCount = FETCHING;
                    dislikeRollingNumberNode.updatedCountNumber = @(0);
                    [dislikeRollingNumberNode updateRollingNumberView];
                    [dislikeNode addYogaChild:dislikeRollingNumberNode];
                    [dislikeNode.view addSubview:dislikeRollingNumberNode.view];
                    pairMode = 0;
                }
            } else if ([targetNode isKindOfClass:%c(ELMTextNode)]) {
                likeTextNode = (ELMTextNode *)targetNode;
                if (isDislikeButtonModified)
                    dislikeTextNode = dislikeNode.yogaChildren[1];
                else {
                    id elementContext = [likeTextNode valueForKey:@"_context"];
                    overrideNodeCreation = 2;
                    dislikeTextNode = [[%c(ELMNodeFactory) sharedInstance] nodeWithElement:likeTextNode.element materializationContext:&elementContext];
                    overrideNodeCreation = 0;
                    mutableDislikeText = [[NSMutableAttributedString alloc] initWithAttributedString:likeTextNode.attributedText];
                    dislikeTextNode.attributedText = mutableDislikeText;
                    [dislikeNode addYogaChild:dislikeTextNode];
                    [dislikeNode.view addSubview:dislikeTextNode.view];
                    pairMode = 0;
                }
            }
        } else {
            dislikeTextNode = likeNode.yogaChildren[1];
            if (![dislikeTextNode isKindOfClass:%c(ELMTextNode)]) {
                HBLogDebug(@"RYD: Dislike button not found, instead found %@", dislikeTextNode);
                return node;
            }
            mutableDislikeText = [[NSMutableAttributedString alloc] initWithAttributedString:dislikeTextNode.attributedText];
            mutableDislikeText.mutableString.string = FETCHING;
            dislikeTextNode.attributedText = mutableDislikeText;
        }
        BOOL shouldFetchVote = (ExactLikeNumber() || UseRYDLikeData()) || !isDislikeButtonModified;
        if (shouldFetchVote) {
            getVoteAndModifyButtons(
                videoId,
                pairMode,
                ^(NSString *likeCount, NSNumber *likeNumber) {
                    if (likeRollingNumberNode) {
                        likeRollingNumberNode.updatedCount = likeCount;
                        likeRollingNumberNode.updatedCountNumber = likeNumber;
                        [likeRollingNumberNode updateRollingNumberView];
                        [likeRollingNumberNode relayoutNode];
                    } else {
                        NSMutableAttributedString *mutableLikeText = [[NSMutableAttributedString alloc] initWithAttributedString:likeTextNode.attributedText];
                        mutableLikeText.mutableString.string = likeCount;
                        setTextColor(mutableLikeText);
                        likeTextNode.attributedText = mutableLikeText;
                        likeTextNode.accessibilityLabel = likeCount;
                    }
                },
                ^(NSString *dislikeCount, NSNumber *dislikeNumber) {
                    if (isDislikeButtonModified) return;
                    NSString *dislikeString;
                    switch (pairMode) {
                        case -1:
                            dislikeString = dislikeCount;
                            break;
                        case 0:
                            dislikeString = [NSString stringWithFormat:@"  %@ ", dislikeCount];
                            break;
                    }
                    if (dislikeRollingNumberNode) {
                        dislikeRollingNumberNode.updatedCount = dislikeString;
                        dislikeRollingNumberNode.updatedCountNumber = dislikeNumber;
                        [dislikeRollingNumberNode updateRollingNumberView];
                        [dislikeRollingNumberNode relayoutNode];
                    } else {
                        mutableDislikeText.mutableString.string = dislikeString;
                        setTextColor(mutableDislikeText);
                        dislikeTextNode.attributedText = mutableDislikeText;
                        dislikeTextNode.accessibilityLabel = dislikeCount;
                    }
                }
            );
        }
    }
    return node;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    %orig;
    if (isVideoScrollableActionBar(self) && TweakEnabled()) {
        if (dislikeRollingNumberNode) {
            YTRollingNumberView *likeView = [likeRollingNumberNode valueForKey:@"_rollingNumberView"];
            [dislikeRollingNumberNode updateCount:dislikeRollingNumberNode.updatedCount color:likeView.color];
        } else if (dislikeTextNode) {
            NSString *dislikeText = dislikeTextNode.attributedText.string;
            mutableDislikeText = [[NSMutableAttributedString alloc] initWithAttributedString:likeTextNode.attributedText];
            mutableDislikeText.mutableString.string = dislikeText;
            dislikeTextNode.attributedText = mutableDislikeText;
        }
    }
}

%end

static void setTextNodeColor(ELMTextNode *node, UIColor *color) {
    if (node == nil) return;
    NSString *text = node.attributedText.string;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{ NSForegroundColorAttributeName: color }];
    node.attributedText = attributedText;
}

%hook YTAsyncCollectionView

- (void)pageStyleDidChange:(NSInteger)pageStyle {
    %orig;
    if ([self.pageStylingDelegate isKindOfClass:%c(YTWatchNextResultsViewController)]) {
        YTCommonColorPalette *colorPalette = currentColorPalette();
        UIColor *textColor = [colorPalette textPrimary];
        setTextNodeColor(likeTextNode, textColor);
        setTextNodeColor(dislikeTextNode, textColor);
    }
}

%end

static void layoutActionBar(YTReelWatchPlaybackOverlayView *self) {
    if (!TweakEnabled()) return;
    if (self.didGetVote) return;
    id spvc = [self parentResponder];
    YTReelModel *model = [spvc valueForKey:@"_model"];
    NSString *videoId;
    @try {
        videoId = [model endpoint].reelWatchEndpoint.videoId;
    } @catch (id ex) {
        videoId = [model command].reelWatchEndpoint.videoId;
        if (videoId.length == 0 && [spvc isKindOfClass:%c(YTShortsPlayerViewController)])
            videoId = [[[(YTShortsPlayerViewController *)spvc currentVideo] singleVideo] videoId];
    }
    HBLogDebug(@"RYD: Short ID: %@", videoId);
    if (videoId == nil) return;
    YTELMView *elmView = nil;
    @try {
        elmView = [self valueForKey:@"_actionBarView"];
    } @catch (id ex) {}
    if (elmView == nil) {
        @try {
            YTReelElementAsyncComponentView *view = [self valueForKey:@"_actionBarComponentView"];
            elmView = [view valueForKey:@"_elementView"];
        } @catch (id ex) {}
    }
    BOOL isNested = NO;
    if (elmView == nil) {
        @try {
            YTReelElementAsyncComponentView *playerOverlayView = [self valueForKey:@"_playerOverlayView"];
            elmView = [playerOverlayView valueForKey:@"_elementView"];
            isNested = YES;
        } @catch (id ex) {}
    }
    if (elmView == nil) return;
    if ([elmView isKindOfClass:%c(YTReelWatchActionBarView)])
        elmView = [elmView valueForKey:@"_actionBarElement"];
    ELMContainerNode *containerNode;
    if (isNested) {
        ELMContainerNode *node = [elmView valueForKey:@"_rootNode"];
        node = [node.yogaChildren firstObject];
        containerNode = [node.yogaChildren yt_objectAtIndexOrNil:1];
    } else
        containerNode = [elmView valueForKey:@"_rootNode"];
    ELMContainerNode *likeNode = [containerNode.yogaChildren firstObject];
    ELMContainerNode *dislikeNode = [containerNode.yogaChildren yt_objectAtIndexOrNil:1];
    BOOL foundLikeButton = NO;
    BOOL foundDislikeButton = NO;
    @try {
        ELMComponent *likeOwningComponent = [[likeNode controller] owningComponent];
        if ([likeOwningComponent owningComponent]) likeOwningComponent = [likeOwningComponent owningComponent];
        foundLikeButton = [[likeOwningComponent templateURI] hasPrefix:@"reel_like_button"];
        ELMComponent *dislikeOwningComponent = [[dislikeNode controller] owningComponent];
        if ([dislikeOwningComponent owningComponent]) dislikeOwningComponent = [dislikeOwningComponent owningComponent];
        foundDislikeButton = [[dislikeOwningComponent templateURI] hasPrefix:@"reel_dislike_button"];
    } @catch (id ex) {
        HBLogDebug(@"RYD: Error checking if like/dislike button is found: %@", ex);
    }
    if (!foundLikeButton) {
        do {
            likeNode = [likeNode.yogaChildren firstObject];
        } while ([likeNode.accessibilityIdentifier isEqualToString:@"id.reel_like_button"]);
        do {
            likeNode = [likeNode.yogaChildren firstObject];
        } while (likeNode.yogaChildren.count == 1);
    }
    if (!foundDislikeButton) {
        do {
            dislikeNode = [dislikeNode.yogaChildren firstObject];
        } while ([dislikeNode.accessibilityIdentifier isEqualToString:@"id.reel_dislike_button"]);
        do {
            dislikeNode = [dislikeNode.yogaChildren firstObject];
        } while (dislikeNode.yogaChildren.count == 1);
    }
    NSArray *likeChildren = likeNode.yogaChildren;
    if (likeChildren.count == 1) likeChildren = ((ASDisplayNode *)[likeNode.yogaChildren firstObject]).yogaChildren;
    ELMTextNode *shortLikeTextNode = [likeChildren yt_objectAtIndexOrNil:1];
    NSArray *dislikeChildren = dislikeNode.yogaChildren;
    if (dislikeChildren.count == 1) dislikeChildren = ((ASDisplayNode *)[dislikeNode.yogaChildren firstObject]).yogaChildren;
    ELMTextNode *shortDislikeTextNode = [dislikeChildren yt_objectAtIndexOrNil:1];
    if (shortLikeTextNode == nil || shortDislikeTextNode == nil || ![shortLikeTextNode isKindOfClass:%c(ELMTextNode)] || ![shortDislikeTextNode isKindOfClass:%c(ELMTextNode)]) {
        HBLogDebug(@"RYD: Short like or dislike text node not found");
        return;
    }
    __block NSMutableAttributedString *shortMutableDislikeText = [[NSMutableAttributedString alloc] initWithAttributedString:shortLikeTextNode.attributedText];
    shortMutableDislikeText.mutableString.string = FETCHING;
    shortDislikeTextNode.attributedText = shortMutableDislikeText;
    getVoteAndModifyButtons(
        videoId,
        -1,
        ^(NSString *likeCount, NSNumber *likeNumber) {
            NSMutableAttributedString *shortMutableLikeText = [[NSMutableAttributedString alloc] initWithAttributedString:shortLikeTextNode.attributedText];
            shortMutableLikeText.mutableString.string = likeCount;
            shortLikeTextNode.attributedText = shortMutableLikeText;
            shortLikeTextNode.accessibilityLabel = likeCount;
        },
        ^(NSString *dislikeCount, NSNumber *dislikeNumber) {
            shortMutableDislikeText.mutableString.string = dislikeCount;
            shortDislikeTextNode.attributedText = shortMutableDislikeText;
            shortDislikeTextNode.accessibilityLabel = dislikeCount;
        }
    );
    self.didGetVote = YES;
}

%hook YTReelWatchPlaybackOverlayView

%property (assign, nonatomic) BOOL didGetVote;

- (void)layoutActionBar {
    %orig;
    layoutActionBar(self);
}

%end

%hook YTReelWatchPlaybackOverlayViewSub

%property (assign, nonatomic) BOOL didGetVote;

- (void)layoutActionBar {
    %orig;
    layoutActionBar((YTReelWatchPlaybackOverlayView *)self);
}

%end

%hook YTRollingNumberNode

%property (strong, nonatomic) NSString *updatedCount;
%property (strong, nonatomic) NSNumber *updatedCountNumber;

- (id)initWithElement:(id)element context:(id)context {
    self = %orig;
    if (self) {
        self.updatedCount = nil;
        self.updatedCountNumber = nil;
    }
    return self;
}

- (void)updateRollingNumberView {
    %orig;
    if (self.updatedCount && self.updatedCountNumber)
        [self updateCount:self.updatedCount color:nil];
}

%new(v@:@@)
- (void)updateCount:(NSString *)updatedCount_ color:(UIColor *)color_ {
    YTRollingNumberView *view = [self valueForKey:@"_rollingNumberView"];
    UIFont *font = view.font;
    UIColor *color = color_ ?: view.color;
    NSString *updatedCount = [NSString stringWithFormat:@" %@", updatedCount_];
    if ([view respondsToSelector:@selector(setUpdatedCount:updatedCountNumber:font:fontAttributes:color:skipAnimation:)])
        [view setUpdatedCount:updatedCount updatedCountNumber:self.updatedCountNumber font:font fontAttributes:view.fontAttributes color:color skipAnimation:YES];
    else
        [view setUpdatedCount:updatedCount updatedCountNumber:self.updatedCountNumber font:font color:color skipAnimation:YES];
}

%end

%hook ELMNodeFactory

- (Class)classForElement:(id)element materializationContext:(const void *)context {
    switch (overrideNodeCreation) {
        case 1:
            return %c(YTRollingNumberNode);
        case 2:
            return %c(ELMTextNode);
        default:
            return %orig;
    }
}

%end

%ctor {
    cache = [NSCache new];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:DidShowEnableVoteSubmissionAlertKey] && !VoteSubmissionEnabled()) {
        [defaults setBool:YES forKey:DidShowEnableVoteSubmissionAlertKey];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSBundle *tweakBundle = RYDBundle();
            YTAlertView *alertView = [%c(YTAlertView) confirmationDialogWithAction:^{
                enableVoteSubmission(YES);
            } actionTitle:_LOC([NSBundle mainBundle], @"settings.yes")];
            alertView.title = @(TWEAK_NAME);
            alertView.subtitle = [NSString stringWithFormat:LOC(@"WANT_TO_ENABLE"), @(API_URL), alertView.title, LOC(@"ENABLE_VOTE_SUBMIT")];
            [alertView show];
        });
    }
    [[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Frameworks/Module_Framework.framework", NSBundle.mainBundle.bundlePath]] load];
    %init;
}