
#import "ExposureModeNotifier.h"

@implementation ExposureModeNotifier

@synthesize string_default;
@synthesize string_booting;
@synthesize string_adjusting;
@synthesize string_locked;
@synthesize string_auto;
@synthesize string_manual;

- (id)init
{
    self = [super init];
    
    // prepare text
    string_booting   = NSLocalizedString(@"AE starting up",  @"indicate Auto Exposure mode is starting up");
    string_adjusting = NSLocalizedString(@"AE adjusting",    @"indicate Auto Exposure mode is adjusting exposure");
    string_locked    = NSLocalizedString(@"Exposure Lock",   @"indicate Exposure is in Lock");
    string_auto      = NSLocalizedString(@"Auto Exposure",   @"indicate Exposure is in Auto");
    string_manual    = NSLocalizedString(@"Manual Exposure", @"indicate Exposure is manualy controlled");
	
	string_default = string_auto;
    
    return self;
}

@end
