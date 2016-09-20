
#import <Foundation/Foundation.h>

@interface TorchButton : UIView
{
    BOOL enabled; // TorchButton availability
    
    UIImageView *torch_on_imageView;
    UIImageView *torch_off_imageView;
    
    CGPoint initialCenter;
    
    UIDeviceOrientation currentOrientation;
}
@property CGPoint initialCenter;

- (void) rotated:(NSNotification *)notification;

@end
