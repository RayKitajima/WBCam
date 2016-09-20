
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "DeviceConfig_iPhone4_iOS5.h"
#import "DeviceConfig_iPhone4_iOS6.h"
#import "DeviceConfig_iPhone4_iOS7.h"
#import "DeviceConfig_iPhone4S_iOS5.h"
#import "DeviceConfig_iPhone4S_iOS6.h"
#import "DeviceConfig_iPhone4S_iOS7.h"
#import "DeviceConfig_iPhone5_iOS6.h"
#import "DeviceConfig_iPhone5_iOS7.h"
#import "DeviceConfig_iPhone5S_iOS7.h"
#import "DeviceConfig_iPhone5C_iOS7.h"
#import "DeviceConfig_iPod4_iOS5.h"
#import "DeviceConfig_iPod4_iOS6.h"
#import "DeviceConfig_iPod5_iOS6.h"
#import "DeviceConfig_iPod5_iOS7.h"

#include <sys/types.h>
#include <sys/sysctl.h>

static ApplicationConfig *sharedInstance = nil;
@implementation ApplicationConfig
@synthesize deviceConfig;
@synthesize finderPreviewQueue;
@synthesize backgroundQueue;
@synthesize shared_lock;

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id)init
{
    self = [super init];
    
    // determin hardware
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    //free(machine);
    
    /*
    UIDevice *dv = [UIDevice currentDevice];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSLog(@"### device info:");
    NSLog(@"### ");
    NSLog(@"### hardware platform  : %@", platform );
    NSLog(@"### name               : %@", dv.name );
    NSLog(@"### systemName         : %@", dv.systemName );
    NSLog(@"### systemVersion      : %@", dv.systemVersion );
    NSLog(@"### model              : %@", dv.model );
    NSLog(@"### localizedModel     : %@", dv.localizedModel );
    NSLog(@"### userInterfaceIdiom : %@", dv.userInterfaceIdiom );
    NSLog(@"### ");
    NSLog(@"### screen size        : %f x %f", screenRect.size.width,screenRect.size.height);
    NSLog(@"### ");
    */
    
    // make shared lock object
    shared_lock = [[NSLock alloc] init];
    
    // detect device
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *ios_version = device.systemVersion;
    
    NSError *error = NULL;
    
    NSRegularExpression *regex_model_iphone4  = [NSRegularExpression regularExpressionWithPattern:@".*iPhone3.*" options:0 error:&error];
    NSRegularExpression *regex_model_iphone4S = [NSRegularExpression regularExpressionWithPattern:@".*iPhone4.*" options:0 error:&error];
    NSRegularExpression *regex_model_iphone5  = [NSRegularExpression regularExpressionWithPattern:@".*iPhone5.[12]" options:0 error:&error];
	
	NSRegularExpression *regex_model_iphone5S = [NSRegularExpression regularExpressionWithPattern:@".*iPhone6.*" options:0 error:&error];
	NSRegularExpression *regex_model_iphone5C = [NSRegularExpression regularExpressionWithPattern:@".*iPhone5.[34]" options:0 error:&error];
	
    //NSRegularExpression *regex_model_ipod4  = [NSRegularExpression regularExpressionWithPattern:@".*iPod4.*" options:0 error:&error];
    NSRegularExpression *regex_model_ipod5    = [NSRegularExpression regularExpressionWithPattern:@".*iPod5.*" options:0 error:&error];
    
    NSRegularExpression *regex_iosver5 = [NSRegularExpression regularExpressionWithPattern:@"5\\.\\d+" options:0 error:&error];
    NSRegularExpression *regex_iosver6 = [NSRegularExpression regularExpressionWithPattern:@"6\\.\\d+" options:0 error:&error];
	NSRegularExpression *regex_iosver7 = [NSRegularExpression regularExpressionWithPattern:@"7\\.\\d+" options:0 error:&error];
    
    // check hardware model
    NSTextCheckingResult *match_iphone4  = [regex_model_iphone4 firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)];
    NSTextCheckingResult *match_iphone4S = [regex_model_iphone4S firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)];
    NSTextCheckingResult *match_iphone5  = [regex_model_iphone5 firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)];
	
	NSTextCheckingResult *match_iphone5S = [regex_model_iphone5S firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)]; // TODO:ios7,iphone5sc
	NSTextCheckingResult *match_iphone5C = [regex_model_iphone5C firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)]; // TODO:ios7,iphone5sc
	
    //NSTextCheckingResult *match_ipod4  = [regex_model_ipod4 firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)];
    NSTextCheckingResult *match_ipod5    = [regex_model_ipod5 firstMatchInString:platform options:0 range:NSMakeRange(0, platform.length)];
    
    // check ios version
    NSTextCheckingResult *match_v5 = [regex_iosver5 firstMatchInString:ios_version options:0 range:NSMakeRange(0, ios_version.length)];
    NSTextCheckingResult *match_v6 = [regex_iosver6 firstMatchInString:ios_version options:0 range:NSMakeRange(0, ios_version.length)];
	NSTextCheckingResult *match_v7 = [regex_iosver7 firstMatchInString:ios_version options:0 range:NSMakeRange(0, ios_version.length)];
    
    deviceConfig = nil;
    
    if( match_iphone4 && match_v5 )
    {
        // 
        // iphone3,*(4G), ios version 5
        // 
        NSLog(@"DEVICE is iPhone3,* (4G) with iOS5");
        deviceConfig = [[DeviceConfig_iPhone4_iOS5 alloc] init];
    }
    else if( match_iphone4 && match_v6 )
    {
        //
        // iphone3,*(4G), ios version 6
        //
        NSLog(@"DEVICE is iPhone3,* (4G) with iOS6");
        deviceConfig = [[DeviceConfig_iPhone4_iOS6 alloc] init];
    }
    else if( match_iphone4 && match_v7 )
    {
        //
        // iphone3,*(4G), ios version 7
        //
        NSLog(@"DEVICE is iPhone3,* (4G) with iOS7");
        deviceConfig = [[DeviceConfig_iPhone4_iOS7 alloc] init];
    }
    else if( match_iphone4S && match_v5 )
    {
        // 
        // iphone4,*(5G), ios version 5
        // 
        NSLog(@"DEVICE is iPhone4,* (5G) with iOS5");
        deviceConfig = [[DeviceConfig_iPhone4S_iOS5 alloc] init];
    }
    else if( match_iphone4S && match_v6 )
    {
        //
        // iphone4,*(5G), ios version 6
        //
        NSLog(@"DEVICE is iPhone4,* (5G) with iOS6");
        deviceConfig = [[DeviceConfig_iPhone4S_iOS6 alloc] init];
    }
    else if( match_iphone4S && match_v7 )
    {
        //
        // iphone4,*(5G), ios version 7
        //
        NSLog(@"DEVICE is iPhone4,* (5G) with iOS7");
        deviceConfig = [[DeviceConfig_iPhone4S_iOS7 alloc] init];
    }
    else if( match_iphone5 && match_v6 )
    {
        //
        // iphone5,*(6G), ios version 6
        //
        NSLog(@"DEVICE is iPhone5,* (5G) with iOS6");
        deviceConfig = [[DeviceConfig_iPhone5_iOS6 alloc] init];
    }
    else if( match_iphone5 && match_v7 )
    {
        //
        // iphone5,*(6G), ios version 7
        //
        NSLog(@"DEVICE is iPhone5,* (5G) with iOS7");
        deviceConfig = [[DeviceConfig_iPhone5_iOS7 alloc] init];
    }
    else if( match_iphone5S && match_v7 )
    {
        //
        // iphone5S,*(6G), ios version 7
        //
        NSLog(@"DEVICE is iPhone5S,* (5G) with iOS7");
        deviceConfig = [[DeviceConfig_iPhone5S_iOS7 alloc] init];
    }
    else if( match_iphone5C && match_v7 )
    {
        //
        // iphone5C,*(6G), ios version 7
        //
        NSLog(@"DEVICE is iPhone5C,* (5G) with iOS7");
        deviceConfig = [[DeviceConfig_iPhone5C_iOS7 alloc] init];
    }
    /* ipod4 is disabled for distribution release
    else if( match_ipod4 && (match_v5 || match_v6) )
    {
        // 
        // ipod4,*(4G), ios version 5
        // 
        NSLog(@"DEVICE is iPod4,* (4G)");
        //
        // iPod4 is not supported, immediately kill the app
        //
        //exit(0);
        deviceConfig = [[DeviceConfig_iPod4_iOS5 alloc] init];
    }
    */
    else if( match_ipod5 && match_v6 )
    {
        //
        // ipod5,*(5G), ios version 6
        //
        NSLog(@"DEVICE is iPod5,* (5G)");
        deviceConfig = [[DeviceConfig_iPod5_iOS6 alloc] init];
    }
    else if( match_ipod5 && match_v7 )
    {
        //
        // ipod5,*(5G), ios version 7
        //
        NSLog(@"DEVICE is iPod5,* (5G)");
        deviceConfig = [[DeviceConfig_iPod5_iOS7 alloc] init];
    }
    else
    {
        NSLog(@"unsupported device.");
        exit(0);
    }
    
    if( deviceConfig == nil ){
        NSLog(@"cannot determin device.");
        exit(0);
    }
    
    // prepare finder queue (videoDataOutputQueue)
    //finderPreviewQueue = dispatch_queue_create("FinderPreviewQueue", DISPATCH_QUEUE_SERIAL);
    finderPreviewQueue = dispatch_get_main_queue();
