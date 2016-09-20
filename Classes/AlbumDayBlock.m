
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "AlbumDayBlock.h"
#import "AlbumThumbnailView.h"
#import "AlbumUtility.h"
#import "AlbumDataCenter.h"


@interface AlbumDayBlock(Private)
- (CGRect) thumbRectForIndex:(int)index;
- (AlbumThumbnailView *) loadThumb:(NSString *)fileName;
@end

@implementation AlbumDayBlock
@synthesize loaded;
@synthesize iso_day;
@synthesize files, thumbs;
@synthesize prev, next;

#pragma mark
#pragma mark === visibility controller ===
#pragma mark

- (void) showThumbs
{
    NSLog(@"##### AlbumDayBlock.showThumbs() for %@, block has %d thumbs",iso_day,thumbs.count);
    
    for( int i=0; i<thumbs.count; i++ ){
        AlbumThumbnailView *thumb = [thumbs objectAtIndex:i];
        //NSLog(@"##> calling showThumb for %@",thumb.fileName);
        [thumb showThumb];
    }
}

- (void) hideThumbs
{
    for( int i=0; i<thumbs.count; i++ ){
        AlbumThumbnailView *thumb = [thumbs objectAtIndex:i];
        [thumb hideThumb];
    }
}

#pragma mark
#pragma mark === album view setup ===
#pragma mark

#define ALBUM_THUMBNAILS_PER_ROW 4
#define ALBUM_THUMBNAILVIEW_WIDTH 79
#define ALBUM_THUMBNAILVIEW_HEIGHT 79
#define ALBUM_PHOTO_MARGIN_X 4
#define ALBUM_PHOTO_MARGIN_Y 4
#define ALBUM_BLOCK_MARGIN_X 3
#define ALBUM_BLOCK_MARGIN_Y 24

// 
// album contianer layout
// 
// +---------------- dayblock view
// | date         14
// +----------------
// |  4
// |4 +------------+ thumbnail view
// |  |  4      4  |
// |  |4 +--80--+ 4| photo view
// |  |  |      |  |
// |  |  80     |  |
// |  |  |      |  |
// |  |4 +------+ 4|
// |  |  4      4  |
// |  +------------+
// 

- (CGRect) thumbRectForIndex:(int)index
{
    int col = index % ALBUM_THUMBNAILS_PER_ROW;
    int row = (int)( (double)index / ALBUM_THUMBNAILS_PER_ROW );
    
    int x = col * ALBUM_THUMBNAILVIEW_WIDTH;
    int y = row * ALBUM_THUMBNAILVIEW_HEIGHT;
    
    //NSLog(@"# thumb at %d,%d",x,y);
    
    CGRect thumbRect = CGRectMake(x+ALBUM_BLOCK_MARGIN_X, y+ALBUM_BLOCK_MARGIN_Y, ALBUM_THUMBNAILVIEW_WIDTH, ALBUM_THUMBNAILVIEW_HEIGHT);
    
    return thumbRect;
}

// deep build.
// 
// this method will be called when the the object is actually needed by album view.
// 
// xthis method will be called only when the initial album laoding.
// xbecause adding and deleting thumb in the block will be always managed in the memory.
- (void) buildDayBlock
{
    NSLog(@"building AlbumDayBlock.");
    
    if( loaded ){
        NSLog(@"### AlbumDayBlock %@ already loaded its thumbs",iso_day);
        return;
    }
    
    if( files == nil ){ return; }
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docPaths objectAtIndex:0];
    NSString *dayDir = [docDir stringByAppendingPathComponent:iso_day];
    
    for( int i = 0; i < files.count; i++ ){
        //NSLog(@"# thumb index:%d of %d",i,files.count);
        NSString *file = [files objectAtIndex:i];
        CGRect thumbRect = [self thumbRectForIndex:i];
        
        // scratch
        AlbumThumbnailView *thumb = [[AlbumThumbnailView alloc] initWithFrame:thumbRect dir:dayDir file:file];
        
        [thumbs addObject:thumb];
        [self addSubview:thumb];
        
        thumb.block = self;
    }
    
    loaded = YES;
}

- (AlbumThumbnailView *) loadThumb:(NSString *)fileName
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docPaths objectAtIndex:0];
    NSString *dayDir = [docDir stringByAppendingPathComponent:iso_day];
    
    // seek index
    int index = 0;
    for( int i = 0; i < files.count; i++ ){
        if( [fileName isEqualToString:[files objectAtIndex:i]] ){
            index = i;
        }
    }
    CGRect thumbRect = [self thumbRectForIndex:index];
    AlbumThumbnailView *thumb = [[AlbumThumbnailView alloc] initWithFrame:thumbRect dir:dayDir file:fileName];
    thumb.block = self;
    return thumb;
}

