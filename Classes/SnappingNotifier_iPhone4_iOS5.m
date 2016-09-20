
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SnappingNotifier_iPhone4_iOS5.h"
#import "ApplicationDecoration.h"

@implementation SnappingNotifier_iPhone4_iOS5

- (BOOL) isNotificationHidden
{
    return snappingLabel.hidden;
}

- (void) showNotification
{
    [indicator startAnimating];
    snappingLabel.hidden = NO;
}

- (void) hideNotification
{
    [indicator stopAnimating];
    snappingLabel.hidden = YES;
    
    // reset to start string
    snappingLabel.text = string_snapping;
}

- (void) showSnapping 
{
    snappingLabel.text = string_snapping;
}

- (void) showSaving 
{
    snappingLabel.text = string_saving;
}

- (id)initWithFrame:(CGRect)frame withCenter:(CGPoint)center
{
    self = [super initWithFrame:frame];
    
    // indicator
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(0, 0, 30, 30);
    indicator.center = CGPointMake(center.x, center.y);
    [self addSubview:indicator];
    
    // string
    string_snapping = NSLocalizedString(@"Taking photo...", @"Just you did press snap button, indicate taking photo.");
    string_saving   = NSLocalizedString(@"Saving photo...", @"Photo has been taken, indicate saving the photo.");
    
    // label
    snappingLabel = [[UILabel alloc] init];
    snappingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    snappingLabel.frame = frame;
    snappingLabel.text = string_snapping;
    snappingLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    snappingLabel.textAlignment = NSTextAlignmentCenter;
    snappingLabel.textColor = [UIColor whiteColor];
    snappingLabel.backgroundColor = [UIColor clearColor];
    snappingLabel.center = CGPointMake(center.x, center.y + 40);
    snappingLabel.hidden = YES;
    [self addSubview:snappingLabel];
    
    return self;
}

@end
