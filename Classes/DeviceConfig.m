
#import "DeviceConfig.h"

static DeviceConfig *sharedInstance = nil;
@implementation DeviceConfig

@synthesize applicationMode;
@synthesize delayedThumbnailLoadThreshold;
@synthesize deviceIdentification;
@synthesize previewFramerate;
@synthesize screenWidth, screenHeight, screenRect;
@synthesize previewWidth, previewHeight, previewRect;
@synthesize previewDisplayWidth,previewDisplayHeight;
@synthesize previewBufferWidth, previewBufferHeight, previewBufferRect;
@synthesize previewWidthAdjusted, previewHeightAdjusted, previewRectAdjusted;
@synthesize previewScreenAdjustmentX, previewScreenAdjustmentY;
@synthesize stillimageWidth, stillimageHeight, stillimageSize, stillimagePixels;
@synthesize albumPreviewImageReduceRate;
@synthesize previewToolbarWidth, previewToolbarHeight, previewToolbarShadowWidth, previewToolbarShadowHeight;
@synthesize previewToolBarRect,previewToolBarImage,previewToolBarImageRect,previewToolBarShadowImage;
@synthesize previewToolBarShadowImageRect,snapButtonRect,gearButtonRect,libIconRect;
@synthesize unifiedModeNotificationRect,unifiedModeNotificationCenter;
@synthesize snapButtonUpImage,snapButtonUpImageRect,snapButtonDownImage,snapButtonDownImageRect,snapButtonIconCenterPoint;
@synthesize gearButtonUpImage,gearButtonUpImageRect,gearButtonDownImage,gearButtonDownImageRect,gearButtonIconCenterPoint;
@synthesize finderHideImage,dummyBlackImage,albumBgImage,finderGridImage;

- (id)init
{
    self = [super init];
    
    // shared
    
    // preview(finder) toolbar (default 3.5inch)
    previewToolbarWidth        = 320;
    previewToolbarHeight       = 53;
    previewToolbarShadowWidth  = 320;
    previewToolbarShadowHeight = 5;
    
    // 
    // other concrete values should be defined in concrete class
    // 
    
    return self;
}

+ (id) sharedInstance
{
	@synchronized(self){
		if( !sharedInstance ){
			sharedInstance = [ApplicationConfig deviceConfig];
		}
	}
    return sharedInstance;
}

#pragma mark
#pragma mark === convenience access ===
#pragma mark

+ (NSString *) applicationMode
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.applicationMode;
}

+ (int) delayedThumbnailLoadThreshold
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.delayedThumbnailLoadThreshold;
}

+ (DeviceIdentificationType) deviceIdentification
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.deviceIdentification;
}

+ (int) screenWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.screenWidth;
}

+ (int) previewFramerate
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewFramerate;
}

+ (int) screenHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.screenHeight;
}

+ (CGRect) screenRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.screenRect;
}

+ (int) previewWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewWidth;
}

+ (int) previewHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewHeight;
}

+ (CGRect) previewRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewRect;
}

+ (int) previewDisplayWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewDisplayWidth;
}

+ (int) previewDisplayHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewDisplayHeight;
}

+ (int) previewBufferWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewBufferWidth;
}

+ (int) previewBufferHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewBufferHeight;
}

+ (CGRect) previewBufferRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewBufferRect;
}

+ (int) previewWidthAdjusted
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewWidthAdjusted;
}

+ (int) previewHeightAdjusted
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewHeightAdjusted;
}

+ (CGRect) previewRectAdjusted
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewRectAdjusted;
}

+ (int) stillimageWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.stillimageWidth;
}

+ (int) stillimageHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.stillimageHeight;
}

+ (int) stillimageSize
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.stillimageSize;
}

+ (int) stillimagePixels
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.stillimagePixels;
}

+ (int) albumPreviewImageReduceRate
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.albumPreviewImageReduceRate;
}

+ (int) previewToolbarWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolbarWidth;
}

+ (int) previewToolbarHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolbarHeight;
}

+ (int) previewToolbarShadowWidth
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolbarShadowWidth;
}

+ (int) previewToolbarShadowHeight
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolbarShadowHeight;
}

// resource access

+ (CGRect) previewToolBarRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolBarRect;
}
+ (UIImage *) previewToolBarImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolBarImage;
}
+ (CGRect) previewToolBarImageRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolBarImageRect;
}
+ (UIImage *) previewToolBarShadowImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolBarShadowImage;
}
+ (CGRect) previewToolBarShadowImageRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.previewToolBarShadowImageRect;
}
+ (CGRect) snapButtonRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.snapButtonRect;
}
+ (CGRect) gearButtonRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.gearButtonRect;
}
+ (CGRect) libIconRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.libIconRect;
}
+ (CGRect) unifiedModeNotificationRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.unifiedModeNotificationRect;
}
+ (CGPoint) unifiedModeNotificationCenter
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.unifiedModeNotificationCenter;
}

+ (UIImage *) snapButtonUpImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.snapButtonUpImage;
}
+ (UIImage *) snapButtonDownImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.snapButtonDownImage;
}
+ (CGRect) snapButtonUpImageRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.snapButtonUpImageRect;
}
+ (CGRect) snapButtonDownImageRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.snapButtonDownImageRect;
}
+ (CGPoint) snapButtonIconCenterPoint
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.snapButtonIconCenterPoint;
}

+ (UIImage *) gearButtonUpImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.gearButtonUpImage;
}
+ (UIImage *) gearButtonDownImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.gearButtonDownImage;
}
+ (CGRect) gearButtonUpImageRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.gearButtonUpImageRect;
}
+ (CGRect) gearButtonDownImageRect
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.gearButtonDownImageRect;
}
+ (CGPoint) gearButtonIconCenterPoint
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.gearButtonIconCenterPoint;
}

+ (UIImage *) FinderHideImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.finderHideImage;
}

+ (UIImage *) DummyBlackImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.dummyBlackImage;
}

+ (UIImage *) AlbumBgImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.albumBgImage;
}

+ (UIImage *) FinderGridImage
{
    DeviceConfig *instance = [self sharedInstance];
    return instance.finderGridImage;
}

@end
