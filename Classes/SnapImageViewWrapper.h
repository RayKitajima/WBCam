
#import <Foundation/Foundation.h>

@class SnapImageView;

@interface SnapImageViewWrapper : UIView
{
    SnapImageView *imageView;
}
@property (retain) SnapImageView *imageView;

@end
