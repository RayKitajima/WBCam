
#import "WhiteBalanceProcessorNOP.h"

@implementation WhiteBalanceProcessorNOP

- (void) processBitmapBGRA:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers reducedPixelNumber:(int)reducedPixelNumber
{
	__asm__ volatile (
					  //"mov r0, #0 \n\t" // pixel count
					  // buffer
					  //"mov r1, #0 \n\t" // pixel loader 1
					  //"mov r2, #0 \n\t" // pixel loader 2
					  
					  "mov r3, #0 \n\t"              // pixel number (offsets for pixelBuffer)  ---> d0[0]
					  "mov r4, %[pixelBuffer] \n\t"  // pointer for the input array             ---> d0[1]
					  "mov r5, %[reducer] \n\t"      // pointer for the output array            ---> d1[0]
					  "mov r6, %[pixelNumbers] \n\t" // pointer for the pixel numbers array     ---> d1[1]
					  
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
					  "vtrn.8 q1, q2 \n\t"  // q1(rgbargba...),q2(rgbargba...) -> q1(rrbbrrbb...),q2(ggaaggaa...)
					  "vtrn.8 q3, q4 \n\t"  // q3(rgbargba...),q4(rgbargba...) -> q3(rrbbrrbb...),q4(ggaaggaa...)
					  
					  // Vector Transpose step.2, deinterleaved in q1-q4
					  "vtrn.16 q1, q3 \n\t" // q1(rrbbrrbb...),q3(rrbbrrbb...) -> q1(rrrrrrrr...),q2(bbbbbbbb...)
					  "vtrn.16 q2, q4 \n\t" // q2(ggaaggaa...),q4(ggaaggaa...) -> q2(gggggggg...),q4(aaaaaaaa...)
					  
					  // vector ready:
					  // r:q1{d2,d3}, g;q2{d4,d5}, b:q3{d6,d7}, a:q4{d8,d9}
					  
					  // ********************************************************************************
					  
					  // writeout to main memory (interleaved)
					  "vst4.8 {d2,d4,d6,d8}, [r5]! \n\t"
					  "vst4.8 {d3,d5,d7,d9}, [r5]! \n\t"
					  
					  "subs r0, r0, #64 \n\t" // count down loop count (=lines element)
					  "bne 1b \n\t"           // back to the loop label
					  
					  : [reducer] "+r" (reducer)
					  : [pixelBuffer] "r" (pixelBuffer), [pixelNumbers] "r" (pixelNumbers), [pixelCount] "r" (reducedPixelNumber)
					  : "r0", "r1", "r2", "r3", "r4", "r5", "r6" //, "q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"
					  );
	
	//NSLog(@"asm done");
	
}

