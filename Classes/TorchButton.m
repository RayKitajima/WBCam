
#import <QuartzCore/QuartzCore.h>
#import "TorchButton.h"
#import "CameraSession.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"

const CGFloat torch_off_alpha       = 0.50f;
const CGFloat button_off_bg_alpha   = 0.45f;
const CGFloat button_off_line_alpha = 0.45f;

const CGFloat torch_on_alpha        = 0.75f;
const CGFloat button_on_bg_alpha    = 0.70f;
const CGFloat button_on_line_alpha  = 0.70f;

@interface TorchButton(Private)
- (void) toggleTorch;
@end

@implementation TorchButton
@synthesize initialCenter;

#pragma mark
#pragma mark === Touch handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
    [self toggleTorch];
}

#pragma mark
#pragma mark === Torch control  ===
#pragma mark

- (void) toggleTorch
{
    AVCaptureDevice *device = [CameraSession device];
    
    if( [device torchMode] == AVCaptureTorchModeOn ){
        // set torch off
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }else{
        // set torch on
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
}

#pragma mark
#pragma mark === observing torch mode ===
#pragma mark

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"torchMode"] ){
        
        AVCaptureDevice *device = [CameraSession device];
        if( [device torchMode] == AVCaptureTorchModeOn ){
            // torch has been on
            torch_on_imageView.hidden  = NO;
            torch_off_imageView.hidden = YES;
            
            CALayer *layer = [self layer];
            [layer setBackgroundColor:[[UIColor colorWithWhite:0.3f alpha:button_on_bg_alpha] CGColor]];
            [layer setBorderColor:[[UIColor colorWithWhite:1.0f alpha:button_on_line_alpha] CGColor]];
        }else{
            // torch has been off
            torch_on_imageView.hidden  = YES;
            torch_off_imageView.hidden = NO;
            
            CALayer *layer = [self layer];
            [layer setBackgroundColor:[[UIColor colorWithWhite:0.3f alpha:button_off_bg_alpha] CGColor]];
            [layer setBorderColor:[[UIColor colorWithWhite:1.0f alpha:button_off_line_alpha] CGColor]];
        }
        
    }
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    enabled = YES;
    
    torch_on_imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"torch_on_72x40"]];
    torch_off_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"torch_off_72x40"]];
    
    torch_on_imageView.frame  = CGRectMake(13, 8, 24, 13);
    torch_off_imageView.frame = CGRectMake(13, 8, 24, 13);
    
    torch_on_imageView.layer.opacity  = torch_on_alpha;
    torch_off_imageView.layer.opacity = torch_off_alpha;
    
    torch_on_imageView.hidden  = YES;
    torch_off_imageView.hidden = NO;
    
    [self addSubview:torch_on_imageView];
    [self addSubview:torch_off_imageView];
    
    CALayer *layer = [self layer];
    [layer setBackgroundColor:[[UIColor colorWithWhite:0.3f alpha:button_off_bg_alpha] CGColor]];
    [layer setBorderWidth:1.0f];
    [layer setBorderColor:[[UIColor colorWithWhite:1.0f alpha:button_off_line_alpha] CGColor]];
    [layer setCornerRadius:15.f];
    
    initialCenter = self.center;
    
    // 
    // observe torch mode change
    // 
    AVCaptureDevice *device = [CameraSession device];
    [device addObserver:self forKeyPath:@"torchMode" options:NSKeyValueObservingOptionNew context:NULL];
    
    // 
    // get device orientation
    // 
    currentOrientation = [[UIDevice currentDevice] orientation];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(rotated:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    return self;
}

#pragma mark
#pragma mark === device rotation observer ===
#pragma mark

