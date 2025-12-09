#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import <YouTubeHeader/MDCSlider.h>
// #import <YouTubeHeader/MLAVPlayer.h>
#import <YouTubeHeader/MLHAMPlayerItemSegment.h>
#import <YouTubeHeader/MLHAMQueuePlayer.h>
#import <YouTubeHeader/QTMIcon.h>
#import <YouTubeHeader/UIView+YouTube.h>
#import <YouTubeHeader/YTActionSheetAction.h>
#import <YouTubeHeader/YTAlertView.h>
#import <YouTubeHeader/YTColor.h>
#import <YouTubeHeader/YTColorPalette.h>
#import <YouTubeHeader/YTCommonColorPalette.h>
#import <YouTubeHeader/YTCommonUtils.h>
#import <YouTubeHeader/YTLabel.h>
#import <YouTubeHeader/YTQTMButton.h>
#import <YouTubeHeader/YTIMenuItemSupportedRenderers.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/YTVarispeedSwitchController.h>
#import <YouTubeHeader/YTVarispeedSwitchControllerOption.h>

#define TweakKey @"YouSpeed"
#define MoreSpeedKey @"YSMS"
#define FixNativeSpeedKey @"YSFNS"
#define SpeedSliderKey @"YSSS"
#define MIN_SPEED 0.25
#define MAX_SPEED 5.0

@interface YTMainAppControlsOverlayView (YouSpeed)
- (void)didPressYouSpeed:(id)arg;
- (void)updateYouSpeedButton:(id)arg;
@end

@interface YTMainAppVideoPlayerOverlayViewController (YouSpeed)
- (void)didChangePlaybackSpeed:(MDCSlider *)s;
@end

@interface YTInlinePlayerBarContainerView (YouSpeed)
- (void)didPressYouSpeed:(id)arg;
- (void)updateYouSpeedButton:(id)arg;
@end

NSString *YouSpeedUpdateNotification = @"YouSpeedUpdateNotification";
NSString *currentSpeedLabel = @"1x";
float currentPlaybackRate = 1.0;

static NSBundle *YouSpeedBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouSpeed" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: PS_ROOT_PATH_NS(@"/Library/Application Support/YouSpeed.bundle")];
    });
    return bundle;
}

static BOOL MoreSpeed() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:MoreSpeedKey];
}

static BOOL FixNativeSpeed() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:FixNativeSpeedKey];
}

static BOOL SpeedSlider() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SpeedSliderKey];
}

static NSString *speedLabel(float rate) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 2;
    NSString *rateString = [formatter stringFromNumber:[NSNumber numberWithFloat:rate]];
    return [NSString stringWithFormat:@"%@x", rateString];
}

static void didSelectRate(float rate) {
    currentPlaybackRate = rate;
    currentSpeedLabel = speedLabel(rate);
    [[NSNotificationCenter defaultCenter] postNotificationName:YouSpeedUpdateNotification object:nil];
}

%group Video

%hook YTPlayerOverlayManager

- (void)varispeedSwitchController:(id)arg1 didSelectRate:(float)rate {
    didSelectRate(rate);
    %orig;
}

%end

%hook YTPlayerViewController

- (void)varispeedSwitchController:(id)arg1 didSelectRate:(float)rate {
    didSelectRate(rate);
    %orig;
}

%end

%end

%group Top

%hook YTMainAppControlsOverlayView

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    [self updateYouSpeedButton:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateYouSpeedButton:) name:YouSpeedUpdateNotification object:nil];
    return self;
}

- (id)initWithDelegate:(id)delegate autoplaySwitchEnabled:(BOOL)autoplaySwitchEnabled {
    self = %orig;
    [self updateYouSpeedButton:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateYouSpeedButton:) name:YouSpeedUpdateNotification object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YouSpeedUpdateNotification object:nil];
    %orig;
}

%new(v@:@)
- (void)updateYouSpeedButton:(id)arg {
    [self.overlayButtons[TweakKey] setTitle:currentSpeedLabel forState:UIControlStateNormal];
}

