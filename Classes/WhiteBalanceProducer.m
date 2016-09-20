
#import "WhiteBalanceProducer.h"
#import "WhiteBalanceProcessorPPP.h"
#import "WhiteBalanceProcessorPPM.h"
#import "WhiteBalanceProcessorPMM.h"
#import "WhiteBalanceProcessorPMP.h"
#import "WhiteBalanceProcessorMMM.h"
#import "WhiteBalanceProcessorMMP.h"
#import "WhiteBalanceProcessorMPP.h"
#import "WhiteBalanceProcessorMPM.h"

@implementation WhiteBalanceProducer
@synthesize currentWhiteBalanceProcessor;

static WhiteBalanceProducer *sharedInstance = nil;

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
	self = [super init];
    
    // default processor
    self.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorPPP alloc] init];
    
	return self;
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

+ (id) sharedInstance
{
    @synchronized(self){
		if( !sharedInstance ){
			sharedInstance = [[WhiteBalanceProducer alloc] init];
		}
	}
    return sharedInstance;
}

// usage:
//     
//     WhiteBalanceProcessorDef *processor = [WhiteBalanceProducer getCurrentWhiteBalanceProcessorForParam:wbp];
//     [processor processBitmapBGRA:pixelBuffer ...];
//     
+ (WhiteBalanceProcessorDef *) getCurrentWhiteBalanceProcessorForParam:(int *)wbp
{
    WhiteBalanceProducer *instance = [self sharedInstance];
    
    // BGR plus/minus
    
    // PPP
    if( wbp[0] >= 0 && wbp[1] >= 0 && wbp[2] >= 0 )
    {
//        NSLog(@"PPP mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorPPP alloc] init];
    }
    // PPM
    else if( wbp[0] >= 0 && wbp[1] >= 0 && wbp[2] < 0 ){
//        NSLog(@"PPM mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorPPM alloc] init];
    }
    // PMM
    else if( wbp[0] >= 0 && wbp[1] < 0 && wbp[2] < 0 ){
//        NSLog(@"PMM mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorPMM alloc] init];
    }
    // PMP
    else if( wbp[0] >= 0 && wbp[1] < 0 && wbp[2] >= 0 ){
//        NSLog(@"PMP mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorPMP alloc] init];
    }
    // MMM
    else if( wbp[0] < 0 && wbp[1] < 0 && wbp[2] < 0 ){
//        NSLog(@"MMM mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorMMM alloc] init];
    }
    // MMP
    else if( wbp[0] < 0 && wbp[1] < 0 && wbp[2] >= 0 ){
//        NSLog(@"MMP mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorMMP alloc] init];
    }
    // MPP
    else if( wbp[0] < 0 && wbp[1] >= 0 && wbp[2] >= 0 ){
//        NSLog(@"MPP mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorMPP alloc] init];
    }
    // MPM
    else if( wbp[0] < 0 && wbp[1] >= 0 && wbp[2] < 0 ){
//        NSLog(@"MPM mode:");
        instance.currentWhiteBalanceProcessor = [[WhiteBalanceProcessorMPM alloc] init];
    }
    
    return instance.currentWhiteBalanceProcessor;
}

+ (WhiteBalanceProcessorDef *) getCurrentWhiteBalanceProcessor
{
    WhiteBalanceProducer *instance = [self sharedInstance];
    return instance.currentWhiteBalanceProcessor;
}

@end
