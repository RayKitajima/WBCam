
#import <Foundation/Foundation.h>
#import "AlbumActionCenter.h"

typedef void (^ProgressBlock)();

@interface AlbumUtility : NSObject
{
    NSLocale *locale;
    NSDateFormatter *formatter_in;
    NSDateFormatter *formatter_out;
    NSDateFormatter *formatter_iso;
    
    // supporting copy to camera roll
    ALAssetsLibrary *aLAssetsLibrary;
    BOOL isCopyingThumbsToCameraRoll;
    int currentCopyToCameraRollIndex;
    NSArray *currentCopyToCameraRollThumbs;
    ProgressBlock currentCopyToCameraRollProgressBlock;
}
@property (retain) NSDateFormatter *formatter_in;
@property (retain) NSDateFormatter *formatter_out;
@property (retain) NSDateFormatter *formatter_iso;
@property (retain) ALAssetsLibrary *aLAssetsLibrary;
@property (retain) NSArray *currentCopyToCameraRollThumbs;
@property int currentCopyToCameraRollIndex;
@property BOOL isCopyingThumbsToCameraRoll;
@property (readwrite,copy) ProgressBlock currentCopyToCameraRollProgressBlock;

+ (CGAffineTransform) CGAffineTransformForALAssetOrientation:(ALAssetOrientation)orientation;

- (void) execCopyThumbToCameraRoll; // instance method
+ (void) copyPhotosToCameraRoll:(NSArray *)thumbs withProgressBar:(AlbumActionCopyToCameraRollProgressBar *)progress withProgressBlock:(void (^)(void))progressBlock;

+ (NSString *) folderNameForTodaysPhoto;
+ (BOOL) isIsoDay:(NSString *)iso_day;
+ (void) ensureAlbumDateFolders:(NSString *)iso_day;
+ (void) ensureTrashDateFolder:(NSString *)iso_day;
+ (NSString *) pathOfTrashDateFolder:(NSString *)iso_day;
+ (void) emptyTrashFolder;
+ (NSString *) currentUnixtimeAsString;
+ (void) removeDayFolder:(NSString *)iso_day;

+ (NSString *) isoStyleToday;
+ (NSString *) localizedDayStringForIsoDay:(NSString *)iso_day;

@end
