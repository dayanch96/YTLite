#import <YouTubeHeader/UIView+YouTube.h>
#import <YouTubeHeader/YTFrostedGlassView.h>
#import <YouTubeHeader/YTInlinePlayerBarContainerView.h>
#import <YouTubeHeader/YTMainAppControlsOverlayView.h>
#import <YouTubeHeader/YTQTMButton.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>

@interface YTSettingsSectionItemManager (YTVideoOverlay)
- (void)updateYTVideoOverlaySectionWithEntry:(id)entry;
@end

@interface YTMainAppControlsOverlayView (YTVideoOverlay)
@property (retain, nonatomic) NSMutableDictionary <NSString *, YTQTMButton *> *overlayButtons;
- (UIImage *)buttonImage:(NSString *)tweakId;
@end

@interface YTInlinePlayerBarContainerView (YTVideoOverlay)
@property (retain, nonatomic) NSMutableDictionary <NSString *, YTQTMButton *> *overlayButtons;
@property (retain, nonatomic) NSMutableDictionary <NSString *, YTFrostedGlassView *> *overlayGlasses;
- (UIImage *)buttonImage:(NSString *)tweakId;
@end

#define _LOC(b, x) [b localizedStringForKey:x value:nil table:nil]
#define LOC(x) _LOC(tweakBundle, x)

#define OVERLAY_BUTTON_SIZE 24
