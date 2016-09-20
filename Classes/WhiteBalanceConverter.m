
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WhiteBalanceConverter.h"
#import "WhiteBalanceProcessorDef.h"
#import "WhiteBalanceProcessorNOP.h"
#import "PreviewHelper.h"
#import "WhiteBalanceProducer.h"
#import "ApplicationUtility.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"

@implementation WhiteBalanceConverter

#pragma mark
#pragma mark === pixelNumbers for each orientation ===
#pragma mark

// $W=5; $H=10;
// 
// # DOWN(3)
// print "===== DOWN =====\n";
// for( $j=0; $j<$H; $j++ ){
//     for( $i=0; $i<$W; $i++ ){
//         $n = ($H - $j) + $H * $i - 1;
//         print "$n, ";
//     }
//     print "\n";
// }
// print "\n";
- (void) init_sortedPixelNumbers_down
{
    unsigned char *pixelNumbers_down = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    sortedPixelNumbers_down = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    
    unsigned char *pixel_cursor = pixelNumbers_down;
    int *pixel_cursor_int;
    int W = [DeviceConfig stillimageWidth];
    int H = [DeviceConfig stillimageHeight];
    int n = 0;
    int n2 = 0;
    for( int j = 0; j < H; j++ ){
        for( int i = 0; i < W; i++ ){
            n = (H - j) + H * i - 1;
            n2 = n << 2; // as byte location
            pixel_cursor_int = (int *)pixel_cursor;
            *pixel_cursor_int = n2;
            pixel_cursor+=4;
        }
    }
    
	// pre-sort lines to load in neon world
	sortedPixelNumbers_down = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
	ArrangePixelNumbersForNeon((int *)pixelNumbers_down,(int *)sortedPixelNumbers_down,[DeviceConfig stillimagePixels]);
    
    free(pixelNumbers_down);
}

// # UP(3)
// print "===== UP =====\n";
// for( $j=0; $j<$H; $j++ ){
//     for( $i=0; $i<$W; $i++ ){
//         $n = $W * $H - $H * ($i + 1) + $j;
//         print "$n, ";
//     }
//     print "\n";
// }
// print "\n";
- (void) init_sortedPixelNumbers_up
{
    unsigned char *pixelNumbers_up = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    sortedPixelNumbers_up = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    
    unsigned char *pixel_cursor = pixelNumbers_up;
    int *pixel_cursor_int;
    int W = [DeviceConfig stillimageWidth];
    int H = [DeviceConfig stillimageHeight];
    int n = 0;
    int n2 = 0;
    for( int j = 0; j < H; j++ ){
        for( int i = 0; i < W; i++ ){
            n = W * H - H * (i + 1) + j;
            n2 = n << 2; // as byte location
            pixel_cursor_int = (int *)pixel_cursor;
            *pixel_cursor_int = n2;
            pixel_cursor+=4;
        }
    }
    
	// pre-sort lines to load in neon world
	sortedPixelNumbers_up = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
	ArrangePixelNumbersForNeon((int *)pixelNumbers_up,(int *)sortedPixelNumbers_up,[DeviceConfig stillimagePixels]);
    
    free(pixelNumbers_up);
}

// # RIGHT(3)
// print "===== RIGHT =====\n";
// for( $i=0; $i<$W; $i++ ){
//     for( $j=0; $j<$H; $j++ ){
//         $n = $W * $H - ($H * $i) - $j - 1;
//         print "$n, ";
//     }
//     print "\n";
// }
// print "\n";
- (void) init_sortedPixelNumbers_right
{
    unsigned char *pixelNumbers_right = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    sortedPixelNumbers_right = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    
    unsigned char *pixel_cursor = pixelNumbers_right;
    int *pixel_cursor_int;
    int W = [DeviceConfig stillimageWidth];
    int H = [DeviceConfig stillimageHeight];
    int n = 0;
    int n2 = 0;
    for( int i = 0; i < W; i++ ){
        for( int j = 0; j < H; j++ ){
            n = W * H - (H * i) - j - 1;
            n2 = n << 2; // as byte location
            pixel_cursor_int = (int *)pixel_cursor;
            *pixel_cursor_int = n2;
            pixel_cursor+=4;
        }
    }
    
	// pre-sort lines to load in neon world
	sortedPixelNumbers_right = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
	ArrangePixelNumbersForNeon((int *)pixelNumbers_right,(int *)sortedPixelNumbers_right,[DeviceConfig stillimagePixels]);
    
    free(pixelNumbers_right);
}

