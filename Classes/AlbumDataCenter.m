//
// *****************************************************************************************
// basically, this data facade provides only cached data.
// loading actual data and instantiating actual instance is responsibility for consumer.
// also, this data facade, only cache block, have no concern with thumbnail caching.
// thumbnails are always managed in the world of block.
// *****************************************************************************************
// 
#import "AlbumDataCenter.h"

#pragma mark
#pragma mark *** utility classes ***
#pragma mark

@implementation AlbumBlockManifest
@synthesize iso_day, files;
- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:iso_day forKey:@"iso_day"];
    [coder encodeObject:files forKey:@"files"];
}
- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    iso_day = [decoder decodeObjectForKey:@"iso_day"];
    files = [decoder decodeObjectForKey:@"files"];
    return self;
}
- (void) addFileEntry:(NSString *)fileName
{
    [files addObject:fileName];
}
- (void) removeFileEntry:(NSString *)fileName
{
    [files removeObject:fileName];
}
@end

@implementation AlbumManifest
@synthesize blocks;
static AlbumManifest *albumManifest_sharedInstance = nil;
+ (id) sharedInstance
{
	@synchronized(self){
		if( !albumManifest_sharedInstance ){
			albumManifest_sharedInstance = [[AlbumManifest alloc] init];
		}
	}
    return albumManifest_sharedInstance;
}
- (void) load
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    
    blocks = [NSMutableDictionary dictionary];
    
    NSError *error = NULL;
    NSRegularExpression *regex_iso_day = [NSRegularExpression regularExpressionWithPattern:@"\\d{4}\\-\\d{2}\\-\\d{2}" options:0 error:&error];
    
    NSArray *dirs = [fileManager contentsOfDirectoryAtPath:docPath error:NULL];
    for( int i=0; i<dirs.count; i++ ){
        NSString *iso_day = [dirs objectAtIndex:i];
        NSTextCheckingResult *matches = [regex_iso_day firstMatchInString:iso_day options:0 range:NSMakeRange(0, iso_day.length)];
        if( matches ){
            //NSLog(@"AlbumManifest : iso_day found : %@",iso_day);
            
            NSString *day_path = [docPath stringByAppendingPathComponent:iso_day];
            NSString *photoDir = [day_path stringByAppendingPathComponent:@"photo"]; // look at photo, most stable folder
            
            NSMutableArray *files = [NSMutableArray array];
            
            NSRegularExpression *regex_file = [NSRegularExpression regularExpressionWithPattern:@"\\d{10}\\.jpg" options:0 error:&error];
            
            NSArray *items = [fileManager contentsOfDirectoryAtPath:photoDir error:NULL];
            for( int i=0; i<items.count; i++ ){
                NSString *file = [items objectAtIndex:i];
                NSTextCheckingResult *matches = [regex_file firstMatchInString:file options:0 range:NSMakeRange(0, file.length)];
                if( matches ){
                    //NSLog(@"AlbumManifest : photo file found : %@",file);
                    [files addObject:file];
                }
            }
            AlbumBlockManifest *block_manifest = [[AlbumBlockManifest alloc] init];
            block_manifest.iso_day = iso_day;
            block_manifest.files = files;
            [blocks setObject:block_manifest forKey:iso_day];
        }
    }
}
- (void) loadFilesInAlbumBlockManifest:(AlbumBlockManifest *)block_manifest
{
    NSString *iso_day = block_manifest.iso_day;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *dayPath = [docPath stringByAppendingPathComponent:iso_day];
    NSString *photoDir = [dayPath stringByAppendingPathComponent:@"photo"]; // look at photo, most stable folder
    
    NSMutableArray *files = [NSMutableArray array];
    
    NSError *error = NULL;
    NSRegularExpression *regex_file = [NSRegularExpression regularExpressionWithPattern:@"\\d{10}\\.jpg" options:0 error:&error];
    
    NSArray *items = [fileManager contentsOfDirectoryAtPath:photoDir error:NULL];
    for( int i=0; i<items.count; i++ ){
        NSString *file = [items objectAtIndex:i];
        NSTextCheckingResult *matches = [regex_file firstMatchInString:file options:0 range:NSMakeRange(0, file.length)];
        if( matches ){
            //NSLog(@"AlbumManifest : photo file found : %@",file);
            [files addObject:file];
        }
    }
    
    block_manifest.files = files;
}
- (void) flash
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *manifest_path = [docPath stringByAppendingPathComponent:@"album_manifest.plist"];
    
    [NSKeyedArchiver archiveRootObject:self toFile:manifest_path];
    
    // old way?
    //id data = [NSKeyedArchiver archivedDataWithRootObject:self];
    //[data writeToFile:manifest_path atomically:YES];
}
- (NSArray *) filesInAlbumBlock:(NSString *)iso_day
{
    AlbumBlockManifest *block_manifest = [blocks objectForKey:iso_day];
    if( block_manifest.files.count == 0 ){
        // confirm in the actual files
        //NSLog(@"files for %@ in the manifest is 0, confirming actual directory", iso_day);
        [self loadFilesInAlbumBlockManifest:block_manifest];
    }
    //NSLog(@"filesInAlbumBlock : files in manifest (%d)", block_manifest.files.count);
    return block_manifest.files;
}
- (void) syncBlockWithAlbumDayBlock:(AlbumDayBlock *)block
{
    //NSLog(@"syncBlockWithAlbumDayBlock : files in AlbumDayBlock (%d)", block.files.count);
    if( block != nil ){
        AlbumBlockManifest *block_manifest = [blocks objectForKey:block.iso_day];
        block_manifest.files = [NSMutableArray arrayWithArray:block.files];
    }else{
        [blocks removeObjectForKey:block.iso_day];
    }
    [self performSelectorInBackground:@selector(flash) withObject:nil];
}
- (AlbumBlockManifest *) albumBlockManifestOfIsoDay:(NSString *)iso_day
{
    return [blocks objectForKey:iso_day];
}
- (void) ensureIsoDay:(NSString *)iso_day andFileName:(NSString *)fileName
{
    AlbumBlockManifest *block_manifest;
    if( ![self existIsoDay:iso_day] ){
        block_manifest = [self addIsoDay:iso_day]; // generate empty block manifest entry
    }else{
        block_manifest = [self albumBlockManifestOfIsoDay:iso_day];
    }
    [block_manifest addFileEntry:fileName];
    [self performSelectorInBackground:@selector(flash) withObject:nil];
}
- (void) deleteIsoDay:(NSString *)iso_day
{
    [blocks removeObjectForKey:iso_day];
    [self performSelectorInBackground:@selector(flash) withObject:nil];
}
- (BOOL) existIsoDay:(NSString *)iso_day
{
    AlbumBlockManifest *block_manifest = [blocks objectForKey:iso_day];
    BOOL exist = YES;
    if( block_manifest == nil ){
        exist = NO;
    }
    return exist;
}
- (AlbumBlockManifest *) addIsoDay:(NSString *)iso_day
{
    // 
    // after adding iso_day.
    // it is required to be called syncBlock, to get block manifest right.
    // 
    AlbumBlockManifest *block_manifest = [[AlbumBlockManifest alloc] init];
    block_manifest.iso_day = iso_day;
    block_manifest.files = nil;
    [blocks setObject:block_manifest forKey:iso_day];
    return block_manifest;
}
- (NSArray *) iso_days
{
    NSArray *iso_days_raw = [blocks allKeys];
    NSArray *iso_days_sorted = [iso_days_raw sortedArrayUsingSelector:@selector(compare:)];
    return iso_days_sorted;
}
- (id) init
{
    //NSLog(@"AlbumManifest : initializing");
    self = [super init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    
    NSString *manifest_path = [docPath stringByAppendingPathComponent:@"album_manifest.plist"];
    
    if( [fileManager fileExistsAtPath:manifest_path] )
    {
        //NSLog(@"AlbumManifest : retrieving from plist file");
        // retrieve from plist file
        id data = [NSMutableData dataWithContentsOfFile:manifest_path];
        self = (AlbumManifest *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        //NSLog(@"AlbumManifest : building manifest by laoding document directory");
        // fresh load
        [self load];
    }
    
    return self;
}
- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:blocks forKey:@"blocks"];
}
- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    blocks = [decoder decodeObjectForKey:@"blocks"];
    return self;
}
@end


