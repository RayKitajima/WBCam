
#import <Foundation/Foundation.h>

@interface GearAlignmentWB : UIView
{
    UIImageView *alignmentImageView;
	CGPoint initialPoint;
    int displayWidth;
    int displayHeight;
    UIDeviceOrientation currentOrientation;
}
- (id) initAlignment;
- (void) rotated:(NSNotification *)notification;
@end
