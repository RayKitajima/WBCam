
#import <QuartzCore/QuartzCore.h>
#import "SnapImageScroller.h"
#import "AlbumActionCenter.h"
#import "SnapImageViewWrapper.h"
#import "SnapImageView.h"

#define ZOOM_STEP 1.5
#define ZOOM_MIN 1.0
#define ZOOM_MAX 5.0
#define SCROLLER_PADDING_X 30;
#define SCROLLER_PADDING_Y 54;

@interface SnapImageScroller (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation SnapImageScroller
@synthesize imageViewWrapper;
@synthesize isRawPhotoLoaded;

// 
// image will be scaled to fit in screen width
// 
- (void) replaceImage:(UIImage *)newImage
{
    // 
    // check aspect and get initial display size
    // 
    float screen_ratio = self.frame.size.width / (float)self.frame.size.height;
    float image_ratio  = newImage.size.width / (float)newImage.size.height;
    
    int display_width;
    int display_height;
    
    if( image_ratio < screen_ratio ){
        NSLog(@"side padding mode");
        
        float ratio = self.frame.size.height / (float)newImage.size.height;
        
        display_width = newImage.size.width * ratio;
        display_height = self.frame.size.height;
        
    }else{
        NSLog(@"top and down padding mode");
        
        float ratio = self.frame.size.width / (float)newImage.size.width;
        
        display_width = self.frame.size.width;
        display_height = newImage.size.height * ratio;
        
    }
    
    // update image display size
    initial_image_display_width = display_width;
    initial_image_display_height = display_height;
    
    // reset them by current orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [self rotateWithUIDeviceOrientation:orientation];
    
    NSLog(@"### replacing image");
    NSLog(@"### display size ( w:%d, h:%d )", initial_image_display_width, initial_image_display_height);
    
    // 
    // then replace the image
    // 
    imageViewWrapper.imageView.image = newImage;
}

#pragma mark
#pragma mark === UIScrollViewDelegate implementation ===
#pragma mark

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
    //NSLog(@"# viewForZoomingInScrollView called");
    return imageViewWrapper;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale 
{
    NSLog(@"*** scrollViewDidEndZooming:withView:atScale called");
    NSLog(@"*** SnapImageScroller zoome scale   : %f",scale);
    //NSLog(@"*** SnapImageScroller bounds        : %@",NSStringFromCGRect(scrollView.bounds));
    //NSLog(@"*** SnapImageScroller content size  : %@",NSStringFromCGSize(scrollView.contentSize));
    //NSLog(@"*** SnapImageScroller contentOffset : %@",NSStringFromCGPoint(self.contentOffset));
    
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
    
    // request raw photo loading
    if( !isRawPhotoLoaded ){
        //NSLog(@"SnapImageScroller send request for loading photo (zoomed)");
        [AlbumActionCenter requestLoadingPhotoInSnap];
    }
    
    // hide grid
    [AlbumActionCenter hideHidableSnapDecoration];
    
    // adjust inset
    [self resetInsetWithScale:self.zoomScale];
    
    // reset navigations if minimum scale
    if( scale == 1 ){
        [self resetDecorationNaviTool];
    }
}

- (void) resetInsetWithScale:(CGFloat)scale
{
    int current_frame_width  = initial_scrollview_display_width * scale; // same as self.frame
    int current_frame_height = initial_scrollview_display_height * scale;
    
    int overflow_x = ( current_frame_width  - self.frame.size.width  ) / 2;
    int overflow_y = ( current_frame_height - self.frame.size.height ) / 2;
//    if( isLandscapeMode ){
//        overflow_x = ( current_frame_width  - self.frame.size.height ) / 2;
//        overflow_y = ( current_frame_height - self.frame.size.width  ) / 2;
//    }
    
    int padding_x = ( current_frame_width  - scale * initial_image_display_width  ) / 2;
    int padding_y = ( current_frame_height - scale * initial_image_display_height ) / 2;
    if( isLandscapeMode ){
        padding_x = ( current_frame_width  - scale * initial_image_display_height ) / 2;
        padding_y = ( current_frame_height - scale * initial_image_display_width  ) / 2;
    }
    
    int inset_def_x = SCROLLER_PADDING_X;
    int inset_def_y = SCROLLER_PADDING_Y;
    int inset_x = 0;
    int inset_y = 0;
    
    if( padding_x == 0 && overflow_x > 0 ){
        inset_x = inset_def_x;
    }
    else if( padding_x == 0 && overflow_x < 0 ){
        inset_x = overflow_x;
    }
    else if( padding_x >= 0 ){
        inset_x = - padding_x + inset_def_x;
    }
    else if( padding_x < 0  ){
        inset_x = - padding_x + inset_def_x;
    }
    
    if( padding_y < overflow_y ){
        inset_y = padding_y - inset_def_y;
    }else{
        inset_y = overflow_y - inset_def_y;
    }
    
    //NSLog(@"# landscape  : %d",isLandscapeMode);
    //NSLog(@"# init img W : %d",initial_image_display_width);
    //NSLog(@"# init img H : %d",initial_image_display_height);
    //NSLog(@"# img view W : %d",current_frame_width);
    //NSLog(@"# img view H : %d",current_frame_height);
    //NSLog(@"# frame w    : %f",self.frame.size.width);
    //NSLog(@"# frame H    : %f",self.frame.size.height);
    //NSLog(@"# overflow_x : %d",overflow_x);
    //NSLog(@"# overflow_y : %d",overflow_y);
    //NSLog(@"# padding_x  : %d",padding_x);
    //NSLog(@"# padding_y  : %d",padding_y);
    //NSLog(@"# inset_x    : %d",inset_x);
    //NSLog(@"# inset_y    : %d",inset_y);
    
    if( self.zoomScale != 1.0 ){
        //NSLog(@"* setting contentInset");
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        self.contentInset = UIEdgeInsetsMake(-inset_y, inset_x, -inset_y, inset_x);
        [UIView commitAnimations];
    }else{
        //NSLog(@"* discarding contentInset");
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        self.contentInset = UIEdgeInsetsZero;
        [UIView commitAnimations];
    }
}

- (void) resetScrollView
{
    NSLog(@"# resetScrollView");
    
    // reset zoom
    float resetScale = 1.0f;
    CGRect resetRect = [self zoomRectForScale:resetScale withCenter:self.center];
    [self zoomToRect:resetRect animated:NO];
    
    // reset inset
    self.contentInset = UIEdgeInsetsZero;
    
    // reset raw photo request
    isRawPhotoLoaded = NO;
}

- (void) resetDecorationNaviTool
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [AlbumActionCenter toggleHidableSnapDecoration];
    [AlbumActionCenter showSnapViewNaviAndTool];
    [UIView commitAnimations];
}

