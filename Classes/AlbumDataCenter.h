
#import <Foundation/Foundation.h>
#import "AlbumDayBlock.h"
#import "AlbumThumbnailView.h"

// *****************************************************************************************
// basically, this data facade provides only cached data.
// loading actual data and instantiating actual instance is responsibility for consumer.
// also, this data facade, only cache block, have no concern with thumbnail caching.
// thumbnails are always managed in the world of block.
// *****************************************************************************************

@interface AlbumBlockManifest : NSObject <NSCoding>
{
    NSString *iso_day;
    NSMutableArray *files;
}
@property (retain) NSString *iso_day;
@property (retain) NSMutableArray *files;
- (void) addFileEntry:(NSString *)fileName;
- (void) removeFileEntry:(NSString *)fileName;
@end

@interface AlbumManifest : NSObject <NSCoding>
{
    NSMutableDictionary *blocks;
}
@property (retain) NSMutableDictionary *blocks;
- (AlbumBlockManifest *) albumBlockManifestOfIsoDay:(NSString *)iso_day;
- (NSArray *) filesInAlbumBlock:(NSString *)iso_day;
- (NSArray *) iso_days;
- (void) ensureIsoDay:(NSString *)iso_day andFileName:(NSString *)fileName;
- (BOOL) existIsoDay:(NSString *)iso_day;
- (AlbumBlockManifest *) addIsoDay:(NSString *)iso_day;
- (void) deleteIsoDay:(NSString *)iso_day;
- (void) flash; // flash to plist file
- (void) syncBlockWithAlbumDayBlock:(AlbumDayBlock *)block;
+ (id) sharedInstance;
@end

@interface AlbumDataCenter : NSObject
{
    // file structure cache (persistent)
    AlbumManifest *manifest;
    
    // instance structure cache (volatile)
    NSMutableDictionary *albumDayBlockDictionary; // AlbumDayBlock for iso_day
}
@property (retain) AlbumManifest *manifest;
@property (retain) NSMutableDictionary *albumDayBlockDictionary;

+ (id) sharedInstance;

+ (void) bootstrap; // just load manifest

// utility
+ (UIImage *) loadLatestPhotoAsUIImage;
+ (AlbumThumbnailView *) loadLatestPhotoAsAlbumThumbnailView;
+ (AlbumThumbnailView *) loadFirstPhotoAsAlbumThumbnailView;

// retrieving
+ (NSArray *) allIsoDays; // list of iso_day (=NSString)
+ (NSArray *) allAlbumDayBlocks; // list of AlbumDayBlock
+ (NSArray *) allFilesForIsoDay:(NSString *)iso_day;
+ (AlbumDayBlock *) albumDayBlockForIsoDay:(NSString *)iso_day;

// adding
+ (void) cacheAlbumDayBlock:(AlbumDayBlock *)block;
+ (void) commitNewIsoDayIfNotExist:(NSString *)iso_day withFileName:(NSString *)fileName;

// deleting
+ (void) deleteAlbumDayBlockCache:(AlbumDayBlock *)block;
+ (void) deleteIsoDayFromAlbumManifest:(NSString *)iso_day;

// sync modified block and manifest
+ (void) notifyAlbumDayBlockChanged:(AlbumDayBlock *)block;

@end
