
#import "GearColorMark.h"
#import <QuartzCore/QuartzCore.h>

@implementation GearColorMark
@synthesize color;

- (id) initWithFrame:(CGRect)frame withCGColorRef:(CGColorRef)cgcolor
{
	self = [super initWithFrame:frame];
	self.color = cgcolor;
	
	self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
	
	return self;
}

- (void) drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGFloat w = self.bounds.size.width;
	CGFloat h = self.bounds.size.width;
	CGContextSetFillColorWithColor(c, self.color);
	CGContextFillEllipseInRect(c, CGRectMake(0, 0, w, h));
}

@end
