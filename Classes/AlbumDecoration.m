
#import "AlbumDecoration.h"
#import "DeviceConfig.h"

#pragma mark
#pragma mark ***** UIImageForAlbumDecoration *****
#pragma mark

@implementation UIImageViewForAlbumDecoration
@end

#pragma mark
#pragma mark ***** AlbumDecoration *****
#pragma mark

@implementation AlbumDecoration
@synthesize selectionImage,shadowImage;
@synthesize photoShadowImage_lt,photoShadowImage_t,photoShadowImage_rt;
@synthesize photoShadowImage_l,photoShadowImage_r;
@synthesize photoShadowImage_lb,photoShadowImage_b,photoShadowImage_rb;
@synthesize gridImageForSnapOverlay, backgroundImage;

static AlbumDecoration *albumDecorationInstance = nil;

- (void) setup
{
    NSLog(@"setup AlbumDecoration shared object");
    
    selectionImage = [UIImage imageNamed:@"album_thumb_selection_mask_75x75.png"];
    shadowImage = [UIImage imageNamed:@"album_thumb_shadow_78x78.png"];
    
    photoShadowImage_lt = [UIImage imageNamed:@"album_photo_shadow_lt_10x10.png"];
    photoShadowImage_t  = [UIImage imageNamed:@"album_photo_shadow_t_320x10.png"];
    photoShadowImage_rt = [UIImage imageNamed:@"album_photo_shadow_rt_10x10.png"];
    photoShadowImage_l  = [UIImage imageNamed:@"album_photo_shadow_l_10x480.png"];
    photoShadowImage_r  = [UIImage imageNamed:@"album_photo_shadow_r_10x480.png"];
    photoShadowImage_lb = [UIImage imageNamed:@"album_photo_shadow_lb_10x10.png"];
    photoShadowImage_b  = [UIImage imageNamed:@"album_photo_shadow_b_320x10.png"];
    photoShadowImage_rb = [UIImage imageNamed:@"album_photo_shadow_rb_10x10.png"];
    
    gridImageForSnapOverlay = [UIImage imageNamed:@"guide_640x960.png"];
    backgroundImage = [DeviceConfig AlbumBgImage];
    
}

// decoration for album (=list)

+ (UIImage *) selectionImage
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.selectionImage;
}

+ (UIImage *) shadowImage
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.shadowImage;
}

// photo(=snap) shadow

+ (UIImage *) photoShadowImageLeftTop
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_lt;
}

+ (UIImage *) photoShadowImageTop
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_t;
}

+ (UIImage *) photoShadowImageRightTop
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_rt;
}

+ (UIImage *) photoShadowImageLeft
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_l;
}

+ (UIImage *) photoShadowImageRight
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_r;
}

+ (UIImage *) photoShadowImageLeftBottom
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_lb;
}

+ (UIImage *) photoShadowImageBottom
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_b;
}

+ (UIImage *) photoShadowImageRightBottom
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.photoShadowImage_rb;
}

// snap

+ (UIImage *) gridImageForSnapOverlay
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.gridImageForSnapOverlay;
}

+ (UIImage *) backgroundImage
{
    AlbumDecoration *instance = [AlbumDecoration sharedInstance];
    return instance.backgroundImage;
}

+ (id) sharedInstance
{
	//NSLog(@"PreviewHelper instance called");
	@synchronized(self){
		if( !albumDecorationInstance ){
			albumDecorationInstance = [[AlbumDecoration alloc] init];
            [albumDecorationInstance setup];
		}
	}
    return albumDecorationInstance;
}

@end


