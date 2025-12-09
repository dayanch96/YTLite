#import "GOOMultiLineView.h"
#import "GOODialogViewAction.h"

@interface GOODialogView : GOOMultiLineView
- (NSMutableArray <GOODialogViewAction *> *)actions;
- (UILabel *)titleLabel;
@end