#pragma mark
#pragma mark *** data center (facade) ***
#pragma mark

@implementation AlbumDataCenter
@synthesize manifest;
@synthesize albumDayBlockDictionary;

static AlbumDataCenter *albumDataCenter_sharedInstance = nil;

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (BOOL) justCalledBootstrap
{
    return YES;
}
+ (void) bootstrap
{
    //NSLog(@"booting AlbumDataCenter");
    
    AlbumDataCenter *instance = [self sharedInstance];
    [instance justCalledBootstrap];
}

- (id) init
{
    NSLog(@"**********************************");
    NSLog(@"*                                *");
    NSLog(@"* AlbumDataCenter initialization *");
    NSLog(@"*                                *");
    NSLog(@"**********************************");
    
    self = [super init];
    
    albumDataCenter_sharedInstance = self;
    
    manifest = [AlbumManifest sharedInstance];
    
    albumDayBlockDictionary = [NSMutableDictionary dictionary];
    
    return self;
}

#pragma mark
#pragma mark === utility ===
#pragma mark

+ (AlbumThumbnailView *) loadFirstPhotoAsAlbumThumbnailView
{
    NSArray *iso_days = [AlbumDataCenter allIsoDays]; // sorted by iso_day
    
    //NSLog(@"loading first photo (thumb) : %@",iso_days);
    if( iso_days.count == 0 ){
        NSLog(@"loading first photo (thumb) : no photo in the album");
        return nil;
    }
    
    int first_idx = 0;
    NSString *first_iso_day = [iso_days objectAtIndex:first_idx];
    
    AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:first_iso_day];
    
    if( !block.loaded ){
        [block buildDayBlock];
    }
    
    return [block firstThumb];
}

