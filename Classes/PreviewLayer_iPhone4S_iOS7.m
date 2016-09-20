
#import "PreviewLayer_iPhone4S_iOS7.h"

@implementation PreviewLayer_iPhone4S_iOS7

- (void) drawInContext:(CGContextRef)context
{
	CGRect bounds = self.bounds;
    
    // the acctual adjustment value for x is 2.5 point.
    // but non int value makes preview renderring slow.
    // use int value.
    bounds.origin.x = bounds.origin.x - 2;
    //bounds.origin.y = bounds.origin.y - 0;
    
	CGImageRef snapRef = self.frameImage;
	CGContextDrawImage(context, bounds, snapRef);
}

@end
