
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnapImageScroller.h"

@interface SnapContainer : UIView 
{
    UIImage *holdedSnapImage;
    SnapImageScroller *imageScrollView;
}

@property (retain) SnapImageScroller *imageScrollView;

- (void) setSnapImage:(UIImage *)image;
- (UIImage *) getSnapImage;

- (void) updateShadow;
- (void) setSnapImageObjectOnly:(UIImage *)image;

- (void) showSnapImage;
- (void) hideSnapImage;

- (void) dimmFinder;
- (void) illumFinder;

@end