%new(v@:@)
- (void)didPressYouSpeed:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    [c didPressVarispeed:arg];
    [self updateYouSpeedButton:nil];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

- (id)init {
    self = %orig;
    [self updateYouSpeedButton:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateYouSpeedButton:) name:YouSpeedUpdateNotification object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YouSpeedUpdateNotification object:nil];
    %orig;
}

%new(v@:@)
- (void)updateYouSpeedButton:(id)arg {
    [self.overlayButtons[TweakKey] setTitle:currentSpeedLabel forState:UIControlStateNormal];
}

%new(v@:@)
- (void)didPressYouSpeed:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self.delegate valueForKey:@"_delegate"];
    [c didPressVarispeed:arg];
    [self updateYouSpeedButton:nil];
}

%end

%end

%group OverrideNative

%hook YTMenuController

- (NSMutableArray <YTActionSheetAction *> *)actionsForRenderers:(NSMutableArray <YTIMenuItemSupportedRenderers *> *)renderers fromView:(UIView *)fromView entry:(id)entry shouldLogItems:(BOOL)shouldLogItems firstResponder:(id)firstResponder {
    NSUInteger index = [renderers indexOfObjectPassingTest:^BOOL(YTIMenuItemSupportedRenderers *renderer, NSUInteger idx, BOOL *stop) {
        YTIMenuItemSupportedRenderersElementRendererCompatibilityOptionsExtension *extension = (YTIMenuItemSupportedRenderersElementRendererCompatibilityOptionsExtension *)[renderer.elementRenderer.compatibilityOptions messageForFieldNumber:396644439];
        BOOL isVideoSpeed = [extension.menuItemIdentifier isEqualToString:@"menu_item_playback_speed"];
        if (isVideoSpeed) *stop = YES;
        return isVideoSpeed;
    }];
    NSMutableArray <YTActionSheetAction *> *actions = %orig;
    if (index != NSNotFound) {
        YTActionSheetAction *action = actions[index];
        action.handler = ^{
            [firstResponder didPressVarispeed:fromView];
        };
        UIView *elementView = [action.button valueForKey:@"_elementView"];
        elementView.userInteractionEnabled = NO;
    }
    return actions;
}

%end

%end

%group Speed

%hook YTVarispeedSwitchController

- (id)init {
    self = %orig;
    #define itemCount 16
    float speeds[] = {MIN_SPEED, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.5, 4.0, 4.5, MAX_SPEED};
    id options[itemCount];
    Class YTVarispeedSwitchControllerOptionClass = %c(YTVarispeedSwitchControllerOption);
    for (int i = 0; i < itemCount; ++i) {
        NSString *title = [NSString stringWithFormat:@"%.2fx", speeds[i]];
        options[i] = [[YTVarispeedSwitchControllerOptionClass alloc] initWithTitle:title rate:speeds[i]];
    }
    [self setValue:[NSArray arrayWithObjects:options count:itemCount] forKey:@"_options"];
    return self;
}

%end

%hook MLHAMQueuePlayer

- (void)setRate:(float)newRate {
    float rate = [[self valueForKey:@"_rate"] floatValue];
    if (rate == newRate) return;
    MLHAMPlayerItemSegment *segment = [self valueForKey:@"_currentSegment"];
    MLInnerTubePlayerConfig *config = [segment playerItem].config;
    if (![config varispeedAllowed]) return;
    [self setValue:@(newRate) forKey:@"_rate"];
    [self internalSetRate];
}

%end

// %hook MLAVPlayer

// - (void)setRate:(float)newRate {
//     MLInnerTubePlayerConfig *config = [self valueForKey:@"_config"];
//     if (![config varispeedAllowed]) return;
//     float rate = [[self valueForKey:@"_rate"] floatValue];
//     if (rate == newRate) return;
//     [self setValue:@(newRate) forKey:@"_rate"];
//     self.assetPlayer.rate = newRate;
//     MLPlayerStickySettings *stickySettings = [self valueForKey:@"_stickySettings"];
//     stickySettings.rate = newRate;
//     MLPlayerEventCenter *eventCenter = [self valueForKey:@"_playerEventCenter"];
//     [eventCenter broadcastRateChange:newRate];
//     [self.delegate playerRateDidChange:newRate];
// }

