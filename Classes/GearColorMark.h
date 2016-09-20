
#import <Foundation/Foundation.h>

@interface GearColorMark : UIView
{
	CGColorRef color;
}
@property CGColorRef color;

- (id) initWithFrame:(CGRect)frame withCGColorRef:(CGColorRef)cgcolor;

@end
