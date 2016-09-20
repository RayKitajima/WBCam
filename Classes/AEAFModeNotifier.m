
#import "AEAFModeNotifier.h"

@implementation AEAFModeNotifier

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
	string_default   = NSLocalizedString(@"AE/AF default",     @"default string");
    string_booting   = NSLocalizedString(@"AE/AF starting up", @"notifiy starting up AE/AF mode");
    string_adjusting = NSLocalizedString(@"AE/AF Adjusting",   @"notify adjusting AE/AF mode");
    string_locked    = NSLocalizedString(@"AE/AF Lock",        @"notify AE/AF is in Lock, aka AEAF Lock");
    string_auto      = NSLocalizedString(@"AE/AF Auto",        @"notify AE/AF is in Auto");
    string_manual    = nil; // not available
    
    return self;
}

@end
