
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "UnifiedModeNotifier.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "ApplicationDecoration.h"

#import "UnifiedModeNotifier_35inch.h"
#import "UnifiedModeNotifier_40inch.h"

@implementation UnifiedModeNotifier
@synthesize initialCenter;

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

static UnifiedModeNotifier *instance = nil;

+ (id) sharedInstanceWithFrame:(CGRect)frame
{
	//NSLog(@"UnifiedModeNotifier instance called");
	@synchronized(self){
		if( !instance ){
            ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
            DeviceConfig *deviceConfig = [app_conf deviceConfig];
            
            switch (deviceConfig.deviceIdentification) {
                    
                case kDeviceIdentification_iPhone4_iOS5:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone4_iOS6:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone4_iOS7:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS5:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS6:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS7:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone5_iOS6:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_40inch");
                    instance = [[UnifiedModeNotifier_40inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone5_iOS7:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_40inch");
                    instance = [[UnifiedModeNotifier_40inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone5S_iOS7:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_40inch");
                    instance = [[UnifiedModeNotifier_40inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPhone5C_iOS7:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_40inch");
                    instance = [[UnifiedModeNotifier_40inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPod4_iOS5:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    instance = nil;
                    break;
                    
                case kDeviceIdentification_iPod4_iOS6:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_35inch");
                    instance = [[UnifiedModeNotifier_35inch alloc] initWithFrame:frame];
                    instance = nil;
                    break;
                    
                case kDeviceIdentification_iPod5_iOS6:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_40inch");
                    instance = [[UnifiedModeNotifier_40inch alloc] initWithFrame:frame];
                    break;
                    
                case kDeviceIdentification_iPod5_iOS7:
                    NSLog(@"UnifiedModeNotifier concrete instance : UnifiedModeNotifier_40inch");
                    instance = [[UnifiedModeNotifier_40inch alloc] initWithFrame:frame];
                    break;
                    
                default:
                    break;
                    
            }
		}
	}
    return instance;
}

#pragma mark
#pragma mark === object interface ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void) show {};
- (void) hide {};

- (void) showWBAdjusting {};
- (void) showWBLocked {};
- (void) showWBAuto {};
- (void) showWBManual {};
- (void) clearWBNotification {};

- (void) showFocusAdjusting {};
- (void) showFocusLocked {};
- (void) showFocusAuto {};
- (void) showFocusManual {};
- (void) clearFocusNotification {};

- (void) showExposureAdjusting {};
- (void) showExposureLocked {};
- (void) showExposureAuto {};
- (void) showExposureManual {};
- (void) clearExposureNotification {};

// live for backward compatibility
- (void) showAEAFAdjusting {};
- (void) showAEAFLocked {};
- (void) showAEAFAuto {};
- (void) showAEAFManual {};
- (void) clearAEAFNotification {};

- (void) rotated:(NSNotification *)notification {};






@end
