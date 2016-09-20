
#import "PreviewLayer.h"

@implementation PreviewLayer
@dynamic frameImage,cnt; // CGImageRef

// ********************************
// requires concrete implementation
// ********************************
// 
// adjust centering margin and mismatch of buffer and preview rect
// 
/*
- (void) drawInContext:(CGContextRef)context
{
	//self.cnt++;
	//NSLog(@"drawInContext called : %d", self.cnt);
	CGRect bounds = self.bounds;
    bounds.origin.x = bounds.origin.x-ADJUSTMENT_X;
    bounds.origin.y = bounds.origin.y-ADJUSTMENT_Y;
	CGImageRef snapRef = self.frameImage;
	CGContextDrawImage(context, bounds, snapRef);
}
*/

- (id) init
{
	self = [super init];
	
	// init with dummy image
    UIImage *previewImage = [UIImage imageNamed:@"dummy_black_320x426.png"]; 
	CGImageRef image = previewImage.CGImage;
	frameImage = image;
    
	//CGImageRelease(image); // cause crash in calayer? why???
    
	return self;
}

+ (void) setFrameImage:(CGImageRef)frameImage
{
	self.frameImage = frameImage;
    CGImageRelease(frameImage);
}

+ (NSSet *)keyPathsForValuesAffectingContent;
{
    static NSSet *keys = nil;
    if (!keys)
        keys = [[NSSet alloc] initWithObjects:@"frameImage", nil];
    return keys;
}

@end
