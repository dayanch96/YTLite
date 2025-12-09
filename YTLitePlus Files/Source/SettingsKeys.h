#import "../YTLitePlus.h"

// Keys for "Copy Settings" button (for: YTLitePlus)
// In alphabetical order for tweaks after YTLitePlus
NSArray *NSUserDefaultsCopyKeys = @[
    // YTLitePlus - gathered using get_keys.py
    @"YTTapToSeek_enabled", @"alwaysShowRemainingTime_enabled", @"bigYTMiniPlayer_enabled", @"castConfirm_enabled",
    @"disableAccountSection_enabled", @"disableAmbientModeFullscreen_enabled",
    @"disableAmbientModePortrait_enabled", @"disableAutoplaySection_enabled", @"disableCollapseButton_enabled",
    @"disableEngagementOverlay_enabled", @"disableLiveChatSection_enabled",
    @"disableManageAllHistorySection_enabled", @"disableNotificationsSection_enabled",
    @"disablePrivacySection_enabled", @"disablePullToFull_enabled", @"disableRemainingTime_enabled",
    @"disableTryNewFeaturesSection_enabled", @"disableVideoQualityPreferencesSection_enabled",
    @"disableYourDataInYouTubeSection_enabled", @"enableSaveToButton_enabled", @"enableShareButton_enabled",
    @"enableVersionSpoofer_enabled", @"fixCasting_enabled", @"flex_enabled", @"fullscreenToTheRight_enabled",
    @"hideAutoplayMiniPreview_enabled", @"hideCastButton_enabled", @"hideHUD_enabled", @"hideHeatwaves_enabled",
    @"hideHomeTab_enabled", @"hidePreviewCommentSection_enabled", @"hideRightPanel_enabled",
    @"hideSpeedToast_enabled", @"hideSponsorBlockButton_enabled", @"hideVideoPlayerShadowOverlayButtons_enabled",
    @"iPadLayout_enabled", @"iPhoneLayout_enabled", @"inline_muted_playback_enabled", @"lowContrastMode_enabled",
    @"newSettingsUI_enabled", @"oledKeyBoard_enabled", @"playerGesturesHapticFeedback_enabled",
    @"playerGestures_enabled", @"seekAnywhere_enabled", @"switchCopyandPasteFunctionality_enabled",
    @"videoPlayerButton_enabled", @"ytNoModernUI_enabled", @"ytStartupAnimation_enabled",
    // DEMC - https://github.com/therealFoxster/DontEatMyContent/blob/master/Tweak.h
    @"DEMC_enabled", @"DEMC_colorViewsEnabled", @"DEMC_safeAreaConstant", @"DEMC_disableAmbientMode", 
    @"DEMC_limitZoomToFill", @"DEMC_enableForAllVideos",
    // iSponsorBlock cannot be exported using this method - it is also being removed in v5
    // Return-YouTube-Dislike - https://github.com/PoomSmart/Return-YouTube-Dislikes/blob/main/TweakSettings.h
    @"RYD-ENABLED", @"RYD-VOTE-SUBMISSION", @"RYD-EXACT-LIKE-NUMBER", @"RYD-EXACT-NUMBER",
    // All YTVideoOverlay Tweaks - https://github.com/PoomSmart/YTVideoOverlay/blob/0fc6d29d1aa9e75f8c13d675daec9365f753d45e/Tweak.x#L28C1-L41C84
    @"YTVideoOverlay-YouLoop-Enabled", @"YTVideoOverlay-YouTimeStamp-Enabled", @"YTVideoOverlay-YouMute-Enabled", 
    @"YTVideoOverlay-YouQuality-Enabled", @"YTVideoOverlay-YouLoop-Position", @"YTVideoOverlay-YouTimeStamp-Position", 
    @"YTVideoOverlay-YouMute-Position", @"YTVideoOverlay-YouQuality-Position",
    // YouPiP - https://github.com/PoomSmart/YouPiP/blob/main/Header.h
    @"YouPiPPosition", @"CompatibilityModeKey", @"PiPActivationMethodKey", @"PiPActivationMethod2Key", 
    @"NoMiniPlayerPiPKey", @"NonBackgroundableKey",
    // YTABConfig cannot be reasonably exported using this method
    // YTHoldForSpeed will be removed in v5
    // YouTube Plus / YTLite cannot be exported using this method
    // YTUHD - https://github.com/PoomSmart/YTUHD/blob/master/Header.h
    @"EnableVP9", @"AllVP9",
    // Useful YouTube Keys
    @"inline_muted_playback_enabled",
];


// Some default values to ignore when exporting settings
NSDictionary *NSUserDefaultsCopyKeysDefaults = @{
    @"fixCasting_enabled": @1,
    @"inline_muted_playback_enabled": @5,
    @"newSettingsUI_enabled": @1,
    @"DEMC_safeAreaConstant": @21.5,
    @"RYD-ENABLED": @1,
    @"RYD-VOTE-SUBMISSION": @1,
    // Duplicate keys are not allowed in NSDictionary. If present, only the last one will be kept.
};