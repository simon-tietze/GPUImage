#import "RawDataTestAppDelegate.h"

@implementation RawDataTestAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    unsigned char n = 1000;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    GLubyte *rawDataBytes = calloc(n * n * 4, sizeof(GLubyte));
    for (unsigned int yIndex = 0; yIndex < n; yIndex++)
    {
        for (unsigned int xIndex = 0; xIndex < n; xIndex++)
        {
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4] = xIndex;
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4 + 1] = yIndex;
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4 + 2] = 255;
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4 + 3] = 0;            
        }
    }
    
    GPUImageRawDataInput *rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:rawDataBytes size:CGSizeMake(n, n)];
    GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CalculationShader"];
    GPUImageRawDataOutput *rawDataOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(n, n) resultsInBGRAFormat:YES];
    
    [rawDataInput addTarget:customFilter];
    [customFilter addTarget:rawDataOutput];
    
    [rawDataOutput setNewFrameAvailableBlock:^{
        GLubyte *outputBytes = [rawDataOutput rawBytesForImage];
        NSInteger bytesPerRow = [rawDataOutput bytesPerRowInOutput];
        NSLog(@"Bytes per row: %d", bytesPerRow);
        for (unsigned int yIndex = 0; yIndex < n; yIndex++)
        {
            for (unsigned int xIndex = 0; xIndex < n; xIndex++)
            {
                NSLog(@"Byte at (%d, %d): %d, %d, %d, %d", xIndex, yIndex, outputBytes[yIndex * bytesPerRow + xIndex * 4], outputBytes[yIndex * bytesPerRow + xIndex * 4 + 1], outputBytes[yIndex * bytesPerRow + xIndex * 4 + 2], outputBytes[yIndex * bytesPerRow + xIndex * 4 + 3]);
            }
        }
    }];
    
    [rawDataInput processData];
    
    free(rawDataBytes);

    return YES;
}

@end
