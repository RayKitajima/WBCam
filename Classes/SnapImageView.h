
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SnapImageView : UIImageView
{
    UIDeviceOrientation currentOrientation;
}
@property UIDeviceOrientation currentOrientation;

- (void) rotateSnapImageView:(NSNotification *)notification;

@end
