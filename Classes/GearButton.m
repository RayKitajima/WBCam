
#import <UIKit/UIKit.h>
#import "GearButton.h"
#import "CameraController.h"
#import "DeviceConfig.h"

@implementation GearButton


#pragma mark
#pragma mark === ui supports  ===
#pragma mark

- (void) buttonOn
{
	backgroundDown.hidden = NO; // button image is down
}

- (void) buttonOff
{
	backgroundDown.hidden = YES; // button image is up
}

- (void) enableButtonAction
{
    NSLog(@"GearButton.enableButtonAction() called");
    enabled = YES;
    gearIcon.layer.opacity = 1.0;
}

- (void) disableButtonAction
{
    NSLog(@"GearButton.disableButtonAction() called");
    enabled = NO;
    gearIcon.layer.opacity = 0.2;
}

#pragma mark
#pragma mark === button handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
	backgroundDown.hidden = NO; // button down
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
    
	active = !active;
	
    if( active ){
		NSLog(@"*** GearsButton active");
		[self buttonOn];
		[CameraController gearsAppear]; // show gears
	}else{
		NSLog(@"*** GearsButton off");
		[self buttonOff];
		[CameraController gearsDisappear]; // hide gears
	}
}


#pragma mark
#pragma mark === object setting  ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // background up
    UIImage *bg_up_img = [DeviceConfig gearButtonUpImage];
    backgroundUp = [[UIImageView alloc] initWithImage:bg_up_img];
    backgroundUp.frame = [DeviceConfig gearButtonUpImageRect];
    backgroundUp.hidden = NO;
    
    // background down
    UIImage *bg_down_img = [DeviceConfig gearButtonDownImage];
    backgroundDown = [[UIImageView alloc] initWithImage:bg_down_img];
    backgroundDown.frame = [DeviceConfig gearButtonDownImageRect];
    backgroundDown.hidden = YES;
    
    // gear icon
    UIImage *gearIconImage = [UIImage imageNamed:@"gear_icon"]; // auto retina
    gearIcon = [[UIImageView alloc] initWithImage:gearIconImage];
    gearIcon.center = [DeviceConfig gearButtonIconCenterPoint];
    
    // get device orientation
    currentOrientation = [[UIDevice currentDevice] orientation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self addSubview:backgroundUp];
    [self addSubview:backgroundDown];
    [self addSubview:gearIcon];
    
    enabled = YES;
	active = NO;
    
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
    gearIcon.transform = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    [UIView commitAnimations];
}

@end
