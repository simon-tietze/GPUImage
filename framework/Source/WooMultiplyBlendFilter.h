#import "GPUImageTwoInputFilter.h"

@interface WooMultiplyBlendFilter : GPUImageTwoInputFilter
{
	GPUMatrix4x4 colorTransform;
	GLint colorTransformUniform;
}

@property (readwrite, nonatomic, copy) UIColor* color1;
@property (readwrite, nonatomic, copy) UIColor* color2;
@property (readwrite, nonatomic, copy) UIColor* color3;
@property (readwrite, nonatomic) CGFloat luminanceTransfer;

@end
