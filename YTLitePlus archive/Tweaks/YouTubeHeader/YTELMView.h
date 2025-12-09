#import "ELMView.h"
#import "YTELMContext.h"
#import "YTIElementRenderer.h"
#import "YTResponder.h"

@interface YTELMView : ELMView <YTResponder>
- (instancetype)initWithFrame:(CGRect)frame elementRenderer:(YTIElementRenderer *)elementRenderer parentResponder:(id <YTResponder>)parentResponder;
- (instancetype)initWithFrame:(CGRect)frame elementRenderer:(YTIElementRenderer *)elementRenderer context:(YTELMContext *)parentResponder;
@end
