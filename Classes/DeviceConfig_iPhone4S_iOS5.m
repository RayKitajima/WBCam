
#import "DeviceConfig_iPhone4S_iOS5.h"

@implementation DeviceConfig_iPhone4S_iOS5

- (id)init
{
    self = [super init];
    
    applicationMode = @"iphone4,* iOS5";
    deviceIdentification = kDeviceIdentification_iPhone4S_iOS5;
    
    delayedThumbnailLoadThreshold = 80;
    
    // hardware defition of screen, preview and buffer
    
    // no previewFramerate, use max
    
    screenWidth  = 320;
    screenHeight = 480; // main screen : 460 + status bar : 20
    screenRect   = CGRectMake(0, 0, (float)screenWidth, (float)screenHeight);
    
    previewWidth  = 320;
    previewHeight = 427;
    previewRect   = CGRectMake(0, 0, (float)previewWidth, (float)previewHeight);
    
	previewDisplayWidth  = 320;
	previewDisplayHeight = 427;
	
    previewBufferWidth  = 320;
    previewBufferHeight = 426-6; // it seems that buffer has additional 6pix padding
    previewBufferRect   = CGRectMake(0, 0, previewBufferWidth, previewBufferHeight);
    
    // adjust preview by buffer and preview ratio
    
    float w_ratio = 1.0f;
    float h_ratio = 1.0f;
    
    if( ( previewBufferWidth < previewWidth ) || ( previewBufferHeight < previewHeight ) ){
        if( previewBufferWidth < previewWidth ){
            w_ratio = previewWidth / (float)previewBufferWidth;
        }
        if( previewBufferHeight < previewHeight ){
            h_ratio = previewHeight / (float)previewBufferHeight;
        }
    }
    
    float ratio;
    if( w_ratio > h_ratio ){
        ratio = w_ratio;
    }else{
        ratio = h_ratio;
    }
    
    previewWidthAdjusted  = (int)( ratio * (float)previewWidth );  // 325
    previewHeightAdjusted = (int)( ratio * (float)previewHeight ); // 427
    previewRectAdjusted   = CGRectMake(0, 0, (float)previewWidthAdjusted, (float)previewHeightAdjusted);
    
    // calculate adjustment
    
    previewScreenAdjustmentX = (int)( abs(previewWidthAdjusted - previewWidth) / 2.0f );   // (325 - 320)/2 = 2.5 : hardcoded in Previewlayer
    previewScreenAdjustmentY = (int)( abs(previewHeightAdjusted - previewHeight) / 2.0f ); // (427 - 427)/2 = 0
    
    // stillimage
    stillimageWidth  = 2448;
    stillimageHeight = 3264;
    stillimageSize   = (3264*2448*4);
    stillimagePixels = (3264*2448);
    
    // album preview image reduce rate
    albumPreviewImageReduceRate = 4; // 1/4
    
    // resources
	
	// PreviewToolBar assets
	previewToolBarRect = CGRectMake(0, 0, screenWidth, 53+5);
	previewToolBarImage = [UIImage imageNamed:@"toolbar_bg3_640x106.png"];
	previewToolBarImageRect = CGRectMake(0, 0+5, 320.0f, 53.0f);
	previewToolBarShadowImage = [UIImage imageNamed:@"toolbar_shadow_320x5.png"];
	previewToolBarShadowImageRect = CGRectMake(0, 0, 320.0f, 5.0f);
	snapButtonRect = CGRectMake(107.5f, 0+5, 105.0f, 53.0f);
	gearButtonRect = CGRectMake(269.0f, 0+5, 51.0f, 53.0f);
	libIconRect = CGRectMake(0, 3, 53, 53);
	unifiedModeNotificationRect = CGRectMake(0, 0, 130, 14);
    unifiedModeNotificationCenter = CGPointMake(screenWidth/2, screenHeight-60-4);
	
	// SnapButton assets (up and down)
	snapButtonUpImage = [UIImage imageNamed:@"toolbar_cam_btn_up_210x106.png"];
	snapButtonUpImageRect = CGRectMake(0, 0, 105.0f, 53.0f);
	snapButtonDownImage = [UIImage imageNamed:@"toolbar_cam_btn_down_210x106.png"];
	snapButtonDownImageRect = CGRectMake(0, 0, 105.0f, 53.0f);
	snapButtonIconCenterPoint = CGPointMake(105/2.0f, 53/2.0f);
	
	// GearButton assets (up and down)
	gearButtonUpImage = [UIImage imageNamed:@"toolbar_gear_btn_up_102x106.png"];
	gearButtonUpImageRect = CGRectMake(0, 0, 51.0f, 53.0f);
	gearButtonDownImage = [UIImage imageNamed:@"toolbar_gear_btn_down_102x106.png"];
	gearButtonDownImageRect = CGRectMake(0, 0, 51.0f, 53.0f);
	gearButtonIconCenterPoint = CGPointMake(51/2.0f+1, 53/2.0f+1);
	
    finderHideImage = [UIImage imageNamed:@"FinderHide"];
    dummyBlackImage = [UIImage imageNamed:@"dummy_black_320x426"];
    albumBgImage    = [UIImage imageNamed:@"album_bg_640x960"];
    finderGridImage = [UIImage imageNamed:@"guide_640x854.png"];
    
    return self;
}

@end
