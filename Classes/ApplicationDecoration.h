
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ApplicationDecoration : NSObject
{
    NSMutableArray *cubes;
    UIView *cubeAnimationView;
    UIImageView *cube1;
    UIImageView *cube2;
    UIImageView *cube3;
    UIImageView *cube4;
    int cubeAnimationIndex;
    BOOL cubeAnimationRunning;
    BOOL shouldStopCubeAnimation;
}
@property (retain) UIView *cubeAnimationView;
@property BOOL shouldStopCubeAnimation;
@property BOOL cubeAnimationRunning;
@property (retain) NSMutableArray *cubes;
@property int cubeAnimationIndex;

+ (id) sharedInstance;

+ (void) forceTerminateCubeAnim;
+ (BOOL) cubeAnimationRunning;
+ (void) startCubeAnimationOnView:(UIView *)targetView withCenter:(CGPoint)center;
+ (void) stopCubeAnimation;

@end
