
@interface WhiteBalanceProcessorNOP : NSObject {
}

- (void) processBitmapBGRA:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers reducedPixelNumber:(int)reducedPixelNumber;

@end
