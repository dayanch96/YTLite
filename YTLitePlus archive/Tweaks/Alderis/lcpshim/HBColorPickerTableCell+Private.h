#import "libcolorpicker.h"

@interface HBColorPickerTableCell ()

- (UIColor *)_colorValue;
- (void)_setColorValue:(UIColor *)color;
- (void)_updateValue;

- (void)_present;

@end
