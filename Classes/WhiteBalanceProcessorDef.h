
#import <Foundation/Foundation.h>


@interface WhiteBalanceProcessorDef : NSObject {
}

- (void) normalizePixel:(int *)pixel;

// pixel is input,output
// wbp requires absolute values
- (void) processAPixel:(int *)pixel whitebalanceParameter:(int *)wbp;

- (void) processBitmapBGRA:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers whitebalanceParameter:(int *)wbp reducedPixelNumber:(int)reducedPixelNumber;

- (void) processBitmapRGBA:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers whitebalanceParameter:(int *)wbp reducedPixelNumber:(int)reducedPixelNumber;

@end
