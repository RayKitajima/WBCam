
#import <Foundation/Foundation.h>

@interface ApplicationUtility : NSObject
{
    
}
extern inline CGImageRef CreateCGImageFromBitmap(unsigned char *bitmap, int width, int height);
extern inline void ArrangePixelNumbersForNeon(int *inArray, int *outArray, int length);

@end
