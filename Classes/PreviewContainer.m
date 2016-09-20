
#import "PreviewContainer.h"
#import "CameraHelper.h"
#import "CameraSession.h"
#import "CameraController.h"
#import "PreviewHelper.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"

@implementation PreviewContainer
@synthesize finderView;

#pragma mark
#pragma mark === Touch handling  ===
#pragma mark

// 
// in PreviewLayer_DEVICE_IOSVER.drawInContext, adjusting screen center by hard coding
// 
// bounds.origin.x = bounds.origin.x-ADJUSTMENT_X;
// bounds.origin.y = bounds.origin.y-ADJUSTMENT_Y;
// 
// touch handling is adjusted by the parameter of DeviceConfig
// 

- (void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer 
{
    if( lastTouchPoint.x != 0 && lastTouchPoint.y != 0 ){
        NSLog(@"preventing handleSingleTap()");
        return;
    }
    
	// exposuer
    CGPoint touchPoint = [gestureRecognizer locationInView:self.finderView];
    
    ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
    DeviceConfig *deviceConfig = [app_conf deviceConfig];
    
    // normalize, and adjust centering margin.
    // this is a point for the device,
    // so the Tx is devided by the height.
    //float Tx = ( (float)touchPoint.y + deviceConfig.previewScreenAdjustmentX ) / (float)deviceConfig.screenHeight;
	//float Ty = ( (float)touchPoint.x + deviceConfig.previewScreenAdjustmentY ) / (float)deviceConfig.screenWidth;
	float Tx = ( (float)touchPoint.y + deviceConfig.previewScreenAdjustmentY ) / (float)deviceConfig.previewHeightAdjusted;
	float Ty = ( (float)touchPoint.x + deviceConfig.previewScreenAdjustmentX ) / (float)deviceConfig.previewWidthAdjusted;
    Ty = 1.0f - Ty;
    
    CGPoint exposurePoint = CGPointMake(Tx, Ty);
    
    //[CameraSession applyExposurePointOfInterest:exposurePoint];
    
    [CameraSession notifyExposureFocusPointOfInterest:exposurePoint]; // adjust exposure and focus by the point
    [CameraController showNotificationBoxAtPoint:touchPoint];
    
    [CameraController changeAEAFModeNotificationToAuto];
    
    //NSLog(@"# select exposure at [TOC] %1.3f, %1.3f", touchPoint.x, touchPoint.y);
    //NSLog(@"# select exposure at [NOR] %1.3f, %1.3f", Tx, Ty);
    //NSLog(@"# select exposure at [PIX] %1.3f+%u, %1.3f+%u", 
    //      touchPoint.x, deviceConfig.previewScreenAdjustmentX, touchPoint.y, deviceConfig.previewScreenAdjustmentY);
}

- (void) handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer 
{
	if( !canEnterWhitePointSelection ) return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.finderView];
    
	//CGPoint touchPoint = [[touches anyObject] locationInView:self.finderView];
	
    ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
    DeviceConfig *deviceConfig = [app_conf deviceConfig];
    
	// normalize, and adjust centering margin.
    // this is a point for the preview layer,
    // so the Tx is devided by width.
	//float Tx = ( (float)touchPoint.x + deviceConfig.previewScreenAdjustmentX ) / (float)deviceConfig.screenWidth;
	//float Ty = ( (float)touchPoint.y + deviceConfig.previewScreenAdjustmentY ) / (float)deviceConfig.screenHeight;
	float Tx = ( (float)touchPoint.x + deviceConfig.previewScreenAdjustmentX ) / (float)deviceConfig.previewWidthAdjusted;
	float Ty = ( (float)touchPoint.y + deviceConfig.previewScreenAdjustmentY ) / (float)deviceConfig.previewHeightAdjusted;
    
    [CameraSession disableAutoWhiteBalance];
	[CameraHelper notifyWhiteBalancePointTx:Tx Ty:Ty];
    [CameraController showNotificationBoxAtPoint:touchPoint];
	[CameraController changeWBModeNotificationToManual];
    
    //NSLog(@"# select whitepoint at [NOR] %1.3f, %1.3f", Tx, Ty);
    //NSLog(@"# select whitepoint at [PIX] %1.3f+%u, %1.3f+%u", 
    //      touchPoint.x, deviceConfig.previewScreenAdjustmentX, touchPoint.y, deviceConfig.previewScreenAdjustmentY);
}

- (void) handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer 
{
	[CameraHelper cancelWhiteBalance];
    [CameraSession enableAutoWhiteBalance];
	
	//NSLog(@"# Reset WB");
}

