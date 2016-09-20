
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "AlbumUtility.h"
#import "CameraUtility.h"
#import "PhotoMetaData.h"
#import "AlbumThumbnailView.h"

@interface AlbumUtility(Private)
- (NSDate *) makeNSDateForIsoStyleDay:(NSString *)iso_day;
- (NSString *) localizedDayStringForDate:(NSDate *)date;
- (id) initWithLocale:(NSLocale *)user_locale;
+ (id) sharedInstance;
- (NSString *) localizedDayStringForIsoDay:(NSString *)iso_day;
@end

@implementation AlbumUtility
@synthesize formatter_in, formatter_out, formatter_iso;
@synthesize aLAssetsLibrary, isCopyingThumbsToCameraRoll;
@synthesize currentCopyToCameraRollThumbs, currentCopyToCameraRollIndex;
@synthesize currentCopyToCameraRollProgressBlock;
static AlbumUtility *albumUtilityInstance = nil;

#pragma mark
#pragma mark === orientation tool ===
#pragma mark

// 
// deprecated, 
// snap image will be immediately converted to appropriate orientation with wb processing.
// so, this method is no longer used.
// 
+ (CGAffineTransform) CGAffineTransformForALAssetOrientation:(ALAssetOrientation)orientation
{
    // 
    // Device and object orientation
    // 
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // :                                                                 :                          :
    // : +---------+   +---------+   +----------+---+   +---+----------+ :                          :
    // : |         |   |    O    |   |          |   |   |   |          | :                          :
    // : |         |   +---------+   |          |   |   |   |          | :                          :
    // : |    1    |   |         |   |     3    | O |   | O |    4     | :                          :
    // : |         |   |         |   |          |   |   |   |          | :       device/obj         :
    // : |         |   |    2    |   |          |   |   |   |          | :                          :
    // : +---------+   |         |   +----------+---+   +---+----------+ :                          :
    // : |    O    |   |         |                                       :                          :
    // : +---------+   +---------+                                       :                          :
    // :                                                                 :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Portrate      Portrate      LandscapeRight     LandscapeLeft    : UIInterfaceOrientation   :
    // :                 UpsideDown                                      :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Up(def)       Down          Left               Right            : ALAssetOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Right         Left          Up                 Down             : UIImageOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // 
    // 
    // + - - - - - - - - - - - - + - - - +
    // : current                 : angle :
    // + - - - - - - - - - - - - + - - - +
    // : (1) Portrait            :     0 :
    // + - - - - - - - - - - - - + - - - +
    // : (2) PortraitUpsideDown  :   180 :
    // + - - - - - - - - - - - - + - - - +
    // : (3) LandscapeRight      :   -90 :
    // + - - - - - - - - - - - - + - - - +
    // : (4) LandscapeLeft       :    90 :
    // + - - - - - - - - - - - - + - - - +
    // 
    // 
    CGFloat angle;
    if( orientation == ALAssetOrientationUp )
    {
        // 1
        angle = 0.0f;
        //NSLog(@"cam rotated: (1)");
    }
    else if( orientation == ALAssetOrientationDown )
    {
        // 2
        angle = 180.0f;
        //NSLog(@"cam rotated: (2)");
    }
    else if( orientation == ALAssetOrientationLeft )
    {
        // 3
        angle = -90.0f;
        //NSLog(@"cam rotated: (3)");
    }
    else if( orientation == ALAssetOrientationRight )
    {
        // 4
        angle = 90.0f;
        //NSLog(@"cam rotated: (4)");
    }
    else
    {
        // error
        angle = 0.0f;
        //NSLog(@"# rotated unknown orientation");
    }
    
    return CGAffineTransformMakeRotation( angle * (M_PI/180.0f) );
}

#pragma mark
#pragma mark === service ===
#pragma mark

// album action

