
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SnappingNotifier_iPod4_iOS6.h"
#import "ApplicationDecoration.h"


@implementation SnappingNotifier_iPod4_iOS6

- (BOOL) isNotificationHidden
{
    return snappingLabel.hidden;
}

- (void) showNotification
{
    snappingLabel.hidden = NO;
}

- (void) hideNotification
{
    snappingLabel.hidden = YES;
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
    
    // string
    string_snapping = @"";
    string_saving   = @"";
    
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
