
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "PreviewHelper.h"
#import "PreviewLayer.h"
#import "PreviewUtility.h"
#import "ApplicationUtility.h"

#import "PreviewHelper_iPhone4_iOS5.h"
#import "PreviewHelper_iPhone4_iOS6.h"
#import "PreviewHelper_iPhone4_iOS7.h"
#import "PreviewHelper_iPhone4S_iOS5.h"
#import "PreviewHelper_iPhone4S_iOS6.h"
#import "PreviewHelper_iPhone4S_iOS7.h"
#import "PreviewHelper_iPhone5_iOS6.h"
#import "PreviewHelper_iPhone5_iOS7.h"
#import "PreviewHelper_iPhone5S_iOS7.h"
#import "PreviewHelper_iPhone5C_iOS7.h"
#import "PreviewHelper_iPod4_iOS5.h"
#import "PreviewHelper_iPod4_iOS6.h"
#import "PreviewHelper_iPod5_iOS6.h"
#import "PreviewHelper_iPod5_iOS7.h"

@implementation PreviewHelper
@synthesize layer;
@synthesize whiteBalanceProcessor;
@synthesize whiteBalanceProcessorNOP;
@synthesize whiteBalanceProducer;
@synthesize shouldAdjustWhiteBalance;
@synthesize manualPreviewFrameRate;
@synthesize exposureAdjustmentLevel;

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

static PreviewHelper *instance = nil;

