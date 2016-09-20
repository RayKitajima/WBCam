
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>


@interface SnapHelper : NSObject 
{
    AVCaptureStillImageOutput *stillImageOutput;
    BOOL checked; // dummy
}

@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property BOOL checked; // dummy

// singleton interfaces

+ (id) sharedInstance;

+ (void) snapStillImageWithALAssetOrientation:(ALAssetOrientation)orientation;
+ (void) snapRawStillImageWithALAssetOrientation:(ALAssetOrientation)orientation;
+ (void) snapJpegStillImageWithALAssetOrientation:(ALAssetOrientation)orientation;

+ (void) checkInstance; // dummy

@end
