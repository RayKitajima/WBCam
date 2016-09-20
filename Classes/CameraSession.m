
#import "CameraSession.h"
#import "CameraController.h"
#import "PreviewHelper.h"
#import "SnapHelper.h"

static CameraSession *sharedInstance = nil;

@implementation CameraSession
@synthesize captureDevice, captureInput, captureSession;

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
    self = [super init];
    
    // initialize capture device
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // initialize camera session
    captureSession = [[AVCaptureSession alloc] init];
    
    // **********************************************
    //  iOS5 supports dual resolution
    //  AVCaptureSessionPresetPhoto provides
    //  both full resolution and reduced data output
    // **********************************************
    [captureSession beginConfiguration];
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [captureSession commitConfiguration];
    
    
    // initialize capture input
    NSError *error;
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if( error ){
        NSLog(@"# Couldn't create video input");
    }
    
    // set input
    [captureSession beginConfiguration];
    if( [captureSession canAddInput:captureInput] ){
        [captureSession addInput:captureInput];
    }else{
        NSLog(@"# fail to prepare captureInput");
    }
    [captureSession commitConfiguration];
    
    return self;
}

- (void) validate
{
    if( !captureDevice ){
        
        NSLog(@"*** [CameraSession.validate] detect invalid captureDevice");
        
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if( !captureSession ){
        
        NSLog(@"*** [CameraSession.validate] detect invalid captureSession");
        
        captureSession = [[AVCaptureSession alloc] init];
    }
}

#pragma mark
#pragma mark === basic singleton service ===
#pragma mark

+ (id) sharedInstance
{
    @synchronized(self){
        if(!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

+ (AVCaptureSession *) session
{
    CameraSession *instance = [self sharedInstance];
    return instance.captureSession;
}

+ (AVCaptureDeviceInput *) input
{
    CameraSession *instance = [self sharedInstance];
    return instance.captureInput;
}

+ (AVCaptureDevice *) device
{
    CameraSession *instance = [self sharedInstance];
    return instance.captureDevice;
}

+ (void) bootup
{
    CameraSession *instance = [self sharedInstance];
    [instance validate];
}

#pragma mark
#pragma mark === start and stop ===
#pragma mark

+ (void) ensureCameraSessionRunning
{
    NSLog(@"# * * * * * * * * * * * * * * * * * * * * * * * * * *");
    NSLog(@"# ");
    NSLog(@"# CameraSession.ensureCameraSessionRunning() called");
    NSLog(@"# ");
    NSLog(@"# this is a hook for the unexpected camera session stop");
    NSLog(@"# at the time resuming via album.");
    NSLog(@"# [album->suspend(got background)->resume(album)->camera].");
    NSLog(@"# it cannot be detected by running' or interupted property.");
    NSLog(@"# ");
    NSLog(@"# to avoid this stall, simply stop and start the session");
    NSLog(@"# at the CameraController.viewWillAppear().");
    NSLog(@"# ");
    NSLog(@"# this stall might be a bug of this application,");
    NSLog(@"# but untill now, the bug is not discovered.");
    NSLog(@"# ");
    NSLog(@"# * * * * * * * * * * * * * * * * * * * * * * * * * *");
    CameraSession *instance = [self sharedInstance];
    [instance.captureSession stopRunning];
    [instance.captureSession startRunning];
}

+ (BOOL) isRunning
{
    CameraSession *instance = [self sharedInstance];
    return instance.captureSession.running;
}

+ (void) startRunning
{
    CameraSession *instance = [self sharedInstance];
    [instance.captureSession startRunning];
}

+ (void) stopRunning
{
    CameraSession *instance = [self sharedInstance];
    [instance.captureSession stopRunning];
}

#pragma mark
#pragma mark === device level whitebalance ===
#pragma mark

+ (void) ensureManualWhiteBalanceMode
{
    // 
    // check whitebalance mode (might always true), 
    // and automatically enter manual whitebalance mode if not yet in.
    // 
    PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
    if( !previewHelper.shouldAdjustWhiteBalance ){
        int originalWhitebalanceParameterReal[3];
        originalWhitebalanceParameterReal[0] = 0;
        originalWhitebalanceParameterReal[1] = 0;
        originalWhitebalanceParameterReal[2] = 0;
        [previewHelper enableWhiteBalanceWithRealParameter:originalWhitebalanceParameterReal];
    }
}

+ (void) enableAutoWhiteBalance
{
    AVCaptureDevice *device = [CameraSession device];
    
    [device lockForConfiguration:nil];
    
    if( [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] ){
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }else{
        NSLog(@"AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance not supported");
    }
    
    [device unlockForConfiguration];
    
    NSLog(@"enter AutoWhiteBalance");
}

+ (void) disableAutoWhiteBalance
{
    // ***********************************
    // *                                 *
    // * not yet available, waiting iOS5 *
    // *                                 *
    // *    -> ready by iOS5 !!!         *
    // *                                 *
    // ***********************************
    //return;
    
    AVCaptureDevice *device = [CameraSession device];
    
    [device lockForConfiguration:nil];
    
    if( [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ){
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    }else{
        NSLog(@"AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance not supported");
    }
    
    [device unlockForConfiguration];
    
    NSLog(@"enter ManualWhiteBalance");
}

#pragma mark
#pragma mark === exposure focus control ===
#pragma mark

// cancel AE/EF lock and enter continuous auto mode
+ (void) enableContinuousAEAF
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]
       && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* enableContinuousAEAF()");
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter AEAF");
    }
}

// tap to select exposure and focus, with continuous
+ (void) notifyExposureFocusPointOfInterest:(CGPoint)point
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]
       && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* notifyExposureFocusPointOfInterest()");
            [device setExposurePointOfInterest:point];
            [device setFocusPointOfInterest:point];
            
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter quick adjust");
    }
}

