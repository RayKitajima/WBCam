
@interface GearLPButton : UIView
{
    UIView *gear_btn_mark_view;
    UILabel *btnLabel;
	
    CGPoint initialCenter;
    
    UIDeviceOrientation currentOrientation;
}
@property CGPoint initialCenter;

- (void) rotated:(NSNotification *)notification;

@end