// AE/AF lock
- (void) handlePress:(UIGestureRecognizer *)gestureRecognizer
{
    if( lastTouchPoint.x != 0 && lastTouchPoint.y != 0 ){
        NSLog(@"preventing handleSingleTap()");
        return;
    }
    
    // blocking flag will be cleared at end of notification animation
    if( !canEnterAEAFLock ){ return; }
    
    NSLog(@"# pressed");
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    
    ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
    DeviceConfig *deviceConfig = [app_conf deviceConfig];
    
    // normalize, and adjust centering margin.
    // this is a point for the device,
    // so the Tx is devided by the height.
	float Tx = ( (float)touchPoint.x + deviceConfig.previewScreenAdjustmentX ) / (float)deviceConfig.screenHeight;
	float Ty = ( (float)touchPoint.y + deviceConfig.previewScreenAdjustmentY ) / (float)deviceConfig.screenWidth;
    
    CGPoint lockPoint = CGPointMake(Tx, Ty);
    lastTouchPoint = lockPoint;
    
    NSLog(@"# select AE/AF lock at [NOR] %1.3f, %1.3f", Tx, Ty);
    NSLog(@"# select whitepoint at [PIX] %1.3f+%u, %1.3f+%u", 
          touchPoint.x, deviceConfig.previewScreenAdjustmentX, touchPoint.y, deviceConfig.previewScreenAdjustmentY);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"# forcusing");
        [CameraSession notifyExposureFocusPointOfInterest:lockPoint];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"# locking");
            [CameraController showAEAFLockAnimationAtPoint:touchPoint withCompletionBlock:^(void){}];
            [CameraController changeAEAFModeNotificationToLock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"# done");
                [CameraSession applyAEAFLockWithPoint:lockPoint];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"# enabling next touch");
                    [self enableEnterAEAFLock];
                    [self performSelector:@selector(releaseLastTouchPoint) withObject:nil afterDelay:2.0f];
                });
            });
        });
    });
    
    /*
    [CameraSession applyAEAFLockWithPoint:lockPoint]; // AE/AF lock
    
    [CameraController showAEAFLockAnimationAtPoint:touchPoint 
                               withCompletionBlock:^(void){ 
                                   [self enableEnterAEAFLock];
                                   [self performSelector:@selector(releaseLastTouchPoint) withObject:nil afterDelay:2.0f];
                               }];
    */
}

- (void) handleSwipe:(UIGestureRecognizer *)gestureRecognizer 
{
	[CameraHelper cancelWhiteBalance];
    
    [CameraController runAutoWhiteBalanceBlockWithCompletionBlock:^(void){}];
    //[CameraSession enableContinuousAEAF];
    [CameraSession notifyExposureFocusPointOfInterest:CGPointMake(0.5f, 0.5f)];
    
	PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
	[previewHelper discardLuminance];
	
    [CameraController changeAEAFModeNotificationToAuto];
    
	//NSLog(@"# Reset WB by swipe gesture");
}

#pragma mark
#pragma mark === ui support ===
#pragma mark

- (BOOL) finderDimmed
{
    BOOL dimmed = NO;
    if( finderView.alpha < 1.0 ){
        dimmed = YES;
    }
    return dimmed;
}

- (void) dimmFinder
{
    self.finderView.alpha = 0.5;
}

- (void) illumFinder
{
    self.finderView.alpha = 1.0;
}

- (void) hideFinder
{
    self.finderView.alpha = 0.0;
}

// release lastTouchPoint

- (void) releaseLastTouchPoint
{
    NSLog(@"releasing lastTouchPoint");
    lastTouchPoint = CGPointZero;
}

// whitepoint selection mode

- (void) blockEnterWhitepointSelection
{
    canEnterWhitePointSelection = NO;
}

- (void) enableEnterWhitepointSelection
{
    canEnterWhitePointSelection = YES;
}

- (BOOL) canEnterWhitePointSelection
{
    return canEnterWhitePointSelection;
}

// color selection mode

- (void) blockEnterColorSelection
{
    canEnterColorSelection = NO;
}

- (void) enableEnterColorSelection
{
    canEnterColorSelection = YES;
}

- (BOOL) canEnterColorSelection
{
    return canEnterColorSelection;
}

// AE/AF lock 

- (void) blockEnterAEAFLock
{
    canEnterAEAFLock = NO;
}

- (void) enableEnterAEAFLock
{
    canEnterAEAFLock = YES;
}

- (BOOL) canEnterAEAFLock
{
    return canEnterAEAFLock;
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.multipleTouchEnabled = YES;
    
    // YES to enter white(or gray) point selection, NO to block
    canEnterWhitePointSelection = YES;
    
    // YES to enter manual color selection, No to block
    canEnterColorSelection = YES;
    
    // YES to enter AE/AF lock setup
    canEnterAEAFLock = YES;
    
    // init cgpoint for preventing continuous touch event
    lastTouchPoint = CGPointZero;
    
    // set background color as black
    //self.backgroundColor = [UIColor blackColor];
    
    // these setup procedures requires to be serialized
    dispatch_async(dispatch_get_main_queue(), ^{
        // initialize CameraHelper singleton object
        CameraHelper *cameraHelper = [CameraHelper sharedInstance];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // get preview view for the live preview.
            // this is CameraHelper's public service, not a instance method.
            // returned object is already retained.
            // the previewRectAdjusted is adjusted rect by the ratio of buffer and visible preview area
            finderView = [cameraHelper allocatePreviewViewWithBounds:[DeviceConfig previewRectAdjusted]];
            
            //finderView = [[UIView alloc] initWithFrame:[DeviceConfig previewRectAdjusted]];
            
            PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
            previewHelper.layer.frame = [DeviceConfig previewRectAdjusted];
            //[previewHelper.layer setNeedsDisplay];
            [finderView.layer addSublayer:previewHelper.layer];
            
            [self addSubview:finderView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cameraHelper setupPreviewOutput];
            });
        });
    });
    
    // add gesture recognizers
    UITapGestureRecognizer   *singleTap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer   *doubleTap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer   *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    UISwipeGestureRecognizer *swipeRight   = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeLeft    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeUp      = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeDown    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    //UILongPressGestureRecognizer *press    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:twoFingerTap];
    [self addGestureRecognizer:swipeRight];
    [self addGestureRecognizer:swipeLeft];
    [self addGestureRecognizer:swipeUp];
    [self addGestureRecognizer:swipeDown];
    //[self addGestureRecognizer:press];
    
    return self;
}

@end
