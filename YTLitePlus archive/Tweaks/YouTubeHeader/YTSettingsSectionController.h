#import <Foundation/NSObject.h>
#import "YTSettingsSectionItem.h"

@interface YTSettingsSectionController : NSObject
@property (nonatomic, readonly, strong) NSArray <YTSettingsSectionItem *> *items;
@end
