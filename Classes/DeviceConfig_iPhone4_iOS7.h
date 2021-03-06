
#import <Foundation/Foundation.h>
#import "DeviceConfig.h"

// iphone4 screen
#define IPHONE4_iOS7_SCREEN_WIDTH 320
#define IPHONE4_iOS7_SCREEN_HEIGHT 460

// iphone4 PresetPhoto with reduce
#define IPHONE4_iOS7_PREVIEW_BUFFER_WIDTH 852
#define IPHONE4_iOS7_PREVIEW_BUFFER_HEIGHT 640
#define IPHONE4_iOS7_PREVIEW_BUFFER_PADDING 12
#define IPHONE4_iOS7_PREVIEW_REDUCE_RATE 2
#define IPHONE4_iOS7_PREVIEW_REDUCED_WIDTH 320
#define IPHONE4_iOS7_PREVIEW_REDUCED_HEIGHT 426
#define IPHONE4_iOS7_PREVIEW_REDUCED_PIXELS (320*426)
#define IPHONE4_iOS7_PREVIEW_ORIGINAL_PIXELS (852*640)
#define IPHONE4_iOS7_PREVIEW_REDUCED_SIZE ((426 * 320) * 4)
#define IPHONE4_iOS7_PREVIEW_REDUCER_SIZE ((426 * 320) * 4)
#define IPHONE4_iOS7_PREVIEW_NON_ALPHE 255

// point spreader
#define IPHONE4_IOS7_POINT_SPREAD_SIZE 4

@interface DeviceConfig_iPhone4_iOS7 : DeviceConfig
@end
