
#import "ApplicationActionCenter.h"
#import "AlbumViewNavigation.h"
#import "ApplicationDecoration.h"
#import "DeviceConfig.h"

@interface ApplicationActionCenter(private)
- (void) setupLocationManager;
@end

@implementation ApplicationActionCenter
@synthesize isColdBooting;
@synthesize window;
@synthesize albumNavigationController;
@synthesize cameraNavigationController;
@synthesize shouldRestoreLastWhitebalanceParameter;
@synthesize currentApplicationContext;
@synthesize locationManager, locationEnabled, currentLongitude, currentLatitude, currentAltitude;
@synthesize shouldUpdateLibIcon;
@synthesize shouldRestartCameraSession;
@synthesize shouldWhitebalanceByImage, currentWhitebalanceByImageBlock;
@synthesize isViewWillAppearAlreadyCalled;

static ApplicationActionCenter *sharedInstance = nil;

- (id) init
{
    self = [super init];
    
    sharedInstance = self;
    
    isColdBooting = YES;
    shouldRestoreLastWhitebalanceParameter = YES;
    shouldUpdateLibIcon = NO;
    shouldRestartCameraSession = NO;
    
    // initialize Camera
    
    cameraViewController = [CameraController sharedInstance];
    
    cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    
    cameraIsActive = NO;
    
    // initialize Album
    
    albumViewController = [AlbumViewController sharedInstance];
    
    albumNavigationController = [[AlbumViewNavigation alloc] initWithRootViewController:albumViewController];
    
    albumIsActive = NO;
    
    // root background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[DeviceConfig FinderHideImage]]; // auto retina, same image as finder hider
    [self.view addSubview:bg];
    
    // setup location manager, this block requires off the main thread
    [self performSelectorOnMainThread:@selector(setupLocationManager) withObject:nil waitUntilDone:YES];
    
    return self;
}

- (UIViewController *) currentViewController
{
    return currentViewController;
}

// 
// context switch
// 

// 
// !!! CAUTION !!!
// 
// a viewController called by ApplicationActionCenter 
// should call ApplicationActionCenter.successToBooting()
// at the end of its viewWillAppear procedure.
// 

- (void) bringupCamera
{
    NSLog(@"# ApplicationActionCenter.bringupCamera() called");
    
    if( albumIsActive )
    {
        NSLog(@"# album is active");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[albumNavigationController dismissModalViewControllerAnimated:YES];
			[albumNavigationController dismissViewControllerAnimated:YES completion:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [window addSubview:cameraNavigationController.view];
                cameraNavigationController.view.hidden = NO;
            });
        });
    }
    else
    {
        NSLog(@"# album is NOT active");
        [window addSubview:cameraNavigationController.view];
        cameraNavigationController.view.hidden = NO;
    }
    
    currentViewController = cameraViewController;
    currentApplicationContext = kApplicationContext_Camera;
    
    cameraIsActive = YES;
    albumIsActive = NO;
}

- (void) bringupAlbum
{
    NSLog(@"# ApplicationActionCenter.bringupAlbum() called");
    if( cameraIsActive )
    {
        NSLog(@"# camera is active");
        
        /*dispatch_async(dispatch_get_main_queue(), ^{
            [cameraNavigationController presentModalViewController:albumNavigationController animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cameraNavigationController.view removeFromSuperview];
            });
        });*/
        
        //[cameraNavigationController presentModalViewController:albumNavigationController animated:YES];
		[cameraNavigationController presentViewController:albumNavigationController animated:YES completion:nil];
        [cameraNavigationController.view removeFromSuperview];
    }
    else
    {
        NSLog(@"# camera NOT active");
        //[self presentModalViewController:albumNavigationController animated:YES];
		[self presentViewController:albumNavigationController animated:YES completion:nil];
    }
    
    currentViewController = albumViewController;
    currentApplicationContext = kApplicationContext_Album;
    
    cameraIsActive = NO;
    albumIsActive = YES;
}

#pragma mark
#pragma mark === LocationManager and CLLocationManagerDelegate ===
#pragma mark

- (void) setupLocationManager
{
    // location
    currentLatitude = 0.0;
    currentLongitude = 0.0;
    locationManager = [[CLLocationManager alloc] init];
    
    if( [CLLocationManager locationServicesEnabled] ){
        NSLog(@"### LocationService enabled");
		locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
	}else{
        NSLog(@"### LocationService disabled");
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"*** WBCam got Location info");
    currentLatitude = newLocation.coordinate.latitude;
    currentLongitude = newLocation.coordinate.longitude;
    currentAltitude = newLocation.altitude;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"*** WBCam fail to get Location info");
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

