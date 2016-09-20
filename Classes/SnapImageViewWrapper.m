
#import "SnapImageViewWrapper.h"
#import "SnapImageView.h"
#import "DeviceConfig.h"

@implementation SnapImageViewWrapper
@synthesize imageView;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    UIImage *startImage = [UIImage imageNamed:@"dummy_black.png"]; // 320x460
    imageView = [[SnapImageView alloc] initWithImage:startImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit; // * important setting
    imageView.frame = [DeviceConfig screenRect];
    imageView.hidden = NO;
    imageView.center = self.center;
    
    [self addSubview:imageView];
    
    return self;
}

@end