#pragma mark
#pragma mark === Touch handling  ===
#pragma mark

- (void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer 
{
    // single tap to hide grid
    //NSLog(@"handleSingleTap called");
    
    // toggle day label and grid
    if( [self zoomScale] == 1 ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [AlbumActionCenter toggleHidableSnapDecoration];
        [AlbumActionCenter showSnapViewNaviAndTool];
        [UIView commitAnimations];
    }
    
    // toggle navigation bar and tool bar
    if( [self zoomScale] > 1 ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [AlbumActionCenter toggleSnapViewNaviAndTool];
        [UIView commitAnimations];
    }
    
    // toggle scroll indicator mode
    if( [AlbumActionCenter isSnapViewNaviAndToolVisible] ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [self scrollIndicatorWithNaviAndTool];
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [self scrollIndicatorWithoutNaviAndTool];
        [UIView commitAnimations];
    }
    
}

- (void) handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer 
{
    // double tap zooms in
    //NSLog(@"handleDoubleTap called");
    
    float newScale = [self zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self.imageViewWrapper]];
    [self zoomToRect:zoomRect animated:YES];
    
    // request raw photo loading
    if( !isRawPhotoLoaded ){
        NSLog(@"send request for loading photo (double tap)");
        [AlbumActionCenter requestLoadingPhotoInSnap];
    }
}

