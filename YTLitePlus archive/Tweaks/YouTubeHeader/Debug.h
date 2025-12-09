#import "YTAlertView.h"

#define showAlertInfo(message) \
    do { \
        YTAlertView *alert = [NSClassFromString(@"YTAlertView") infoDialog]; \
        alert.title = @"Alert"; \
        alert.subtitle = message; \
        dispatch_async(dispatch_get_main_queue(), ^{ \
            [alert show]; \
        }); \
    } while (0)

#if DEBUG
#define showAlertDebug(message) showAlertInfo(message)
#else
#define showAlertDebug(message)
#endif
