#import "YTIElementLoggingContainer.h"
#import "YTIModalClientThrottlingRules.h"

@interface YTIShowFullscreenInterstitialCommand : GPBMessage
@property (nonatomic, readwrite, assign) BOOL hasModalClientThrottlingRules;
@property (nonatomic, readwrite, strong) YTIModalClientThrottlingRules *modalClientThrottlingRules;
@property (nonatomic, strong, readwrite) YTIElementLoggingContainer *elementLoggingContainer;
@end
