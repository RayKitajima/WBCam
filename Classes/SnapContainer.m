
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "SnapContainer.h"
#import "CameraHelper.h"
#import "AlbumDecoration.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "SnapImageView.h"

@implementation SnapContainer
@synthesize imageScrollView;

#pragma mark
#pragma mark === decoration ===
#pragma mark

- (void) applyShadowWithImage:(UIImage *)image
{
    int screen_width  = [DeviceConfig screenWidth];
    int screen_height = [DeviceConfig screenHeight];
    
    // clear decoration
    NSArray *views = imageScrollView.imageViewWrapper.imageView.subviews;
    if( views.count > 1 ){
        for( int i=0; i<views.count; i++ ){
            UIView *subView = [views objectAtIndex:i];
            if( [subView isKindOfClass:[UIImageViewForAlbumDecoration class]] ){
                [subView removeFromSuperview];
            }
        }
    }
    
    // apply fresh shadow
    float ratio = screen_width / image.size.width;
    float height = image.size.height * ratio;
    float y_offset = (screen_height - height) / 2;
    
    UIImage *shadow_lt = [AlbumDecoration photoShadowImageLeftTop];
    UIImage *shadow_t  = [AlbumDecoration photoShadowImageTop];
    UIImage *shadow_rt = [AlbumDecoration photoShadowImageRightTop];
    UIImage *shadow_l  = [AlbumDecoration photoShadowImageLeft];
    UIImage *shadow_r  = [AlbumDecoration photoShadowImageRight];
    UIImage *shadow_lb = [AlbumDecoration photoShadowImageLeftBottom];
    UIImage *shadow_b  = [AlbumDecoration photoShadowImageBottom];
    UIImage *shadow_rb = [AlbumDecoration photoShadowImageRightBottom];
    
    CGRect rect_lt = CGRectMake(          -10,    -10+y_offset,           10,     10 );
    CGRect rect_t  = CGRectMake(            0,    -10+y_offset, screen_width,     10 );
    CGRect rect_rt = CGRectMake( screen_width,    -10+y_offset,           10,     10 );
    CGRect rect_l  = CGRectMake(          -10,      0+y_offset,           10, height );
    CGRect rect_r  = CGRectMake( screen_width,      0+y_offset,           10, height );
    CGRect rect_lb = CGRectMake(          -10, height+y_offset,           10,     10 );
    CGRect rect_b  = CGRectMake(            0, height+y_offset, screen_width,     10 );
    CGRect rect_rb = CGRectMake( screen_width, height+y_offset,           10,     10 );
    
    UIImageViewForAlbumDecoration *v_shadow_lt = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_lt];
    UIImageViewForAlbumDecoration *v_shadow_t  = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_t];
    UIImageViewForAlbumDecoration *v_shadow_rt = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_rt];
    UIImageViewForAlbumDecoration *v_shadow_l  = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_l];
    UIImageViewForAlbumDecoration *v_shadow_r  = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_r];
    UIImageViewForAlbumDecoration *v_shadow_lb = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_lb];
    UIImageViewForAlbumDecoration *v_shadow_b  = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_b];
    UIImageViewForAlbumDecoration *v_shadow_rb = [[UIImageViewForAlbumDecoration alloc] initWithImage:shadow_rb];
    
    v_shadow_lt.frame = rect_lt;
    v_shadow_t.frame  = rect_t;
    v_shadow_rt.frame = rect_rt;
    v_shadow_l.frame  = rect_l;
    v_shadow_r.frame  = rect_r;
    v_shadow_lb.frame = rect_lb;
    v_shadow_b.frame  = rect_b;
    v_shadow_rb.frame = rect_rb;
    
    v_shadow_t.layer.opacity = 0.8;
    v_shadow_l.layer.opacity = 0.8;
    v_shadow_r.layer.opacity = 0.8;
    v_shadow_b.layer.opacity = 0.8;
    
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_lt atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_t atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_rt atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_l atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_r atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_lb atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_b atIndex:0];
    [imageScrollView.imageViewWrapper.imageView insertSubview:v_shadow_rb atIndex:0];
}

#pragma mark
#pragma mark === scrollView container ===
#pragma mark

- (void) updateShadow
{
    [self applyShadowWithImage:imageScrollView.imageViewWrapper.imageView.image];
}

- (void) setSnapImageObjectOnly:(UIImage *)image
{
    // set image
    //[self.imageScrollView.imageView setImage:image];
    [self.imageScrollView replaceImage:image];
}

- (void) setSnapImage:(UIImage *)image
{
    // set image
    //[self.imageScrollView.imageView setImage:image];
    [self.imageScrollView replaceImage:image];
    
    // update shadow
    [self applyShadowWithImage:image];
}

- (UIImage *) getSnapImage
{
    return self.imageScrollView.imageViewWrapper.imageView.image;
}

- (void) showSnapImage
{
    self.hidden = NO;
}

- (void) hideSnapImage
{
    self.hidden = YES;
}

#pragma mark
#pragma mark === ui support ===
#pragma mark

- (void) dimmFinder
{
    self.imageScrollView.alpha = 0.5;
}

- (void) illumFinder
{
    self.imageScrollView.alpha = 1.0;
}


#pragma mark
#pragma mark === setting and tearing of the object ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
	NSLog(@"SnapContainer initialization start...");
    
    self = [super initWithFrame:frame];
    
    self.multipleTouchEnabled = YES;
    //self.layer.needsDisplayOnBoundsChange = YES;
    self.opaque = NO;
    
    // 
	// scrollview for the snap
    // 
    imageScrollView = [[SnapImageScroller alloc] initWithFrame:frame];
    [self addSubview:imageScrollView];
    
    NSLog(@"SnapContainer initialization done");
    
    return self;
}


@end
