
#import <Foundation/Foundation.h>

@interface UIImageViewForAlbumDecoration : UIImageView {}
@end

@interface AlbumDecoration : NSObject
{
    // only provides uiimage
    UIImage *selectionImage;
    UIImage *shadowImage; // for thumbnail, deprecated
    
    UIImage *photoShadowImage_lt; // left top
    UIImage *photoShadowImage_t;  // top
    UIImage *photoShadowImage_rt; // right top
    UIImage *photoShadowImage_l;  // left
    UIImage *photoShadowImage_r;  // right
    UIImage *photoShadowImage_lb; // left bottom
    UIImage *photoShadowImage_b;  // bottom
    UIImage *photoShadowImage_rb; // right bottom
    
    // for snap
    UIImage *gridImageForSnapOverlay;
    UIImage *backgroundImage;
}

@property (retain) UIImage *selectionImage;
@property (retain) UIImage *shadowImage;

@property (retain) UIImage *photoShadowImage_lt;
@property (retain) UIImage *photoShadowImage_t;
@property (retain) UIImage *photoShadowImage_rt;
@property (retain) UIImage *photoShadowImage_l;
@property (retain) UIImage *photoShadowImage_r;
@property (retain) UIImage *photoShadowImage_lb;
@property (retain) UIImage *photoShadowImage_b;
@property (retain) UIImage *photoShadowImage_rb;

@property (retain) UIImage *gridImageForSnapOverlay;
@property (retain) UIImage *backgroundImage;

+ (id) sharedInstance;

+ (UIImage *) selectionImage;
+ (UIImage *) shadowImage;

+ (UIImage *) photoShadowImageLeftTop;
+ (UIImage *) photoShadowImageTop;
+ (UIImage *) photoShadowImageRightTop;
+ (UIImage *) photoShadowImageLeft;
+ (UIImage *) photoShadowImageRight;
+ (UIImage *) photoShadowImageLeftBottom;
+ (UIImage *) photoShadowImageBottom;
+ (UIImage *) photoShadowImageRightBottom;

+ (UIImage *) gridImageForSnapOverlay;
+ (UIImage *) backgroundImage;

@end
