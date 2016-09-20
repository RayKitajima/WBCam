
#import "PreviewHelper_iPhone4S_iOS7.h"
#import "PreviewUtility.h"
#import "ApplicationUtility.h"

#import "PreviewLayer_iPhone4S_iOS7.h"
#import "DeviceConfig_iPhone4S_iOS7.h"

@interface PreviewHelper_iPhone4S_iOS7(Private)
static inline CGImageRef CreateCGImageFromPixelBuffer_Impl(WhiteBalanceProcessorDef *whiteBalanceProcessor, CVPixelBufferRef pixelBuffer, unsigned char *reducer, unsigned char *pixelNumbers, int *wbp);
@end

@implementation PreviewHelper_iPhone4S_iOS7

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (void) initializeHelper
{
    // ***************************************************
	// prepare iPhone4S iOS7 specific perview layer object
    // ***************************************************
	self.layer = [PreviewLayer_iPhone4S_iOS7 layer];
	
    // define manual preview frame rate
    manualPreviewFrameRate = 0.03;
    
	//
	// preview processor object
	//
	self.whiteBalanceProcessorNOP = [[WhiteBalanceProcessorNOP alloc] init];
    self.whiteBalanceProducer = [[WhiteBalanceProducer alloc] init];
	
    // now, always enable whitebalance
    whitebalanceParameter[0] = 0;
    whitebalanceParameter[1] = 0;
    whitebalanceParameter[2] = 0;
    self.whiteBalanceProcessor = [WhiteBalanceProducer getCurrentWhiteBalanceProcessorForParam:whitebalanceParameter];
    shouldAdjustWhiteBalance = YES;
	
	unsigned char *reducerAddress = (unsigned char *)malloc(IPHONE4S_iOS7_PREVIEW_REDUCER_SIZE);
	reducer = reducerAddress;
	
	pixelNumbers = (unsigned char *)malloc(IPHONE4S_iOS7_PREVIEW_REDUCED_PIXELS*4);
	
	unsigned char *pixel_cursor = pixelNumbers;
	int *pixel_cursor_int;
	int W = IPHONE4S_iOS7_PREVIEW_BUFFER_HEIGHT; // reducedWidth
	int H = IPHONE4S_iOS7_PREVIEW_BUFFER_WIDTH;  // reducedHieght
    int p = IPHONE4S_iOS7_PREVIEW_BUFFER_PADDING;
    int Hp = H + p;
	int n = 0;
	int n2 = 0;
    for( int j=0; j<H; j+=IPHONE4S_iOS7_PREVIEW_REDUCE_RATE ){
        for( int i=0; i<W; i+=IPHONE4S_iOS7_PREVIEW_REDUCE_RATE ){
            n = (Hp * W) - (Hp * i) - j - 1;
            n2 = n << 2; // as byte location
            pixel_cursor_int = (int *)pixel_cursor;
            *pixel_cursor_int = n2;
            pixel_cursor+=4;
        }
    }
	
	// pre-sort lines to load in neon world
	sortedPixelNumbers = (unsigned char *)malloc(IPHONE4S_iOS7_PREVIEW_REDUCED_PIXELS*4);
	ArrangePixelNumbersForNeon((int *)pixelNumbers,(int *)sortedPixelNumbers,IPHONE4S_iOS7_PREVIEW_REDUCED_PIXELS);
}

/*- (void) dealloc
 {
 free(reducer);
 free(pixelNumbers);
 free(sortedPixelNumbers);
 //free(whitebalanceParameter);
 }*/

#pragma mark
#pragma mark === whitebalance parameters ===
#pragma mark

- (void) setWhiteBalanceParam:(float)Tx Ty:(float)Ty
{
    // bitmap location should be restored by screen size
    float Bx = (float)IPHONE4S_iOS7_SCREEN_WIDTH * Tx;
	float By = (float)IPHONE4S_iOS7_SCREEN_HEIGHT * Ty;
	
	NSLog(@"Touch Point         : %1.3f, %1.3f", Tx, Ty);
	NSLog(@"Bitmap Point        : %1.3f, %1.3f", Bx, By);
	
    int pixelNumber = ( IPHONE4S_iOS7_PREVIEW_REDUCED_HEIGHT - (int)By ) * IPHONE4S_iOS7_PREVIEW_REDUCED_WIDTH + (int)Bx;
	
	//NSLog(@"Pixel number : %d", pixelNumber);
	
	// pin
	//unsigned char *pinpix = reducer + pixelNumber * 4;
	// its rgb
	//int pBw = pinpix[0];
    //int pGw = pinpix[1];
    //int pRw = pinpix[2];
    //NSLog(@"WB point [pinned  ] : %d, %d, %d", pBw, pGw, pRw);
    
    // spreaded
    int spreaded = 0;
    int sRw = 0;
    int sGw = 0;
    int sBw = 0;
    for( int i = -1 * IPHONE4S_IOS7_POINT_SPREAD_SIZE; i < IPHONE4S_IOS7_POINT_SPREAD_SIZE; i++ ){
        for( int j = -1 * IPHONE4S_IOS7_POINT_SPREAD_SIZE; j < IPHONE4S_IOS7_POINT_SPREAD_SIZE; j++ ){
            int pixelnum = pixelNumber - i * IPHONE4S_iOS7_PREVIEW_REDUCED_WIDTH + j;
            if( pixelnum < 0 ){ continue; }
            if( pixelnum > IPHONE4S_iOS7_PREVIEW_REDUCED_PIXELS ){ continue; }
            unsigned char *pix = reducer + pixelnum * 4;
            sBw += (int)pix[0];
            sGw += (int)pix[1];
            sRw += (int)pix[2];
            spreaded++;
            //NSLog(@"spread (%d): %d,%d,%d", pixelnum, pix[0], pix[1], pix[2]);
            //NSLog(@"spread (%d): %d,%d,%d", pixelnum, sRw, sGw, sBw);
        }
    }
    int Rw = (int)(sRw / spreaded);
    int Gw = (int)(sGw / spreaded);
    int Bw = (int)(sBw / spreaded);
    
	NSLog(@"WB point [spreaded] : %d, %d, %d", Bw, Gw, Rw);
	//NSLog(@"sum: %d,%d,%d (%d)", sRw,sGw,sBw,spreaded);
    
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
    
    NSLog(@"WB param : %1.3d, %1.3d, %1.3d", whitebalanceParameterReal[0], whitebalanceParameterReal[1], whitebalanceParameterReal[2]);
}

