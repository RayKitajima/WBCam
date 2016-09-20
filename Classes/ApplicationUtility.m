
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ApplicationUtility.h"

@implementation ApplicationUtility

extern inline CGImageRef CreateCGImageFromBitmap(unsigned char *bitmap, int width, int height)
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef context = CGBitmapContextCreate(bitmap, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	
	CGImageRef cgimage = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	return cgimage;
}

// pre-order pixelNumbers for neon
extern inline void ArrangePixelNumbersForNeon(int *inArray, int *outArray, int length)
{
	for( int i = 0; i < length; i+=16 )
	{
		outArray[i+0]  = inArray[i+0];
		outArray[i+4]  = inArray[i+1];
		outArray[i+8]  = inArray[i+2];
		outArray[i+12] = inArray[i+3];
		outArray[i+1]  = inArray[i+4];
		outArray[i+5]  = inArray[i+5];
		outArray[i+9]  = inArray[i+6];
		outArray[i+13] = inArray[i+7];
		outArray[i+2]  = inArray[i+8];
		outArray[i+6]  = inArray[i+9];
		outArray[i+10] = inArray[i+10];
		outArray[i+14] = inArray[i+11];
		outArray[i+3]  = inArray[i+12];
		outArray[i+7]  = inArray[i+13];
		outArray[i+11] = inArray[i+14];
		outArray[i+15] = inArray[i+15];
	}
}

@end
