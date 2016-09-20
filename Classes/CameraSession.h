
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraSession : NSObject {
    AVCaptureDevice *captureDevice;     // shared device object
    AVCaptureDeviceInput *captureInput; // shared input object
    AVCaptureSession *captureSession;   // shared session object
}

@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureDeviceInput *captureInput;
@property (retain) AVCaptureDevice *captureDevice;

+ (id) sharedInstance;

+ (AVCaptureSession *) session;
+ (AVCaptureDeviceInput *) input;
+ (AVCaptureDevice *) device;

+ (void) bootup;

+ (BOOL) isRunning;
+ (void) startRunning;
+ (void) stopRunning;
+ (void) ensureCameraSessionRunning;

+ (void) ensureManualWhiteBalanceMode;
+ (void) enableAutoWhiteBalance;
+ (void) disableAutoWhiteBalance;

+ (void) enableContinuousAEAF;
+ (void) notifyExposureFocusPointOfInterest:(CGPoint)point;

+ (void) notifyExposurePointOfInterest:(CGPoint)point;
+ (void) notifyFocusPointOfInterest:(CGPoint)point;
+ (void) notifyExposureLock;
+ (void) notifyFocusLock;

+ (void) applyAEAFLockWithPoint:(CGPoint)point;
+ (void) applyExposurePointOfInterest:(CGPoint)point; // deprecated

@end
