
#import <Foundation/Foundation.h>
#import "ApplicationConfig.h"

typedef enum {
    kDeviceIdentification_iPhone4_iOS5,  // device:iPhone3,* iOS:5.*
    kDeviceIdentification_iPhone4_iOS6,  // device:iPhone3,* iOS:6.*
	kDeviceIdentification_iPhone4_iOS7,  // device:iPhone3,* iOS:7.*
    kDeviceIdentification_iPhone4S_iOS5, // device:iPhone4,* iOS:5.*
    kDeviceIdentification_iPhone4S_iOS6, // device:iPhone4,* iOS:6.*
	kDeviceIdentification_iPhone4S_iOS7, // device:iPhone4,* iOS:7.*
    kDeviceIdentification_iPhone5_iOS6,  // device:iPhone5,* iOS:6.*
	
	kDeviceIdentification_iPhone5_iOS7,  // device:iPhone5,* iOS:7.*
	kDeviceIdentification_iPhone5S_iOS7, // device:iPhone5S,* iOS:7.*
	kDeviceIdentification_iPhone5C_iOS7, // device:iPhone5C,* iOS:7.*
	
    kDeviceIdentification_iPod4_iOS5,    // device:iPod4,* iOS:5.*
    kDeviceIdentification_iPod4_iOS6,    // device:iPod4,* iOS:6.*
    kDeviceIdentification_iPod5_iOS6,    // device:iPod5,* iOS:6.*
	kDeviceIdentification_iPod5_iOS7,    // device:iPod5,* iOS:7.*
} DeviceIdentificationType;

@class ApplicationConfig;

@interface DeviceConfig : NSObject
{
    NSString *applicationMode; // general mode name
    
    int delayedThumbnailLoadThreshold; // sec, thumnail load delay of album scrolling
    
    DeviceIdentificationType deviceIdentification;
    
    // preview
    
    // frame per sec for the manual preview. used as CMTimeMake(1,previewFramerate) = 1/previewFramerate frame per sec
    // you should also check the PreviewHelper_Impl.manualPreviewFrameRate
    int previewFramerate; 
    
    // AVCaptureVideoDataOutput
    // +----------+---------+---------+
    // : iphone5  : iPhone4 : iPod4   :
    // +----------+---------+---------+
    // : 1136x640 : 852x640 : 960x720 :
    // +----------+---------+---------+
    
    // 
    // | prev...rWidth |
    // | screenWidth   |
    // | previewWidth  |
    // 
    // +---------------+  --------------------
    // |               |   ^              ^
    // |               |   :              :
    // |               |   :            screenHeight
    // |               |   :              :
    // |               |  previewHeight   :
    // |               |   :              :
    // |               |   :              :
    // |               |   V              :
    // |...............|  ---             :
    // |     ([o])     |                  V    <--- previewTollbarShadowHeight
    // +---------------+  -------------------- <-+
    // |       o       |                         +- previewToolbarHeight
    // +---------------+  -------------------- <-+
    // 
    
    int screenWidth;          // screen width as point
    int screenHeight;         // screen height as point
    CGRect screenRect;        // its rect
    
    int previewWidth;         // width of visible preview area
    int previewHeight;        // height of visible preview area
    CGRect previewRect;       // its rect
    
	int previewDisplayWidth;  // width of visible preview area
	int previewDisplayHeight; // height of visible preview area
	
    int previewBufferWidth;   // width of original reduced preview buffer image
    int previewBufferHeight;  // height of original reduced preview buffer image
    CGRect previewBufferRect; // its rect
    
    int previewWidthAdjusted;   // width of preview container rect to fill the preview area by th buffer. adjusted by buffer preview retio
    int previewHeightAdjusted;  // its height
    CGRect previewRectAdjusted; // its rect
    
    int previewToolbarWidth;        // width of preview(finder)'s toolbar
    int previewToolbarHeight;       // also its height
    int previewToolbarShadowWidth;  // finder toolbar has a shadow area, but this is not containd to the height of toolbar
    int previewToolbarShadowHeight; // also its height
    
	// PreviewToolBar assets
	CGRect previewToolBarRect;
	UIImage *previewToolBarImage;
	CGRect previewToolBarImageRect;
	UIImage *previewToolBarShadowImage;
	CGRect previewToolBarShadowImageRect;
	CGRect snapButtonRect;
	CGRect gearButtonRect;
	CGRect libIconRect;
	CGRect unifiedModeNotificationRect;
	CGPoint unifiedModeNotificationCenter;
	
	// SnapButton assets (up and down)
	UIImage *snapButtonUpImage;
	UIImage *snapButtonDownImage;
	CGRect snapButtonUpImageRect;
	CGRect snapButtonDownImageRect;
	CGPoint snapButtonIconCenterPoint;
	
	// GearButton assets (up and down)
	UIImage *gearButtonUpImage;
	UIImage *gearButtonDownImage;
	CGRect gearButtonUpImageRect;
	CGRect gearButtonDownImageRect;
	CGPoint gearButtonIconCenterPoint;
	
