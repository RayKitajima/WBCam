
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PreviewContainer.h"
#import "PreviewToolBar.h"
#import "SnappingNotifier.h"
#import "UnifiedModeNotifier.h"
#import "GearContainer.h"
#import "TorchButton.h"

@interface CameraController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImageView *finderHideView;
    UIView *blackMaskView;
    
    PreviewContainer *previewContainer;    // live preview container
	
    UIImageView *notificationBoxRed;       // notifier of manual exposure/forcus and whitebalance interest point
    UIImageView *notificationBoxBlue;      // notifier of AE/AF lock point
    UIImageView *finderGrid;               // grid
    
    ALAssetOrientation currentOrientation; // current device orientation
    ALAssetOrientation snapOrientation;    // orientation at the time of snap
    
    PreviewToolBar *previewToolBar;
    
	GearContainer *gearContainer;
	TorchButton *torchButton;
	
    SnappingNotifier *snappingNotifier;       // show progress of shot
    UnifiedModeNotifier *unifiedModeNotifier; // show current whitebalance/AE/AF mode (ajusting(auto)/locked/manual...)
}

@property (retain) PreviewContainer *previewContainer;
@property (retain) UIImageView *notificationBoxRed;
@property (retain) UIImageView *notificationBoxBlue;
@property (retain) UnifiedModeNotifier *unifiedModeNotifier;

+ (id) sharedInstance;

+ (void) snap;
+ (void) saveSnap:(UIImage *)image withMetadata:(CFDictionaryRef)meta;
+ (void) runAutoWhiteBalanceBlockWithCompletionBlock:(void (^)(void))completionBlock;
+ (void) regressPreview;
+ (void) bringupPhotoLibrary;;

+ (void) showNotificationBoxAtPoint:(CGPoint)point;
+ (void) showInterestPointNotificationAnimation;
+ (void) repeatInterestPointNotificationAnimation;
+ (void) stopInterestPointNotificationAnimation;

+ (void) changeWBModeNotificationToAuto;
+ (void) changeWBModeNotificationToManual;

+ (void) changeExposureModeNotificationToAuto;
+ (void) changeExposureModeNotificationToManual;
+ (void) changeFocusModeNotificationToAuto;
+ (void) changeFocusModeNotificationToManual;

+ (void) changeAEAFModeNotificationToLock;
+ (void) changeAEAFModeNotificationToAdjusting;
+ (void) changeAEAFModeNotificationToAuto;
+ (void) changeAEAFModeNotificationToNone;

+ (void) gearsAppear;
+ (void) gearsDisappear;

+ (void) showAEAFLockAnimationAtPoint:(CGPoint)screenPoint withCompletionBlock:(void (^)(void))completionBlock;

@end