// %end

%end

%group Slider

@interface YouSpeedSliderAlertView : YTAlertView
- (void)setupViews:(YTMainAppVideoPlayerOverlayViewController *)delegate sliderLabel:(NSString *)sliderLabel;
@end

%subclass YouSpeedSliderAlertView : YTAlertView

%new(v@:@@)
- (void)setupViews:(YTMainAppVideoPlayerOverlayViewController *)delegate sliderLabel:(NSString *)sliderLabel {
    CGSize labelSize = CGSizeMake(50, 20);
    CGSize adjustButtonSize = CGSizeMake(30, 30);
    CGSize presetButtonSize = CGSizeMake(50, 30);

    MDCSlider *slider = [%c(MDCSlider) new];
    slider.statefulAPIEnabled = YES;
    slider.thumbHollowAtStart = NO;
    slider.minimumValue = MIN_SPEED;
    slider.maximumValue = MAX_SPEED;
    slider.value = currentPlaybackRate;
    slider.continuous = NO;
    slider.accessibilityLabel = sliderLabel;
    slider.tag = 'slid';
    [slider setTrackBackgroundColor:[%c(YTColor) grey3Alpha70] forState:UIControlStateNormal];

    YTLabel *minLabel = [%c(YTLabel) new];
    minLabel.text = speedLabel(MIN_SPEED);
    minLabel.textAlignment = NSTextAlignmentLeft;
    minLabel.tag = 'minl';
    [minLabel yt_setSize:labelSize];
    [minLabel setTypeKind:22];

    YTLabel *maxLabel = [%c(YTLabel) new];
    maxLabel.text = speedLabel(MAX_SPEED);
    maxLabel.textAlignment = NSTextAlignmentRight;
    maxLabel.tag = 'maxl';
    [maxLabel yt_setSize:labelSize];
    [maxLabel setTypeKind:22];

    YTLabel *currentValueLabel = [%c(YTLabel) new];
    currentValueLabel.text = currentSpeedLabel;
    currentValueLabel.textAlignment = NSTextAlignmentCenter;
    currentValueLabel.tag = 'cvl0';
    [currentValueLabel yt_setSize:labelSize];
    [currentValueLabel setTypeKind:22];

    UIImage *minusImage = [%c(QTMIcon) imageWithName:@"ic_remove" color:nil];
    UIImage *plusImage = [%c(QTMIcon) imageWithName:@"ic_add" color:nil];
    BOOL legacy = minusImage == nil;
    if (legacy) {
        minusImage = [%c(QTMIcon) imageWithName:@"ic_remove_circle" color:nil];
        plusImage = [[%c(QTMIcon) imageWithName:@"ic_add_circle" color:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    YTQTMButton *minusButton = [%c(YTQTMButton) buttonWithImage:minusImage accessibilityLabel:@"Decrease playback speed" accessibilityIdentifier:@"playback.speed.minus"];
    minusButton.flatButtonHasOpaqueBackground = !legacy;
    minusButton.sizeWithPaddingAndInsets = YES;
    minusButton.tag = 'mbtn';
    [minusButton yt_setSize:adjustButtonSize];
    [minusButton addTarget:delegate action:@selector(didPressMinusButton:) forControlEvents:UIControlEventTouchUpInside];

    YTQTMButton *plusButton = [%c(YTQTMButton) buttonWithImage:plusImage accessibilityLabel:@"Increase playback speed" accessibilityIdentifier:@"playback.speed.plus"];
    plusButton.flatButtonHasOpaqueBackground = !legacy;
    plusButton.sizeWithPaddingAndInsets = YES;
    plusButton.tag = 'pbtn';
    [plusButton yt_setSize:adjustButtonSize];
    [plusButton addTarget:delegate action:@selector(didPressPlusButton:) forControlEvents:UIControlEventTouchUpInside];

    YTQTMButton *speed025Button = [%c(YTQTMButton) textButton];
    speed025Button.flatButtonHasOpaqueBackground = YES;
    speed025Button.sizeWithPaddingAndInsets = YES;
    speed025Button.tag = 's025';
    [speed025Button yt_setSize:presetButtonSize];
    [speed025Button setTitleTypeKind:21];
    [speed025Button setTitle:@"0.25x" forState:UIControlStateNormal];
    [speed025Button addTarget:delegate action:@selector(didPressSpeedPresetButton:) forControlEvents:UIControlEventTouchUpInside];

    YTQTMButton *speed050Button = [%c(YTQTMButton) textButton];
    speed050Button.flatButtonHasOpaqueBackground = YES;
    speed050Button.sizeWithPaddingAndInsets = YES;
    speed050Button.tag = 's050';
    [speed050Button yt_setSize:presetButtonSize];
    [speed050Button setTitleTypeKind:21];
    [speed050Button setTitle:@"0.5x" forState:UIControlStateNormal];
    [speed050Button addTarget:delegate action:@selector(didPressSpeedPresetButton:) forControlEvents:UIControlEventTouchUpInside];

    YTQTMButton *speed100Button = [%c(YTQTMButton) textButton];
    speed100Button.flatButtonHasOpaqueBackground = YES;
    speed100Button.sizeWithPaddingAndInsets = YES;
    speed100Button.tag = 's100';
    [speed100Button yt_setSize:presetButtonSize];
    [speed100Button setTitleTypeKind:21];
    [speed100Button setTitle:@"1x" forState:UIControlStateNormal];
    [speed100Button addTarget:delegate action:@selector(didPressSpeedPresetButton:) forControlEvents:UIControlEventTouchUpInside];

    YTQTMButton *speed150Button = [%c(YTQTMButton) textButton];
    speed150Button.flatButtonHasOpaqueBackground = YES;
    speed150Button.sizeWithPaddingAndInsets = YES;
    speed150Button.tag = 's150';
    [speed150Button yt_setSize:presetButtonSize];
    [speed150Button setTitleTypeKind:21];
    [speed150Button setTitle:@"1.5x" forState:UIControlStateNormal];
    [speed150Button addTarget:delegate action:@selector(didPressSpeedPresetButton:) forControlEvents:UIControlEventTouchUpInside];

    YTQTMButton *speed200Button = [%c(YTQTMButton) textButton];
    speed200Button.flatButtonHasOpaqueBackground = YES;
    speed200Button.sizeWithPaddingAndInsets = YES;
    speed200Button.tag = 's200';
    [speed200Button yt_setSize:presetButtonSize];
    [speed200Button setTitleTypeKind:21];
    [speed200Button setTitle:@"2x" forState:UIControlStateNormal];
    [speed200Button addTarget:delegate action:@selector(didPressSpeedPresetButton:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat contentWidth = [%c(YTCommonUtils) isIPad] ? 350 : 250;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 120)];
    [contentView addSubview:slider];
    [contentView addSubview:minLabel];
    [contentView addSubview:maxLabel];
    [contentView addSubview:currentValueLabel];
    [contentView addSubview:minusButton];
    [contentView addSubview:plusButton];
    [contentView addSubview:speed025Button];
    [contentView addSubview:speed050Button];
    [contentView addSubview:speed100Button];
    [contentView addSubview:speed150Button];
    [contentView addSubview:speed200Button];

    CGFloat sliderWidth = contentWidth - 80;
    slider.frame = CGRectMake(0, 0, sliderWidth, adjustButtonSize.height);
    slider.delegate = (id <MDCSliderDelegate>)contentView;
    [slider addTarget:delegate action:@selector(didChangePlaybackSpeed:) forControlEvents:UIControlEventValueChanged];

    self.customContentView = contentView;
}

- (void)layoutSubviews {
    %orig;
    UIView *contentView = self.customContentView;
    YTLabel *minLabel = [contentView viewWithTag:'minl'];
    YTLabel *maxLabel = [contentView viewWithTag:'maxl'];
    YTLabel *currentValueLabel = [contentView viewWithTag:'cvl0'];
    YTQTMButton *minusButton = [contentView viewWithTag:'mbtn'];
    YTQTMButton *plusButton = [contentView viewWithTag:'pbtn'];
    MDCSlider *slider = [contentView viewWithTag:'slid'];
    YTQTMButton *speed025Button = [contentView viewWithTag:'s025'];
    YTQTMButton *speed050Button = [contentView viewWithTag:'s050'];
    YTQTMButton *speed100Button = [contentView viewWithTag:'s100'];
    YTQTMButton *speed150Button = [contentView viewWithTag:'s150'];
    YTQTMButton *speed200Button = [contentView viewWithTag:'s200'];
    NSArray <YTQTMButton *> *presetButtons = @[speed025Button, speed050Button, speed100Button, speed150Button, speed200Button];

    [slider alignCenterTopToCenterTopOfView:contentView paddingY:0];
    [minLabel alignTopLeadingToBottomLeadingOfView:slider paddingX:0 paddingY:10];
    [maxLabel alignTopTrailingToBottomTrailingOfView:slider paddingX:0 paddingY:10];
    [currentValueLabel alignCenterTopToCenterBottomOfView:slider paddingY:10];
    [minusButton alignCenterTrailingToCenterLeadingOfView:slider paddingX:10];
    [plusButton alignCenterLeadingToCenterTrailingOfView:slider paddingX:10];

    CGFloat padding = (contentView.frame.size.width - (50 * 5)) / 4;
    CGFloat buttonY = currentValueLabel.frame.origin.y + currentValueLabel.frame.size.height + 15;

    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft)
        presetButtons = [[presetButtons reverseObjectEnumerator] allObjects];
    for (int i = 0; i < presetButtons.count; ++i) {
        YTQTMButton *button = presetButtons[i];
        [button yt_setOrigin:CGPointMake(i * (padding + 50), buttonY)];
    }
}

- (void)pageStyleDidChange:(NSInteger)pageStyle {
    %orig;
    YTCommonColorPalette *colorPalette;
    Class YTCommonColorPaletteClass = %c(YTCommonColorPalette);
    if (YTCommonColorPaletteClass)
        colorPalette = pageStyle == 1 ? [YTCommonColorPaletteClass darkPalette] : [YTCommonColorPaletteClass lightPalette];
    else
        colorPalette = [%c(YTColorPalette) colorPaletteForPageStyle:pageStyle];
    UIView *contentView = self.customContentView;
    MDCSlider *slider = [contentView viewWithTag:'slid'];
    YTLabel *minLabel = [contentView viewWithTag:'minl'];
    YTLabel *maxLabel = [contentView viewWithTag:'maxl'];
    YTLabel *currentValueLabel = [contentView viewWithTag:'cvl0'];
    YTQTMButton *minusButton = [contentView viewWithTag:'mbtn'];
    YTQTMButton *plusButton = [contentView viewWithTag:'pbtn'];
    YTQTMButton *speed025Button = [contentView viewWithTag:'s025'];
    YTQTMButton *speed050Button = [contentView viewWithTag:'s050'];
    YTQTMButton *speed100Button = [contentView viewWithTag:'s100'];
    YTQTMButton *speed150Button = [contentView viewWithTag:'s150'];
    YTQTMButton *speed200Button = [contentView viewWithTag:'s200'];

    UIColor *textColor = [colorPalette textPrimary];
    UIColor *adjustButtonBackgroundColor = [UIColor colorWithWhite:pageStyle alpha:0.2];
    minLabel.textColor = textColor;
    maxLabel.textColor = textColor;
    currentValueLabel.textColor = textColor;
    minusButton.tintColor = textColor;
    minusButton.enabledBackgroundColor = adjustButtonBackgroundColor;
    plusButton.tintColor = textColor;
    plusButton.enabledBackgroundColor = adjustButtonBackgroundColor;
    speed025Button.customTitleColor
        = speed050Button.customTitleColor
        = speed100Button.customTitleColor
        = speed150Button.customTitleColor
        = speed200Button.customTitleColor = textColor;
    speed025Button.enabledBackgroundColor
        = speed050Button.enabledBackgroundColor
        = speed100Button.enabledBackgroundColor
        = speed150Button.enabledBackgroundColor
        = speed200Button.enabledBackgroundColor = adjustButtonBackgroundColor;
    [slider setThumbColor:textColor forState:UIControlStateNormal];
    [slider setTrackFillColor:textColor forState:UIControlStateNormal];
}

%end

YouSpeedSliderAlertView *alert;

%hook YTMainAppVideoPlayerOverlayViewController

- (void)didPressVarispeed:(id)arg1 {
    if (!SpeedSlider()) {
        %orig;
        return;
    }
    NSBundle *tweakBundle = YouSpeedBundle();
    NSString *label = LOC(@"PLAYBACK_SPEED");
    NSString *chooseFromOriginalLabel = LOC(@"CHOOSE_FROM_ORIGINAL");
    alert = [%c(YouSpeedSliderAlertView) infoDialog];
    [alert setupViews:self sliderLabel:label];
    alert.title = label;
    alert.shouldDismissOnBackgroundTap = YES;
    alert.customContentViewInsets = UIEdgeInsetsMake(8, 0, 0, 0);
    [alert addTitle:chooseFromOriginalLabel withCancelAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            %orig;
        });
    }];
    [alert show];
}

