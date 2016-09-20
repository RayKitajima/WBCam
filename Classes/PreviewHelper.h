
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

#import "PreviewLayer.h"
#import "WhiteBalanceProcessorDef.h"
#import "WhiteBalanceProcessorNOP.h"
#import "WhiteBalanceProducer.h"

@interface PreviewHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	PreviewLayer *layer;
    
    float manualPreviewFrameRate;
    
	BOOL shouldAdjustWhiteBalance;    // ture, we are in the manual whitebalance mode
	int whitebalanceParameter[3];     // BGR, absolute value of whitebalanceParameterReal
    int whitebalanceParameterReal[3]; // BGR, real value, adjustment ratio, 8bit left shifted
	int exposureAdjustmentLevel;      // -5...+5
	int exposureAdjustmentParam;      // -5*25...+5*25
    
	unsigned char *reducer;            // bitmap reducing space, allocated in init
	unsigned char *pixelNumbers;       // for non wb
	unsigned char *sortedPixelNumbers; // for wb
    
    WhiteBalanceProcessorDef *whiteBalanceProcessor;
	WhiteBalanceProcessorNOP *whiteBalanceProcessorNOP;
	WhiteBalanceProducer *whiteBalanceProducer;
}

@property (retain) PreviewLayer *layer;
@property (retain) WhiteBalanceProcessorDef *whiteBalanceProcessor;
@property (retain) WhiteBalanceProcessorNOP *whiteBalanceProcessorNOP;
@property (retain) WhiteBalanceProducer *whiteBalanceProducer;
@property BOOL shouldAdjustWhiteBalance;
@property float manualPreviewFrameRate;
@property int exposureAdjustmentLevel;

// required implementation
// and also, concrete PreviewHelper should implement captureOutput:didOutputSampleBuffer:fromConnection

- (void) initializeHelper;
- (void) clearPipeline;

- (void) getPointColor:(int *)colors atTx:(float)Tx Ty:(float)Ty;

- (void) setWhiteBalanceParamByImage:(UIImage *)image;

// shared methods

- (void) setWhiteBalanceParam:(float)Tx Ty:(float)Ty;
- (void) cancelWhiteBalance;

- (void) setWhiteBalanceParameterAsReal:(int *)realParam;
- (void) enableWhiteBalanceWithRealParameter:(int *)realParam;
- (void) luminancePlus;
- (void) luminanceMinus;
- (void) discardLuminance;

- (int) currentWhiteBalanceParameterRp;
- (int) currentWhiteBalanceParameterGp;
- (int) currentWhiteBalanceParameterBp;
- (void) setWhiteBalanceParameterRp:(int)Rp;
- (void) setWhiteBalanceParameterGp:(int)Gp;
- (void) setWhiteBalanceParameterBp:(int)Bp;

- (int) currentWhiteBalanceParameterRealRp;
- (int) currentWhiteBalanceParameterRealGp;
- (int) currentWhiteBalanceParameterRealBp;
- (void) setWhiteBalanceParameterRealRp:(int)Rp;
- (void) setWhiteBalanceParameterRealGp:(int)Gp;
- (void) setWhiteBalanceParameterRealBp:(int)Bp;

+ (id) sharedInstance;

@end
