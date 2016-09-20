
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AlbumViewController.h"
#import "CameraController.h"

@interface StartupScreenController : UIViewController <UINavigationControllerDelegate>
{
    // Startup animatijon holder
    UIView *startupView;
}
@end

@interface WBCamAppDelegate : UIView <UIApplicationDelegate> 
{
	UIWindow* window;
	UIViewController *currentViewController;
    
    // Startup
    StartupScreenController *startupController;
    
    // Camera
    UINavigationController *cameraNavigationController;
    CameraController *cameraViewController;
    
    // Album
    UINavigationController *albumNavigationController;
    AlbumViewController *albumViewController;
}

- (void) bootstrap;

@end

