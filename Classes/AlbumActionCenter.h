
#import <Foundation/Foundation.h>
#import "AlbumThumbnailView.h"
#import "AlbumViewController.h"
#import "SnapViewController.h"


// progress for copy to camera roll
@interface AlbumActionCopyToCameraRollProgressBar : UIView
{
    UIView *bgView;
    int fullcount;
    int donecount;
    NSString *baseText;
    UILabel *progressLabel;
    BOOL complete;
}
- (id) initWithFrame:(CGRect)frame withNumber:(int)num;
- (void) countDown;
- (BOOL) completed;
- (void) showAndStart;
- (void) hideAndEnd;
@end


// action center
@interface AlbumActionCenter : NSObject
{
    BOOL blockUI; // YES to block enter ui block
    BOOL isMultiSelectionMode; // YES if in the multi-selection mode
    BOOL shouldRebuildAlbum; // YES if the album data structure was changed
    
    BOOL shouldRebuildBlock; // YES if some block was modified, actual modification is set in blockRebuildRequests
    NSMutableArray *blockRebuildRequests;
    
    BOOL shouldScrollToBottomOfAlbum; // make flag on to scroll to the bottom of the album, at the start of album view
    
    NSMutableArray *selectedThumbs; // collection of AlbumThumbnailView objects
    NSUInteger selectedCount;
    
    AlbumViewController *albumViewController;
    SnapViewController *snapViewController;
}

@property (nonatomic) BOOL blockUI;
@property (retain) NSMutableArray *selectedThumbs;
@property (retain) AlbumViewController *albumViewController;
@property (retain) SnapViewController *snapViewController;
@property (nonatomic) BOOL shouldRebuildAlbum;
@property (nonatomic) BOOL shouldRebuildBlock;
@property (retain) NSMutableArray *blockRebuildRequests;
@property (nonatomic) BOOL shouldScrollToBottomOfAlbum;

- (NSUInteger) selectedCount;
- (void) setSelectedCount:(NSUInteger)count;

+ (id) sharedInstance;

+ (BOOL) blockUI;
+ (void) getUIBlock;
+ (void) releaseUIBlock;

+ (void) requestRebuildBlock:(NSString *)iso_day; // calls AlbumDayBlock.modified()

+ (void) removePhotos:(NSArray *)thumbs;
+ (void) removePhotos:(NSArray *)thumbs withCompletionBlock:(void (^)(void))completionBlock;

+ (void) immediateRebuildAlbum;
+ (void) requestRebuildAlbumBeforeAppear;
+ (void) withdrawRequestRebuildAlbum;
+ (BOOL) shouldRebuildAlbum;
+ (void) forceRebuildAlbum;

+ (BOOL) shouldScrollToBottomOfAlbum;
+ (void) requestScrollToBottomOfAlbum;
+ (void) withdrawScrollToBottomOfAlbum;

+ (BOOL) isMultiSelectionMode;
+ (void) enableMultiSelectionMode;
+ (void) disableMultiSelectionMode;

+ (void) requestLoadingPhotoInSnap;
+ (void) withdrawLoadingPhotoInSnap; // not yet implemented

+ (void) toggleHidableSnapDecoration;
+ (void) hideHidableSnapDecoration;
+ (void) showHidableSnapDecoration;

+ (void) toggleSnapViewNaviAndTool;
+ (void) hideSnapViewNaviAndTool;
+ (void) showSnapViewNaviAndTool;
+ (BOOL) isSnapViewNaviAndToolVisible;

+ (NSArray *) getSelectedThumbs;

+ (void) clearPhotosSelection;
+ (void) selectPhoto:(AlbumThumbnailView *)thumb;
+ (void) deselectPhoto:(AlbumThumbnailView *)thumb;

+ (void) presentSnapViewControllerWithThumb:(AlbumThumbnailView *)thumb;

+ (AlbumActionCopyToCameraRollProgressBar *) getCopyToCameraRollProgressBarWithFrame:(CGRect)frame withNumber:(int)num;

@end