- (void) rotated:(NSNotification *)notification
{
    //UIDeviceOrientation newOrientation = [[notification object] orientation];
	UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
    
    // 
    // Device and object orientation
    // 
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // :                                                                 :                          :
    // : +---------+   +---------+   +----------+---+   +---+----------+ :                          :
    // : |         |   |    O    |   |          |   |   |   |          | :                          :
    // : |         |   +---------+   |          |   |   |   |          | :                          :
    // : |    1    |   |         |   |     3    | O |   | O |    4     | :                          :
    // : |         |   |         |   |          |   |   |   |          | :       device/obj         :
    // : |         |   |    2    |   |          |   |   |   |          | :                          :
    // : +---------+   |         |   +----------+---+   +---+----------+ :                          :
    // : |    O    |   |         |                                       :                          :
    // : +---------+   +---------+                                       :                          :
    // :                                                                 :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Portrate      Portrate      LandscapeRight     LandscapeLeft    : UIInterfaceOrientation   :
    // :                 UpsideDown                                      :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Up(def)       Down          Left               Right            : ALAssetOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Right         Left          Up                 Down             : UIImageOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // 
    // 
    // + - - - - - - - - - - - - + - - - +
    // : current                 : angle :
    // + - - - - - - - - - - - - + - - - +
    // : (1) Portrait            :     0 :
    // + - - - - - - - - - - - - + - - - +
    // : (2) PortraitUpsideDown  :   180 :
    // + - - - - - - - - - - - - + - - - +
    // : (3) LandscapeRight      :   -90 :
    // + - - - - - - - - - - - - + - - - +
    // : (4) LandscapeLeft       :    90 :
    // + - - - - - - - - - - - - + - - - +
    // 
    // 
    
    CGFloat angle = 0.0f;
    CGFloat middle = 0.0f;
    
    CGFloat newCenterX = 0.0f;
    CGFloat newCenterY = 0.0f;
    
    if( newOrientation == UIDeviceOrientationPortrait )
    {
        // 1
        if( currentOrientation == UIDeviceOrientationPortrait ){
            //NSLog(@"cam rotated: (1)->(1)");
            angle  = 0.0f;
            middle = 0.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            //NSLog(@"cam rotated: (2)->(1)");
            angle  = 0.0f;
            middle = -90.0f; // same as other self rotation
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            //NSLog(@"cam rotated: (3)->(1)");
            angle  = 0.0f;
            middle = -45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            //NSLog(@"cam rotated: (4)->(1)");
            angle  = 0.0f;
            middle = 45.0f;
        }
        // calculate new center
        newCenterX = initialCenter.x;
        newCenterY = initialCenter.y;
    }
    else if( newOrientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        if( currentOrientation == UIDeviceOrientationPortrait ){
            //NSLog(@"cam rotated: (1)->(2)");
            angle  = -180.0f; // same as other self rotation
            middle = -90.0f; 
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            //NSLog(@"cam rotated: (2)->(2)");
            angle  = 180.0f;
            middle = 180.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            //NSLog(@"cam rotated: (3)->(2)");
            angle  = -180.0f;
            middle = -135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            //NSLog(@"cam rotated: (4)->(2)");
            angle  = 180.0f;
            middle = 135.0f;
        }
        // calculate new center
        newCenterX = [DeviceConfig previewDisplayWidth] - initialCenter.x;
        newCenterY = [DeviceConfig previewDisplayHeight] - initialCenter.y;
    }
    else if( newOrientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        if( currentOrientation == UIDeviceOrientationPortrait ){
            //NSLog(@"cam rotated: (1)->(3)");
            angle  = -90.0f;
            middle = -45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            //NSLog(@"cam rotated: (2)->(3)");
            angle  = -90.0f;
            middle = -135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            //NSLog(@"cam rotated: (3)->(3)");
            angle  = -90.0f;
            middle = -90.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            //NSLog(@"cam rotated: (4)->(3)");
            angle  = -90.0f;
            middle = 0.0f;
        }
        // calculate new center
        newCenterX = initialCenter.x - 10;
        newCenterY = [DeviceConfig previewDisplayHeight] - initialCenter.y - 15;
    }
    else if( newOrientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        if( currentOrientation == UIDeviceOrientationPortrait ){
            //NSLog(@"cam rotated: (1)->(4)");
            angle  = 90.0f;
            middle = 45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            //NSLog(@"cam rotated: (2)->(4)");
            angle  = 90.0f;
            middle = 135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            //NSLog(@"cam rotated: (3)->(4)");
            angle  = 90.0f;
            middle = 0.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            //NSLog(@"cam rotated: (4)->(4)");
            angle  = 90.0f;
            middle = 90.0f;
        }
        // calculate new center
        newCenterX = [DeviceConfig previewDisplayWidth] - initialCenter.x + 10;
        newCenterY = initialCenter.y + 10;
    }
    else
    {
        // unsupported orientation
        // do nothing
        return;
    }
    
    currentOrientation = newOrientation;
    
    if( angle == middle ){
        //NSLog(@"no need to animate");
        return;
    }
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             self.layer.opacity = 0.0;
                         } 
                         completion:^(BOOL finished){
                             self.center = CGPointMake(newCenterX, newCenterY);
                             self.transform = rotate;
                             //NSLog(@"notificationLabel moved to center : %@",NSStringFromCGPoint(notification.center));
                             [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
                                 self.layer.opacity = 1.0;
                             } completion:nil];
                         }];
    });
}

@end
