
#import "WBModeNotifier.h"

@implementation WBModeNotifier

@synthesize string_default;
@synthesize string_booting;
@synthesize string_adjusting;
@synthesize string_locked;
@synthesize string_auto;
@synthesize string_manual;

- (id) init
{
    self = [super init];
    
    // prepare text
    string_booting   = NSLocalizedString(@"WB starting up", @"indicate starting up whitebalance mode");
    string_adjusting = NSLocalizedString(@"WB Adjusting",   @"indicate running(=adjusting) auto whitebalance block");
    string_locked    = NSLocalizedString(@"WB Lock",        @"indicate whitebalance is locked, (is in device level wb lock)");
    string_auto      = NSLocalizedString(@"WB Auto",        @"indicate whitebalance is automatically adjusted continuously");
    string_manual    = NSLocalizedString(@"WB Manual",      @"indicate whitebalance is manually adjusted by user's selection");
    
	string_default = string_auto;
	
    return self;
}

@end
