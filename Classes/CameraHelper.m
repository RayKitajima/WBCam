
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CameraController.h"
#import "CameraHelper.h"
#import "CameraSession.h"
#import "PreviewHelper.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"

@implementation CameraHelper
@synthesize image;
@synthesize previewOutput;
@synthesize checked;

static CameraHelper *sharedInstance = nil;

#pragma mark
#pragma mark === object setting ===
#pragma mark

// 
// allocate preview view
// 
- (UIView *) allocatePreviewViewWithBounds:(CGRect)bounds
{
    //NSLog(@"CameraHelper : allocatePreviewViewWithBounds called");
    NSLog(@"CameraHelper : bounds is %@",NSStringFromCGRect(bounds));
	UIView *view = [[UIView alloc] initWithFrame:bounds];
	PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
	previewHelper.layer.frame = bounds;
	[previewHelper.layer setNeedsDisplay];
	[view.layer addSublayer:previewHelper.layer];
    
	return view;
}

// 
// befoer setup video output, you should setup layer.
// 
// setup output pipeline
// 
- (void) setupPreviewOutput
{
    NSLog(@"CameraHelper : setupPreviewOutput");
    
    // setup frame rate
    /*
     * 
     * this code is not work for iOS bug.
     * adding sitllImageOutput after adding videoDataOutput erases this duration setting.
     * wait bug fix.
     * until the fix ipod cannot be supported.
     * 
     *
    AVCaptureConnection *connection = [previewOutput connectionWithMediaType:AVMediaTypeVideo];
    if( [DeviceConfig previewFramerate] ){
        NSLog(@"setting videoMinFrameDuration : 1/%d",[DeviceConfig previewFramerate]);
        [connection setVideoMinFrameDuration:CMTimeMake(1, [DeviceConfig previewFramerate])];
        [connection setVideoMaxFrameDuration:CMTimeMake(1, [DeviceConfig previewFramerate])];
    }
    */
    
    // 
    // prep GCD queue, sample buffer processing requires serial queue.
    // 
    // (1) dispatch_queue_t my_queue = dispatch_queue_create("task", NULL);     : serial queue
    // (2) dispatch_queue_t my_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);      : slow and corrupted preview image
    // (3) dispatch_queue_t my_queue = dispatch_get_main_queue();                                       : serial queue
    // (4) dispatch_queue_t my_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,NULL); : global not serial
    // 
    // * bench on ipad2
    //   (3) is 20% faster than (1),(2),(4), 0.23->0.19 sec
    // 
    
    // advanced shared queue for more snap performance
    ApplicationConfig *app_config = [ApplicationConfig sharedInstance];
    dispatch_queue_t preview_queue = [app_config finderPreviewQueue]; // for front process
    
    // setup PreviewHelper singleton object
	PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
    
    // setup videoDataOutput for the live preview with the PreviewHelper object
	[previewOutput setSampleBufferDelegate:previewHelper queue:preview_queue];
}

// prepqre AVCaptureVideoDataOutput
- (id) init
{
	self = [super init];
    
    NSLog(@"CameraHelper : initializing");
    
    // prep output
	previewOutput = [[AVCaptureVideoDataOutput alloc] init];
	[previewOutput setAlwaysDiscardsLateVideoFrames:YES];
	[previewOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // manual preview videoOutput requires BGRA
    
    // ********************************************
    //  iOS5 supports dual resolution
    //  stillImageOutput object is once added here
    //  and presist while application alive
    // ********************************************
    NSLog(@"adding previewOut object to the global session");
    AVCaptureSession *session = [CameraSession session];
    [session beginConfiguration];
    if( [session canAddOutput:previewOutput] ){
        [session addOutput:previewOutput];
    }else{
        NSLog(@"CameraHelper : # fail to prepare previewOutput");
    }
    [session commitConfiguration];
    
    
    NSLog(@"CameraHelper : output ready");
    
	return self;
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

+ (id) sharedInstance
{
	//if(!sharedInstance) sharedInstance = [[self alloc] init];
    //return sharedInstance;
    @synchronized(self){
		if( !sharedInstance ){
			sharedInstance = [[CameraHelper alloc] init];
		}
	}
    return sharedInstance;
}

+ (void) notifyWhiteBalanceImage:(UIImage *)image
{
	PreviewHelper *instance = [PreviewHelper sharedInstance];
	[instance setWhiteBalanceParamByImage:image];
}

+ (void) notifyWhiteBalancePointTx:(float)Tx Ty:(float)Ty
{
	PreviewHelper *instance = [PreviewHelper sharedInstance];
	[instance setWhiteBalanceParam:Tx Ty:Ty];
}

+ (void) cancelWhiteBalance
{
	PreviewHelper *instance = [PreviewHelper sharedInstance];
	[instance cancelWhiteBalance];
}

+ (void) clearPipeline
{
	PreviewHelper *instance = [PreviewHelper sharedInstance];
    [instance performSelectorOnMainThread:@selector(clearPipeline) withObject:nil waitUntilDone:YES];
    //instance.layer.frameImage = nil;
    //[instance.layer setNeedsDisplay]; // immediately update view
}

+ (UIImage *) image
{
    // quick snap
	PreviewHelper *instance = [PreviewHelper sharedInstance];
	CGImageRef imageRef = (CGImageRef)instance.layer.frameImage;
	UIImage *snapImage = [[UIImage alloc] initWithCGImage:imageRef];
	return snapImage;
}

// dummy
+ (void) checkInstance
{
    CameraHelper *instance = [self sharedInstance];
    instance.checked = YES;
}

@end
