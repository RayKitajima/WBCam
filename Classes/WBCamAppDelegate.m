
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#import "WBCamAppDelegate.h"
#import "CameraController.h"
#import "CameraUtility.h"
#import "AlbumUtility.h"
#import "WhiteBalanceConverter.h"
#import "AlbumDataCenter.h"
#import "AlbumViewNavigation.h"
#import "ApplicationActionCenter.h"
#import "CameraHelper.h"
#import "ApplicationDecoration.h"
#import "ApplicationConfig.h"

#import "CameraSession.h"
#import "SnapHelper.h"


@implementation StartupScreenController
- (void) viewDidLoad
{
    UIImage *defaultpng = [UIImage imageNamed:@"Default"]; // auto retina
    startupView = [[UIImageView alloc] initWithImage:defaultpng];
    startupView.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:startupView];
    [ApplicationDecoration startCubeAnimationOnView:startupView withCenter:startupView.center];
}
@end

@implementation WBCamAppDelegate

- (void) bootstrap
{
    // 
    // initialize Application and Device info
    // 
    [ApplicationConfig bootup];
    
    // 
    // clear application data
    // 
    BOOL clearAppData = NO;
    if( clearAppData )
    {
        [CameraUtility clearApplicationData];
    }
    
    // 
    // empty trash
    // 
    BOOL emptyTrash = YES;
    if( emptyTrash )
    {
        [AlbumUtility emptyTrashFolder];
    }
    
    // 
    // clear album manifest file (album_manifest.plist)
    // 
    BOOL clearAlbumManifest = NO;
    
    if( clearAlbumManifest )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *manifest_path = [docPath stringByAppendingPathComponent:@"album_manifest.plist"];
        [fileManager removeItemAtPath:manifest_path error:NULL];
    }
    
    // metafile migration
    //[self delete_migrated_metafile];
    
    // 
    // prep whitebalance converte
    // 
    [WhiteBalanceConverter bootup];
    
    // 
    // prepare album manifest
    // 
    [AlbumDataCenter bootstrap];
    
    // prep camera
    
    // 
    // prepare session and device
    // 
    [CameraSession bootup];
}

- (void) launchApplication
{
    // bootstrap
    [self bootstrap];
    
    // prep ApplicationActionCenter(rootViewController) and show the app
    ApplicationActionCenter *applicationActionCenter = [ApplicationActionCenter sharedInstance];
    applicationActionCenter.window = window;
    
    // iOS6
    NSLog(@"### applicationActionCenter.view added");
    
    window.rootViewController = applicationActionCenter;
    //[window addSubview:applicationActionCenter.view];
    
    // 
    // choose context
    // 
    BOOL startWithCamera = YES;
    
    if( startWithCamera )
    {
        [applicationActionCenter bringupCamera];
	}
    else
    {
        [applicationActionCenter bringupAlbum];
    }
    currentViewController = [applicationActionCenter currentViewController];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	CGRect frame = [[UIScreen mainScreen] bounds];
	window = [[UIWindow alloc] initWithFrame:frame];
	
    // 
    // choose startup animation
    // 
    BOOL startWithAnimation = YES;
    
    if( startWithAnimation ){
        // to show the cube animation,
        // run application initialization in the background and return YES immediately.
        startupController = [[StartupScreenController alloc] init];
        
        // for iOS6
        window.rootViewController = startupController;
        //[window addSubview:startupController.view];
        
        [window makeKeyAndVisible];
        [self performSelectorInBackground:@selector(launchApplication) withObject:nil];
    }
    else
    {
        [self launchApplication];
        [window makeKeyAndVisible];
    }
    
    // start getting orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
	return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"*** applicationWillEnterForeground");
}

- (void) applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"*** applicationWillResignActive");
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"*** applicationDidEnterBackground");
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"*** applicationDidBecomeActive");
}