- (void) processBitmapBGRA_orig:(unsigned char *)pixelBuffer reducer:(unsigned char *)reducer pixelNumber:(int *)pixelNumbers reducedPixelNumber:(int)reducedPixelNumber
{
	__asm__ volatile (
					  //"mov r0, #0 \n\t" // pixel count
					  // buffer
					  //"mov r1, #0 \n\t" // pixel loader 1
					  //"mov r2, #0 \n\t" // pixel loader 2
					  
					  "mov r3, #0 \n\t"             // pixel number (offsets for pixelBuffer)
					  "mov r4, %[pixelBuffer] \n\t" // pointer for the input array
					  "mov r5, %[reducer] \n\t"     // pointer for the output array
					  "mov r6, %[pixelNumbers] \n\t"       // pointer for the pixel numbers array
					  
					  "mov r0, %[pixelCount] \n\t" // pixel count used for loop count (=REDUCED_PIXELS)
					  
					  "ldr r3, [r6], #4 \n\t" // load the first pixel number (=0)
					  
					  // ********************************************************************************
					  
					  "1: \n\t" // loop jump is failed, if the 3 pixel loading block was defined. --> sub routine w/ buffer q16
					  
					  // lane 1 : q1{d2-d3}
					  // load 4 pixels into arm registers
					  "ldr r1, [r4, r3] \n\t" // pixel(1)  ; r4:input, r3:pixel number, load as word(32bit=4pixel)
					  "ldr r3, [r6], #4 \n\t" // load next pixel number(=offset) into r3
					  "ldr r2, [r4, r3] \n\t" // pixel(2)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d2, r1, r2  \n\t"
					  "ldr r1, [r4, r3] \n\t" // pixel(3)
					  "ldr r3, [r6], #4 \n\t"
					  "ldr r2, [r4, r3] \n\t" // pixel(4)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d3, r1, r2  \n\t"
					  
					  // lane 2 : q2{d4-d5}
					  // load 4 pixels into arm registers
					  "ldr r1, [r4, r3] \n\t" // pixel(1)  ; r4:input, r3:pixel number
					  "ldr r3, [r6], #4 \n\t" // load next pixel number(=offset) into r3
					  "ldr r2, [r4, r3] \n\t" // pixel(2)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d4, r1, r2  \n\t"
					  "ldr r1, [r4, r3] \n\t" // pixel(3)
					  "ldr r3, [r6], #4 \n\t"
					  "ldr r2, [r4, r3] \n\t" // pixel(4)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d5, r1, r2  \n\t"
					  
					  // lane 3 : q3{d6-d7}
					  // load 4 pixels into arm registers (r1-r4)
					  "ldr r1, [r4, r3] \n\t" // pixel(1)  ; r4:input, r3:pixel number
					  "ldr r3, [r6], #4 \n\t" // load next pixel number(=offset) into r3
					  "ldr r2, [r4, r3] \n\t" // pixel(2)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d6, r1, r2  \n\t"
					  "ldr r1, [r4, r3] \n\t" // pixel(3)
					  "ldr r3, [r6], #4 \n\t"
					  "ldr r2, [r4, r3] \n\t" // pixel(4)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d7, r1, r2  \n\t"
					  
					  // lane 4 : q4{d8-d9}
					  // load 4 pixels into arm registers (r1-r4)
					  "ldr r1, [r4, r3] \n\t" // pixel(1)  ; r4:input, r3:pixel number
					  "ldr r3, [r6], #4 \n\t" // load next pixel number(=offset) into r3
					  "ldr r2, [r4, r3] \n\t" // pixel(2)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d8, r1, r2  \n\t"
					  "ldr r1, [r4, r3] \n\t" // pixel(3)
					  "ldr r3, [r6], #4 \n\t"
					  "ldr r2, [r4, r3] \n\t" // pixel(4)
					  "ldr r3, [r6], #4 \n\t"
					  "vmov d9, r1, r2  \n\t"
					  
					  // Vector Transpose step.1
					  "vtrn.8 q1, q2 \n\t"  // q1(rgbargba...),q2(rgbargba...) -> q1(rrbbrrbb...),q2(ggaaggaa...)
					  "vtrn.8 q3, q4 \n\t"  // q3(rgbargba...),q4(rgbargba...) -> q3(rrbbrrbb...),q4(ggaaggaa...)
					  
					  // Vector Transpose step.2, deinterleaved in q1-q4
					  "vtrn.16 q1, q3 \n\t" // q1(rrbbrrbb...),q3(rrbbrrbb...) -> q1(rrrrrrrr...),q2(bbbbbbbb...)
					  "vtrn.16 q2, q4 \n\t" // q2(ggaaggaa...),q4(ggaaggaa...) -> q2(gggggggg...),q4(aaaaaaaa...)
					  
					  // vector ready:
					  // r:q1{d2,d3}, g;q2{d4,d5}, b:q3{d6,d7}, a:q4{d8,d9}
					  
					  // ********************************************************************************
					  
					  // writeout to main memory (interleaved)
					  "vst4.8 {d2,d4,d6,d8}, [r5]! \n\t"
					  "vst4.8 {d3,d5,d7,d9}, [r5]! \n\t"
					  
					  "subs r0, r0, #64 \n\t" // count down loop count (=lines element)
					  "bne 1b \n\t"           // back to the loop label
					  
					  : [reducer] "+r" (reducer)
					  : [pixelBuffer] "r" (pixelBuffer), [pixelNumbers] "r" (pixelNumbers), [pixelCount] "r" (reducedPixelNumber)
					  : "r0", "r1", "r2", "r3", "r4", "r5", "r6" //, "q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"
					  );
	
	//NSLog(@"asm done");
	
}

@end
