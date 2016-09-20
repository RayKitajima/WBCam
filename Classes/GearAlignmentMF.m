
#import "GearAlignmentMF.h"
#import "GearContainer.h"

#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "CameraSession.h"
#import "CameraController.h"

@implementation GearAlignmentMF

#pragma mark
#pragma mark === button handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	initialPoint = [((UITouch*)[touches anyObject])locationInView:self];
	NSLog(@"MF drag start at point : %@",NSStringFromCGPoint(initialPoint));
	
	GearContainer *container = [GearContainer quickInstance];
	[container makeDraggingAlignmentMF];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [((UITouch*)[touches anyObject])locationInView:self];
	
	CGRect frame = [self frame];
	frame.origin.x += point.x - initialPoint.x;
	frame.origin.y += point.y - initialPoint.y;
    
    if( frame.origin.x < 0 ){ return; }
    if( frame.origin.x > (displayWidth - frame.size.width) ){ return; }
    if( frame.origin.y < 0 ){ return; }
    if( frame.origin.y > (displayHeight - frame.size.height) ){ return; }
    
	[self setFrame:frame];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = CGPointMake( self.frame.origin.x + self.frame.size.width / 2 , self.frame.origin.y + self.frame.size.height / 2 );
	NSLog(@"MF drag end at point (object) : %@",NSStringFromCGPoint(point));
	
	GearContainer *container = [GearContainer quickInstance];
	[container makeNormalAlignmentMF];
	
	// notify focus point of interrest
    ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
    DeviceConfig *deviceConfig = [app_conf deviceConfig];
    
    // normalize, and adjust centering margin.
    // this is a point for the device,
    // so the Tx is devided by the height.
	float Tx = ( (float)point.y + deviceConfig.previewScreenAdjustmentY ) / (float)deviceConfig.previewHeightAdjusted;
	float Ty = ( (float)point.x + deviceConfig.previewScreenAdjustmentX ) / (float)deviceConfig.previewWidthAdjusted;
    Ty = 1.0f - Ty;
    
    CGPoint focusPoint = CGPointMake(Tx, Ty);
    
    [CameraSession notifyFocusPointOfInterest:focusPoint];
    [CameraController changeFocusModeNotificationToManual];
}

#pragma mark
#pragma mark === object setting  ===
#pragma mark

- (id) initAlignment
{
	UIImage *alignmentImage = [UIImage imageNamed:@"alignment_g"];
    alignmentImageView = [[UIImageView alloc] initWithImage:alignmentImage]; // rotatable
	//self = [super initWithImage:alignment];
    self = [super initWithFrame:CGRectMake(0, 0, 64, 64)];
	[self addSubview:alignmentImageView];
    
	self.userInteractionEnabled = YES;
    alignmentImageView.userInteractionEnabled = YES;
	
    // cache the screen size
    ApplicationConfig *app_conf = [ApplicationConfig sharedInstance];
    DeviceConfig *deviceConfig = [app_conf deviceConfig];
    displayWidth = deviceConfig.previewDisplayWidth;
    displayHeight = deviceConfig.previewDisplayHeight;
    
    // 
    // get device orientation
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
    CGFloat angle;
    if( newOrientation == UIDeviceOrientationPortrait )
    {
        // 1
        angle = 0.0f;
        //NSLog(@"cam rotated: (1)");
    }
    else if( newOrientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        angle = 180.0f;
        //NSLog(@"cam rotated: (2)");
    }
    else if( newOrientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        angle = -90.0f;
        //NSLog(@"cam rotated: (3)");
    }
    else if( newOrientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        angle = 90.0f;
        //NSLog(@"cam rotated: (4)");
    }
    else
    {
        // unsupported orientation
        // do nothing
        return;
    }
    
    currentOrientation = newOrientation;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.13f];
    alignmentImageView.transform = CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
    [UIView commitAnimations];
}

@end