- (void) applicationWillTerminate:(UIApplication *)application 
{
    // this application does not manage Background state
    NSLog(@"*** applicationWillTerminate");
    
    // end getting orientation
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


#pragma mark
#pragma mark === bootstrap ===
#pragma mark

- (void) delete_migrated_metafile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    
    NSError *error = NULL;
    NSRegularExpression *regex_iso_day = [NSRegularExpression regularExpressionWithPattern:@"\\d{4}\\-\\d{2}\\-\\d{2}" options:0 error:&error];
    NSRegularExpression *regex_file = [NSRegularExpression regularExpressionWithPattern:@"\\d{10}\\.meta" options:0 error:&error];
    
    NSArray *dirs = [fileManager contentsOfDirectoryAtPath:docPath error:NULL];
    for( int i=0; i<dirs.count; i++ ){
        NSString *iso_day = [dirs objectAtIndex:i];
        NSTextCheckingResult *matches = [regex_iso_day firstMatchInString:iso_day options:0 range:NSMakeRange(0, iso_day.length)];
        if( matches ){
            NSString *day_path = [docPath stringByAppendingPathComponent:iso_day];
            NSString *meta_dir = [day_path stringByAppendingPathComponent:@"meta"];
            
            NSArray *items = [fileManager contentsOfDirectoryAtPath:meta_dir error:NULL];
            
            for( int i=0; i<items.count; i++ ){
                NSString *file = [items objectAtIndex:i];
                NSTextCheckingResult *matches = [regex_file firstMatchInString:file options:0 range:NSMakeRange(0, file.length)];
                
                if( matches ){
                    NSString *unixtime = [file stringByDeletingPathExtension];
                    NSString *meta_escape = [[meta_dir stringByAppendingPathComponent:unixtime] stringByAppendingPathExtension:@"escape"];
                    
                    NSLog(@"removing escape file : %@/%@.escape",iso_day,unixtime);
                    
                    // escape meta file
                    [fileManager removeItemAtPath:meta_escape error:NULL];
                }
            }
        }
    }
}

- (void) migrateMetaFile_migrated
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    
    NSError *error = NULL;
    NSRegularExpression *regex_iso_day = [NSRegularExpression regularExpressionWithPattern:@"\\d{4}\\-\\d{2}\\-\\d{2}" options:0 error:&error];
    NSRegularExpression *regex_file = [NSRegularExpression regularExpressionWithPattern:@"\\d{10}\\.meta" options:0 error:&error];
    
    NSArray *dirs = [fileManager contentsOfDirectoryAtPath:docPath error:NULL];
    for( int i=0; i<dirs.count; i++ ){
        NSString *iso_day = [dirs objectAtIndex:i];
        NSTextCheckingResult *matches = [regex_iso_day firstMatchInString:iso_day options:0 range:NSMakeRange(0, iso_day.length)];
        if( matches ){
            NSString *day_path = [docPath stringByAppendingPathComponent:iso_day];
            NSString *meta_dir = [day_path stringByAppendingPathComponent:@"meta"];
            
            NSArray *items = [fileManager contentsOfDirectoryAtPath:meta_dir error:NULL];
            
            for( int i=0; i<items.count; i++ ){
                NSString *file = [items objectAtIndex:i];
                NSTextCheckingResult *matches = [regex_file firstMatchInString:file options:0 range:NSMakeRange(0, file.length)];
                
                if( matches ){
                    NSString *meta_path = [meta_dir stringByAppendingPathComponent:file];
                    
                    NSString *unixtime = [file stringByDeletingPathExtension];
                    NSString *meta_escape = [[meta_dir stringByAppendingPathComponent:unixtime] stringByAppendingPathExtension:@"escape"];
                    
                    // load current meta file
                    NSData *meta_data = [[NSData alloc] initWithContentsOfFile:meta_path];
                    NSString *loadedString = [[NSString alloc] initWithData:meta_data encoding:NSUTF8StringEncoding];
                    //ALAssetOrientation orientation = [CameraUtility stringOrientationToALAssetOrientation:loadedString];
                    
                    // escape meta file
                    [fileManager moveItemAtPath:meta_path toPath:meta_escape error:NULL];
                    
                    NSLog(@"converting meta file : %@/%@",iso_day,file);
                    
                    // make meta object
                    PhotoMetaData *meta = [[PhotoMetaData alloc] init];
                    meta.iso_day = iso_day;
                    meta.file_name = file;
                    meta.photo_orientation = loadedString;
                    meta.comment = nil;
                    
                    // serialize and write out metafile
                    [NSKeyedArchiver archiveRootObject:meta toFile:meta_path];
                    
                }
            }
        }
    }
}

@end