+ (id) sharedInstance
{
	//NSLog(@"PreviewHelper instance called");
	@synchronized(self){
		if( !instance ){
            ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
            DeviceConfig *deviceConfig = [app_conf deviceConfig];
            
            switch (deviceConfig.deviceIdentification) {
                    
                case kDeviceIdentification_iPhone4_iOS5:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone4_iOS5");
                    instance = [[PreviewHelper_iPhone4_iOS5 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone4_iOS6:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone4_iOS6");
                    instance = [[PreviewHelper_iPhone4_iOS6 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone4_iOS7:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone4_iOS7");
                    instance = [[PreviewHelper_iPhone4_iOS7 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS5:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone4S_iOS5");
                    instance = [[PreviewHelper_iPhone4S_iOS5 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS6:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone4S_iOS6");
                    instance = [[PreviewHelper_iPhone4S_iOS6 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS7:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone4S_iOS7");
                    instance = [[PreviewHelper_iPhone4S_iOS7 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone5_iOS6:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone5_iOS6");
                    instance = [[PreviewHelper_iPhone5_iOS6 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone5_iOS7:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone5_iOS7");
                    instance = [[PreviewHelper_iPhone5_iOS7 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone5S_iOS7:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone5S_iOS7");
                    instance = [[PreviewHelper_iPhone5S_iOS7 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPhone5C_iOS7:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPhone5C_iOS7");
                    instance = [[PreviewHelper_iPhone5C_iOS7 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPod4_iOS5:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPod4_iOS5");
                    instance = [[PreviewHelper_iPod4_iOS5 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPod4_iOS6:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPod4_iOS6");
                    instance = [[PreviewHelper_iPod4_iOS6 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPod5_iOS6:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPod5_iOS6");
                    instance = [[PreviewHelper_iPod5_iOS6 alloc] init];
                    break;
                    
                case kDeviceIdentification_iPod5_iOS7:
                    NSLog(@"PreviewHelper concrete instance : PreviewHelper_iPod5_iOS7");
                    instance = [[PreviewHelper_iPod5_iOS7 alloc] init];
                    break;
                    
                default:
                    break;
                    
            }
			//[instance initializeHelper]; // should be called in init()
		}
	}
    return instance;
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
    self = [super init];
    [self initializeHelper];
	exposureAdjustmentLevel = 0;
	exposureAdjustmentParam = 0;
    return self;
}

- (void) initializeHelper {}

// requires serial queue
- (void) clearPipeline
{
    self.layer.frameImage = nil;
    [self.layer setNeedsDisplay];
}

// recommended dealloc implementation
/*
- (void) dealloc 
{
	free(reducer);
    free(pixelNumbers);
    free(sortedPixelNumbers);
    free(whitebalanceParameter);
    [whiteBalanceProcessor dealloc];
    [whiteBalanceProcessorNOP dealloc];
    [whiteBalanceProducer dealloc];
	[self.layer dealloc];
    [super dealloc];
}
*/

#pragma mark
#pragma mark === abstruct, management of whitebalance parameter ===
#pragma mark

- (void) setWhiteBalanceParam:(float)Tx Ty:(float)Ty {}
- (void) getPointColor:(int *)colors atTx:(float)Tx Ty:(float)Ty {}

#pragma mark
#pragma mark === abstruct, perview processing ===
#pragma mark

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {}

static inline CGImageRef CreateCGImageFromPixelBuffer_Impl(WhiteBalanceProcessorDef *whiteBalanceProcessor, CVPixelBufferRef pixelBuffer, unsigned char *reducer, unsigned char *pixelNumbers, int *wbp) 
{
    return nil;
}

#pragma mark
#pragma mark === luminance control ===
#pragma mark

- (void) luminancePlus
{
	if( exposureAdjustmentLevel < 5 ){
		exposureAdjustmentLevel++;
	}
	[self enableWhiteBalanceWithRealParameter:whitebalanceParameterReal]; // method applies exposureAdjustmentParam
}
- (void) luminanceMinus
{
	if( exposureAdjustmentLevel > -5 ){
		exposureAdjustmentLevel--;
	}
	[self enableWhiteBalanceWithRealParameter:whitebalanceParameterReal]; // method applies exposureAdjustmentParam
}

- (void) discardLuminance
{
	exposureAdjustmentLevel = 0;
	exposureAdjustmentParam = 0;
}

#pragma mark
#pragma mark === whitebalance parameter by image ===
#pragma mark

- (void) setWhiteBalanceParamByImage:(UIImage *)image
{
    NSLog(@"setWhiteBalanceParamByImage called");
    
    //int image_width = CGImageGetWidth(image.CGImage);
    //int image_height = CGImageGetHeight(image.CGImage);
    int image_width = image.size.width;
    int image_height = image.size.height;
    int image_pixels = image_width * image_height;
    
    int center_x = (int)(image_width / 2);
    int center_y = (int)(image_height / 2);
    
    int pixelNumber = center_y * image_width + center_x;
	
    CGImageRef imageRef = [image CGImage];
    //size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    CFDataRef data = CGDataProviderCopyData(provider);
    unsigned char *pixels = (unsigned char *)CFDataGetBytePtr(data);
    
	NSLog(@"image size   : %d,%d", image_width, image_height);
    NSLog(@"image pixels : %d", image_pixels);
    //NSLog(@"image row    : %d", bytesPerRow);
    NSLog(@"image cneter : %d,%d", center_x,center_y);
	
	// pin and its rgb
	//unsigned char *pinpix = pixels + pixelNumber * 4;
	//int pBw = pinpix[0];
    //int pGw = pinpix[1];
    //int pRw = pinpix[2];
    //NSLog(@"[selected image] WB point [pinned  ] : %d, %d, %d", pBw, pGw, pRw);
    
    // spreaded
    int spreaded = 0;
    int sRw = 0;
    int sGw = 0;
    int sBw = 0;
    for( int i = -2; i < 2; i++ ){
        for( int j = - 2; j < 2; j++ ){
            int pixelnum = pixelNumber - i * image_width + j;
            if( pixelnum < 0 ){ continue; }
            if( pixelnum > image_pixels ){ continue; }
            unsigned char *pix = pixels + pixelnum * 4;
            sRw += (int)pix[0]; // *****
            sGw += (int)pix[1]; //  RGB 
            sBw += (int)pix[2]; // *****
            spreaded++;
            //NSLog(@"[selected image] spread (%d): %d,%d,%d", pixelnum, pix[0], pix[1], pix[2]);
            //NSLog(@"[selected image] spread (%d): %d,%d,%d", pixelnum, sRw, sGw, sBw);
        }
    }
    int Rw = (int)(sRw / spreaded);
    int Gw = (int)(sGw / spreaded);
    int Bw = (int)(sBw / spreaded);
    
	NSLog(@"[selected image] WB point [spreaded] : %d, %d, %d", Bw, Gw, Rw);
	//NSLog(@"[selected image] sum: %d,%d,%d (%d)", sRw,sGw,sBw,spreaded);
    
	// select largest color element
	int max_color = 0;
    int colors[3];
    colors[0] = Rw;
    colors[1] = Gw;
    colors[2] = Bw;
	for( int i = 0; i < 3; i++ ){
		if( colors[i] > max_color )
			max_color = colors[i];
	}
    NSLog(@"max                 : %d", max_color );
    
    // brightness preservation
    float preserved_Y = 0.299 * Rw + 0.587 * Gw + 0.114 * Bw;
    float Vw = 0.5 * max_color - 0.419 * max_color - 0.081 * max_color; // V of YUV
    
    // adjusted gray point
    // 
    // full rgb is calculated by these line, but all the same.
    // 
    // float Yw = 0.299 * max_color + 0.587 * max_color + 0.114 * max_color;
    // float Uw = -0.169 * max_color - 0.331 * max_color + 0.5 * max_color;
    // float Vw = 0.5 * max_color - 0.419 * max_color - 0.081 * max_color;
    // float bRwf = preserved_Y + 1.402*Vw;
    // float bGwf = preserved_Y - 0.344*Uw - 0.714*Vw;
    // float bBwf = preserved_Y + 1.772*Uw;
    // 
    float adjusted_max_color = preserved_Y + 1.402*Vw;
    NSLog(@"max (adjusted)      : %d", (int)adjusted_max_color );
    
    NSLog(@"WB point [preserve] : %d, %d, %d", (int)adjusted_max_color, (int)adjusted_max_color, (int)adjusted_max_color);
    
	// white balance parameter with preserved brightness
	float Rpf = (adjusted_max_color / Rw) - 1;
	float Gpf = (adjusted_max_color / Gw) - 1;
	float Bpf = (adjusted_max_color / Bw) - 1;
	
    // whitebalance parameter
	int Rp = (int)(Rpf*256);
	int Gp = (int)(Gpf*256);
	int Bp = (int)(Bpf*256);
	
    // now got real parameter
    whitebalanceParameterReal[0] = Bp;
    whitebalanceParameterReal[1] = Gp;
    whitebalanceParameterReal[2] = Rp;
    
    [self enableWhiteBalanceWithRealParameter:whitebalanceParameterReal];
    
    //CFRelease(data);
    
    NSLog(@"[selected image] WB param : %1.3d, %1.3d, %1.3d", whitebalanceParameterReal[0], whitebalanceParameterReal[1], whitebalanceParameterReal[2]);
}

#pragma mark
#pragma mark === management of whitebalance parameters ===
#pragma mark

- (void) enableWhiteBalance
{
    shouldAdjustWhiteBalance = YES;
}

- (void) cancelWhiteBalance
{
    // now always enable whitebalance
    whitebalanceParameterReal[0] = 0;
    whitebalanceParameterReal[1] = 0;
    whitebalanceParameterReal[2] = 0;
    whitebalanceParameter[0] = 0;
    whitebalanceParameter[1] = 0;
    whitebalanceParameter[2] = 0;
    self.whiteBalanceProcessor = [WhiteBalanceProducer getCurrentWhiteBalanceProcessorForParam:whitebalanceParameter];
    
    shouldAdjustWhiteBalance = YES;
    
	//shouldAdjustWhiteBalance = NO;
}

- (void) setWhiteBalanceParameterAsReal:(int *)realParam
{
    [self enableWhiteBalanceWithRealParameter:realParam];
}

- (void) enableWhiteBalanceWithRealParameter:(int *)realParam
{
	exposureAdjustmentParam = 25 * exposureAdjustmentLevel;
	
	int Bp = realParam[0];
	int Gp = realParam[1];
	int Rp = realParam[2];
	Bp = Bp + exposureAdjustmentParam;
	Gp = Gp + exposureAdjustmentParam;
	Rp = Rp + exposureAdjustmentParam;
//	if( Rp > 256 ){ Rp = 256; }
//	if( Gp > 256 ){ Gp = 256; }
//	if( Bp > 256 ){ Bp = 256; }
	
	int exposureAdjustedRealParam[3];
    exposureAdjustedRealParam[0] = Bp;
    exposureAdjustedRealParam[1] = Gp;
    exposureAdjustedRealParam[2] = Rp;
	
    // set and get processor
    self.whiteBalanceProcessor = [WhiteBalanceProducer getCurrentWhiteBalanceProcessorForParam:exposureAdjustedRealParam];
    
    // ready to plus/minus, reset to abs
    whitebalanceParameter[0] = abs(exposureAdjustedRealParam[0]);
	whitebalanceParameter[1] = abs(exposureAdjustedRealParam[1]);
	whitebalanceParameter[2] = abs(exposureAdjustedRealParam[2]);
    
	shouldAdjustWhiteBalance = YES;
}

// access for the real parameters, 
- (int) currentWhiteBalanceParameterRealBp
{
    return whitebalanceParameterReal[0];
}
- (int) currentWhiteBalanceParameterRealGp
{
    return whitebalanceParameterReal[1];
}
- (int) currentWhiteBalanceParameterRealRp
{
    return whitebalanceParameterReal[2];
}

// these methods requires absolute values,
// but to calculate whitebalance, it is required real values.
// so these should not be used.
- (void) setWhiteBalanceParameterRealBp:(int)Bp
{
    whitebalanceParameterReal[0] = Bp;
}
- (void) setWhiteBalanceParameterRealGp:(int)Gp
{
    whitebalanceParameterReal[1] = Gp;
}
- (void) setWhiteBalanceParameterRealRp:(int)Rp
{
    whitebalanceParameterReal[2] = Rp;
}

// access for the absolute parameters, 
// might be never used
- (int) currentWhiteBalanceParameterBp
{
    return whitebalanceParameter[0];
}
- (int) currentWhiteBalanceParameterGp
{
    return whitebalanceParameter[1];
}
- (int) currentWhiteBalanceParameterRp
{
    return whitebalanceParameter[2];
}

// these methods requires absolute values,
// but to calculate whitebalance, it is required real values.
// so these should not be used.
- (void) setWhiteBalanceParameterBp:(int)Bp
{
    whitebalanceParameter[0] = Bp;
}
- (void) setWhiteBalanceParameterGp:(int)Gp
{
    whitebalanceParameter[1] = Gp;
}
- (void) setWhiteBalanceParameterRp:(int)Rp
{
    whitebalanceParameter[2] = Rp;
}


@end
