
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AlbumViewController.h"
#import "CameraController.h"

typedef void (^WhitebalanceByImageBlock)();

@interface ApplicationActionCenter : UIViewController <UINavigationControllerDelegate,CLLocationManagerDelegate>
{
    // YES while cold boot 
    // (= YES before first viewController appeared)
    BOOL isColdBooting;
    
    // turn YES while application is running (Active state).
    // turn NO when dropping to Inactive state.
    // if YES, CameraController will restore wbp instead of kicking auto-whitebalance-block at viewWillAppear.
    BOOL shouldRestoreLastWhitebalanceParameter;
    
    BOOL cameraIsActive;
    BOOL albumIsActive;
    
    // ApplicationContext
    ApplicationContextType currentApplicationContext;
    
    // ref of instance in the app delegate
    UIWindow *window; 
    UIViewController *currentViewController;
    
    // Camera
    UINavigationController *cameraNavigationController;
    CameraController *cameraViewController;
    
    // to hack applicationWillResignActive, 
    // check wether the becomeActive is from enterForeground.
    // 
    // route:
    // 
    //   1) applicationDidFinishLaunching -> applicationDidBecomeActive
    //      this case requires pipeline regress
    // 
    //   2) applicationWillEnterForeground(calles camera's viewWillAppear) -> applicationDidBecomeActive
    //      this case not requires, pipeline is regressed in viewWillAppear
    // 
    // * this flag should be offed, in the applicationDidBecomeActive phase (watched by CameraController).
    // * this flag should be oned, in the applicationWillResingActive phase (watched by CameraController).
    // 
    BOOL isViewWillAppearAlreadyCalled;
    
    // request of hooking unexpected videoDataOutput stall
    // not yet used, so that now waiting iOS5 GM
    BOOL shouldRestartCameraSession;
    
    // Album
    UINavigationController *albumNavigationController;
    AlbumViewController *albumViewController;
    
    // Location
    BOOL locationEnabled;
    CLLocationManager *locationManager;
    CLLocationDegrees currentLongitude;
	CLLocationDegrees currentLatitude;
    CLLocationDistance currentAltitude;
    
    // libicon update request
    BOOL shouldUpdateLibIcon;
    
    // support manual whitebalance by user selected image
    BOOL shouldWhitebalanceByImage;
    WhitebalanceByImageBlock currentWhitebalanceByImageBlock;
}

@property BOOL isColdBooting;
@property (retain) UIWindow *window;
@property (retain) UINavigationController *cameraNavigationController;
@property (retain) UINavigationController *albumNavigationController;
@property (nonatomic) BOOL shouldRestoreLastWhitebalanceParameter;
@property (nonatomic) ApplicationContextType currentApplicationContext;
@property (retain) CLLocationManager *locationManager;
@property BOOL locationEnabled;
@property CLLocationDegrees currentLongitude;
@property CLLocationDegrees currentLatitude;
@property CLLocationDistance currentAltitude;
@property BOOL shouldUpdateLibIcon;
@property BOOL shouldRestartCameraSession;
@property BOOL isViewWillAppearAlreadyCalled;

@property (readwrite,copy) WhitebalanceByImageBlock currentWhitebalanceByImageBlock;
@property BOOL shouldWhitebalanceByImage;

- (UIViewController *) currentViewController;

- (void) bringupCamera;
- (void) bringupAlbum;

+ (id) sharedInstance;

+ (BOOL) isColdBooting;
+ (void) successToBooting;

+ (void) setCurrentApplicationContext:(ApplicationContextType)context;
+ (ApplicationContextType) getCurrentApplicationContext;

+ (void) bringupCamera;
+ (void) bringupAlbum;

+ (BOOL) shouldWhitebalanceByImage;
+ (void) requestWhitebalanceByImageWithBlock:(void (^)(void))whitebalanceByImageBlock;
+ (void) withdrawRequestWhitebalanceByImage;

+ (BOOL) shouldRestoreLastWhitebalanceParameter;
+ (void) requestShouldRestoreLastWhitebalanceParameter;
+ (void) withdrawShouldRestoreLastWhitebalanceParameter;

+ (BOOL) locationServiceEnabled;
+ (CLLocationDegrees) currentLongitude;
+ (CLLocationDegrees) currentLatitude;
+ (CLLocationDistance) currentAltitude;
+ (NSString *) currentLatitudeRef;
+ (NSString *) currentLongitudeRef;
+ (NSString *) currentAltitudeRef;

+ (void) requestShouldUpdateLibIcon;
+ (void) withdrawRequestShouldUpdateLibIcon;

+ (void) requestShouldRestartCameraSession;
+ (void) withdrawRequestShouldRestartCameraSession;

+ (BOOL) isViewWillAppearAlreadyCalled;
+ (void) flagonViewWillAppearAlreadyCalled;
+ (void) flagoffViewWillAppearAlreadyCalled;

@end
