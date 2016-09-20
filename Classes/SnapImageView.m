
#import <QuartzCore/QuartzCore.h>
#import "SnapImageView.h"
#import "SnapImageScroller.h"
#import "ApplicationActionCenter.h"

@implementation SnapImageView
@synthesize currentOrientation;

#pragma mark
#pragma mark === device rotation observer ===
#pragma mark

- (id) initWithImage:(UIImage *)image
{
    NSLog(@"*** initializing SnapImageView");
    
    self = [super initWithImage:image];
    
    // 
    // get device orientation
    // 
    currentOrientation = [[UIDevice currentDevice] orientation];
    
    // 
    // observing shouldUpdateLibIcon
    // 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(rotateSnapImageView:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    return self;
}

#pragma mark
#pragma mark === device rotation observer ===
#pragma mark

- (void) rotateSnapImageView:(NSNotification *)notification
{
    NSLog(@"*** SnapImageView.roteted called");
    
    //UIDeviceOrientation newOrientation = [[notification object] orientation];
	UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
    
    //NSLog(@"*** SnapImageView : orientaion %@",newOrientation);
    
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
    CGFloat angle  = 0.0f;
    CGFloat middle = 0.0f;
    if( newOrientation == UIDeviceOrientationPortrait )
    {
        // 1
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(1)");
            angle  = 0.0f;
            middle = 0.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(1)");
            angle  = 0.0f;
            middle = -90.0f; // same as other self rotation
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(1)");
            angle  = 0.0f;
            middle = -45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(1)");
            angle  = 0.0f;
            middle = 45.0f;
        }
    }
    else if( newOrientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(2)");
            angle  = -180.0f; // same as other self rotation
            middle = -90.0f; 
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(2)");
            angle  = 180.0f;
            middle = 180.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(2)");
            angle  = -180.0f;
            middle = -135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(2)");
            angle  = 180.0f;
            middle = 135.0f;
        }
    }
    else if( newOrientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(3)");
            angle  = -90.0f;
            middle = -45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(3)");
            angle  = -90.0f;
            middle = -135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(3)");
            angle  = -90.0f;
            middle = -90.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(3)");
            angle  = -90.0f;
            middle = 0.0f;
        }
    }
    else if( newOrientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(4)");
            angle  = 90.0f;
            middle = 45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(4)");
            angle  = 90.0f;
            middle = 135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(4)");
            angle  = 90.0f;
            middle = 0.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(4)");
            angle  = 90.0f;
            middle = 90.0f;
        }
    }
    else
    {
        // unsupported orientation
        // do nothing
        return;
    }
    
    currentOrientation = newOrientation;
    
//    if( angle == middle ){
//        NSLog(@"no need to animate");
//        return;
//    }
    
    CGAffineTransform phase_1_rotate = CGAffineTransformMakeRotation( middle * (M_PI/180.0f) );
    //CGAffineTransform phase_1 = CGAffineTransformScale( phase_1_rotate, 1.4f, 1.4f );
    CGAffineTransform phase_1 = CGAffineTransformScale( phase_1_rotate, 1.0f, 1.0f );
    
    CGAffineTransform phase_2_rotate = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    CGAffineTransform phase_2 = CGAffineTransformScale( phase_2_rotate, 1.0f, 1.0f );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.07f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             self.transform = phase_1;
                         } 
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.05f delay:0.03f options:0 animations:^{
                                 self.transform = phase_2;
                             } completion:nil];
                         }];
    });
}

@end
