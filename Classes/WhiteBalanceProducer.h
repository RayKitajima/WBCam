
#import <Foundation/Foundation.h>
#import "WhiteBalanceProcessorDef.h"

@interface WhiteBalanceProducer : NSObject {
    WhiteBalanceProcessorDef *currentWhiteBalanceProcessor;
}

@property (retain) WhiteBalanceProcessorDef *currentWhiteBalanceProcessor;

+ (WhiteBalanceProcessorDef *) getCurrentWhiteBalanceProcessorForParam:(int *)wbp;
+ (WhiteBalanceProcessorDef *) getCurrentWhiteBalanceProcessor;

@end
