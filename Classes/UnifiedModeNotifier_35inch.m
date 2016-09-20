
#import <QuartzCore/QuartzCore.h>
#import "UnifiedModeNotifier_35inch.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "PreviewHelper.h"

@implementation UnifiedModeNotifier_35inch

#pragma mark
#pragma mark === view control ===
#pragma mark

- (void) show
{
    self.hidden = NO;
}

- (void) hide
{
    self.hidden = YES;
}

- (void) updateNotification
{
    if( [string_Exposure isEqualToString:@""] )
    {
        string_Exposure = exposureModeNotifier.string_default;
    }
    if( [string_Focus isEqualToString:@""] )
    {
        string_Focus = focusModeNotifier.string_default;
    }
    if( [string_WB isEqualToString:@""] )
    {
        string_WB = wbModeNotifier.string_default;
    }
    
	// marge
	string_unified = [[[[string_Exposure stringByAppendingString:@"  |  "] stringByAppendingString:string_Focus] stringByAppendingString:@"  |  "] stringByAppendingString:string_WB];
	
    //NSLog(@"# UnifiedModeNotifier : self.center is %.3f,%.3f",self.center.x,self.center.y);
    
    //CGSize line_size = [string_unified sizeWithFont:notificationLabel.font];
    //CGRect frame = notificationLabel.frame;
    //frame.size.width = line_size.width + 30;
    //frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    
    //notificationLabel.frame = frame;
    //notificationLabel.text = string_unified;
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         // hide
                         notificationLabel.layer.opacity = 0.0;
                     } 
                     completion:^(BOOL finished){
                         // backup current rotation
                         CGAffineTransform current = notificationLabel.transform;
                         
                         // rotate to default
                         CGAffineTransform rotate = CGAffineTransformMakeRotation(0);
                         notificationLabel.transform = rotate;
                         
                         // update frame and text
                         //CGSize line_size = [string_unified sizeWithFont:notificationLabel.font];
						 CGSize line_size = [string_unified sizeWithAttributes:@{NSFontAttributeName:notificationLabel.font}];
                         CGRect frame = notificationLabel.frame;
                         frame.size.width = line_size.width + 30;
                         frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
                         notificationLabel.frame = frame;
                         notificationLabel.text = string_unified;
                         
                         // restore rotation
                         notificationLabel.transform = current;
                         
                         [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
                             notificationLabel.layer.opacity = 1.0;
                         } completion:nil];
                     }];
    
}

#pragma mark
#pragma mark === WB notification ===
#pragma mark

- (void) showWBAdjusting
{
    string_WB = wbModeNotifier.string_adjusting;
    [self updateNotification];
}
- (void) showWBLocked
{
    string_WB = wbModeNotifier.string_locked;
    [self updateNotification];
}
- (void) showWBAuto
{
    string_WB = wbModeNotifier.string_auto;
    [self updateNotification];
}
- (void) showWBManual
{
    string_WB = wbModeNotifier.string_manual;
    [self updateNotification];
}
- (void) clearWBNotification
{
    string_WB = @"";
    [self updateNotification];
}


#pragma mark
#pragma mark === exposure notification ===
#pragma mark

- (void) showExposureAdjusting
{
    string_Exposure = exposureModeNotifier.string_adjusting;
    [self updateNotification];
}
- (void) showExposureLocked
{
    string_Exposure = exposureModeNotifier.string_locked;
    [self updateNotification];
}
- (void) showExposureAuto
{
    string_Exposure = exposureModeNotifier.string_auto;
    [self updateNotification];
}
- (void) showExposureManual
{
    //string_Exposure = exposureModeNotifier.string_manual;
    //[self updateNotification];

	PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
	int level = previewHelper.exposureAdjustmentLevel;
	
	if( level > 0 ){
		NSString *levelStr = [NSString stringWithFormat:@"(+%d)",level];
		string_Exposure = [exposureModeNotifier.string_manual stringByAppendingString:levelStr];
	}else if( level < 0 ){
		NSString *levelStr = [NSString stringWithFormat:@"(%d)",level];
		string_Exposure = [exposureModeNotifier.string_manual stringByAppendingString:levelStr];
	}else{
		string_Exposure = exposureModeNotifier.string_manual;
	}
	
    [self updateNotification];
}
- (void) clearExposureNotification
{
    string_Exposure = @"";
    [self updateNotification];
}

