
#import <QuartzCore/QuartzCore.h>
#import "ApplicationDecoration.h"

@interface ApplicationDecoration(Private)
- (void) animateCubes;
- (void) terminateCubeAnim;
@end

@implementation ApplicationDecoration
@synthesize cubeAnimationView;
@synthesize shouldStopCubeAnimation;
@synthesize cubeAnimationRunning;
@synthesize cubes;
@synthesize cubeAnimationIndex;

static ApplicationDecoration *sharedInstance = nil;

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
    NSLog(@"### ApplicationDecoration initialization");
    self = [super init];
    
    shouldStopCubeAnimation = NO;
    cubeAnimationRunning = NO;
    
    // prep cube animation view
    
    cubes = [NSMutableArray array];
    cubeAnimationIndex = 0; // 0~3
    
    CGRect baseRect = CGRectMake(0, 0, 170, 40);
    //float cubeWidth = 30.0f;
    //float cubeHeight = 30.0f;
    
    cubeAnimationView = [[UIView alloc] initWithFrame:baseRect];
    cubeAnimationView.hidden = YES;
    
    UIImage *cube1_img = [UIImage imageNamed:@"cube1_78x78.png"];
    cube1 = [[UIImageView alloc] initWithImage:cube1_img];
    cube1.frame = CGRectMake(10, 10, 30.0f, 30.0f);
    cube1.layer.opacity = 0.2;
    [cubes addObject:cube1];
    
    UIImage *cube2_img = [UIImage imageNamed:@"cube2_78x78.png"];
    cube2 = [[UIImageView alloc] initWithImage:cube2_img];
    cube2.frame = CGRectMake(50, 10, 30.0f, 30.0f);
    cube2.layer.opacity = 0.2;
    [cubes addObject:cube2];
    
    UIImage *cube3_img = [UIImage imageNamed:@"cube3_78x78.png"];
    cube3 = [[UIImageView alloc] initWithImage:cube3_img];
    cube3.frame = CGRectMake(90, 10, 30.0f, 30.0f);
    cube3.layer.opacity = 0.2;
    [cubes addObject:cube3];
    
    UIImage *cube4_img = [UIImage imageNamed:@"cube4_78x78.png"];
    cube4 = [[UIImageView alloc] initWithImage:cube4_img];
    cube4.frame = CGRectMake(130, 10, 30.0f, 30.0f);
    cube4.layer.opacity = 0.2;
    [cubes addObject:cube4];
    
    [cubeAnimationView addSubview:cube1];
    [cubeAnimationView addSubview:cube2];
    [cubeAnimationView addSubview:cube3];
    [cubeAnimationView addSubview:cube4];
    
    return self;
}

#pragma mark
#pragma mark === CubeAnimation ===
#pragma mark

- (void) animateCubes
{
    [UIView animateWithDuration:0.3f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //NSLog(@"### animateCubes (%d)",self.cubeAnimationIndex);
                         UIImageView *cube = [self.cubes objectAtIndex:self.cubeAnimationIndex];
                         cube.layer.opacity = 0.7f;
                     }
                     completion:^(BOOL finished){
                         //if( finished ){
                         //    NSLog(@"### *animateCubes completion block : finished YES");
                         //}
                         //if( shouldStopCubeAnimation ){
                         //    NSLog(@"### *animateCubes completion block : shouldStopCubeAnimation YES");
                         //}
                         
                         //if( finished && shouldStopCubeAnimation )
                         if( shouldStopCubeAnimation )
                         {
                             //NSLog(@"### animateCubes finished");
                             [self terminateCubeAnim];
                         }
                         else{
                             //NSLog(@"### animateCubes continue");
                             UIImageView *cube = [self.cubes objectAtIndex:self.cubeAnimationIndex];
                             [UIView beginAnimations:@"CubeAnimation_Rev" context:NULL];
                             [UIView setAnimationDuration:0.3f];
                             cube.layer.opacity = 0.2f;
                             [UIView commitAnimations];
                             
                             self.cubeAnimationIndex = (self.cubeAnimationIndex + 1) % 4;
                             [self animateCubes];
                         }
                     }];
}

- (void) terminateCubeAnim
{
    NSLog(@"### terminateCubeAnim() called");
    
    // BUG?
    // removeFromSuperView will dealoc the cubeAnimationView instance immediately, 
    // so you cant call removeFromSuperview here, the view might be stil in use by some animation.
    //[cubeAnimationView removeFromSuperview];
    
    // BUG?
    // hiding animation view in here causes EXEC_BAD_ACCESS in perviewlayer drawing?
    //cubeAnimationView.hidden = YES;
    
    cubeAnimationRunning = NO;
}

// public interface

+ (void) forceTerminateCubeAnim
{
    NSLog(@"### forceTerminateCubeAnim() called");
    
    ApplicationDecoration *instance = [self sharedInstance];
    instance.cubeAnimationView.hidden = YES;
    instance.shouldStopCubeAnimation = YES;
    [instance.cubeAnimationView removeFromSuperview];
    
    // re-using uiview animation across view will not animate.
    // animation should be start with fresh instance of ApplicationDecoration
    // so just discard the shared instance
    sharedInstance = nil;
}

+ (BOOL) cubeAnimationRunning
{
    ApplicationDecoration *instance = [self sharedInstance];
    return instance.cubeAnimationRunning;
}

+ (void) startCubeAnimationOnView:(UIView *)targetView withCenter:(CGPoint)center
{
    NSLog(@"### startCubeAnimationOnView:withCenter() called");
    ApplicationDecoration *instance = [self sharedInstance];
    instance.shouldStopCubeAnimation = NO;
    [targetView addSubview:instance.cubeAnimationView];
    instance.cubeAnimationView.center = center;
    instance.cubeAnimationView.hidden = NO;
    //[instance animateCubes];
    [instance performSelectorInBackground:@selector(animateCubes) withObject:nil];
    instance.cubeAnimationRunning = YES;
}

+ (void) stopCubeAnimation
{
    NSLog(@"### stopCubeAnimation() called");
    ApplicationDecoration *instance = [self sharedInstance];
    instance.shouldStopCubeAnimation = YES;
    
    // re-using uiview animation across view will not animate.
    // animation should be start with fresh instance of ApplicationDecoration
    // so just discard the shared instance
    sharedInstance = nil;
}


#pragma mark
#pragma mark === singleton ===
#pragma mark

+ (id) sharedInstance
{
	@synchronized(self){
		if( !sharedInstance ){
            NSLog(@"### instantiating new ApplicationDecoration");
			sharedInstance = [[ApplicationDecoration alloc] init];
		}
	}
    return sharedInstance;
}

@end