// # LEFT(3)
// print "===== LEFT =====\n";
// for( $i=0; $i<$W; $i++ ){
//     for( $j=0; $j<$H; $j++ ){
//         $n = ($H * $i)  + $j;
//         print "$n, ";
//     }
//     print "\n";
// }
// print "\n";
- (void) init_sortedPixelNumbers_left
{
    unsigned char *pixelNumbers_left = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    sortedPixelNumbers_left = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
    
    unsigned char *pixel_cursor = pixelNumbers_left;
    int *pixel_cursor_int;
    int W = [DeviceConfig stillimageWidth];
    int H = [DeviceConfig stillimageHeight];
    int n = 0;
    int n2 = 0;
    for( int i = 0; i < W; i++ ){
        for( int j = 0; j < H; j++ ){
            n = (H * i) + j;
            n2 = n << 2; // as byte location
            pixel_cursor_int = (int *)pixel_cursor;
            *pixel_cursor_int = n2;
            pixel_cursor+=4;
        }
    }
    
	// pre-sort lines to load in neon world
	sortedPixelNumbers_left = (unsigned char *)malloc([DeviceConfig stillimagePixels]*4);
	ArrangePixelNumbersForNeon((int *)pixelNumbers_left,(int *)sortedPixelNumbers_left,[DeviceConfig stillimagePixels]);
    
    free(pixelNumbers_left);
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
    self = [super init];
    
    // prep pixel numbers for snap
    [self init_sortedPixelNumbers_up];
    [self init_sortedPixelNumbers_down];
    [self init_sortedPixelNumbers_right];
    [self init_sortedPixelNumbers_left];
    
    return self;
}

/*- (void) dealloc 
{
    free(sortedPixelNumbers_up);
    free(sortedPixelNumbers_down);
    free(sortedPixelNumbers_right);
    free(sortedPixelNumbers_left);
}*/

#pragma mark
#pragma mark === whitebalance tool ===
#pragma mark

// 
// for BGRA, preview data stream from camera session
// 
- (CGImageRef)  allocCGImageApplyingWhiteBalanceForCMSampleBufferRef:(CMSampleBufferRef)sampleBuffer withALAssetOrientation:(ALAssetOrientation)orientation
{
    // *********************
    // 
    // select pixelNumbers,
    // define image rect
    // 
    // *********************
    unsigned char *sortedPixelNumbers_now;
    int image_width;
    int image_height;
    switch( orientation ){
            
        case ALAssetOrientationUp:
            sortedPixelNumbers_now = sortedPixelNumbers_up;
            image_width  = [DeviceConfig stillimageWidth];
            image_height = [DeviceConfig stillimageHeight];
            break;
            
        case ALAssetOrientationDown:
            sortedPixelNumbers_now = sortedPixelNumbers_down;
            image_width  = [DeviceConfig stillimageWidth];
            image_height = [DeviceConfig stillimageHeight];
            break;
            
        case ALAssetOrientationRight:
            sortedPixelNumbers_now = sortedPixelNumbers_right;
            image_width  = [DeviceConfig stillimageHeight];
            image_height = [DeviceConfig stillimageWidth];
            break;
            
        case ALAssetOrientationLeft:
            sortedPixelNumbers_now = sortedPixelNumbers_left;
            image_width  = [DeviceConfig stillimageHeight];
            image_height = [DeviceConfig stillimageWidth];
            break;
            
        default:
            break;
    }
    
    // base address for the source image
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    //CGRect rect = CVImageBufferGetCleanRect(pixelBuffer);
    //NSLog(@"### allocCGImageApplyingWhiteBalanceForCMSampleBufferRef w:%f,h:%f",rect.size.width,rect.size.height);
    
    unsigned char *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // base address for the output image
    unsigned char *reducerAddress = (unsigned char *)malloc([DeviceConfig stillimageSize]);
    unsigned char *reducer = reducerAddress;
    
    // whitebalance parameter array, bgr parameter
    PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
    int wbp[3];
    wbp[0] = [previewHelper currentWhiteBalanceParameterBp];
    wbp[1] = [previewHelper currentWhiteBalanceParameterGp];
    wbp[2] = [previewHelper currentWhiteBalanceParameterRp];
    
    //NSLog(@"### wbp Bp:%d,Gp:%d,Rp:%d",wbp[0],wbp[1],wbp[2]);
    
    //NSDate *now = [NSDate date];
    
    // whitebalance processor
    WhiteBalanceProcessorDef *whiteBalanceProcessor = [WhiteBalanceProducer getCurrentWhiteBalanceProcessor];
    
    // process whitebalance
    [whiteBalanceProcessor processBitmapBGRA:baseAddress reducer:reducer pixelNumber:(int *)sortedPixelNumbers_now whitebalanceParameter:wbp reducedPixelNumber:[DeviceConfig stillimagePixels]*4];
    
    //NSDate *then = [NSDate date];
	//NSLog(@"WB[NEON]: %1.3fsec", [then timeIntervalSinceDate:now]);
    
    //NSDate *now_img = [NSDate date];
    
    // and get CGImage object
    CGImageRef cgimage = CreateCGImageFromBitmap(reducer,image_width,image_height);
    
    //NSDate *then_img = [NSDate date];
	//NSLog(@"WB[IMG] : %1.3fsec", [then_img timeIntervalSinceDate:now_img]);
    
    // unlock the base address
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    free(reducerAddress);
    
    return cgimage;
}

