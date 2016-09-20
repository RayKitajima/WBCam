
#import <QuartzCore/QuartzCore.h>
#import "GearWBButton.h"
#import "GearColorMark.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "GearContainer.h"

const CGFloat wb_gear_button_off_alpha      = 0.50f;
const CGFloat wb_gear_button_off_bg_alpha   = 0.45f;
const CGFloat wb_gear_button_off_line_alpha = 0.45f;

const CGFloat wb_gear_button_on_alpha       = 0.75f;
const CGFloat wb_gear_button_on_bg_alpha    = 0.70f;
const CGFloat wb_gear_button_on_line_alpha  = 0.70f;

@implementation GearWBButton
@synthesize initialCenter;

#pragma mark
#pragma mark === button handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
	
	active = !active;
	
    if( active ){
		[self buttonOn];
	}else{
		[self buttonOff];
	}
}

#pragma mark
#pragma mark === button on/off ===
#pragma mark

- (void) buttonOn
{
	NSLog(@"WB button on");
	
	CALayer *layer = [self layer];
	[layer setBackgroundColor:[[UIColor colorWithWhite:0.3f alpha:wb_gear_button_on_bg_alpha] CGColor]];
	[layer setBorderColor:[[UIColor colorWithWhite:1.0f alpha:wb_gear_button_on_line_alpha] CGColor]];
	
	GearContainer *container = [GearContainer quickInstance];
	[container showAlignmentWB]; // on
}

- (void) buttonOff
{
	NSLog(@"WB button on");
	
	CALayer *layer = [self layer];
	[layer setBackgroundColor:[[UIColor colorWithWhite:0.3f alpha:wb_gear_button_off_bg_alpha] CGColor]];
	[layer setBorderColor:[[UIColor colorWithWhite:1.0f alpha:wb_gear_button_off_line_alpha] CGColor]];
	
	GearContainer *container = [GearContainer quickInstance];
	[container hideAlignmentWB]; // off
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    enabled = YES;
	active  = NO;
    
    gear_btn_mark_view = [[GearColorMark alloc] initWithFrame:CGRectMake(7, 10, 10, 10) withCGColorRef:[UIColor blueColor].CGColor];
    gear_btn_mark_view.layer.opacity = wb_gear_button_off_alpha;
	gear_btn_mark_view.hidden = NO;
    [self addSubview:gear_btn_mark_view];
    
    CALayer *layer = [self layer];
    [layer setBackgroundColor:[[UIColor colorWithWhite:0.3f alpha:wb_gear_button_off_bg_alpha] CGColor]];
    [layer setBorderWidth:1.0f];
    [layer setBorderColor:[[UIColor colorWithWhite:1.0f alpha:wb_gear_button_off_line_alpha] CGColor]];
    [layer setCornerRadius:15.f];
    
    initialCenter = self.center;
	
	// label
    btnLabel = [[UILabel alloc] init];
    btnLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    btnLabel.frame = CGRectMake(17, 0, 30, 30);
    btnLabel.text = @"WB";
    btnLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    btnLabel.textAlignment = NSTextAlignmentCenter;
    btnLabel.textColor = [UIColor whiteColor];
    btnLabel.backgroundColor = [UIColor clearColor];
	btnLabel.layer.opacity = wb_gear_button_off_alpha;
    btnLabel.hidden = NO;
    [self addSubview:btnLabel];
	
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
    UIDeviceOrientation newOrientation = [[notification object] orientation];
    
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
		newCenterX = initialCenter.y;
        newCenterY = [DeviceConfig previewDisplayWidth] - initialCenter.x + 10;
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
        newCenterX = [DeviceConfig previewDisplayWidth] - initialCenter.y;
        newCenterY = [DeviceConfig previewDisplayHeight] - ( [DeviceConfig previewDisplayWidth] -initialCenter.x ) - 10;
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