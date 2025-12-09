NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMZoomSlider : UISlider

@property (getter=isMinimumAutozooming) BOOL minimumAutozooming;
@property (getter=isMaximumAutozooming) BOOL maximumAutozooming;
@property (getter=_isAutozooming, setter = _setAutozooming :) BOOL _autozooming;
@property (readonly) NSTimer *_visibilityTimer;
@property (readonly) UIImageView *_thumbImageView;
@property (readonly) UIView *_minTrackMaskView;
@property (readonly) UIView *_maxTrackMaskView;
@property (assign, nonatomic) UIView *delegate;

- (BOOL)visibilityTimerIsValid;

- (void)_beginAutozooming;
- (void)_commonCAMZoomSliderInitialization;
- (void)_endAutozooming;
- (void)_hideZoomSlider:(id)arg1;
- (void)_postHideZoomSliderAnimation;
- (void)_updateAutozooming;

- (void)makeInvisible;
- (void)makeVisible;
- (void)makeVisibleAnimated:(BOOL)animated;
- (void)startVisibilityTimer;
- (void)stopVisibilityTimer;

@end
