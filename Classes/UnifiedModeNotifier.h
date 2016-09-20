
#import <Foundation/Foundation.h>
#import "WBModeNotifier.h"
#import "AEAFModeNotifier.h"
#import "ExposureModeNotifier.h"
#import "FocusModeNotifier.h"

@interface UnifiedModeNotifier : UIView
{
    WBModeNotifier       *wbModeNotifier;
    AEAFModeNotifier     *aeafModeNotifier;
	ExposureModeNotifier *exposureModeNotifier;
	FocusModeNotifier    *focusModeNotifier;
    
    NSString *string_unified;
    NSString *string_WB;
    NSString *string_AEAF;
	NSString *string_Exposure;
	NSString *string_Focus;
    
    UILabel *notificationLabel;
    
    CGPoint initialCenter;
    UIDeviceOrientation currentOrientation;
}
@property CGPoint initialCenter;

+ (id) sharedInstanceWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame;

- (void) show;
- (void) hide;

- (void) showWBAdjusting;
- (void) showWBLocked;
- (void) showWBAuto;
- (void) showWBManual;
- (void) clearWBNotification;

- (void) showFocusAdjusting;
- (void) showFocusLocked;
- (void) showFocusAuto;
- (void) showFocusManual;
- (void) clearFocusNotification;

- (void) showExposureAdjusting;
- (void) showExposureLocked;
- (void) showExposureAuto;
- (void) showExposureManual;
- (void) clearExposureNotification;

// live for backward compatibility
- (void) showAEAFAdjusting;
- (void) showAEAFLocked;
- (void) showAEAFAuto;
- (void) showAEAFManual;
- (void) clearAEAFNotification;

- (void) rotated:(NSNotification *)notification;

@end

