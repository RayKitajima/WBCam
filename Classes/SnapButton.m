
#import <UIKit/UIKit.h>
#import "SnapButton.h"
#import "CameraController.h"
#import "DeviceConfig.h"

@implementation SnapButton


#pragma mark
#pragma mark === ui supports  ===
#pragma mark

- (void) enableButtonAction
{
    NSLog(@"SnapButton.enableButtonAction() called");
    enabled = YES;
    snapIcon.layer.opacity = 1.0;
}

- (void) disableButtonAction
{
    NSLog(@"SnapButton.disableButtonAction() called");
    enabled = NO;
    snapIcon.layer.opacity = 0.2;
}


#pragma mark
#pragma mark === Touch handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
    
    // button down
    backgroundDown.hidden = NO;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
    
    // button up
    backgroundDown.hidden = YES;
    
    // call snap action
    [CameraController snap];
    
    // then, will be disabled, disableButtonAction(), by CameraController while saving photo
}


#pragma mark
#pragma mark === object setting  ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // background up
    UIImage *bg_up_img = [DeviceConfig snapButtonUpImage];
    backgroundUp = [[UIImageView alloc] initWithImage:bg_up_img];
    backgroundUp.frame = [DeviceConfig snapButtonUpImageRect];
    backgroundUp.hidden = NO;
    
    // background down
    UIImage *bg_down_img = [DeviceConfig snapButtonDownImage];
    backgroundDown = [[UIImageView alloc] initWithImage:bg_down_img];
    backgroundDown.frame = [DeviceConfig snapButtonDownImageRect];
    backgroundDown.hidden = YES;
    
    // camera icon
    UIImage *camIconImage = [UIImage imageNamed:@"cam_icon"]; // auto retina
    snapIcon = [[UIImageView alloc] initWithImage:camIconImage];
    snapIcon.center = [DeviceConfig snapButtonIconCenterPoint];
    //snapIcon.frame = CGRectMake(0, 0, 26.0f, 19.0f);
    
    // get device orientation
    currentOrientation = [[UIDevice currentDevice] orientation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self addSubview:backgroundUp];
    [self addSubview:backgroundDown];
    [self addSubview:snapIcon];
    
    enabled = YES;
    
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
    CGFloat angle;
    if( newOrientation == UIDeviceOrientationPortrait )
    {
        // 1
        angle = 0.0f;
        //NSLog(@"cam rotated: (1)");
    }
    else if( newOrientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        angle = 180.0f;
        //NSLog(@"cam rotated: (2)");
    }
    else if( newOrientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        angle = -90.0f;
        //NSLog(@"cam rotated: (3)");
    }
    else if( newOrientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        angle = 90.0f;
        //NSLog(@"cam rotated: (4)");
    }
    else
    {
        // unsupported orientation
        // do nothing
        return;
    }
    
    currentOrientation = newOrientation;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.13f];
    snapIcon.transform = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    [UIView commitAnimations];
}

@end
