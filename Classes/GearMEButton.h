
#import <Foundation/Foundation.h>

@interface GearMEButton : UIView
{
    BOOL enabled; // button availability
	BOOL active;  // on or off
    
    UIView *gear_btn_mark_view;
    UILabel *btnLabel;
	
    CGPoint initialCenter;
    
    UIDeviceOrientation currentOrientation;
}
@property CGPoint initialCenter;

- (void) buttonOn;
- (void) buttonOff;

- (void) rotated:(NSNotification *)notification;

@end
