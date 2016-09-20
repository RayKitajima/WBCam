
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface GearButton : UIView {
    
    BOOL enabled;
	BOOL active;
    
    UIImageView *backgroundUp;
    UIImageView *backgroundDown;
    UIImageView *gearIcon;
    
    UIDeviceOrientation currentOrientation;
    
}

- (void) buttonOn;
- (void) buttonOff;

- (void) enableButtonAction;
- (void) disableButtonAction;

- (id) initWithFrame:(CGRect)frame;
- (void) rotated:(NSNotification *)notification;

@end