%new(v@:@)
- (void)didChangePlaybackSpeed:(MDCSlider *)s {
    float rate = s.value;
    UILabel *currentValueLabel = [s.superview viewWithTag:'cvl0'];
    [(id <YTVarispeedSwitchControllerDelegate>)self.delegate varispeedSwitchController:nil didSelectRate:rate];
    currentValueLabel.text = currentSpeedLabel;
}

%new(v@:@)
- (void)didPressMinusButton:(YTQTMButton *)button {
    MDCSlider *slider = [button.superview viewWithTag:'slid'];
    float newValue = MAX(slider.minimumValue, slider.value - 0.05);
    [slider setValue:newValue animated:YES];
    [self didChangePlaybackSpeed:slider];
}

%new(v@:@)
- (void)didPressPlusButton:(YTQTMButton *)button {
    MDCSlider *slider = [button.superview viewWithTag:'slid'];
    float newValue = MIN(slider.maximumValue, slider.value + 0.05);
    [slider setValue:newValue animated:YES];
    [self didChangePlaybackSpeed:slider];
}

%new(v@:@)
- (void)didPressSpeedPresetButton:(YTQTMButton *)button {
    MDCSlider *slider = [button.superview viewWithTag:'slid'];
    float newValue = 1.0;
    switch (button.tag) {
        case 's025':
            newValue = 0.25;
            break;
        case 's050':
            newValue = 0.5;
            break;
        case 's100':
            newValue = 1.0;
            break;
        case 's150':
            newValue = 1.5;
            break;
        case 's200':
            newValue = 2.0;
            break;
    }

    slider.value = newValue;
    [self didChangePlaybackSpeed:slider];
    [alert dismiss];
    alert = nil;
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey, @{
        AccessibilityLabelKey: @"Speed",
        SelectorKey: @"didPressYouSpeed:",
        AsTextKey: @YES,
        ExtraBooleanKeys: @[MoreSpeedKey, FixNativeSpeedKey, SpeedSliderKey],
    });
    %init(Video);
    %init(Top);
    %init(Bottom);
    if (MoreSpeed()) {
        %init(Speed);
    }
    if (FixNativeSpeed()) {
        %init(OverrideNative);
    }
    %init(Slider);
}
