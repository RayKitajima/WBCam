
#import "DeviceConfig_iPhone5S_iOS7.h"

@implementation DeviceConfig_iPhone5S_iOS7

- (id)init
{
    self = [super init];
    
    applicationMode = @"iphone5S,* iOS7";
    deviceIdentification = kDeviceIdentification_iPhone5S_iOS7;
    
    delayedThumbnailLoadThreshold = 80;
    
    previewToolbarWidth        = 320;
    previewToolbarHeight       = 142.5;
    previewToolbarShadowWidth  = 320;
    previewToolbarShadowHeight = 5;
	
    // hardware defition of screen, preview and buffer
    
    // no previewFramerate, use max
    
    screenWidth  = 320;
    screenHeight = 568; // main screen : 548 + status bar : 20
    screenRect   = CGRectMake(0, 0, (float)screenWidth, (float)screenHeight);
    
    previewWidth  = 320;
    previewHeight = 427;
    previewRect   = CGRectMake(0, 0, (float)previewWidth, (float)previewHeight);
    
	previewDisplayWidth  = 320;
	previewDisplayHeight = 427;
	
    previewBufferWidth  = 320;
    previewBufferHeight = 420; // it seems that buffer has additional 6pix padding
    previewBufferRect   = CGRectMake(0, 0, previewBufferWidth, previewBufferHeight);
    
    // adjust preview by buffer and preview ratio
    
    float w_ratio = 1.0f;
    float h_ratio = 1.0f;
    
    if( ( previewBufferWidth < previewWidth ) || ( previewBufferHeight < previewHeight ) ){
        if( previewBufferWidth < previewWidth ){
            w_ratio = previewWidth / (float)previewBufferWidth;
        }
        if( previewBufferHeight < previewHeight ){
            h_ratio = previewHeight / (float)previewBufferHeight; // 515/426=1.21
        }
    }
    
    float ratio;
    if( w_ratio > h_ratio ){
        ratio = w_ratio;
    }else{
        ratio = h_ratio;
    }
    
    previewWidthAdjusted  = (int)( ratio * (float)previewWidth );  // (1.21)*320=387(->386)
    previewHeightAdjusted = (int)( ratio * (float)previewHeight ); // (1.21)*515=623(->622)
    previewRectAdjusted   = CGRectMake(0, 0, (float)previewWidthAdjusted, (float)previewHeightAdjusted);
    
    // calculate adjustment
    
    previewScreenAdjustmentX = (int)( abs(previewWidthAdjusted - previewWidth) / 2.0f );   // (387 - 320)/2 = 33.5 : hardcoded in Previewlayer
    previewScreenAdjustmentY = (int)( abs(previewHeightAdjusted - previewHeight) / 2.0f ); // (623 - 515)/2 = 54
    
    // stillimage
    stillimageWidth  = 2448;
    stillimageHeight = 3264;
    stillimageSize   = (3264*2448*4);
    stillimagePixels = (3264*2448);
    
    // album preview image reduce rate
    albumPreviewImageReduceRate = 4; // 1/4
    
    // resources
	
	// PreviewToolBar assets
	previewToolBarRect = CGRectMake(0, 0, screenWidth, 142.5+5);
	previewToolBarImage = [UIImage imageNamed:@"toolbar_bg3_640x285.png"];
	previewToolBarImageRect = CGRectMake(0, 0+5, 320.0f, 142.5f);
	previewToolBarShadowImage = [UIImage imageNamed:@"toolbar_shadow_320x5.png"];
	previewToolBarShadowImageRect = CGRectMake(0, 0, 320.0f, 5.0f);
	snapButtonRect = CGRectMake(107.5f, 42.5+5, 105.0f, 100.0f);
	gearButtonRect = CGRectMake(269.0f, 42.5+5, 51.0f, 100.0f);
	libIconRect = CGRectMake(0, 67.5, 53, 53); // 4inch toolbar has more 135pix space than 3.5inch one
	unifiedModeNotificationRect = CGRectMake(0, 0, 130, 14);
    unifiedModeNotificationCenter = CGPointMake(screenWidth/2, previewHeight+28);
	
	// SnapButton assets (up and down)
	snapButtonUpImage = [UIImage imageNamed:@"toolbar_cam_btn_up_210x200.png"];
	snapButtonUpImageRect = CGRectMake(0, 0, 105.0f, 100.0f);
	snapButtonDownImage = [UIImage imageNamed:@"toolbar_cam_btn_down_210x200.png"];
	snapButtonDownImageRect = CGRectMake(0, 0, 105.0f, 100.0f);
	snapButtonIconCenterPoint = CGPointMake(105/2.0f, 100/2.0f);
	
	// GearButton assets (up and down)
	gearButtonUpImage = [UIImage imageNamed:@"toolbar_gear_btn_up_102x200.png"];
	gearButtonUpImageRect = CGRectMake(0, 0, 51.0f, 100.0f);
	gearButtonDownImage = [UIImage imageNamed:@"toolbar_gear_btn_down_102x200.png"];
	gearButtonDownImageRect = CGRectMake(0, 0, 51.0f, 100.0f);
	gearButtonIconCenterPoint = CGPointMake(51/2.0f, 100/2.0f+2);
	
    finderHideImage = [UIImage imageNamed:@"FinderHide"];
    dummyBlackImage = [UIImage imageNamed:@"dummy_black_386x622"];
    albumBgImage    = [UIImage imageNamed:@"album_bg_640x1136"];
    finderGridImage = [UIImage imageNamed:@"guide_640x854.png"];
    
    return self;
}

@end
