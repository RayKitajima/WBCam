
#import "PreviewLayer_iPod4_iOS5.h"

@implementation PreviewLayer_iPod4_iOS5

- (void) drawInContext:(CGContextRef)context
{
	CGRect bounds = self.bounds;
    
    bounds.origin.x = bounds.origin.x; // - 20;
    bounds.origin.y = bounds.origin.y; // - 26;
    
	CGImageRef snapRef = self.frameImage;
	CGContextDrawImage(context, bounds, snapRef);
}

@end
