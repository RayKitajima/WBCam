
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> 
{
	UIImage *image;
    UIView *previewView; // containing preview layer
    AVCaptureVideoDataOutput *previewOutput;
    BOOL checked; // dummy
}
@property (retain) UIImage *image;
@property (retain) AVCaptureVideoDataOutput *previewOutput;
@property BOOL checked;

- (UIView *) allocatePreviewViewWithBounds:(CGRect)bounds;
- (void) setupPreviewOutput;

+ (id) sharedInstance;

+ (void) notifyWhiteBalanceImage:(UIImage *)image;

+ (void) notifyWhiteBalancePointTx:(float)Tx Ty:(float)Ty;
+ (void) cancelWhiteBalance;

+ (void) clearPipeline;
+ (UIImage *) image; // quick snap

+ (void) checkInstance; // dummy

@end