//    dispatch_retain(finderPreviewQueue);
    
    // prepare background queue
    backgroundQueue = dispatch_queue_create("BackgroundQueue", NULL);
//    dispatch_retain(backgroundQueue);
    
    return self;
}

#pragma mark
#pragma mark === public services ===
#pragma mark

- (void) validate
{
    // do nothing
}

+ (void) bootup
{
    ApplicationConfig *instance = [self sharedInstance];
    [instance validate];
}

+ (id) sharedInstance
{
	@synchronized(self){
		if( !sharedInstance ){
			sharedInstance = [[ApplicationConfig alloc] init];
		}
	}
    return sharedInstance;
}

+ (DeviceConfig *) deviceConfig
{
    ApplicationConfig *instance = [self sharedInstance];
    return instance.deviceConfig;
}

+ (dispatch_queue_t) finderPreviewQueue
{
    ApplicationConfig *instance = [self sharedInstance];
    return instance.finderPreviewQueue;
}

+ (dispatch_queue_t) foregroundQueue
{
    ApplicationConfig *instance = [self sharedInstance];
    return instance.finderPreviewQueue;
}

+ (dispatch_queue_t) backgroundQueue
{
    ApplicationConfig *instance = [self sharedInstance];
    return instance.backgroundQueue;
}

+ (NSLock *) sharedLock
{
    ApplicationConfig *instance = [self sharedInstance];
    return instance.shared_lock;
}

@end
