
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "AlbumThumbnailView.h"

@class AlbumThumbnailView;

@interface AlbumDayBlock : UIView
{
    BOOL loaded;
    BOOL shouldRebuild;        // someone manipulated block structure, required to rebuild before use
    NSString *iso_day;         // target day (=folder name)
    
    BOOL isFirstBlock;         // this is the first block in the album
    BOOL isLastBlock;          // this is the last block in the album
    
    UIImageView *day_tag_bg;   // label bg
    UILabel *day_label;        // tilte of the block
    
    NSMutableArray *files;     // containing NSString objects for photo filenames of the day
    NSMutableArray *thumbs;    // containing AlbumThumbnailView objects for the files
    
    AlbumDayBlock *prev;
    AlbumDayBlock *next;
}
@property BOOL loaded;
@property (retain) NSString *iso_day;
@property (retain) NSArray *files;
@property (retain) NSArray *thumbs;
@property (retain) AlbumDayBlock *prev;
@property (retain) AlbumDayBlock *next;

- (id) initWithFrame:(CGRect)frame withIsoDay:(NSString *)iso_day withFiles:(NSArray *)files;

- (void) buildDayBlock;
- (void) trimDayBlock;

- (void) modified;
- (BOOL) shouldRebuildBeforeUse;
- (void) rebuildedSafeToUse;
- (void) removeDateFolderIfEmpty;
- (void) delinkWithThumb:(AlbumThumbnailView *)thumb;

- (AlbumThumbnailView *) getThumbAtIndex:(int)index;
- (AlbumThumbnailView *) lastThumb;
- (AlbumThumbnailView *) firstThumb;

- (void) showThumbs;
- (void) hideThumbs;

@end