- (void) execCopyThumbToCameraRoll
{
    ALAssetsLibraryWriteImageCompletionBlock stepBlock = ^(NSURL *assetURL, NSError *error){
        
        // exec progress block
        currentCopyToCameraRollProgressBlock();
        
        // count up index
        currentCopyToCameraRollIndex++;
        
        // go next copy
        if( currentCopyToCameraRollIndex < currentCopyToCameraRollThumbs.count )
        {
            NSLog(@"# execCopyThumbToCameraRoll continue...");
            [self execCopyThumbToCameraRoll];
        }
        else
        {
            // reset
            currentCopyToCameraRollIndex = 0;
            currentCopyToCameraRollThumbs = nil;
            isCopyingThumbsToCameraRoll = NO;
            NSLog(@"# execCopyThumbToCameraRoll done.");
        }
    };
    
    AlbumThumbnailView *thumb = [currentCopyToCameraRollThumbs objectAtIndex:currentCopyToCameraRollIndex];
    NSData *photoData = [thumb photoData];
    PhotoMetaData *metaObj = [thumb metaObj];
    UIImage *loadedImage = [[UIImage alloc] initWithData:photoData];
    
    [aLAssetsLibrary writeImageToSavedPhotosAlbum:[loadedImage CGImage] metadata:metaObj.meta completionBlock:stepBlock];
}

+ (void) copyPhotosToCameraRoll:(NSArray *)thumbs withProgressBar:(AlbumActionCopyToCameraRollProgressBar *)progress withProgressBlock:(void (^)(void))progressBlock
{
    NSLog(@"*** copyPhotosToCameraRoll called");
    AlbumUtility *instance = [self sharedInstance];
    if( !instance.isCopyingThumbsToCameraRoll ){
        instance.isCopyingThumbsToCameraRoll = YES;
        instance.currentCopyToCameraRollIndex = 0;
        instance.currentCopyToCameraRollThumbs = thumbs;
        instance.currentCopyToCameraRollProgressBlock = progressBlock;
        [instance execCopyThumbToCameraRoll];
    }
}

// album view

+ (NSString *) currentUnixtimeAsString
{
    double unixtime = (double)[[NSDate date] timeIntervalSince1970];
    NSString *unixtime_str = [NSString stringWithFormat:@"%.0f",unixtime];
    return unixtime_str;
}

+ (NSString *) isoStyleToday
{
    AlbumUtility *instance = [self sharedInstance];
    
    NSDate *now = [NSDate date];
    
    NSLog(@"AlbumUtility.isoStyleToday() now:%@",now);
    
    //NSString *now_str = [now description]; // ex) 2011-07-17 22:42:55 +0900
    //NSArray *now_strs = [now_str componentsSeparatedByString:@" "];
    //NSString *iso_today = [now_strs objectAtIndex:0];
    
    NSString *iso_today = [instance.formatter_iso stringFromDate:now];
    
    NSLog(@"AlbumUtility.isoStyleToday() formatted iso:%@",iso_today);
    
    return iso_today;
}

// alias for isoStyleToday
+ (NSString *) folderNameForTodaysPhoto
{
    return [AlbumUtility isoStyleToday];
}

+ (BOOL) isIsoDay:(NSString *)iso_day
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d{4}\\-\\d{2}\\-\\d{2}$" options:0 error:&error];
    NSTextCheckingResult *matches = [regex firstMatchInString:iso_day options:0 range:NSMakeRange(0, iso_day.length)];
    BOOL matched = NO;
    if( matches ){
        matched = YES;
    }
    return matched;
}

// method user has responsibility for the empty of the target folder
+ (void) removeDayFolder:(NSString *)iso_day
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *dayPath = [docPath stringByAppendingPathComponent:iso_day];
    
    NSString *thumbPath = [dayPath stringByAppendingPathComponent:@"thumb"];
    NSString *previewPath = [dayPath stringByAppendingPathComponent:@"preview"];
    NSString *photoPath = [dayPath stringByAppendingPathComponent:@"photo"];
    NSString *metaPath = [dayPath stringByAppendingPathComponent:@"meta"];
    
    [fileManager removeItemAtPath:thumbPath error:NULL];
    [fileManager removeItemAtPath:previewPath error:NULL];
    [fileManager removeItemAtPath:photoPath error:NULL];
    [fileManager removeItemAtPath:metaPath error:NULL];
    
    [fileManager removeItemAtPath:dayPath error:NULL];
}

