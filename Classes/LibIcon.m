
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LibIcon.h"
#import "CameraController.h"
#import "AlbumDataCenter.h"
#import "ApplicationActionCenter.h"

@interface LibIcon(Private)
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
@end

@implementation LibIcon

#pragma mark
#pragma mark === ui supports  ===
#pragma mark

- (void) enableButtonAction
{
    enabled = YES;
}

- (void) disableButtonAction
{
    enabled = NO;
}


#pragma mark
#pragma mark === Touch handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enabled ){ return; }
    
    // bringup saved photo library
    [CameraController bringupPhotoLibrary];
}


#pragma mark
#pragma mark === object setting  ===
#pragma mark

- (UIImage*) maskImage:(UIImage *)image
{
    CGImageRef maskRef = maskImage.CGImage; 
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return maskedImage;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // prep ALAssetsLibrary
    library = [[ALAssetsLibrary alloc] init];
    
    // prep mask
    maskImage = [UIImage imageNamed:@"libicon_mask_53x53"];
    
    // masked thumbnail
    UIImage *initLibIconImage = [UIImage imageNamed:@"dummy_libicon_53x53"];
    photoThumbnail = [[UIImageView alloc] initWithImage:initLibIconImage];
//    photoThumbnail.frame = frame;
    // set mask
    photoThumbnail.image = [self maskImage:initLibIconImage];
    
    /*
    CALayer *layer = [photoThumbnail layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0f];
    [layer setBorderWidth:1.0f];
    [layer setBorderColor:[[UIColor blackColor] CGColor]];
    */
    
    photoThumbnail.hidden = NO;
    
    // 
    // get device orientation
    // 
    currentOrientation = [[UIDevice currentDevice] orientation];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(rotated:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    [self addSubview:photoThumbnail];
    
    enabled = YES;
    
    [self updateIcon];
    
    // 
    // observing shouldUpdateLibIcon
    // 
    ApplicationActionCenter *applicationActionCenter = [ApplicationActionCenter sharedInstance];
    [applicationActionCenter addObserver:self 
                              forKeyPath:@"shouldUpdateLibIcon" 
                                 options:NSKeyValueObservingOptionNew 
                                 context:NULL];
    
    return self;
}

- (void) setLibIcon:(UIImageView *)imageView
{
    photoThumbnail = imageView;
}

// shortcut
- (void) updateIcon
{
    [self showLastItemInThePhotoLibrary];
}

- (void) showLastItemInThePhotoLibrary
{
    UIImage *lastPhoto = [AlbumDataCenter loadLatestPhotoAsUIImage];
    if( lastPhoto != nil ){
        photoThumbnail.image = [self maskImage:lastPhoto];
    }else{
        UIImage *initLibIconImage = [UIImage imageNamed:@"dummy_libicon_53x53.png"];
        //photoThumbnail.image = initLibIconImage;
        photoThumbnail.image = [self maskImage:initLibIconImage];
    }
    [ApplicationActionCenter withdrawRequestShouldUpdateLibIcon];
}

#pragma mark
#pragma mark === observing button availability ===
#pragma mark

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"LibIcon detect key change");
    if( [keyPath isEqualToString:@"shouldUpdateLibIcon"] ){
        ApplicationActionCenter *action = (ApplicationActionCenter *)object;
        NSLog(@"shouldUpdateLibIcon change:%d",action.shouldUpdateLibIcon);
        if( action.shouldUpdateLibIcon ){
            [self updateIcon];
        }
    }
}

#pragma mark
#pragma mark === device rotation observer ===
#pragma mark

- (void) rotated:(NSNotification *)notification
{
    //UIDeviceOrientation newOrientation = [[notification object] orientation];
	UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
    
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
    CGFloat angle  = 0.0f;
    CGFloat middle = 0.0f;
    if( newOrientation == UIDeviceOrientationPortrait )
    {
        // 1
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(1)");
            angle  = 0.0f;
            middle = 0.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(1)");
            angle  = 0.0f;
            middle = -90.0f; // same as other self rotation
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(1)");
            angle  = 0.0f;
            middle = -45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(1)");
            angle  = 0.0f;
            middle = 45.0f;
        }
    }
    else if( newOrientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(2)");
            angle  = -180.0f; // same as other self rotation
            middle = -90.0f; 
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(2)");
            angle  = 180.0f;
            middle = 180.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(2)");
            angle  = -180.0f;
            middle = -135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(2)");
            angle  = 180.0f;
            middle = 135.0f;
        }
    }
    else if( newOrientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(3)");
            angle  = -90.0f;
            middle = -45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(3)");
            angle  = -90.0f;
            middle = -135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(3)");
            angle  = -90.0f;
            middle = -90.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(3)");
            angle  = -90.0f;
            middle = 0.0f;
        }
    }
    else if( newOrientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        if( currentOrientation == UIDeviceOrientationPortrait ){
            NSLog(@"cam rotated: (1)->(4)");
            angle  = 90.0f;
            middle = 45.0f;
        }
        else if( currentOrientation == UIDeviceOrientationPortraitUpsideDown ){
            NSLog(@"cam rotated: (2)->(4)");
            angle  = 90.0f;
            middle = 135.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeRight ){
            NSLog(@"cam rotated: (3)->(4)");
            angle  = 90.0f;
            middle = 0.0f;
        }
        else if( currentOrientation == UIDeviceOrientationLandscapeLeft ){
            NSLog(@"cam rotated: (4)->(4)");
            angle  = 90.0f;
            middle = 90.0f;
        }
    }
    else
    {
        // unsupported orientation
        // do nothing
        return;
    }
    
    currentOrientation = newOrientation;
    
    if( angle == middle ){
        NSLog(@"no need to animate");
        return;
    }
    
    /*
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.13f];
    photoThumbnail.transform = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    [UIView commitAnimations];
    */
    
    CGAffineTransform phase_1_rotate = CGAffineTransformMakeRotation( middle * (M_PI/180.0f) );
    //CGAffineTransform phase_1 = CGAffineTransformScale( phase_1_rotate, 1.4f, 1.4f );
    CGAffineTransform phase_1 = CGAffineTransformScale( phase_1_rotate, 1.0f, 1.0f );
    
    CGAffineTransform phase_2_rotate = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    CGAffineTransform phase_2 = CGAffineTransformScale( phase_2_rotate, 1.0f, 1.0f );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.07f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             photoThumbnail.transform = phase_1;
                         } 
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.05f delay:0.03f options:0 animations:^{
                                 photoThumbnail.transform = phase_2;
                             } completion:nil];
                         }];
    });
}

@end