+ (id) sharedInstance
{
    @synchronized(self){
        if(!sharedInstance){
            sharedInstance = [[self alloc] init]; // so always false
        }
    }
    return sharedInstance;
}

// boot check

+ (BOOL) isColdBooting
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.isColdBooting;
}

+ (void) successToBooting
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.isColdBooting = NO;
}

// application context

+ (void) setCurrentApplicationContext:(ApplicationContextType)context
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.currentApplicationContext = context;
}

+ (ApplicationContextType) getCurrentApplicationContext
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.currentApplicationContext;
}

// whitebalance parameter consistence

+ (BOOL) shouldRestoreLastWhitebalanceParameter
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.shouldRestoreLastWhitebalanceParameter;
}

+ (void) requestShouldRestoreLastWhitebalanceParameter
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.shouldRestoreLastWhitebalanceParameter = YES;
}

+ (void) withdrawShouldRestoreLastWhitebalanceParameter
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.shouldRestoreLastWhitebalanceParameter = NO;
}

// bringup context

+ (void) bringupCamera
{
    ApplicationActionCenter *instance = [self sharedInstance];
    [instance bringupCamera];
}

+ (void) bringupAlbum
{
    ApplicationActionCenter *instance = [self sharedInstance];
    [instance bringupAlbum];
}

// location service

+ (BOOL) locationServiceEnabled
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.locationEnabled;
}

+ (CLLocationDegrees) currentLatitude
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.currentLatitude;
}

+ (CLLocationDegrees) currentLongitude
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.currentLongitude;
}

+ (CLLocationDistance) currentAltitude
{
    ApplicationActionCenter *instance = [self sharedInstance];
    CLLocationDistance alt = instance.currentAltitude;
    if( alt < 0.0 ){ 
        alt = - alt;
    }
    return alt;
}

+ (NSString *) currentLatitudeRef
{
    ApplicationActionCenter *instance = [self sharedInstance];
    NSString *lat_ref;
    if( instance.currentLatitude < 0.0 ){
        lat_ref = @"S";
    }else{ 
        lat_ref = @"N";
    }
    return lat_ref;
}

+ (NSString *) currentLongitudeRef
{
    ApplicationActionCenter *instance = [self sharedInstance];
    NSString *lon_ref;
    if( instance.currentLongitude < 0.0 ){ 
        lon_ref = @"W";
    }else{ 
        lon_ref = @"E"; 
    }
    return lon_ref;
}

+ (NSString *) currentAltitudeRef
{
    ApplicationActionCenter *instance = [self sharedInstance];
    NSString *alt_ref;
    if( instance.currentAltitude < 0.0 ){ 
        alt_ref = @"1"; 
    }else{ 
        alt_ref = @"0"; 
    }
    return alt_ref;
}

// update LibIcon

+ (void) requestShouldUpdateLibIcon
{
    ApplicationActionCenter *instance = [self sharedInstance];
    if( !instance.shouldUpdateLibIcon ){
        instance.shouldUpdateLibIcon = YES;
    }
}

+ (void) withdrawRequestShouldUpdateLibIcon
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.shouldUpdateLibIcon = NO;
}

// restart camera session for unexpected videoDataOutput stall

+ (void) requestShouldRestartCameraSession
{
    ApplicationActionCenter *instance = [self sharedInstance];
    if( !instance.shouldRestartCameraSession ){
        instance.shouldRestartCameraSession = YES;
    }
}

+ (void) withdrawRequestShouldRestartCameraSession
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.shouldRestartCameraSession = NO;
}

// manual whitebalance by user selected image

+ (void) requestWhitebalanceByImageWithBlock:(void (^)(void))whitebalanceByImageBlock
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.currentWhitebalanceByImageBlock = whitebalanceByImageBlock;
    instance.shouldWhitebalanceByImage = YES;
}

+ (BOOL) shouldWhitebalanceByImage
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.shouldWhitebalanceByImage;
}

+ (void) withdrawRequestWhitebalanceByImage
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.shouldWhitebalanceByImage = NO;
}

+ (BOOL) isViewWillAppearAlreadyCalled
{
    ApplicationActionCenter *instance = [self sharedInstance];
    return instance.isViewWillAppearAlreadyCalled;
}

+ (void) flagonViewWillAppearAlreadyCalled
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.isViewWillAppearAlreadyCalled = YES;
}

+ (void) flagoffViewWillAppearAlreadyCalled
{
    ApplicationActionCenter *instance = [self sharedInstance];
    instance.isViewWillAppearAlreadyCalled = NO;
}

@end