+ (void) ensureAlbumDateFolders:(NSString *)iso_day
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *docPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath   = [docPaths objectAtIndex:0];
    NSString *dir_today = [docPath stringByAppendingPathComponent:iso_day];
    
    NSString *dir_photo = [dir_today stringByAppendingPathComponent:@"photo"];
    NSString *dir_prev  = [dir_today stringByAppendingPathComponent:@"preview"];
    NSString *dir_thumb = [dir_today stringByAppendingPathComponent:@"thumb"];
    NSString *dir_meta  = [dir_today stringByAppendingPathComponent:@"meta"];
    
    if( ![fileManager fileExistsAtPath:dir_photo] ){
        [fileManager createDirectoryAtPath:dir_photo withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if( ![fileManager fileExistsAtPath:dir_prev] ){
        [fileManager createDirectoryAtPath:dir_prev withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if( ![fileManager fileExistsAtPath:dir_thumb] ){
        [fileManager createDirectoryAtPath:dir_thumb withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if( ![fileManager fileExistsAtPath:dir_meta] ){
        [fileManager createDirectoryAtPath:dir_meta withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

// 
// delete photo will be moved to ~/Documents/Trash/<iso-day>/<unixtime>.[jpg|meta]
// and then, later, actually deleted. (after 7days moved to the trash folder)
// 
+ (void) ensureTrashDateFolder:(NSString *)iso_day
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *docPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath   = [docPaths objectAtIndex:0];
    NSString *trashPath = [docPath stringByAppendingPathComponent:@"Trash"];
    
    NSString *trash_for_day = [trashPath stringByAppendingPathComponent:iso_day];
    
    if( ![fileManager fileExistsAtPath:trash_for_day] ){
        [fileManager createDirectoryAtPath:trash_for_day withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

+ (NSString *) pathOfTrashDateFolder:(NSString *)iso_day
{
    NSArray *docPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath   = [docPaths objectAtIndex:0];
    NSString *trashPath = [docPath stringByAppendingPathComponent:@"Trash"];
    
    NSString *trash_for_day = [trashPath stringByAppendingPathComponent:iso_day];
    
    return trash_for_day;
}

// destructive
+ (void) emptyTrashFolder
{
    NSLog(@"Empty trash:");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *trashPath = [docPath stringByAppendingPathComponent:@"Trash"];
    
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:trashPath];
    NSString *dir;
    while( (dir = [dirEnum nextObject]) ){ // recursively
        NSString *path = [NSString stringWithFormat:@"%@/%@", trashPath, dir];
        NSLog(@"clearing : %@",path);
        [fileManager removeItemAtPath:path error:NULL];
    }
    
    NSLog(@"Empty trash done.");
}


#pragma mark
#pragma mark === singleton based service ===
#pragma mark

// private
- (NSDate *) makeNSDateForIsoStyleDay:(NSString *)iso_day
{
    return [formatter_in dateFromString:iso_day];
}

// private
- (NSString *) localizedDayStringForDate:(NSDate *)date
{
    return [formatter_out stringFromDate:date];
}

// public
- (NSString *) localizedDayStringForIsoDay:(NSString *)iso_day
{
    return [self localizedDayStringForDate:[self makeNSDateForIsoStyleDay:iso_day]];
}

+ (NSString *) localizedDayStringForIsoDay:(NSString *)iso_day
{
    AlbumUtility *instance = [self sharedInstance];
    return [instance localizedDayStringForIsoDay:iso_day];
}

#pragma mark
#pragma mark === object setup ===
#pragma mark

+ (id) sharedInstance
{
	@synchronized(self){
		if( !albumUtilityInstance ){
            NSLocale *locale = [NSLocale currentLocale];
			albumUtilityInstance = [[AlbumUtility alloc] initWithLocale:locale];
		}
	}
    return albumUtilityInstance;
}

- (id) initWithLocale:(NSLocale *)user_locale
{
    self = [super init];
    
    locale = user_locale;
    
    formatter_in = [[NSDateFormatter alloc] init]; // without locale
    [formatter_in setDateFormat:@"yyyy-MM-dd"];
    
    formatter_out = [[NSDateFormatter alloc] init];
    [formatter_out setLocale:locale];
    [formatter_out setDateStyle:NSDateFormatterLongStyle];
    
    formatter_iso = [[NSDateFormatter alloc] init]; // with locale
    [formatter_iso setLocale:locale];
    [formatter_iso setDateFormat:@"yyyy-MM-dd"];
    
    // copy to camera roll support
    aLAssetsLibrary = [[ALAssetsLibrary alloc] init];
    currentCopyToCameraRollIndex = 0;
    isCopyingThumbsToCameraRoll = NO;
    
    return self;
}

@end
