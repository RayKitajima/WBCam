
#import "WhiteBalanceProcessorMMM.h"


@implementation WhiteBalanceProcessorMMM

// MMM
- (void) processAPixel:(int *)pixel whitebalanceParameter:(int *)wbp
{
    int B = pixel[0];
    int G = pixel[1];
    int R = pixel[2];
    int newB = B - (int)( ( B * wbp[0] ) / 256 );
    int newG = G - (int)( ( G * wbp[1] ) / 256 );
    int newR = R - (int)( ( R * wbp[2] ) / 256 );
    pixel[0] = newB;
    pixel[1] = newG;
    pixel[2] = newR;
    [self normalizePixel:pixel];
}

// 
// BGRA processor
// input:BGRA output:BGRA
// 
- (void) processBitmapBGRA:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers whitebalanceParameter:(int *)wbp reducedPixelNumber:(int)reducedPixelNumber
{
	__asm__ volatile (
					  //"mov r0, #0 \n\t" // pixel count
					  // buffer
					  //"mov r1, #0 \n\t" // pixel loader 1
					  //"mov r2, #0 \n\t" // pixel loader 2
					  
					  // load rgba params from memory
					  "ldr r3, [%[wbp]    ] \n\t" // Bp:wbp[0]
					  "ldr r4, [%[wbp], #4] \n\t" // Gp:wbp[1]
					  "ldr r5, [%[wbp], #8] \n\t" // Rp:wbp[2]
					  "mov r6, #0           \n\t" // Ap:dummy
					  
					  // laod rgba params into neon : q14{d28:Bp,d29:Gp}, q15{d30:Rp,d31:Ap}
					  "vdup.8 d28, r3 \n\t"
					  "vdup.8 d29, r4 \n\t"
					  "vdup.8 d30, r5 \n\t"
					  "vdup.8 d31, r6 \n\t"
					  
					  "mov r3, #0 \n\t"              // pixel number (offsets for pixelBuffer)
					  "mov r4, %[pixelBuffer] \n\t"  // pointer for the input array
					  "mov r5, %[reducer] \n\t"      // pointer for the output array
					  "mov r6, %[pixelNumbers] \n\t" // pointer for the pixel numbers array
					  
					  "mov r0, %[pixelCount] \n\t" // pixel count used for loop count (=REDUCED_PIXELS)
					  
					  "ldr r3, [r6], #4 \n\t" // load the first pixel number (=0)
					  
					  // ********************************************************************************
					  
					  "1: \n\t" // loop jump is failed, if the 3 pixel loading block was defined. --> sub routine w/ buffer q16
					  
					  // lane 1 : q1{ d2{s4,d5}, d3{s6,s7} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s4, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s5, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s6, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s7, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // lane 2 : q2{ d4{s8,s9}, d5{s10,s11} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s8, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s9, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s10, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s11, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // lane 3 : q3{ d6{s12,s13}, d7{s14,s15} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s12, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s13, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s14, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s15, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // lane 4 : q4{ d8{s16,s17}, d9{s18,s19} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s16, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s17, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s18, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s19, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // Vector Transpose step.1
					  "vtrn.8 q1, q2 \n\t"  // q1(bgrabgra...),q2(bgrabgra...) -> q1(bbrrbbrr...),q2(ggaaggaa...)
					  "vtrn.8 q3, q4 \n\t"  // q3(bgrabgra...),q4(bgrabgra...) -> q3(bbrrbbrr...),q4(ggaaggaa...)
					  
					  // Vector Transpose step.2, deinterleaved in q1-q4
					  "vtrn.16 q1, q3 \n\t" // q1(bbrrbbrr...),q3(bbrrbbrr...) -> q1(bbbbbbbb...),q3(rrrrrrrr...)
					  "vtrn.16 q2, q4 \n\t" // q2(ggaaggaa...),q4(ggaaggaa...) -> q2(gggggggg...),q4(aaaaaaaa...)
					  
					  // vector ready:
					  // b:q1{d2,d3}, g;q2{d4,d5}, r:q3{d6,d7}, a:q4{d8,d9}
					  
					  // ********************************************************************************
					  
					  // rgba params : q14{ d28:Bp, d29:Gp }, q15{ d30:Rp, d31:Ap }
					  "vmull.u8  q5, d2, d28 \n\t" // q5{d10,d11} [B]
					  "vmull.u8  q6, d3, d28 \n\t" // q6{d12,d13}
					  "vmull.u8  q7, d4, d29 \n\t" // q7{d14,d15} [G]
					  "vmull.u8  q8, d5, d29 \n\t" // q8{d16,d17}
					  "vmull.u8  q9, d6, d30 \n\t" // q9{d18,d19} [R]
					  "vmull.u8 q10, d7, d30 \n\t" // q10{d20,d21}
					  
					  "vrshr.u16  q5,  q5, #8 \n\t" // q5 [B]
					  "vrshr.u16  q6,  q6, #8 \n\t" // q6
					  "vrshr.u16  q7,  q7, #8 \n\t" // q7 [G]
					  "vrshr.u16  q8,  q8, #8 \n\t" // q8
					  "vrshr.u16  q9,  q9, #8 \n\t" // q9 [R]
					  "vrshr.u16 q10, q10, #8 \n\t" // q10
					  
                      // Vector Saturating Shift Right, Narrow takes each element in a quadword vector of integers,
                      // right shifts them by an immediate value, and places the truncated results in a doubleword vector.
                      //                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
					  "vqshrn.u16 d22,  q5, #0 \n\t" // q11{d22,d23}
					  "vqshrn.u16 d23,  q6, #0 \n\t" // 
					  "vqshrn.u16 d24,  q7, #0 \n\t" // q12{d24,d25}
					  "vqshrn.u16 d25,  q8, #0 \n\t" // 
					  "vqshrn.u16 d26,  q9, #0 \n\t" // q13{d26,d27}
					  "vqshrn.u16 d27, q10, #0 \n\t" // 
					  
					  "vqsub.u8 q1, q1, q11 \n\t" // q1{d2,d3} : minus : [B]
					  "vqsub.u8 q2, q2, q12 \n\t" // q2{d4,d5} : minus : [G]
					  "vqsub.u8 q3, q3, q13 \n\t" // q3{d6,d7} : minus : [R]
					  
					  // writeout to main memory (interleaved)
					  "vst4.8 {d2,d4,d6,d8}, [r5]! \n\t"
					  "vst4.8 {d3,d5,d7,d9}, [r5]! \n\t"
					  
					  "subs r0, r0, #64 \n\t" // count down loop count (=lines element)
					  "bne 1b \n\t"           // back to the loop label
					  
					  : [reducer] "+r" (reducer)
					  : [pixelBuffer] "r" (pixelBuffer), [pixelNumbers] "r" (pixelNumbers), [pixelCount] "r" (reducedPixelNumber), [wbp] "r" (wbp)
					  : "r0", "r1", "r2", "r3", "r4", "r5", "r6" , "q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"
					  );
	
	//NSLog(@"asm done");
	
}

