
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "AlbumViewController.h"
#import "AlbumContainer.h"
#import "AlbumThumbnailView.h"
#import "AlbumDayBlock.h"
#import "AlbumUtility.h"
#import "AlbumDataCenter.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"

@interface AlbumContainer(Private)
- (void) buildAlbumBlocks;
- (int) heightOfDayBlockHavingFiles:(NSArray *)files;
- (NSArray*) photosForIndexPath:(NSIndexPath*)indexPath;
- (NSDictionary *) albumDayBlockSetInRange:(NSRange)range;
@end

@implementation AlbumContainer

#pragma mark
#pragma mark === UIScrollViewDelegate implementation ===
#pragma mark

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
    if( self == scrollView ){
        return albumView;
    }
    return nil;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale 
{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark
#pragma mark === delayed thumbnail loading ===
#pragma mark

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // fired at the end of user drag of scrollview
    [self delayedThumbnailLoad:scrollView];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // fired at the time ending scrolling animation caused by user swipe gesture
    [self delayedThumbnailLoad:scrollView];
}

- (void) delayedThumbnailLoad:(UIScrollView *)scrollView
{
    NSLog(@"delayedThumbnailLoad : rendering album scroll view");
    
    int offset = scrollView.contentOffset.y;
    NSRange range = NSMakeRange(offset, [DeviceConfig screenHeight]);
    
    //NSLog(@"delayedThumbnailLoad : last_offset %d",last_offset);
    //NSLog(@"delayedThumbnailLoad : offset      %d",offset);
    //NSLog(@"delayedThumbnailLoad : moved       %d",abs(offset - last_offset));
    
    if( (last_offset >= 0) && abs(offset - last_offset) <= delayedThumbnailLoad_threshold ){
        NSLog(@"delayedThumbnailLoad : less than threshold, returned");
        return;
    }
    
    NSDictionary *dic = [self albumDayBlockSetInRange:range];
    NSSet *visibles = [dic objectForKey:@"vislbles"];
    NSSet *invisibles = [dic objectForKey:@"invisibles"];
    
    // show visibles
    NSEnumerator *block_enum = [visibles objectEnumerator];
    id block;
    while( (block = [block_enum nextObject]) ){
        [block showThumbs];
    }
    
    // hide invisibles
    BOOL hide_invisibles = NO;
    if( hide_invisibles ){
        NSEnumerator *block_enum = [invisibles objectEnumerator];
        id block;
        while( (block = [block_enum nextObject]) ){
            [block hideThumbs];
        }
    }
    
    last_offset = offset;
}

- (NSDictionary *) albumDayBlockSetInRange:(NSRange)range
{
    NSLog(@"albumDayBlockSetInRange : checking range");
    // get collection of AlbumDayBlock sorted by iso_day
    NSArray *albumDayBlocks = [AlbumDataCenter allAlbumDayBlocks];
    if( albumDayBlocks == nil ){
        NSLog(@"no album found to display");
        return nil;
    }
    
    int start = range.location;
    int end   = start + range.length;
    
    NSMutableArray *start_hit_array = [[NSMutableArray alloc] init];
    NSMutableArray *end_hit_array   = [[NSMutableArray alloc] init];
    NSMutableArray *invisibles      = [[NSMutableArray alloc] init];
    
    // seek all, to prepare unloading invisible thumbs
    for( int i=0; i<albumDayBlocks.count; i++ ){
        AlbumDayBlock *block = [albumDayBlocks objectAtIndex:i];
        int block_start = block.frame.origin.y;
        int block_end   = block_start + block.frame.size.height;
        BOOL hit = NO;
        // check start
        if( (block_start >= start) && (block_start <= end) ){
            NSLog(@"hit in start day:%@",block.iso_day);
            [start_hit_array addObject:block];
            hit = YES;
            [block buildDayBlock]; // prepare thumbnails
        }
        // check end
        if( (block_end >= start) &&  (block_end <= end) ){
            NSLog(@"hit in end day:%@",block.iso_day);
            [end_hit_array addObject:block];
            hit = YES;
            [block buildDayBlock]; // prepare thumbnails
        }
        // check visibility
        if( !hit ){
            //NSLog(@"invisible day:%@",block.iso_day);
            [invisibles addObject:block];
            //[block trimDayBlock]; // trim down memory, !!! still bugy
        }
        // check tail
        //if( block_start >= end ){
        //    break;
        //}
    }
    
    // visible set
    NSMutableSet *start_hit_set = [NSMutableSet setWithArray:start_hit_array];
    NSMutableSet *end_hit_set = [NSMutableSet setWithArray:end_hit_array];
    [start_hit_set unionSet:end_hit_set];
    
    // invisible set
    NSMutableSet *invisible_set = [NSMutableSet setWithArray:invisibles];
    
    NSArray *values = [NSArray arrayWithObjects:start_hit_set,invisible_set,nil];
    NSArray *keys   = [NSArray arrayWithObjects:@"vislbles",@"invisibles",nil];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    return dic;
}

#pragma mark
#pragma mark === album view setup ===
#pragma mark

// rebuild album with animation effect
- (void) rebuildAlbum
{
    NSLog(@"*** AlbumContainer.rebuildAlbum called");
    
    // initialize
    for( UIView *sub in [albumView subviews] ){
        [sub removeFromSuperview];
    }
    
    albumView.layer.opacity = 0.8; // for animation effect
    
    // rebuild
    [self buildAlbumBlocks];
    
    // ui update
    [self scrollViewDidEndDecelerating:self];
    
    albumView.layer.opacity = 1.0; // for animation effect
}