- (AlbumThumbnailView *) getThumbAtIndex:(int)index
{
    AlbumThumbnailView *thumb = nil;
    if( thumbs != nil ){
        thumb = [thumbs objectAtIndex:index];
    }else{
        NSString *fileName = [files objectAtIndex:index];
        thumb = [self loadThumb:fileName];
    }
    return thumb;
}

// short cut to get last thumbnail in the thumbs|files
- (AlbumThumbnailView *) lastThumb
{
    int last_index = files.count - 1;
    return [self getThumbAtIndex:last_index];
}

// short cut to get first thumbnail in the thumbs|files
- (AlbumThumbnailView *) firstThumb
{
    return [self getThumbAtIndex:0];
}

// !!! CAUTION !!!
// 
// still buggy, dont call
// 
// thumbnail volatility
// when gone away from display area, block will be trimmed to reduce memory.
// 
- (void) trimDayBlock
{
    NSLog(@"trimDayBlock() is still buggy");
    
    if( thumbs.count == 0 ){
        NSLog(@"block(%@) has not been used",iso_day);
        return;
    }
    NSLog(@"trimming AlbumDayBlock %@",iso_day);
    for( int i = 0; i < thumbs.count; i++ ){
        AlbumThumbnailView *thumb = [thumbs objectAtIndex:i];
        [thumb removeFromSuperview];
        [thumb removeFromAlbumDayBlock];
    }
}

#pragma mark
#pragma mark === file management  ===
#pragma mark

- (void) delinkWithThumb:(AlbumThumbnailView *)thumb
{
    // delink with thumb
    // remove entry from self.files and self.thumbs
    NSLog(@"delinking thumb from block : %@",thumb.fileName);
    [files removeObject:thumb.fileName];
    [thumbs removeObject:thumb];
}

- (void) modified
{
    shouldRebuild = YES;
}

- (BOOL) shouldRebuildBeforeUse
{
    return shouldRebuild;
}

- (void) rebuildedSafeToUse
{
    shouldRebuild = NO;
}

- (void) removeDateFolderIfEmpty
{
    // shallowly
    NSArray *contained_files = [AlbumDataCenter allFilesForIsoDay:iso_day]; // looking for the manifest
    
    if( contained_files == nil || contained_files.count == 0 ){
        NSLog(@"no photo in the day folder:%@",iso_day);
        [AlbumUtility removeDayFolder:iso_day]; // remove entity
        [AlbumDataCenter deleteIsoDayFromAlbumManifest:iso_day]; // remove from manifest
        [AlbumDataCenter deleteAlbumDayBlockCache:self]; // remove from cache
    }
}

#pragma mark
#pragma mark === object setup ===
#pragma mark

// 
// the frame should be calculated by container
// 
- (id) initWithFrame:(CGRect)frame withIsoDay:(NSString *)day withFiles:(NSArray *)infiles
{
    self = [super initWithFrame:frame];
    
	//NSLog(@"AlbumDayBlock initialization start");
    
    loaded = NO;
    shouldRebuild = NO;
    
    iso_day   = day;
    files     = [NSMutableArray arrayWithArray:infiles];
    thumbs    = [[NSMutableArray alloc] init]; // init with empty
    
    // label bg
    UIImage *day_tag_bg_img = [UIImage imageNamed:@"day_tag_626x26"]; // auto retina
    day_tag_bg = [[UIImageView alloc] initWithImage:day_tag_bg_img];
    day_tag_bg.frame = CGRectMake(4, 4, 314, 16);
    [self addSubview:day_tag_bg];
    
    // label string
    NSString *display_iso_day = [AlbumUtility localizedDayStringForIsoDay:iso_day];
    day_label = [[UILabel alloc] initWithFrame:CGRectMake(14, 4, 100, 14)];
    day_label.adjustsFontSizeToFitWidth = YES;
    //day_label.minimumFontSize = 0.0;
	day_label.minimumScaleFactor = 0.0;
    day_label.text = display_iso_day;
    day_label.textColor = [UIColor whiteColor];
    day_label.backgroundColor = [UIColor clearColor];
    day_label.layer.opacity = 0.6;
    [self addSubview:day_label];
    
    // CAUTION (iOS5 beta5)
    // sending building process in background will causes inconsistency of files array object.
    // build block view in background
    //[self performSelectorInBackground:@selector(buildDayBlock) withObject:nil];
    //
    //buildDayBlock will be called if it is needed to display on the album
    //[self buildDayBlock];
    
    return self;
}

@end