// 
// for RGBA, bitmap retrieved from jpeg
// 
- (CGImageRef) allocCGImageApplyingWhiteBalanceForCFDataRef:(CFDataRef)dataRef withALAssetOrientation:(ALAssetOrientation)orientation
{
    // *********************
    // 
    // select pixelNumbers,
    // define image rect
    // 
    // *********************
    unsigned char *sortedPixelNumbers_now;
    int image_width;
    int image_height;
    switch( orientation ){
            
        case ALAssetOrientationUp:
            sortedPixelNumbers_now = sortedPixelNumbers_up;
            image_width  = [DeviceConfig stillimageWidth];
            image_height = [DeviceConfig stillimageHeight];
            break;
            
        case ALAssetOrientationDown:
            sortedPixelNumbers_now = sortedPixelNumbers_down;
            image_width  = [DeviceConfig stillimageWidth];
            image_height = [DeviceConfig stillimageHeight];
            break;
            
        case ALAssetOrientationRight:
            sortedPixelNumbers_now = sortedPixelNumbers_right;
            image_width  = [DeviceConfig stillimageHeight];
            image_height = [DeviceConfig stillimageWidth];
            break;
            
        case ALAssetOrientationLeft:
            sortedPixelNumbers_now = sortedPixelNumbers_left;
            image_width  = [DeviceConfig stillimageHeight];
            image_height = [DeviceConfig stillimageWidth];
            break;
            
        default:
            break;
    }
    
    // base address for the source image
    unsigned char *buffer = (unsigned char *)CFDataGetBytePtr(dataRef);
    
    // base address for the output image
    unsigned char *reducerAddress = (unsigned char *)malloc([DeviceConfig stillimageSize]);
    unsigned char *reducer = reducerAddress;
    
    // whitebalance parameter array, bgr parameter
    PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
    int wbp[3];
    wbp[0] = [previewHelper currentWhiteBalanceParameterBp];
    wbp[1] = [previewHelper currentWhiteBalanceParameterGp];
    wbp[2] = [previewHelper currentWhiteBalanceParameterRp];
    
    //NSLog(@"### wbp Bp:%d,Gp:%d,Rp:%d",wbp[0],wbp[1],wbp[2]);
    
    //NSDate *now = [NSDate date];
    
    // whitebalance processor
    WhiteBalanceProcessorDef *whiteBalanceProcessor = [WhiteBalanceProducer getCurrentWhiteBalanceProcessor];
    
    // process whitebalance
    [whiteBalanceProcessor processBitmapRGBA:buffer reducer:reducer pixelNumber:(int *)sortedPixelNumbers_now whitebalanceParameter:wbp reducedPixelNumber:[DeviceConfig stillimagePixels]*4];
    
    //NSDate *then = [NSDate date];
	//NSLog(@"WB[NEON]: %1.3fsec", [then timeIntervalSinceDate:now]);
    
    //NSDate *now_img = [NSDate date];
    
    // and get CGImage object
    CGImageRef cgimage = CreateCGImageFromBitmap(reducer,image_width,image_height);
    
    //NSDate *then_img = [NSDate date];
	//NSLog(@"WB[IMG] : %1.3fsec", [then_img timeIntervalSinceDate:now_img]);
    
    free(reducerAddress);
    
    return cgimage;
}

- (void) kickstart
{
    // do nothing, singleton startup
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

static WhiteBalanceConverter *sharedInstance = nil;

+ (void) bootup
{
    WhiteBalanceConverter *instance = [self sharedInstance];
    [instance kickstart];
}

+ (id) sharedInstance
{
    @synchronized(self){
		if( !sharedInstance ){
			sharedInstance = [[WhiteBalanceConverter alloc] init];
		}
	}
    return sharedInstance;
}

@end