+ (AlbumThumbnailView *) loadLatestPhotoAsAlbumThumbnailView
{
    NSArray *iso_days = [AlbumDataCenter allIsoDays]; // sorted by iso_day
    
    //NSLog(@"loading latest photo (thumb) : %@",iso_days);
    if( iso_days.count == 0 ){
        NSLog(@"loading latest photo (thumb) : no photo in the album");
        return nil;
    }
    
    int last_idx = iso_days.count-1;
    NSString *last_iso_day = [iso_days objectAtIndex:last_idx];
    
    AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:last_iso_day];
    
    if( !block.loaded ){
        [block buildDayBlock];
    }
    
    return [block lastThumb];
}

+ (UIImage *) loadLatestPhotoAsUIImage
{
    NSArray *iso_days = [AlbumDataCenter allIsoDays]; // sorted by iso_day
    
    //NSLog(@"loading latest photo (uiimage) : %@",iso_days);
    if( iso_days.count == 0 ){
        //NSLog(@"loading latest photo (uiimage) : no photo in the album");
        return nil;
    }
    
    int last_idx = iso_days.count-1;
    NSString *last_iso_day = [iso_days objectAtIndex:last_idx];
	
	NSArray *files = [AlbumDataCenter allFilesForIsoDay:last_iso_day]; // read from manifest
	NSArray *files_sorted = [files sortedArrayUsingSelector:@selector(compare:)];
	NSString *last_filename = [files_sorted objectAtIndex:files_sorted.count-1];
	
	NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docPaths objectAtIndex:0];
    NSString *dayDir = [docDir stringByAppendingPathComponent:last_iso_day];
	
	NSString *thumbPath = [[dayDir stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:last_filename];
	UIImage *thumbImage = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfFile:thumbPath]];
    
    return thumbImage;
}

#pragma mark
#pragma mark === retrieve ===
#pragma mark

+ (NSArray *) allIsoDays
{
    //NSLog(@"getting iso_days from manifest");
    AlbumDataCenter *instance = [self sharedInstance];
    return [instance.manifest iso_days];
}

+ (NSArray *) allAlbumDayBlocks
{
    AlbumDataCenter *instance = [self sharedInstance];
    return [instance.albumDayBlockDictionary allValues];
}

