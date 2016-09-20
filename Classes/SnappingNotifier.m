
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "SnappingNotifier.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "ApplicationDecoration.h"

#import "SnappingNotifier_iPhone4_iOS5.h"
#import "SnappingNotifier_iPhone4_iOS6.h"
#import "SnappingNotifier_iPhone4_iOS7.h"
#import "SnappingNotifier_iPhone4S_iOS5.h"
#import "SnappingNotifier_iPhone4S_iOS6.h"
#import "SnappingNotifier_iPhone4S_iOS7.h"
#import "SnappingNotifier_iPhone5_iOS6.h"
#import "SnappingNotifier_iPhone5_iOS7.h"
#import "SnappingNotifier_iPhone5S_iOS7.h"
#import "SnappingNotifier_iPhone5C_iOS7.h"
#import "SnappingNotifier_iPod4_iOS5.h"
#import "SnappingNotifier_iPod4_iOS6.h"
#import "SnappingNotifier_iPod5_iOS6.h"
#import "SnappingNotifier_iPod5_iOS7.h"

@implementation SnappingNotifier

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

static SnappingNotifier *instance = nil;

+ (id) sharedInstanceWithFrame:(CGRect)frame withCenter:(CGPoint)center
{
	//NSLog(@"SnappingNotifier instance called");
	@synchronized(self){
		if( !instance ){
            ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
            DeviceConfig *deviceConfig = [app_conf deviceConfig];
            
            switch (deviceConfig.deviceIdentification) {
                    
                case kDeviceIdentification_iPhone4_iOS5:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone4_iOS5");
                    instance = [[SnappingNotifier_iPhone4_iOS5 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone4_iOS6:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone4_iOS6");
                    instance = [[SnappingNotifier_iPhone4_iOS6 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone4_iOS7:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone4_iOS7");
                    instance = [[SnappingNotifier_iPhone4_iOS7 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS5:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone4S_iOS5");
                    instance = [[SnappingNotifier_iPhone4S_iOS5 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS6:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone4S_iOS6");
                    instance = [[SnappingNotifier_iPhone4S_iOS6 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone4S_iOS7:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone4S_iOS7");
                    instance = [[SnappingNotifier_iPhone4S_iOS7 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone5_iOS6:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone5_iOS6");
                    instance = [[SnappingNotifier_iPhone5_iOS6 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone5_iOS7:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone5_iOS7");
                    instance = [[SnappingNotifier_iPhone5_iOS7 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone5S_iOS7:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone5S_iOS7");
                    instance = [[SnappingNotifier_iPhone5S_iOS7 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPhone5C_iOS7:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPhone5C_iOS7");
                    instance = [[SnappingNotifier_iPhone5C_iOS7 alloc] initWithFrame:frame withCenter:center];
                    break;
                    
                case kDeviceIdentification_iPod4_iOS5:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPod4_iOS5");
                    // enough fast to not show the indicator (but low res photo)
                    //instance = [[SnappingNotifier_iPod4_iOS5 alloc] initWithFrame:frame withCenter:center];
                    instance = nil;
                    break;
                    
                case kDeviceIdentification_iPod4_iOS6:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPod4_iOS6");
                    // enough fast to not show the indicator (but low res photo)
                    //instance = [[SnappingNotifier_iPod4_iOS6 alloc] initWithFrame:frame withCenter:center];
                    instance = nil;
                    break;
                    
                case kDeviceIdentification_iPod5_iOS6:
                    NSLog(@"SnappingNotifier concrete instance : SnappingNotifier_iPod5_iOS6");
                    instance = [[SnappingNotifier_iPod5_iOS6 alloc] initWithFrame:frame withCenter:center];
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

- (BOOL) isNotificationHidden { return YES; }
- (void) showNotification {}
- (void) hideNotification {}

- (void) showSnapping {}
- (void) showSaving {}

- (id) initWithFrame:(CGRect)frame withCenter:(CGPoint)center
{
    self = [super initWithFrame:frame];
    return self;
}

@end
