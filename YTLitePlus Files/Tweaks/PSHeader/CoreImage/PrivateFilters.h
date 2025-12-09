#import <CoreImage/CoreImage.h>

@interface CIColorPosterize : CIFilter
@property (retain, nonatomic) NSNumber *inputLevels;
@end

@interface CIColorMonochrome : CIFilter
@property (retain, nonatomic) NSNumber *inputIntensity;
@property (retain, nonatomic) CIColor *inputColor;
@end

@interface CIFalseColor : CIFilter
@property (retain, nonatomic) CIColor *inputColor0;
@property (retain, nonatomic) CIColor *inputColor1;
@end

@interface CISepiaTone : CIFilter
@property (retain, nonatomic) NSNumber *inputIntensity;
@end

@interface CIVibrance : CIFilter
@property (retain, nonatomic) NSNumber *inputAmount;
@end

@interface CIBloom : CIFilter
@property (retain, nonatomic) NSNumber *inputIntensity;
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGloom : CIFilter
@property (retain, nonatomic) NSNumber *inputIntensity;
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGaussianBlur : CIFilter
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIThermal : CIFilter
@end

@interface CIXRay : CIFilter
@end

@interface CIPixellate : CIFilter
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputScale;
@end

@interface CIStretch : CIFilter
@property (retain, nonatomic) CIVector *inputPoint;
@property (retain, nonatomic) CIVector *inputSize;
@end

@interface CITwirlDistortion : CIFilter
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputRadius;
@property (retain, nonatomic) NSNumber *inputAngle;
@end

@interface CIHoleDistortion : CIFilter
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIPinchDistortion : CIFilter
@property (retain, nonatomic) NSNumber *inputScale;
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIMirror : CIFilter
@property (retain, nonatomic) NSNumber *inputAngle;
@property (retain, nonatomic) CIVector *inputPoint;
@end

@interface CIWrapMirror : CIFilter
@end

@interface CISharpenLuminance : CIFilter
@property (retain, nonatomic) NSNumber *inputSharpness;
@end

@interface CITriangleKaleidoscope : CIFilter
@property (retain, nonatomic) NSNumber *inputDecay;
@property (retain, nonatomic) NSNumber *inputSize;
@property (retain, nonatomic) NSNumber *inputAngle;
@property (retain, nonatomic) CIVector *inputPoint;
@end

@interface CILightTunnel : CIFilter
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputRotation;
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CICircleSplashDistortion : CIFilter
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputRadius;
@end

@interface CICircularScreen : CIFilter
@property (retain, nonatomic) CIVector *inputCenter;
@property (retain, nonatomic) NSNumber *inputWidth;
@property (retain, nonatomic) NSNumber *inputSharpness;
@end

@interface CILineScreen : CIFilter
@property (retain, nonatomic) NSNumber *inputAngle;
@property (retain, nonatomic) NSNumber *inputWidth;
@property (retain, nonatomic) NSNumber *inputSharpness;
@end