- (void) buildAlbumBlocks
{
    NSLog(@"*** AlbumContainer.buildAlbumBlocks called");
    
    // reset accumulated height
    accumulatedBlockHeight = 0;
    
    // at first, find all day folders
    
    // cache enabled
    NSArray *iso_days = [AlbumDataCenter allIsoDays];
    
    AlbumDayBlock *first = nil;
    AlbumDayBlock *last  = nil;
    AlbumDayBlock *prev  = nil;
    
    for( int i=0; i<iso_days.count; i++ ){
        NSString *iso_day = [iso_days objectAtIndex:i];
        
        AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:iso_day];
        int height; // height of the block
        
        if( block != nil && !block.shouldRebuildBeforeUse ){
            // 
            // cached
            // 
            NSLog(@"iso_day:%@ cached",iso_day);
            NSArray *files = [block files];
            height = [self heightOfDayBlockHavingFiles:files];
            CGRect frame = CGRectMake(0, accumulatedBlockHeight+44, [DeviceConfig screenWidth], height);
            block.frame = frame;
        }else{
            // 
            // scratch
            // 
            NSLog(@"iso_day:%@ not cached, or modified, loading from manifest",iso_day);
            NSArray *files = [AlbumDataCenter allFilesForIsoDay:iso_day]; // read from manifest
            //for( int j=0; j<files.count; j++ ){ NSLog(@"file:%@",[files objectAtIndex:j]); }
            height = [self heightOfDayBlockHavingFiles:files];
            CGRect frame = CGRectMake(0, accumulatedBlockHeight+44, [DeviceConfig screenWidth], height);
            block = [[AlbumDayBlock alloc] initWithFrame:frame withIsoDay:iso_day withFiles:files];
            [block rebuildedSafeToUse];
            
            last_offset = -1; // reset offset information, scroll view is now re-constructed
        }
        
        if( i == 0 ){
            first = block;
        }
        if( i == iso_days.count-1 ){
            last = block;
        }
        
        // make link
        block.prev = prev;
        if( prev != nil ){
            prev.next = block;
        }
        prev = block;
        
        accumulatedBlockHeight += height;
        [albumView addSubview:block];
        
        [AlbumDataCenter cacheAlbumDayBlock:block];
    }
    
    first.prev = last;
    last.next = first;
    
    // update content size
    CGFloat content_width = self.frame.size.width;
    CGFloat content_height = accumulatedBlockHeight + (44 + 4) * 2; // adding up and down mergins
    if( content_height < self.frame.size.height ){
        content_height = self.frame.size.height;
    }
    [self setContentSize:CGSizeMake(content_width, content_height)];
    
    // update album frame size
    albumView.frame = CGRectMake(0, 0, content_width, content_height);
    
    // reset offset
    if( [AlbumActionCenter shouldScrollToBottomOfAlbum] ){
        // scroll to the bottom of the album
        NSLog(@"* scrolling to the bottom of the album (shouldScrollToBottomOfAlbum) ");
        
        [self setContentOffset:CGPointMake(0, content_height - [DeviceConfig screenHeight])];
    }else{
        // sustain the offset
        NSLog(@"* calculating album offset");
        
        int current_offset = self.contentOffset.y;
        
        // reset offset
        if( albumView.frame.size.height - current_offset < [DeviceConfig screenHeight] ){
            current_offset = albumView.frame.size.height - [DeviceConfig screenHeight];
        }
        if( current_offset < 0 ){
            current_offset = 0;
        }
        
        [self setContentOffset:CGPointMake(0, current_offset)];
    }
}

- (int) heightOfDayBlockHavingFiles:(NSArray *)files
{
    //NSLog(@"calc : files=%d",files.count);
    int count = [files count];
    int rows = (int)( count / 4 );
    //NSLog(@"calc : rows=%d",rows);
    if( (count % 4) > 0  ){
        rows++;
    }
    //NSLog(@"calc : rows=%d",rows);
    return rows * 80 + 4 + 16;
}

#pragma mark
#pragma mark === object setup ===
#pragma mark

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	NSLog(@"AlbumContainer initialization start");
    
    self.bounds = frame;
    self.multipleTouchEnabled = YES;
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    [self setContentSize:CGSizeMake(frame.size.width, frame.size.height+1)];
    
    accumulatedBlockHeight = 0;
    
    last_offset = -1;
    //delayedThumbnailLoad_threshold = 80;
    delayedThumbnailLoad_threshold = [DeviceConfig delayedThumbnailLoadThreshold];
    
    // initialize albumView
    albumView = [[UIView alloc] initWithFrame:frame];
    albumView.backgroundColor = [UIColor clearColor];
    [self addSubview:albumView];
    
    // 
    // to show the bottom of the album (latest photos),
    // album blocks should be built in this phase (before showing the view).
    // 
    //x build album view in background
    //x[self performSelectorInBackground:@selector(buildAlbumBlocks) withObject:nil];
    [self buildAlbumBlocks];
    
    // and fire initial notification of thumbnail visibility
    [self scrollViewDidEndDecelerating:self];
    
    return self;
}

@end
