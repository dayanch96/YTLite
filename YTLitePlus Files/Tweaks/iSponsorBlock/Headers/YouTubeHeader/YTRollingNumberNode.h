#import "ASDisplayNode.h"
#import "ELMElement.h"
#import "YTRollingNumberView.h"

@interface YTRollingNumberNode : ASDisplayNode
@property (atomic, strong, readwrite) ELMElement *element;
@property (atomic, assign, readwrite) CGPoint anchorPoint;
@property (atomic, assign, readwrite) CGPoint position;
@property (atomic, assign, readwrite) CGRect frame;
- (instancetype)initWithElement:(ELMElement *)element context:(id)context;
- (YTRollingNumberView *)createRollingNumberView;
- (void)updateRollingNumberView;
- (void)relayoutNode;
- (void)controllerDidApplyProperties;
@end
