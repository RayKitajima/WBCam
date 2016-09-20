
#import <Foundation/Foundation.h>

@interface SnapDayLabel : UIView
{
    NSString *localized_day_tag;
    NSString *localized_day_string;
    UILabel *localized_day_label;
    
    CGPoint initialCenter;
    UIDeviceOrientation currentOrientation;
}
@property CGPoint initialCenter;

- (void) updateWithIsoDay:(NSString *)iso_day withCompletionBlock:(void (^)(void))completionBlock;

- (void) rotated:(NSNotification *)notification;

@end