- (void) handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer 
{
    // two-finger tap zooms out
    //NSLog(@"handleTwoFingerTap called");
    
    float newScale = [self zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self.imageViewWrapper]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect) zoomRectForScale:(float)scale withCenter:(CGPoint)center 
{
    //NSLog(@"# zoomRectForScale called");
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


#pragma mark
#pragma mark === object setup ===
#pragma mark

- (void) scrollIndicatorWithNaviAndTool
{
    self.scrollIndicatorInsets = UIEdgeInsetsMake(44.0f, 0.0f, 44.0f, 0.0f);
}

- (void) scrollIndicatorWithoutNaviAndTool
{
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (id) initWithFrame:(CGRect)frame
{
	NSLog(@"### SnapContainer initialization start");
    
    self = [super initWithFrame:frame];
    
    self.multipleTouchEnabled = YES;
    self.delegate = self;
    
    if( [AlbumActionCenter isSnapViewNaviAndToolVisible] ){
        [self scrollIndicatorWithNaviAndTool];
    }else{
        [self scrollIndicatorWithoutNaviAndTool];
    }
    
    currentZoomScale = [super zoomScale];
    NSLog(@"# initlal zoomScale : %f",currentZoomScale);
    
    isRawPhotoLoaded = NO;
    isLandscapeMode = NO;
    
    // image wrapper
	imageViewWrapper = [[SnapImageViewWrapper alloc] initWithFrame:self.bounds];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    //float minimumScale = [self frame].size.width  / [self.imageView frame].size.width;
    //[self setMinimumZoomScale:minimumScale];
    //[self setZoomScale:minimumScale];
    //[self setMaximumZoomScale:ZOOM_MAX];
    [self setMinimumZoomScale:ZOOM_MIN];
    [self setZoomScale:ZOOM_MIN];
    [self setMaximumZoomScale:ZOOM_MAX];
    
    // add gesture recognizers
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:twoFingerTap];
    
    
    [self resetScrollView];
    
	imageViewWrapper.hidden = NO;
    
    [self addSubview:imageViewWrapper];
    
    // starting scroll indicator with navi and toolbar
    [self scrollIndicatorWithNaviAndTool];
    
    // 
    // save initial frame size of scrllview(self), for the rotation hack
    // 
    initial_scrollview_display_width = frame.size.width;
    initial_scrollview_display_height = frame.size.height;
    
    // 
    // observing shouldUpdateLibIcon
    // 
    currentOrientation = [[UIDevice currentDevice] orientation];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(rotated:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    return self;
}

#pragma mark
#pragma mark === device rotation observer ===
#pragma mark

- (void) rotated:(NSNotification *)notification
{
    NSLog(@"*** SnapImageScroller.roteted called");
    
    //UIDeviceOrientation orientation = [[notification object] orientation];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
    // updae flags
    [self rotateWithUIDeviceOrientation:orientation];
    
    // update inset
    [self resetInsetWithScale:self.zoomScale];
}

- (void) rotateWithUIDeviceOrientation:(UIDeviceOrientation)orientation
{
    if( orientation == UIDeviceOrientationPortrait )
    {
        // 1
        NSLog(@"* scrollview rotated to (1)");
        isLandscapeMode = NO;
    }
    else if( orientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        NSLog(@"* scrollview rotated to (2)");
        isLandscapeMode = NO;
    }
    else if( orientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        NSLog(@"* scrollview rotated to (3), with swap");
        // swap
        isLandscapeMode = YES;
    }
    else if( orientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        NSLog(@"* scrollview rotated to (4), with swap");
        // swap
        isLandscapeMode = YES;
    }
    else
    {
        // unsupported orientation
        // do nothing
        return;
    }
    
    currentOrientation = orientation;
    
    // 
    // Device and object orientation
    // 
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // :                                                                 :                          :
    // : +---------+   +---------+   +----------+---+   +---+----------+ :                          :
    // : |         |   |    O    |   |          |   |   |   |          | :                          :
    // : |         |   +---------+   |          |   |   |   |          | :                          :
    // : |    1    |   |         |   |     3    | O |   | O |    4     | :                          :
    // : |         |   |         |   |          |   |   |   |          | :       device/obj         :
    // : |         |   |    2    |   |          |   |   |   |          | :                          :
    // : +---------+   |         |   +----------+---+   +---+----------+ :                          :
    // : |    O    |   |         |                                       :                          :
    // : +---------+   +---------+                                       :                          :
    // :                                                                 :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Portrate      Portrate      LandscapeRight     LandscapeLeft    : UIInterfaceOrientation   :
    // :                 UpsideDown                                      :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Up(def)       Down          Left               Right            : ALAssetOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Right         Left          Up                 Down             : UIImageOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // 
    // 
    // + - - - - - - - - - - - - + - - - +
    // : current                 : angle :
    // + - - - - - - - - - - - - + - - - +
    // : (1) Portrait            :     0 :
    // + - - - - - - - - - - - - + - - - +
    // : (2) PortraitUpsideDown  :   180 :
    // + - - - - - - - - - - - - + - - - +
    // : (3) LandscapeRight      :   -90 :
    // + - - - - - - - - - - - - + - - - +
    // : (4) LandscapeLeft       :    90 :
    // + - - - - - - - - - - - - + - - - +
    // 
    // 
}

@end
