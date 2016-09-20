
#import <QuartzCore/QuartzCore.h>
#import "AlbumUtility.h"

#import "SnapDayLabel.h"

@implementation SnapDayLabel
@synthesize initialCenter;

- (void) updateWithIsoDay:(NSString *)iso_day withCompletionBlock:(void (^)(void))completionBlock
{
    localized_day_string = [AlbumUtility localizedDayStringForIsoDay:iso_day];
    
    NSString *unified_string = [localized_day_tag stringByAppendingString:localized_day_string];
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         // hide
                         localized_day_label.layer.opacity = 0.0;
                     } 
                     completion:^(BOOL finished){
                         // backup current rotation
                         CGAffineTransform current = localized_day_label.transform;
                         
                         // rotate to default
                         CGAffineTransform rotate = CGAffineTransformMakeRotation(0);
                         localized_day_label.transform = rotate;
                         
                         // update frame and text
                         //CGSize line_size = [unified_string sizeWithFont:localized_day_label.font];
						 CGSize line_size = [unified_string sizeWithAttributes:@{NSFontAttributeName:localized_day_label.font}];
                         CGRect frame = localized_day_label.frame;
                         frame.size.width = line_size.width + 30;
                         frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
                         localized_day_label.frame = frame;
                         localized_day_label.text = unified_string;
                         
                         // restore rotation
                         localized_day_label.transform = current;
                         
                         //restore opacity of label object, and execute completion block
                         [UIView animateWithDuration:0.2f 
                                               delay:0.0f 
                                             options:0 
                                          animations:^{
                                              localized_day_label.layer.opacity = 1.0;
                                          } 
                                          completion:^(BOOL finished){
                                              completionBlock();
                                          }];
                     }];
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    localized_day_tag = NSLocalizedString(@"Shooting date:", @"Tag for snap day label, the date of this photo was taken");
    
    // label
    localized_day_label = [[UILabel alloc] init];
    //notificationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    localized_day_label.frame = frame;
    localized_day_label.text = localized_day_tag;
    localized_day_label.font = [UIFont boldSystemFontOfSize:9.0f];
    localized_day_label.textAlignment = NSTextAlignmentCenter;
    localized_day_label.adjustsFontSizeToFitWidth = NO;
    localized_day_label.textColor = [UIColor whiteColor];
    localized_day_label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    localized_day_label.hidden = NO;
    CALayer *layer = [localized_day_label layer];
    [layer setCornerRadius:8.0f];
    [self addSubview:localized_day_label];
    
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
        CGFloat margin = [DeviceConfig screenHeight] - initialCenter.y;
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
        newCenterX = [DeviceConfig screenWidth] - 15;
        newCenterY = [DeviceConfig screenHeight] / 2;
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
        newCenterX = 15;
        newCenterY = [DeviceConfig screenHeight] / 2;
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
                             localized_day_label.layer.opacity = 0.0;
                         } 
                         completion:^(BOOL finished){
                             self.center = CGPointMake(newCenterX, newCenterY);
                             localized_day_label.transform = rotate;
                             NSLog(@"localized_day_label moved to center : %@",NSStringFromCGPoint(localized_day_label.center));
                             [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
                                 localized_day_label.layer.opacity = 1.0;
                             } completion:nil];
                         }];
    });
}

@end
