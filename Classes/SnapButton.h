
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface SnapButton : UIView {
    
    BOOL enabled;
    
    UIImageView *backgroundUp;
    UIImageView *backgroundDown;
    UIImageView *snapIcon;
    
    UIDeviceOrientation currentOrientation;
    
}

- (void) enableButtonAction;
- (void) disableButtonAction;

- (id) initWithFrame:(CGRect)frame;
- (void) rotated:(NSNotification *)notification;

@end
