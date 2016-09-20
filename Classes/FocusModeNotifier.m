
#import "FocusModeNotifier.h"

@implementation FocusModeNotifier

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
    string_booting   = NSLocalizedString(@"AF starting up", @"indicate Auto Focus is starting up");
    string_adjusting = NSLocalizedString(@"AF Adjusting",   @"indicate Auto Focus mod is adjusting focus");
    string_locked    = NSLocalizedString(@"Focus Lock",     @"indicate Focus is in Lock");
    string_auto      = NSLocalizedString(@"Auto Focus",     @"indicate Focus is in Auto");
    string_manual    = NSLocalizedString(@"Manual Focus",   @"indicate Focus is manualy controlled");
    
	string_default = string_auto;
	
    return self;
}

@end
