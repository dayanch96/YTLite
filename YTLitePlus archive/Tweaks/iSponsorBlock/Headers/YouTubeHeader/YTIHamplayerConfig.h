#import "YTIHamplayerStreamFilter.h"
#import "YTIHamplayerABRConfig.h"
#import "YTIHamplayerSABRAudioTrackRendererConfig.h"

@interface YTIHamplayerConfig : NSObject
@property (nonatomic, assign, readwrite) int renderViewType;
@property (nonatomic, assign, readwrite) BOOL useSbdlRenderView;
@property (nonatomic, assign, readwrite) BOOL useResolutionForHfrHdFormatFilter;
@property (nonatomic, assign, readwrite) BOOL disableHfrHdFormatFilter;
@property (nonatomic, assign, readwrite) BOOL disableResolveOverlappingQualitiesByCodec;
@property (nonatomic, strong, readwrite) YTIHamplayerStreamFilter *streamFilter;
@property (nonatomic, strong, readwrite) YTIHamplayerABRConfig *videoAbrConfig;
@property (nonatomic, strong, readwrite) YTIHamplayerSBARAudioTrackRendererConfig *sbarAudioTrackRenderer;
@end