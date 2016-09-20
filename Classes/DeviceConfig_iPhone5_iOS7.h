
#import <Foundation/Foundation.h>
#import "DeviceConfig.h"

/*
// iphone5 screen
#define IPHONE5_iOS7_SCREEN_WIDTH 320
#define IPHONE5_iOS7_SCREEN_HEIGHT 568

// iphone5 PresetPhoto with reduce
#define IPHONE5_iOS7_PREVIEW_BUFFER_WIDTH 852
#define IPHONE5_iOS7_PREVIEW_BUFFER_HEIGHT 640
#define IPHONE5_iOS7_PREVIEW_BUFFER_PADDING 12
#define IPHONE5_iOS7_PREVIEW_REDUCE_RATE 1
#define IPHONE5_iOS7_PREVIEW_REDUCED_WIDTH 640
#define IPHONE5_iOS7_PREVIEW_REDUCED_HEIGHT 852
#define IPHONE5_iOS7_PREVIEW_REDUCED_PIXELS (640*852)
#define IPHONE5_iOS7_PREVIEW_ORIGINAL_PIXELS (852*640)
#define IPHONE5_iOS7_PREVIEW_REDUCED_SIZE ((852 * 640) * 4)
#define IPHONE5_iOS7_PREVIEW_REDUCER_SIZE ((852 * 640) * 4)
#define IPHONE5_iOS7_PREVIEW_NON_ALPHE 255

// point spreader
#define IPHONE5_IOS7_POINT_SPREAD_SIZE 2
*/

// iphone5 screen
#define IPHONE5_iOS7_SCREEN_WIDTH 320
#define IPHONE5_iOS7_SCREEN_HEIGHT 568

// iphone5 PresetPhoto with reduce
#define IPHONE5_iOS7_PREVIEW_BUFFER_WIDTH 852
#define IPHONE5_iOS7_PREVIEW_BUFFER_HEIGHT 640
#define IPHONE5_iOS7_PREVIEW_BUFFER_PADDING 12
#define IPHONE5_iOS7_PREVIEW_REDUCE_RATE 2
#define IPHONE5_iOS7_PREVIEW_REDUCED_WIDTH 320
#define IPHONE5_iOS7_PREVIEW_REDUCED_HEIGHT 426
#define IPHONE5_iOS7_PREVIEW_REDUCED_PIXELS (320*426)
#define IPHONE5_iOS7_PREVIEW_ORIGINAL_PIXELS (852*640)
#define IPHONE5_iOS7_PREVIEW_REDUCED_SIZE ((426 * 320) * 4)
#define IPHONE5_iOS7_PREVIEW_REDUCER_SIZE ((426 * 320) * 4)
#define IPHONE5_iOS7_PREVIEW_NON_ALPHE 255

// point spreader
#define IPHONE5_IOS7_POINT_SPREAD_SIZE 16

@interface DeviceConfig_iPhone5_iOS7 : DeviceConfig
@end
