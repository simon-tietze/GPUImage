#import "WooMultiplyBlendFilter.h"

NSString *const kWooMultiplyBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp mat4 colorTransform;
 
 void main()
 {
    lowp vec4 faceColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 maskColorOrig = texture2D(inputImageTexture2, textureCoordinate2);


    lowp float whiteness = (maskColorOrig.r + maskColorOrig.g + maskColorOrig.b) / 3.0; 
    vec4 transformedColor = maskColorOrig.r * colorTransform[0] +
                            maskColorOrig.g * colorTransform[1] +
                            maskColorOrig.b * colorTransform[2];
    lowp vec4  maskColor =  mix(transformedColor,
                                maskColorOrig,
                                max(0, 20.0 * (whiteness - 0.95)));
    maskColor.a = maskColorOrig.a;

    lowp vec4 linearFaceColor = faceColor;
    linearFaceColor.rgb = pow(linearFaceColor.rgb, lowp vec3(2.2));
	lowp vec4 lumaAxis = vec4(0.299, 0.587, 0.114, 0);
    lowp float faceLuma  = dot(linearFaceColor, lumaAxis);

    lowp vec4 blendColor = maskColor.a * clamp(1.0 * faceLuma,0.0,1.0) * maskColor;
    lowp vec4 gammaBlendColor = pow(blendColor, lowp vec4(1.0/2.2));    
 	gl_FragColor = gammaBlendColor;
 }
);

@implementation WooMultiplyBlendFilter

@synthesize luminanceTransfer = _luminanceTransfer;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kWooMultiplyBlendFragmentShaderString]))
    {
		return nil;
    }

    colorTransformUniform = [filterProgram uniformIndex:@"colorTransform"];

    colorTransform = (GPUMatrix4x4){
        {1.f, 0.f, 0.f, 0.f},
        {0.f, 1.f, 0.f, 0.f},
        {0.f, 0.f, 1.f, 0.f},
        {0.f, 0.f, 0.f, 1.f}
    };
	[self setMatrix4f:colorTransform forUniform:colorTransformUniform program:filterProgram];

    return self;
}

- (void) setColor1:(UIColor *) c {
    GPUVector4 v;
    [c getRed: &v.one green: &v.two blue: &v.three alpha: &v.four];
    v.four = 0;
	colorTransform.one = v;
	[self setMatrix4f:colorTransform forUniform:colorTransformUniform program:filterProgram];
}

- (UIColor *) color1 {
	return [[UIColor alloc] initWithRed: (float) colorTransform.one.one green: (float) colorTransform.one.two blue: (float) colorTransform.one.three alpha: 1.0f];
}

- (void) setColor2:(UIColor *) c {
    GPUVector4 v;
    [c getRed: &v.one green: &v.two blue: &v.three alpha: &v.four];
    v.four = 0;
    colorTransform.two = v;
    [self setMatrix4f:colorTransform forUniform:colorTransformUniform program:filterProgram];
}

- (UIColor *) color2 {
    return [[UIColor alloc] initWithRed: (float) colorTransform.two.one green: (float) colorTransform.two.two blue: (float) colorTransform.two.three alpha: 1.0f];
}

- (void) setColor3:(UIColor *) c {
    GPUVector4 v;
    [c getRed: &v.one green: &v.two blue: &v.three alpha: &v.four];
    v.four = 0;
    colorTransform.three = v;
    [self setMatrix4f:colorTransform forUniform:colorTransformUniform program:filterProgram];
}

- (UIColor *) color3 {
    return [[UIColor alloc] initWithRed: (float) colorTransform.three.one green: (float) colorTransform.three.two blue: (float) colorTransform.three.three alpha: 1.0f];
}


- (void)setLuminanceTransfer:(CGFloat)newValue;
{
    _luminanceTransfer = newValue;
}


@end

