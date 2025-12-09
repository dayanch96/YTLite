#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//https://stackoverflow.com/a/26341062
static NSString *hexFromUIColor(UIColor *color) {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

static CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

static UIColor *colorWithHexString(NSString *hexString) {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];

    CGFloat alpha, red, blue, green;

    // #RGB
    alpha = 1.0f;
    red   = colorComponentFrom(colorString,0,2);
    green = colorComponentFrom(colorString,2,2);
    blue  = colorComponentFrom(colorString,4,2);

    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}
