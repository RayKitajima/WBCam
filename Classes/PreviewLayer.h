
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ContentAnimatingLayer.h"

@interface PreviewLayer : ContentAnimatingLayer {
	CGImageRef frameImage;
	int cnt;
}

@property CGImageRef frameImage;
@property int cnt;

+ (void) setFrameImage:(CGImageRef)frameImage;

@end
