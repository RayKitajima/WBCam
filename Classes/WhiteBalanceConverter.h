
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface WhiteBalanceConverter : NSObject 
{
    unsigned char *sortedPixelNumbers_up;    // sorted pixel numbers for snap image of orientation UP
    unsigned char *sortedPixelNumbers_down;  // sorted pixel numbers for snap image of orientation DOWN
    unsigned char *sortedPixelNumbers_right; // sorted pixel numbers for snap image of orientation RIGHT
    unsigned char *sortedPixelNumbers_left;  // sorted pixel numbers for snap image of orientation LEFT
}

- (CGImageRef) allocCGImageApplyingWhiteBalanceForCMSampleBufferRef:(CMSampleBufferRef)sampleBuffer withALAssetOrientation:(ALAssetOrientation)orientation;
- (CGImageRef) allocCGImageApplyingWhiteBalanceForCFDataRef:(CFDataRef)dataRef withALAssetOrientation:(ALAssetOrientation)orientation;

+ (id) sharedInstance;
+ (void) bootup;

@end
