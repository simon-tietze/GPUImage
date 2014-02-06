#import "GPUImageTwoInputFilter.h"

@interface WooMultiplyBlendFilter : GPUImageTwoInputFilter
{
	GPUMatrix4x4 colorTransform;
	GLint colorTransformUniform;
	
	GLint lumaPowerUniform;
	GLint lumaMultUniform;
	GLint gammaUniform;
}

@property (readwrite, nonatomic, copy) UIColor* color1;
@property (readwrite, nonatomic, copy) UIColor* color2;
@property (readwrite, nonatomic, copy) UIColor* color3;
@property (readwrite, nonatomic) CGFloat lumaPower;
@property (readwrite, nonatomic) CGFloat lumaMult;
@property (readwrite, nonatomic) CGFloat gamma;

@end
