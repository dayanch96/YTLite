#import "../YTLitePlus.h"

static BOOL isDarkMode() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1);
}
static BOOL oldDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 1);
}

// Themes.xm - Theme Options
// Old dark theme (gray)
%group gOldDarkTheme
UIColor *customColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
%hook YTCommonColorPalette
- (UIColor *)background1 {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)background2 {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)background3 {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [customColor colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)generalBackgroundB {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)menuBackground {
    return self.pageStyle == 1 ? customColor : %orig;
}
%end
%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = customColor;
    } else { return %orig; }
}
%end
%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = customColor;
    } else { return %orig; }
}
%end
%hook YTAsyncCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTRelatedVideosCollectionViewController")]) {
    color = [UIColor clearColor];
    } else if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFullscreenMetadataHighlightsCollectionViewController")]) {
    color = [UIColor clearColor];
    } else {
    return isDarkMode() ? %orig(customColor) : %orig;
    }
    %orig;
}
- (UIColor *)darkBackgroundColor {
    return isDarkMode() ? customColor : %orig;
}
- (void)setDarkBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTWatchNextResultsViewController")]) {
        if (isDarkMode()) {
            self.subviews[0].subviews[0].backgroundColor = customColor;
        }
    }
}
%end

// Hide separators
%hook YTCollectionSeparatorView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

%hook ASScrollView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTSettingsCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTEngagementPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = customColor;
    }
}
%end
%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
- (void)setBarTintColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTELMView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTActionSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end
%hook YTShareMainView
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = customColor;
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = customColor;
  }
}
%end
%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    if (isDarkMode()) {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = customColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = customColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = customColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = customColor;
        }
        responder = [responder nextResponder];
      }
   }
}
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.filter_chip_bar"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = customColor; }
	if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end
%hook YTCinematicContainerView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end
%end

// OLED dark mode by @BandarHL and modified by @arichorn
/*
%group gOLED
%hook YTCommonColorPalette
- (UIColor *)background1 {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)background2 {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)background3 {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [[UIColor blackColor] colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)generalBackgroundB {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)menuBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end
%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end
%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end
%hook YTAsyncCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTRelatedVideosCollectionViewController")]) {
    color = [UIColor clearColor];
    } else if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFullscreenMetadataHighlightsCollectionViewController")]) {
    color = [UIColor clearColor];
    } else {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
    }
    %orig;
}
- (UIColor *)darkBackgroundColor {
    return isDarkMode() ? [UIColor blackColor] : %orig;
}
- (void)setDarkBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTWatchNextResultsViewController")]) {
        if (isDarkMode()) {
            self.subviews[0].subviews[0].backgroundColor = [UIColor blackColor];
        }
    }
}
%end

// Hide separators
%hook YTCollectionSeparatorView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook ASScrollView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTSettingsCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTEngagementPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = [UIColor blackColor];
    }
}
%end
%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
- (void)setBarTintColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTELMView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTActionSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end
%hook YTShareMainView
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = [UIColor blackColor];
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = [UIColor blackColor];
  }
}
%end
%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    if (isDarkMode()) {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        responder = [responder nextResponder];
      }
   }
}
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.filter_chip_bar"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = [UIColor blackColor]; }
	if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end
%hook YTCinematicContainerView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end
%end
*/

// OLED keyboard by @ichitaso <3 - http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
%group gOLEDKB 
%hook TUIEmojiSearchView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIPredictionViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UICandidateViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKeyboardLayoutStar 
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKBRenderConfig // Prediction text color
- (void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (IsEnabled(@"oledKeyBoard_enabled")) {
        %init(gOLEDKB);
    }
    if (oldDarkTheme()) {
        %init(gOldDarkTheme);
    }
}
