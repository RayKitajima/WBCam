
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PreviewToolBar.h"
#import "DeviceConfig.h"

@implementation PreviewToolBar

#pragma mark
#pragma mark === utility ===
#pragma mark

- (void) updateIcon
{
    [libIcon updateIcon];
}

#pragma mark
#pragma mark === public interface ===
#pragma mark

- (void) gearButtonOn
{
	[gearButton buttonOn];
}

- (void) gearButtonOff
{
	[gearButton buttonOff];
}

// simply disable and enable button action
- (void) disableButtonAction
{
    //NSLog(@"*** PreviewToolBar.disableButtonAction called");
    [snapButton disableButtonAction];
	[gearButton disableButtonAction];
    [libIcon disableButtonAction];
}
- (void) enableButtonAction
{
    //NSLog(@"*** PreviewToolBar.enableButtonAction called");
    [snapButton enableButtonAction];
	[gearButton enableButtonAction];
    [libIcon enableButtonAction];
}

- (void) enterSnappingBlock
{
    [snapButton disableButtonAction];
	[gearButton disableButtonAction];
    [libIcon disableButtonAction];
    // then, enter saving block by calling enterSavingBlock from CameraController
}

- (void) enterSavingBlock
{
    // show indicator and block UI while in saving block
    //[indicator startAnimating];
    //indicator.hidden = NO;
}

- (void) exitSavingBlock
{
    // regress from all block.
    // hide indicator and start accept ui
    [snapButton enableButtonAction];
	[gearButton enableButtonAction];
    [libIcon enableButtonAction];
    //indicator.hidden = YES;
    //[indicator stopAnimating];
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // snap button
    CGRect snapButtonRect = [DeviceConfig snapButtonRect];
    snapButton = [[SnapButton alloc] initWithFrame:snapButtonRect];
    snapButton.hidden = NO;
    
	// gear button
	CGRect gear_buttonRect = [DeviceConfig gearButtonRect];
	gearButton = [[GearButton alloc] initWithFrame:gear_buttonRect];
	gearButton.hidden = NO;
	
    // shadow
    UIImage *bg_shadow = [DeviceConfig previewToolBarShadowImage];
    backgroundShadow = [[UIImageView alloc] initWithImage:bg_shadow];
    backgroundShadow.frame = [DeviceConfig previewToolBarShadowImageRect];
    backgroundShadow.layer.opacity = 0.3;
    backgroundShadow.hidden = NO;
    
    // background up
    UIImage *bg_img = [DeviceConfig previewToolBarImage];
    backgroundImage = [[UIImageView alloc] initWithImage:bg_img];
    backgroundImage.frame = [DeviceConfig previewToolBarImageRect];
    backgroundImage.hidden = NO;
    
    // lib icon
    libIcon = [[LibIcon alloc] initWithFrame:[DeviceConfig libIconRect]];
    libIcon.hidden = NO;
    
    [self addSubview:libIcon];
    [self addSubview:backgroundShadow];
    [self addSubview:backgroundImage];
    [self addSubview:snapButton];
	[self addSubview:gearButton];
    
    // prepare indicator
    //indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    //indicator.frame = CGRectMake(0, 0, 20, 20);
    //indicator.center = CGPointMake(26,32);
    //indicator.hidden = YES;
    //[self addSubview:indicator];
    
    return self;
}

@end