// 
// RGBA processor
// input:RGBA output:BGRA
// 
- (void) processBitmapRGBA:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers whitebalanceParameter:(int *)wbp reducedPixelNumber:(int)reducedPixelNumber
{
	__asm__ volatile (
					  //"mov r0, #0 \n\t" // pixel count
					  // buffer
					  //"mov r1, #0 \n\t" // pixel loader 1
					  //"mov r2, #0 \n\t" // pixel loader 2
					  
					  // load rgba params from memory
					  "ldr r3, [%[wbp]    ] \n\t" // Bp:wbp[0]
					  "ldr r4, [%[wbp], #4] \n\t" // Gp:wbp[1]
					  "ldr r5, [%[wbp], #8] \n\t" // Rp:wbp[2]
					  "mov r6, #0           \n\t" // Ap:dummy
					  
					  // laod rgba params into neon : q14{d28:Bp,d29:Gp}, q15{d30:Rp,d31:Ap}
					  "vdup.8 d28, r3 \n\t"
					  "vdup.8 d29, r4 \n\t"
					  "vdup.8 d30, r5 \n\t"
					  "vdup.8 d31, r6 \n\t"
					  
					  "mov r3, #0 \n\t"              // pixel number (offsets for pixelBuffer)
					  "mov r4, %[pixelBuffer] \n\t"  // pointer for the input array
					  "mov r5, %[reducer] \n\t"      // pointer for the output array
					  "mov r6, %[pixelNumbers] \n\t" // pointer for the pixel numbers array
					  
					  "mov r0, %[pixelCount] \n\t" // pixel count used for loop count (=REDUCED_PIXELS)
					  
					  "ldr r3, [r6], #4 \n\t" // load the first pixel number (=0)
					  
					  // ********************************************************************************
					  
					  "1: \n\t" // loop jump is failed, if the 3 pixel loading block was defined. --> sub routine w/ buffer q16
					  
					  // lane 1 : q1{ d2{s4,d5}, d3{s6,s7} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s4, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s5, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s6, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s7, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // lane 2 : q2{ d4{s8,s9}, d5{s10,s11} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s8, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s9, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s10, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s11, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // lane 3 : q3{ d6{s12,s13}, d7{s14,s15} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s12, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s13, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s14, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s15, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // lane 4 : q4{ d8{s16,s17}, d9{s18,s19} }
					  // pixel (1)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s16, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (2)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s17, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (3)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s18, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  // pixel (4)
					  "add r1, r4, r3 \n\t"
					  "vldr.32 s19, [r1] \n\t"
					  "ldr r3, [r6], #4 \n\t"
					  
					  // Vector Transpose step.1
					  "vtrn.8 q1, q2 \n\t"  // q1(bgrabgra...),q2(bgrabgra...) -> q1(bbrrbbrr...),q2(ggaaggaa...)
					  "vtrn.8 q3, q4 \n\t"  // q3(bgrabgra...),q4(bgrabgra...) -> q3(bbrrbbrr...),q4(ggaaggaa...)
					  
					  // Vector Transpose step.2, deinterleaved in q1-q4
					  "vtrn.16 q1, q3 \n\t" // q1(bbrrbbrr...),q3(bbrrbbrr...) -> q1(bbbbbbbb...),q3(rrrrrrrr...)
					  "vtrn.16 q2, q4 \n\t" // q2(ggaaggaa...),q4(ggaaggaa...) -> q2(gggggggg...),q4(aaaaaaaa...)
					  
					  // vector aligned,
                      // but the input is RGBA
					  // actual align is r:q1{d2,d3}, g;q2{d4,d5}, b:q3{d6,d7}, a:q4{d8,d9}
					  
                      // swap R:q1,B:q3
                      "vmov q5, q1 \n\t"
                      "vmov q1, q3 \n\t"
                      "vmov q3, q5 \n\t"
                      
                      // vector ready:
					  // b:q1{d2,d3}, g;q2{d4,d5}, r:q3{d6,d7}, a:q4{d8,d9}
                      
                      // now the data is BGRA, same as BGRA processor implementation
					  
					  // ********************************************************************************
					  
					  // rgba params : q14{ d28:Bp, d29:Gp }, q15{ d30:Rp, d31:Ap }
					  "vmull.u8  q5, d2, d28 \n\t" // q5{d10,d11} [B]
					  "vmull.u8  q6, d3, d28 \n\t" // q6{d12,d13}
					  "vmull.u8  q7, d4, d29 \n\t" // q7{d14,d15} [G]
					  "vmull.u8  q8, d5, d29 \n\t" // q8{d16,d17}
					  "vmull.u8  q9, d6, d30 \n\t" // q9{d18,d19} [R]
					  "vmull.u8 q10, d7, d30 \n\t" // q10{d20,d21}
					  
					  "vrshr.u16  q5,  q5, #8 \n\t" // q5 [B]
					  "vrshr.u16  q6,  q6, #8 \n\t" // q6
					  "vrshr.u16  q7,  q7, #8 \n\t" // q7 [G]
					  "vrshr.u16  q8,  q8, #8 \n\t" // q8
					  "vrshr.u16  q9,  q9, #8 \n\t" // q9 [R]
					  "vrshr.u16 q10, q10, #8 \n\t" // q10
					  
                      // Vector Saturating Shift Right, Narrow takes each element in a quadword vector of integers,
                      // right shifts them by an immediate value, and places the truncated results in a doubleword vector.
                      //                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
					  "vqshrn.u16 d22,  q5, #0 \n\t" // q11{d22,d23}
					  "vqshrn.u16 d23,  q6, #0 \n\t" // 
					  "vqshrn.u16 d24,  q7, #0 \n\t" // q12{d24,d25}
					  "vqshrn.u16 d25,  q8, #0 \n\t" // 
					  "vqshrn.u16 d26,  q9, #0 \n\t" // q13{d26,d27}
					  "vqshrn.u16 d27, q10, #0 \n\t" // 
					  
					  "vqsub.u8 q1, q1, q11 \n\t" // q1{d2,d3} : minus : [B]
					  "vqsub.u8 q2, q2, q12 \n\t" // q2{d4,d5} : minus : [G]
					  "vqsub.u8 q3, q3, q13 \n\t" // q3{d6,d7} : minus : [R]
					  
					  // writeout to main memory (interleaved)
					  "vst4.8 {d2,d4,d6,d8}, [r5]! \n\t"
					  "vst4.8 {d3,d5,d7,d9}, [r5]! \n\t"
					  
					  "subs r0, r0, #64 \n\t" // count down loop count (=lines element)
					  "bne 1b \n\t"           // back to the loop label
					  
					  : [reducer] "+r" (reducer)
					  : [pixelBuffer] "r" (pixelBuffer), [pixelNumbers] "r" (pixelNumbers), [pixelCount] "r" (reducedPixelNumber), [wbp] "r" (wbp)
					  : "r0", "r1", "r2", "r3", "r4", "r5", "r6" , "q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"
					  );
	
	//NSLog(@"asm done");
	
}

@end
