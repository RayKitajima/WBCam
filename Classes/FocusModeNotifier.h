
#import <Foundation/Foundation.h>

@interface FocusModeNotifier : NSObject
{
    NSString *current_string;
    
	NSString *string_default;
    NSString *string_booting;
    NSString *string_adjusting;
    NSString *string_locked;
    NSString *string_auto;
    NSString *string_manual;
}

@property (retain) NSString *string_default;
@property (retain) NSString *string_booting;
@property (retain) NSString *string_adjusting;
@property (retain) NSString *string_locked;
@property (retain) NSString *string_auto;
@property (retain) NSString *string_manual;

@end

