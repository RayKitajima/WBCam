
#import <Foundation/Foundation.h>

@interface CameraUtility : NSObject {}

+ (void) clearApplicationData; // for dev

+ (UIImage *) makePreviewFor:(UIImage *)sourceImage;
+ (UIImage *) makeThumbnailFor:(UIImage *)sourceImage;

+ (UIImage *) rotateUIImage:(UIImage *)image orientation:(ALAssetOrientation)orientation;
+ (NSString *) alAssetOrientationToStringOrientation:(ALAssetOrientation)orientation;
+ (ALAssetOrientation) stringOrientationToALAssetOrientation:(NSString *)str;
+ (ALAssetOrientation) uiDeviceOrientationToALAssetOrientation:(UIDeviceOrientation)orientation;

@end
