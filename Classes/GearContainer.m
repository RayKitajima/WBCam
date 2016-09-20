
#import <QuartzCore/QuartzCore.h>
#import "GearContainer.h"
#import "DeviceConfig.h"
#import "GearAlignmentME.h"
#import "GearAlignmentMF.h"
#import "GearAlignmentWB.h"

@interface GearContainer(Private)
- (void) resetCenterOfAlignmentME;
- (void) resetCenterOfAlignmentMF;
- (void) resetCenterOfAlignmentWB;
@end

@implementation GearContainer
@synthesize gearMEButton,gearMFButton,gearWBButton,gearLPButton,gearLMButton;
@synthesize me_alignment,mf_alignment,wb_alignment,lp_alignment,lm_alignment;

static GearContainer *sharedInstance = nil;

const CGFloat alignment_init_opacity     = 0.40f;
const CGFloat alignment_dragging_opacity = 0.80f;
const CGFloat alignment_normal_opacity   = 0.70f;

#pragma mark
#pragma mark === alignment controls ===
#pragma mark

- (void) dimmGears
{
    self.alpha = 0.5;
}

- (void) illumGears
{
    self.alpha = 1.0;
}

- (void) resetCenterOfAlignments
{
	[self resetCenterOfAlignmentME];
	[self resetCenterOfAlignmentMF];
	[self resetCenterOfAlignmentWB];
}

- (void) allButtonsOff
{
	[gearMEButton buttonOff];
	[gearMFButton buttonOff];
	[gearWBButton buttonOff];
}

// ME

- (void) showAlignmentME
{
	me_alignment.hidden = NO;
}

- (void) hideAlignmentME
{
	me_alignment.hidden = YES;
}

- (void) makeDraggingAlignmentME
{
	me_alignment.layer.opacity = alignment_dragging_opacity;
}

- (void) makeNormalAlignmentME
{
	me_alignment.layer.opacity = alignment_normal_opacity;
}

- (void) resetCenterOfAlignmentME
{
	me_alignment.center = me_alignment_initial_center;
}

// MF

- (void) showAlignmentMF
{
	mf_alignment.hidden = NO;
}

- (void) hideAlignmentMF
{
	mf_alignment.hidden = YES;
}

- (void) makeDraggingAlignmentMF
{
	mf_alignment.layer.opacity = alignment_dragging_opacity;
}

- (void) makeNormalAlignmentMF
{
	mf_alignment.layer.opacity = alignment_normal_opacity;
}

- (void) resetCenterOfAlignmentMF
{
	mf_alignment.center = mf_alignment_initial_center;
}

// WB

- (void) showAlignmentWB
{
	wb_alignment.hidden = NO;
}
- (void) hideAlignmentWB
{
	wb_alignment.hidden = YES;
}

- (void) makeDraggingAlignmentWB
{
	wb_alignment.layer.opacity = alignment_dragging_opacity;
}

- (void) makeNormalAlignmentWB
{
	wb_alignment.layer.opacity = alignment_normal_opacity;
}

- (void) resetCenterOfAlignmentWB
{
	wb_alignment.center = wb_alignment_initial_center;
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	// setup button
	
	gearMEButton = [[GearMEButton alloc] initWithFrame:CGRectMake(262, 8, 54, 30)];
	gearMFButton = [[GearMFButton alloc] initWithFrame:CGRectMake(262, 38+20, 54, 30)];
	gearWBButton = [[GearWBButton alloc] initWithFrame:CGRectMake(262, 38+20+30+20, 54, 30)];
	gearLPButton = [[GearLPButton alloc] initWithFrame:CGRectMake(262, 38+20+30+20+30+20, 54, 30)];
	gearLMButton = [[GearLMButton alloc] initWithFrame:CGRectMake(262, 38+20+30+20+30+20+30+20, 54, 30)];
	
	[self addSubview:gearMEButton];
	[self addSubview:gearMFButton];
	[self addSubview:gearWBButton];
	[self addSubview:gearLPButton];
	[self addSubview:gearLMButton];
	
	// setup alignment
	
	me_alignment_initial_center = CGPointMake( [DeviceConfig previewDisplayWidth]/2, [DeviceConfig previewDisplayHeight]/2 - 64 - 10 );
	mf_alignment_initial_center = CGPointMake( [DeviceConfig previewDisplayWidth]/2, [DeviceConfig previewDisplayHeight]/2 );
	wb_alignment_initial_center = CGPointMake( [DeviceConfig previewDisplayWidth]/2, [DeviceConfig previewDisplayHeight]/2 + 64 + 10 );
	
    // alignment (manual exposure : red)
	me_alignment = [[GearAlignmentME alloc] initAlignment];
    me_alignment.center = me_alignment_initial_center;
    me_alignment.hidden = YES;
	me_alignment.layer.opacity = alignment_init_opacity;
    [self addSubview:me_alignment];
	
    // alignment (manual focus : green)
    mf_alignment = [[GearAlignmentMF alloc] initAlignment];
    mf_alignment.center = mf_alignment_initial_center;
    mf_alignment.hidden = YES;
	mf_alignment.layer.opacity = alignment_init_opacity;
    [self addSubview:mf_alignment];
	
	// alignment (manual white balance : blue)
    wb_alignment = [[GearAlignmentWB alloc] initAlignment];
    wb_alignment.center = wb_alignment_initial_center;
    wb_alignment.hidden = YES;
	wb_alignment.layer.opacity = alignment_init_opacity;
    [self addSubview:wb_alignment];
	
	sharedInstance = self;
	
	return self;
}

#pragma mark
#pragma mark === phseudo singleton interface ===
#pragma mark

+ (id) quickInstance
{
    return sharedInstance;
}

@end
