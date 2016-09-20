
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnapImageViewWrapper.h"

@interface SnapImageScroller : UIScrollView <UIScrollViewDelegate> {
    
    SnapImageViewWrapper *imageViewWrapper;
    BOOL isRawPhotoLoaded;
    
    UIDeviceOrientation currentOrientation;
    BOOL isLandscapeMode;
    
    int initial_scrollview_display_width;
    int initial_scrollview_display_height;
    
    int initial_image_display_width;
    int initial_image_display_height;
    
    CGFloat currentAngle;
    float currentZoomScale;
}

@property (retain) SnapImageViewWrapper *imageViewWrapper;
@property (nonatomic) BOOL isRawPhotoLoaded;

- (void) replaceImage:(UIImage *)newImage;

- (void) scrollIndicatorWithNaviAndTool;
- (void) scrollIndicatorWithoutNaviAndTool;

- (void) resetInsetWithScale:(CGFloat)scale;
- (void) resetScrollView;
- (void) resetDecorationNaviTool;

- (void) rotated:(NSNotification *)notification;
- (void) rotateWithUIDeviceOrientation:(UIDeviceOrientation)orientation;

@end