#pragma mark
#pragma mark === focus notification ===
#pragma mark

- (void) showFocusAdjusting
{
    string_Focus = focusModeNotifier.string_adjusting;
    [self updateNotification];
}
- (void) showFocusLocked
{
    string_Focus = focusModeNotifier.string_locked;
    [self updateNotification];
}
- (void) showFocusAuto
{
    string_Focus = focusModeNotifier.string_auto;
    [self updateNotification];
}
- (void) showFocusManual
{
    string_Focus = focusModeNotifier.string_manual;
    [self updateNotification];
}
- (void) clearFocusNotification
{
    string_Focus = @"";
    [self updateNotification];
}

#pragma mark
#pragma mark === AEAF notification ===
#pragma mark

- (void) showAEAFAdjusting
{
    //string_AEAF = aeafModeNotifier.string_adjusting;
	[self showExposureAdjusting];
	[self showFocusAdjusting];
	
    [self updateNotification];
}
- (void) showAEAFLocked
{
    //string_AEAF = aeafModeNotifier.string_locked;
	[self showExposureLocked];
	[self showFocusLocked];
	
    [self updateNotification];
}
- (void) showAEAFAuto
{
    //string_AEAF = aeafModeNotifier.string_auto;
	[self showExposureAuto];
	[self showFocusAuto];
	
    [self updateNotification];
}
- (void) showAEAFManual
{
    //string_AEAF = aeafModeNotifier.string_manual;
	[self showExposureManual];
	[self showFocusManual];
	
    [self updateNotification];
}
- (void) clearAEAFNotification
{
    //string_AEAF = @"";
	[self clearExposureNotification];
	[self clearFocusNotification];
	
    [self updateNotification];
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    wbModeNotifier       = [[WBModeNotifier alloc] init];
    aeafModeNotifier     = [[AEAFModeNotifier alloc] init];
	exposureModeNotifier = [[ExposureModeNotifier alloc] init];
	focusModeNotifier    = [[FocusModeNotifier alloc] init];
    
    string_unified  = @"";
    string_WB       = @"";
    string_AEAF     = @"";
	string_Exposure = @"";
	string_Focus    = @"";
    
    // label
    notificationLabel = [[UILabel alloc] init];
    //notificationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    notificationLabel.frame = frame;
    notificationLabel.text = string_unified;
    notificationLabel.font = [UIFont boldSystemFontOfSize:9.0f];
    notificationLabel.textAlignment = NSTextAlignmentCenter;
    notificationLabel.adjustsFontSizeToFitWidth = NO;
    notificationLabel.textColor = [UIColor whiteColor];
    notificationLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    notificationLabel.hidden = NO;
    CALayer *layer = [notificationLabel layer];
    [layer setCornerRadius:8.0f];
    [self addSubview:notificationLabel];
    
    self.hidden = NO;
    
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
        newCenterX = initialCenter.x;
        CGFloat margin = [DeviceConfig previewHeight] - initialCenter.y;
        newCenterY = 5 + margin;
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
        CGFloat margin = [DeviceConfig previewHeight] - initialCenter.y;
        //newCenterX = [DeviceConfig previewWidth] - margin - 5;
        newCenterX = [DeviceConfig screenWidth] - margin - 5; // calculate by screen width due to iphone5/ipod5 previewRect hack
        newCenterY = [DeviceConfig previewHeight] / 2;
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
        CGFloat margin = [DeviceConfig previewHeight] - initialCenter.y;
        newCenterX = margin + 5;
        newCenterY = [DeviceConfig previewHeight] / 2;
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
                             notificationLabel.layer.opacity = 0.0;
                         } 
                         completion:^(BOOL finished){
                             self.center = CGPointMake(newCenterX, newCenterY);
                             notificationLabel.transform = rotate;
                             NSLog(@"notificationLabel moved to center : %@",NSStringFromCGPoint(notificationLabel.center));
                             [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
                                 notificationLabel.layer.opacity = 1.0;
                             } completion:nil];
                         }];
    });
}

@end
