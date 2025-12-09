NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMEffectsRenderer : NSObject

@property (assign, nonatomic, getter=isShowingGrid) BOOL showGrid;

- (void)setShowGrid:(BOOL)show animated:(BOOL)animated;
- (void)_previewStarted:(id)arg1;
- (void)_deviceStarted:(id)arg1;
- (void)_setPreviewStartedNotificationNeeded:(BOOL)arg1;

@end