    // these values are used for touch handling only.
    // drawing the preview is hardly coded for each device in PreviewLayer_DEVICE_VER.m.
    // 
    // adjustment:
    // 
    //   touch        : +
    //   preview draw : - (hard coded)
    // 
    int previewScreenAdjustmentX; // adjust screen and preview size mismatch
    int previewScreenAdjustmentY; // adjust screen and preview size mismatch
    
    // stillimage
    int stillimageWidth;
    int stillimageHeight;
    int stillimageSize;
    int stillimagePixels;
    
    // album preview image reduce rate
    // ex) preview.width = stillimage.width/albumPreviewImageReduceRate
    int albumPreviewImageReduceRate;
    
    // resources
    UIImage *finderHideImage;
    UIImage *dummyBlackImage;
    UIImage *albumBgImage;
    UIImage *finderGridImage;
}

@property (retain) NSString *applicationMode;
@property int delayedThumbnailLoadThreshold;
@property DeviceIdentificationType deviceIdentification;
@property int previewFramerate;
@property int screenWidth;
@property int screenHeight;
@property CGRect screenRect;
@property int previewWidth;
@property int previewHeight;
@property int previewDisplayWidth;
@property int previewDisplayHeight;
@property CGRect previewRect;
@property int previewBufferWidth;
@property int previewBufferHeight;
@property CGRect previewBufferRect;
@property int previewWidthAdjusted;
@property int previewHeightAdjusted;
@property CGRect previewRectAdjusted;
@property int previewScreenAdjustmentX;
@property int previewScreenAdjustmentY;
@property int stillimageWidth;
@property int stillimageHeight;
@property int stillimageSize;
@property int stillimagePixels;
@property int albumPreviewImageReduceRate;
@property int previewToolbarWidth;
@property int previewToolbarHeight;
@property int previewToolbarShadowWidth;
@property int previewToolbarShadowHeight;

// resource access

@property CGRect previewToolBarRect;
@property (retain) UIImage *previewToolBarImage;
@property CGRect previewToolBarImageRect;
@property (retain) UIImage *previewToolBarShadowImage;
@property CGRect previewToolBarShadowImageRect;
@property CGRect snapButtonRect;
@property CGRect gearButtonRect;
@property CGRect libIconRect;
@property CGRect unifiedModeNotificationRect;
@property CGPoint unifiedModeNotificationCenter;

@property (retain) UIImage *snapButtonUpImage;
@property (retain) UIImage *snapButtonDownImage;
@property CGRect snapButtonUpImageRect;
@property CGRect snapButtonDownImageRect;
@property CGPoint snapButtonIconCenterPoint;

@property (retain) UIImage *gearButtonUpImage;
@property (retain) UIImage *gearButtonDownImage;
@property CGRect gearButtonUpImageRect;
@property CGRect gearButtonDownImageRect;
@property CGPoint gearButtonIconCenterPoint;

@property (retain) UIImage *finderHideImage;
@property (retain) UIImage *dummyBlackImage;
@property (retain) UIImage *albumBgImage;
@property (retain) UIImage *finderGridImage;
+ (UIImage *) FinderHideImage;
+ (UIImage *) DummyBlackImage;
+ (UIImage *) AlbumBgImage;
+ (UIImage *) FinderGridImage;

// convenience method

+ (NSString *) applicationMode;
+ (int) delayedThumbnailLoadThreshold;

+ (DeviceIdentificationType) deviceIdentification;

+ (int) previewFramerate;
+ (int) screenWidth;
+ (int) screenHeight;
+ (CGRect) screenRect;
+ (int) previewWidth;
+ (int) previewHeight;
+ (int) previewDisplayWidth;
+ (int) previewDisplayHeight;
+ (CGRect) previewRect;
+ (int) previewBufferWidth;
+ (int) previewBufferHeight;
+ (CGRect) previewBufferRect;
+ (int) previewWidthAdjusted;
+ (int) previewHeightAdjusted;
+ (CGRect) previewRectAdjusted;

+ (int) stillimageWidth;
+ (int) stillimageHeight;
+ (int) stillimageSize;
+ (int) stillimagePixels;

+ (int) albumPreviewImageReduceRate;

+ (CGRect) previewToolBarRect;
+ (UIImage*) previewToolBarImage;
+ (CGRect) previewToolBarImageRect;
+ (UIImage*) previewToolBarShadowImage;
+ (CGRect) previewToolBarShadowImageRect;
+ (CGRect) snapButtonRect;
+ (CGRect) gearButtonRect;
+ (CGRect) libIconRect;
+ (CGRect) unifiedModeNotificationRect;
+ (CGPoint) unifiedModeNotificationCenter;

+ (UIImage*) snapButtonUpImage;
+ (UIImage*) snapButtonDownImage;
+ (CGRect) snapButtonUpImageRect;
+ (CGRect) snapButtonDownImageRect;
+ (CGPoint) snapButtonIconCenterPoint;

+ (UIImage*) gearButtonUpImage;
+ (UIImage*) gearButtonDownImage;
+ (CGRect) gearButtonUpImageRect;
+ (CGRect) gearButtonDownImageRect;
+ (CGPoint) gearButtonIconCenterPoint;

+ (int) previewToolbarWidth;
+ (int) previewToolbarHeight;
+ (int) previewToolbarShadowWidth;
+ (int) previewToolbarShadowHeight;

@end