+ (void) notifyExposurePointOfInterest:(CGPoint)point
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* notifyExposurePointOfInterest()");
            [device setExposurePointOfInterest:point];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter quick adjust");
    }
}

+ (void) notifyFocusPointOfInterest:(CGPoint)point
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* notifyExposureFocusPointOfInterest()");
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter quick adjust");
    }
}

+ (void) notifyExposureLock
{
	AVCaptureDevice *device = [CameraSession device];
	
    if( [device isExposureModeSupported:AVCaptureExposureModeLocked] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* applyAEAFLockWithPoint()");
            [device setExposureMode:AVCaptureExposureModeLocked];
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter lock mode");
    }
}

+ (void) notifyFocusLock
{
	AVCaptureDevice *device = [CameraSession device];
	
    if( [device isFocusModeSupported:AVCaptureFocusModeLocked] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* applyAEAFLockWithPoint()");
            [device setFocusMode:AVCaptureFocusModeLocked];
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter lock mode");
    }
}

// AE/AF lock (deprecated)
+ (void) applyAEAFLockWithPoint:(CGPoint)point
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device isExposureModeSupported:AVCaptureExposureModeLocked] 
       && [device isFocusModeSupported:AVCaptureFocusModeLocked] ){
        if( [device lockForConfiguration:nil] ){
            //NSLog(@"* applyAEAFLockWithPoint()");
            //[device setExposurePointOfInterest:point];
            //[device setFocusPointOfInterest:point];
            
            [device setFocusMode:AVCaptureFocusModeLocked];
            [device setExposureMode:AVCaptureExposureModeLocked];
            
            [device unlockForConfiguration];
        }else{
            //NSLog(@"* cannot get config lock");
        }
    }else{
        //NSLog(@"* cannot enter lock mode");
    }
}

// tap to select exposure
+ (void) applyExposurePointOfInterest:(CGPoint)point
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ){
        if( [device lockForConfiguration:nil] ){
            [device setExposurePointOfInterest:point];
            
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            
            [device unlockForConfiguration];
            //NSLog(@"ManualExposure done");
        }
    }else{
        //NSLog(@"exposure point of interest NOT SUPPORTED!");
    }
}

@end