- (void) getPointColor:(int *)colors atTx:(float)Tx Ty:(float)Ty
{
    // bitmap location should be restored by screen size
    float Bx = (float)IPHONE4S_iOS7_SCREEN_WIDTH * Tx;
	float By = (float)IPHONE4S_iOS7_SCREEN_HEIGHT * Ty;
    
	NSLog(@"Touch Point         : %1.3f, %1.3f", Tx, Ty);
	NSLog(@"Bitmap Point        : %1.3f, %1.3f", Bx, By);
    
    int pixelNumber = ( IPHONE4S_iOS7_PREVIEW_REDUCED_HEIGHT - (int)By ) * IPHONE4S_iOS7_PREVIEW_REDUCED_WIDTH + (int)Bx;
    
    // spreaded
    int spreaded = 0;
    int sR = 0;
    int sG = 0;
    int sB = 0;
    for( int i = -1 * IPHONE4S_IOS7_POINT_SPREAD_SIZE; i < IPHONE4S_IOS7_POINT_SPREAD_SIZE; i++ ){
        for( int j = -1 * IPHONE4S_IOS7_POINT_SPREAD_SIZE; j < IPHONE4S_IOS7_POINT_SPREAD_SIZE; j++ ){
            int pixelnum = pixelNumber - i * IPHONE4S_iOS7_PREVIEW_REDUCED_WIDTH + j;
            if( pixelnum < 0 ){ continue; }
            if( pixelnum > IPHONE4S_iOS7_PREVIEW_REDUCED_PIXELS ){ continue; }
            unsigned char *pix = reducer + pixelnum * 4;
            sB += (int)pix[0];
            sG += (int)pix[1];
            sR += (int)pix[2];
            spreaded++;
        }
    }
	colors[0] = (int)(sB / spreaded);
    colors[1] = (int)(sG / spreaded);
    colors[2] = (int)(sR / spreaded);
}

#pragma mark
#pragma mark === perview processing ===
#pragma mark

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"captureOutput:didOutputSampleBuffer called");
    
    // production
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    CGImageRef bufferImage = CreateCGImageFromPixelBuffer_Impl(whiteBalanceProcessor, pixelBuffer, reducer, sortedPixelNumbers, whitebalanceParameter);
    
    // the bufferImage should be released by the layer object
	[self.layer setFrameImage:bufferImage];
    
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	
    CGImageRelease(bufferImage);
}

static inline CGImageRef CreateCGImageFromPixelBuffer_Impl(WhiteBalanceProcessorDef *whiteBalanceProcessor, CVPixelBufferRef pixelBuffer, unsigned char *reducer, unsigned char *pixelNumbers, int *wbp)
{
	unsigned char *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
	
    //	NSDate *now = [NSDate date];
	
	//
	// neon enhanced preview processor
	//
	[whiteBalanceProcessor processBitmapBGRA:baseAddress reducer:reducer pixelNumber:(int *)pixelNumbers whitebalanceParameter:wbp reducedPixelNumber:IPHONE4S_iOS7_PREVIEW_REDUCED_PIXELS*4];
	
    //	NSDate *then = [NSDate date];
    //	NSLog(@"delay [wbp]: %1.3fsec", [then timeIntervalSinceDate:now]);
	
	CGImageRef cgimage = CreateCGImageFromBitmap(reducer,IPHONE4S_iOS7_PREVIEW_REDUCED_WIDTH,IPHONE4S_iOS7_PREVIEW_REDUCED_HEIGHT);
	
	//NSLog(@"image w:%d, h:%d", CGImageGetWidth(cgimage),CGImageGetHeight(cgimage));
	
	return cgimage;
}

@end
