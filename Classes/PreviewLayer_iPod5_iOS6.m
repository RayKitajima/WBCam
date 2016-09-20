
#import "PreviewLayer_iPod5_iOS6.h"

@implementation PreviewLayer_iPod5_iOS6

- (void) drawInContext:(CGContextRef)context
{
	CGRect bounds = self.bounds;
    
    // the acctual adjustment value for x is 33.5 point, and y is 54
    // but non int value makes preview renderring slow.
    // use int value.
    //bounds.origin.x = bounds.origin.x - 0;
    //bounds.origin.y = bounds.origin.y - 0;
    
	CGImageRef snapRef = self.frameImage;
	CGContextDrawImage(context, bounds, snapRef);
}

@end
