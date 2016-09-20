
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface LibIcon : UIView {
    
    ALAssetsLibrary *library;
    
    BOOL enabled;
    
    UIImageView *photoThumbnail;
    UIImage *maskImage;
    BOOL shouldGetPhotoThumbnail;
    
    UIDeviceOrientation currentOrientation;
    
}

- (void) enableButtonAction;
- (void) disableButtonAction;

- (id) initWithFrame:(CGRect)frame;
- (void) rotated:(NSNotification *)notification;

- (void) setLibIcon:(UIImageView *)imageView;
- (void) updateIcon;
- (void) showLastItemInThePhotoLibrary;

@end
