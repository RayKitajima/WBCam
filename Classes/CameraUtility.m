
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CameraController.h"
#import "CameraHelper.h"
#import "CameraSession.h"
#import "PreviewContainer.h"
#import "CameraUtility.h"
#import "AlbumUtility.h"

@implementation CameraUtility

// for develop
+ (void) clearApplicationData
{
    NSLog(@"Clear all application data:");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:docPath];
    NSString *dir;
    while( (dir = [dirEnum nextObject]) ){ // recursively
        NSString *path = [NSString stringWithFormat:@"%@/%@", docPath, dir];
        NSLog(@"clearing : %@",path);
        [fileManager removeItemAtPath:path error:NULL];
    }
    
    NSLog(@"clear done.");
}

+ (UIImage *) makePreviewFor:(UIImage *)sourceImage
{
    int rate = [DeviceConfig albumPreviewImageReduceRate];
    CGSize targetSize = CGSizeMake(sourceImage.size.width/rate, sourceImage.size.height/rate);
    UIGraphicsBeginImageContext(targetSize);
    [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *) makeThumbnailFor:(UIImage *)sourceImage
{
    CGSize targetSize = CGSizeMake(80, 80);
    
	UIImage *newImage = nil;
    
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if( CGSizeEqualToSize(imageSize,targetSize) == NO ){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if( widthFactor >= heightFactor ){
			scaleFactor = widthFactor; // scale to fit height
        }else{
			scaleFactor = heightFactor; // scale to fit width
		}
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if( widthFactor >= heightFactor ){
			thumbnailPoint.y = ( targetHeight - scaledHeight ) * 0.5; 
		}else if( widthFactor < heightFactor ){
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if( newImage == nil ){
        NSLog(@"cannot make thumbnail");
	}
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	return newImage;
}

+ (UIImage *) rotateUIImage:(UIImage *)image orientation:(ALAssetOrientation)orientation
{
    CGImageRef cgimage = image.CGImage;
    
    int width  = CGImageGetWidth(cgimage);
    int height = CGImageGetHeight(cgimage);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    switch( orientation ){
            
        case ALAssetOrientationUp:
            NSLog(@"rotation with ALAssetOrientationUp");
            transform = CGAffineTransformIdentity;
            break;
            
        case ALAssetOrientationDown:
            NSLog(@"rotation with ALAssetOrientationDown");
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case ALAssetOrientationRight:
            NSLog(@"rotation with ALAssetOrientationRight");
            transform = CGAffineTransformRotate(transform, M_PI/2.0);
            break;
            
        case ALAssetOrientationLeft:
            NSLog(@"rotation with ALAssetOrientationLeft");
            transform = CGAffineTransformRotate(transform, -M_PI/2.0);
            break;
            
        default:
            NSLog(@"rotation with default");
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), cgimage);
    UIImage *rotated = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotated;
}

+ (NSString *) alAssetOrientationToStringOrientation:(ALAssetOrientation)orientation
{
    NSString *str = nil;
    
    switch( orientation ){
            
        case ALAssetOrientationUp:
            str = @"ALAssetOrientationUp";
            break;
            
        case ALAssetOrientationDown:
            str = @"ALAssetOrientationDown";
            break;
            
        case ALAssetOrientationRight:
            str = @"ALAssetOrientationRight";
            break;
            
        case ALAssetOrientationLeft:
            str = @"ALAssetOrientationLeft";
            break;
            
        default:
            break;
    }
    
    return str;
}

+ (ALAssetOrientation) stringOrientationToALAssetOrientation:(NSString *)str
{
    ALAssetOrientation orientation = ALAssetOrientationUp; // default is ALAssetOrientationUp
    
    if( [str isEqualToString:@"ALAssetOrientationUp"] )
    {
        orientation = ALAssetOrientationUp;
    }
    else if( [str isEqualToString:@"ALAssetOrientationDown"] )
    {
        orientation = ALAssetOrientationDown;
    }
    else if( [str isEqualToString:@"ALAssetOrientationRight"] )
    {
        orientation = ALAssetOrientationRight;
    }
    else if( [str isEqualToString:@"ALAssetOrientationLeft"] )
    {
        orientation = ALAssetOrientationLeft;
    }
    
    return orientation;
}

+ (ALAssetOrientation) uiDeviceOrientationToALAssetOrientation:(UIDeviceOrientation)orientation
{
    ALAssetOrientation assetOrientation = ALAssetOrientationUp; // default
    
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
    if( orientation == UIDeviceOrientationPortrait )
    {
        // 1
        assetOrientation = ALAssetOrientationUp;
    }
    else if( orientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        assetOrientation = ALAssetOrientationDown;
    }
    else if( orientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        assetOrientation = ALAssetOrientationRight;
    }
    else if( orientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        assetOrientation = ALAssetOrientationLeft;
    }
    else
    {
        // error
        //NSLog(@"# rotated unknown orientation");
        assetOrientation = ALAssetOrientationUp;
    }
    
    return assetOrientation;
}

@end