// 
// AlbumDayBlock object for the specific iso_day
// 
// this method only provides cached object,
// creating concrete object is responsibility of caller
// so caller should check nil of return value.
// 
+ (AlbumDayBlock *) albumDayBlockForIsoDay:(NSString *)iso_day
{
    AlbumDataCenter *instance = [self sharedInstance];
    AlbumDayBlock *block = [instance.albumDayBlockDictionary objectForKey:iso_day]; // check instance dictionary
    
    //NSLog(@"AlbumDataCenter.albumDayBlockForIsoDay called, block is %@",block.iso_day);
    
    // 
    // check exisntece of iso_day in the manifest
    // 
    // the iso_day is ensured to be in the cache or file system,
    // because at the time camera adding a photo, it calls commitNewIsoDay,
    // this creates a new AlbumBlockManifest entry.
    // 
    AlbumBlockManifest *block_manifest = [instance.manifest albumBlockManifestOfIsoDay:iso_day];
    if( !block_manifest ){
        //NSLog(@"### block_manifest is empty");
        // 
        // newly found iso_day, just add iso_day entry in the AlbumDataCenter
        // instantiating block object is responsibility of AlbumContainer.rebuildBlocks().
        // 
        //NSLog(@"the block:%@ is new (might be never called)",iso_day);
        // 
        // adding to the manifest.
        // this is safe. because after adding a iso_day, it is ensured that rebuildBlocks() is called.
        // and then actual block object and block manifest will be got right.
        // 
        [instance.manifest addIsoDay:iso_day];
    }
    
    return block;
}
// array of NSString representing photo file name (=unixtime)
+ (NSArray *) allFilesForIsoDay:(NSString *)iso_day
{
    AlbumDataCenter *instance = [self sharedInstance];
    return [instance.manifest filesInAlbumBlock:iso_day];
}

#pragma mark
#pragma mark === add ===
#pragma mark

// actual day folder should be created by AlbumUtility
// and should be called with adding photo
+ (void) cacheAlbumDayBlock:(AlbumDayBlock *)block
{
    AlbumDataCenter *instance = [self sharedInstance];
    NSString *iso_day = block.iso_day;
    [instance.albumDayBlockDictionary setObject:block forKey:iso_day];
}

+ (void) commitNewIsoDayIfNotExist:(NSString *)iso_day withFileName:(NSString *)fileName
{
    AlbumDataCenter *instance = [self sharedInstance];
    [instance.manifest ensureIsoDay:iso_day andFileName:fileName];
}

#pragma mark
#pragma mark === delete ===
#pragma mark

// actual day folder should be deleted by AlbumUtility
// and should be called immedeately after the call of delete photo
+ (void) deleteAlbumDayBlockCache:(AlbumDayBlock *)block
{
    AlbumDataCenter *instance = [self sharedInstance];
    NSString *iso_day = block.iso_day;
    [instance.albumDayBlockDictionary removeObjectForKey:iso_day];
}

// delete iso_day entry from manifest
+ (void) deleteIsoDayFromAlbumManifest:(NSString *)iso_day
{
    AlbumDataCenter *instance = [self sharedInstance];
    [instance.manifest deleteIsoDay:iso_day];
}

#pragma mark
#pragma mark === modify ===
#pragma mark

// 
// if the block is willing to be deleted, argument is nil.
// 
+ (void) notifyAlbumDayBlockChanged:(AlbumDayBlock *)block
{
    AlbumDataCenter *instance = [self sharedInstance];
    
    // update manifest
    [instance.manifest syncBlockWithAlbumDayBlock:block]; // calls flash
    
    // update instance cache
    [instance.albumDayBlockDictionary setObject:block forKey:block.iso_day];
}

#pragma mark
#pragma mark === singleton ===
#pragma mark

+ (id) sharedInstance
{
	@synchronized(self){
		if( !albumDataCenter_sharedInstance ){
			albumDataCenter_sharedInstance = [[AlbumDataCenter alloc] init];
		}
	}
    return albumDataCenter_sharedInstance;
}

@end
