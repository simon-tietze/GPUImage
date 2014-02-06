#import "WooMultiplyBlendFilter.h"

NSString *const kWooMultiplyBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp mat4 colorTransform;

 uniform lowp float lumaPower;
 uniform lowp float lumaMult;
 uniform lowp float wireframe;
 uniform lowp float gamma;
 
 void main()
 {
    lowp vec4 faceColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 maskColorOrig = texture2D(inputImageTexture2, textureCoordinate2);


    highp float whiteness = (maskColorOrig.r + maskColorOrig.g + maskColorOrig.b) / 3.0; 
    lowp vec4 transformedColor = maskColorOrig.r * colorTransform[0] +
                                 maskColorOrig.g * colorTransform[1] +
                                 maskColorOrig.b * colorTransform[2];
    // don't transform colors close to white
    lowp vec4  maskColor =  mix(transformedColor,
                                maskColorOrig,
                                max(0.0, 20.0 * (whiteness - 0.95)));
    maskColor.a = maskColorOrig.a;

    lowp vec4 linearFaceColor = faceColor;
    linearFaceColor.rgb = pow(linearFaceColor.rgb, lowp vec3(gamma));
	lowp vec4 lumaAxis = vec4(0.299, 0.587, 0.114, 0);
    lowp float faceLuma  = dot(linearFaceColor, lumaAxis);
    faceLuma = lumaBase + pow(faceLuma, lumaPower) * lumaMult;

    lowp vec4 blendColor = maskColor.a * clamp(faceLuma, 0.0, 1.0) * maskColor;
    blendColor.a = maskColorOrig.a;
    lowp vec4 gammaBlendColor = pow(blendColor, lowp vec4(1.0/gamma));    
 	gl_FragColor = gammaBlendColor;
 }
);

@implementation WooMultiplyBlendFilter

@synthesize lumaPower = _lumaPower;
@synthesize lumaMult = _lumaMult;
@synthesize wireframe = _wireframe;
@synthesize gamma = _gamma;

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

    lumaPowerUniform = [filterProgram uniformIndex:@"lumaPower"];
    self.lumaPower = 1.0;

    lumaMultUniform = [filterProgram uniformIndex:@"lumaMult"];
    self.lumaMult = 1.0;

    wireframeUniform = [filterProgram uniformIndex:@"wireframe"];
    self.wireframe = 0.0;

    gammaUniform = [filterProgram uniformIndex:@"gamma"];
    self.gamma = 2.2;

    return self;
}

- (void) setColor1:(UIColor *) c {
    GPUVector4 v;
    [c getRed: &v.one green: &v.two blue: &v.three alpha: &v.four];
    v.four = 0;
	colorTransform.one = v;
	[self setMatrix4f:colorTransform forUniform:colorTransformUniform program:filterProgram];
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.one.one, colorTransform.one.two, colorTransform.one.three, colorTransform.one.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.two.one, colorTransform.two.two, colorTransform.two.three, colorTransform.two.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.three.one, colorTransform.three.two, colorTransform.three.three, colorTransform.three.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.four.one, colorTransform.four.two, colorTransform.four.three, colorTransform.four.four);
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
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.one.one, colorTransform.one.two, colorTransform.one.three, colorTransform.one.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.two.one, colorTransform.two.two, colorTransform.two.three, colorTransform.two.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.three.one, colorTransform.three.two, colorTransform.three.three, colorTransform.three.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.four.one, colorTransform.four.two, colorTransform.four.three, colorTransform.four.four);
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
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.one.one, colorTransform.one.two, colorTransform.one.three, colorTransform.one.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.two.one, colorTransform.two.two, colorTransform.two.three, colorTransform.two.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.three.one, colorTransform.three.two, colorTransform.three.three, colorTransform.three.four);
    NSLog(@"colorTransform:\t%f\t%f\t%f", colorTransform.four.one, colorTransform.four.two, colorTransform.four.three, colorTransform.four.four);
}

- (UIColor *) color3 {
    return [[UIColor alloc] initWithRed: (float) colorTransform.three.one green: (float) colorTransform.three.two blue: (float) colorTransform.three.three alpha: 1.0f];
}


- (void)setLumaPower:(CGFloat)newValue;
{
    _lumaPower = newValue;
    [self setFloat:_lumaPower forUniform:lumaPowerUniform program:filterProgram];
}

- (void)setLumaMult:(CGFloat)newValue;
{
    _lumaMult = newValue;
    [self setFloat:_lumaMult forUniform:lumaMultUniform program:filterProgram];
}

- (void)setWireframe:(CGFloat)newValue;
{
    _wireframe = newValue;
    [self setFloat:_wireframe forUniform:wireframeUniform program:filterProgram];
}

- (void)setGamma:(CGFloat)newValue;
{
    _gamma = newValue;
    [self setFloat:_gamma forUniform:gammaUniform program:filterProgram];
}


@end

