
#import <UIKit/UIKit.h>
#import "ApplicationDecoration.h"

@interface SnappingNotifier : UIView
{
    // 
    // pre-defined notifier elements
    // 
    UIActivityIndicatorView *indicator;
    UILabel *snappingLabel; // indicate snapping and saving
    
    NSString *string_snapping;
    NSString *string_saving;
}

+ (id) sharedInstanceWithFrame:(CGRect)frame withCenter:(CGPoint)center;

- (id)initWithFrame:(CGRect)frame withCenter:(CGPoint)center;

- (BOOL) isNotificationHidden;
- (void) showNotification;
- (void) hideNotification;

- (void) showSnapping;
- (void) showSaving;

@end
