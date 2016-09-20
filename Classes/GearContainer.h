
#import <Foundation/Foundation.h>
#import "GearMEButton.h"
#import "GearMFButton.h"
#import "GearWBButton.h"
#import "GearLPButton.h"
#import "GearLMButton.h"

@interface GearContainer : UIView
{
	GearMEButton *gearMEButton;
	GearMFButton *gearMFButton;
	GearWBButton *gearWBButton;
	GearLPButton *gearLPButton;
	GearLMButton *gearLMButton;
	
	CGPoint me_alignment_initial_center;
	CGPoint mf_alignment_initial_center;
	CGPoint wb_alignment_initial_center;
	CGPoint lp_alignment_initial_center;
	CGPoint lm_alignment_initial_center;
	
	UIView *me_alignment;
	UIView *mf_alignment;
	UIView *wb_alignment;
	UIView *lp_alignment;
	UIView *lm_alignment;
}
@property GearMEButton *gearMEButton;
@property GearMFButton *gearMFButton;
@property GearWBButton *gearWBButton;
@property GearLPButton *gearLPButton;
@property GearLMButton *gearLMButton;
@property UIView *me_alignment;
@property UIView *mf_alignment;
@property UIView *wb_alignment;
@property UIView *lp_alignment;
@property UIView *lm_alignment;

- (void) dimmGears;
- (void) illumGears;

- (void) resetCenterOfAlignments;
- (void) allButtonsOff;

- (void) showAlignmentME;
- (void) hideAlignmentME;
- (void) makeDraggingAlignmentME;
- (void) makeNormalAlignmentME;

- (void) showAlignmentMF;
- (void) hideAlignmentMF;
- (void) makeDraggingAlignmentMF;
- (void) makeNormalAlignmentMF;

- (void) showAlignmentWB;
- (void) hideAlignmentWB;
- (void) makeDraggingAlignmentWB;
- (void) makeNormalAlignmentWB;

+ (id) quickInstance;

@end
