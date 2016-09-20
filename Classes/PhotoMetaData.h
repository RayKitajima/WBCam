
#import <Foundation/Foundation.h>

@interface PhotoMetaData : NSObject <NSCoding>
{
    NSString *iso_day;
    NSString *file_name;
    NSString *photo_orientation; // string expression of ALAssetOrientation
    NSString *comment;
    NSMutableDictionary *meta; // raw metadata from device for exif
}
@property (retain) NSString *iso_day;
@property (retain) NSString *file_name;
@property (retain) NSString *photo_orientation;
@property (retain) NSString *comment;
@property (retain) NSMutableDictionary *meta;

@end
