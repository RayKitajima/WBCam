
#import "AlbumActionCenter.h"
#import "AlbumUtility.h"
#import "AlbumDataCenter.h"
#import "ApplicationDecoration.h"

#pragma mark
#pragma mark ***** AlbumActionCopyToCameraRollProgressBar *****
#pragma mark

static AlbumActionCenter *sharedInstance = nil;

@implementation AlbumActionCopyToCameraRollProgressBar
- (void) countDown
{
    donecount++;
    progressLabel.text = [baseText stringByAppendingFormat:@"%d/%d",donecount,fullcount];
    if( donecount >= fullcount ){
        complete = YES;
    }
}
- (BOOL) completed
{
    return complete;
}
- (void) showAndStart
{
    NSLog(@"AlbumActionCopyToCameraRollProgressBar calls startCubeAnimationOnView()");
    [ApplicationDecoration startCubeAnimationOnView:self withCenter:self.center];
}
- (void) hideAndEnd
{
    if( [ApplicationDecoration cubeAnimationRunning] ){
        NSLog(@"AlbumActionCopyToCameraRollProgressBar calls stopCubeAnimation()");
        [ApplicationDecoration stopCubeAnimation];
    }
}
- (id)initWithFrame:(CGRect)frame withNumber:(int)num
{
    // frame requires full screen
    self = [super initWithFrame:frame];
    
    fullcount = num;
    donecount = 0;
    complete = NO;
    
    bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.layer.opacity = 0.70;
    [self addSubview:bgView];
    
    baseText = NSLocalizedString(@"Copying photos to Camera Roll:", @"indicate copying photos to camera roll:<DONE>/<TOTAL>");
    
    progressLabel = [[UILabel alloc] init];
    progressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    progressLabel.frame = frame;
    progressLabel.text = [baseText stringByAppendingFormat:@"%d/%d",donecount,fullcount];
    progressLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.center = CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2 - 30);
    [self addSubview:progressLabel];
    
    return self;
}
@end

#pragma mark
#pragma mark ***** AlbumActionCenter *****
#pragma mark

@implementation AlbumActionCenter
@synthesize blockUI;
@synthesize selectedThumbs;
@synthesize albumViewController;
@synthesize snapViewController;
@synthesize shouldRebuildAlbum;
@synthesize shouldRebuildBlock, blockRebuildRequests;
@synthesize shouldScrollToBottomOfAlbum;

#pragma mark
#pragma mark === uicomponent services ===
#pragma mark

+ (AlbumActionCopyToCameraRollProgressBar *) getCopyToCameraRollProgressBarWithFrame:(CGRect)frame withNumber:(int)num
{
    AlbumActionCopyToCameraRollProgressBar *bar = [[AlbumActionCopyToCameraRollProgressBar alloc] initWithFrame:frame withNumber:num];
    return bar;
}

#pragma mark
#pragma mark === services ===
#pragma mark

- (BOOL) isMultiSelectionMode
{
    return isMultiSelectionMode;
}

- (void) enableMultiSelectionMode
{
    isMultiSelectionMode = YES;
}

- (void) disableMultiSelectionMode
{
    isMultiSelectionMode = NO;
}

- (void) clearPhotosSelection
{
    NSMutableArray *discards = [NSMutableArray arrayWithArray:selectedThumbs];
    AlbumThumbnailView *thumb;
    for( thumb in discards ){
        [thumb toggleSelection];
    }
}

- (void) selectPhoto:(AlbumThumbnailView *)thumb
{
    //NSLog(@"select thumb:%@",thumb.fileName);
    [selectedThumbs addObject:thumb];
    [self setSelectedCount:[selectedThumbs count]];
    
    //int count = [selectedThumbs count];
    //NSLog(@"counting:%d",count);
}

- (void) deselectPhoto:(AlbumThumbnailView *)thumb
{
    //NSLog(@"deselectPhoto:%@",thumb.fileName);
    [selectedThumbs removeObject:thumb];
    [self setSelectedCount:[selectedThumbs count]];
}

#pragma mark
#pragma mark === object settings ===
#pragma mark

- (id)init
{
    NSLog(@"************************************");
    NSLog(@"*                                  *");
    NSLog(@"* AlbumActionCenter initialization *");
    NSLog(@"*                                  *");
    NSLog(@"************************************");
    
    self = [super init];
    
    sharedInstance = self;
    
    blockUI = NO;
    isMultiSelectionMode = NO;
    shouldRebuildAlbum = NO;
    
    selectedThumbs = [[NSMutableArray alloc] init];
    selectedCount = 0;
    
    return self;
}

- (NSUInteger) selectedCount
{
    return selectedCount;
}

- (void) setSelectedCount:(NSUInteger)count
{
    selectedCount = count;
    //NSLog(@"ActionCenter: update count=%d",selectedCount);
}

#pragma mark
#pragma mark === public services ===
#pragma mark

+ (void) removePhotos:(NSArray *)thumbs withCompletionBlock:(void (^)(void))completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"removePhotos phase.0");
        // 0) hold blocks containing delete target photos (=AlbumThumbnailView.block)
        NSMutableSet *set_of_iso_days = [NSMutableSet set];
        for( AlbumThumbnailView *thumb in thumbs ){
            [set_of_iso_days addObject:thumb.iso_day];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"removePhotos phase.1");
            // 1) remove thumb/preview
            for( AlbumThumbnailView *thumb in thumbs ){
                [thumb removeThumbAndPreview];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"removePhotos phase.2");
                // 2) make trash space as ~/Documents/Trash/iso_day_of_deleting, and move photo/meta in there
                NSString *trash_folder_name = [AlbumUtility folderNameForTodaysPhoto];
                [AlbumUtility ensureTrashDateFolder:trash_folder_name];
                NSString *trash_path = [AlbumUtility pathOfTrashDateFolder:trash_folder_name];
                for( AlbumThumbnailView *thumb in thumbs ){
                    [thumb removeMetaAndPhotoWithTrashPath:trash_path]; // MUST call with AlbumContainer.rebuildAlbum
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"removePhotos phase.3");
                    // 3) delink with block
                    for( AlbumThumbnailView *thumb in thumbs ){
                        [thumb removeFromAlbumDayBlock];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"removePhotos phase.4");
                        // 4) check empty of iso_day, and remove empty folder
                        
                        for( NSString *iso_day in [set_of_iso_days objectEnumerator] ){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"removePhotos phase.5 (%@)",iso_day);
                                AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:iso_day];
                                [block modified]; // make rebuild flag on
                                [AlbumDataCenter notifyAlbumDayBlockChanged:block]; // sync manifest
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"removePhotos phase.6 (%@)",iso_day);
                                    [block removeDateFolderIfEmpty]; // MUST called with modified, but MUST after sync manifest, empty check will be for the manifest
                                    
                                    // exec callback
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSLog(@"animation done.");
                                        completionBlock();
                                    });
                                    
                                });
                            });
                            
                        }// 4)
                        
                    });// 3)
                });// 2)
            });// 1)
        });// 0)
    });
}

// deprecated
// requesting album rebuild is responsibility of caller
+ (void) removePhotos:(NSArray *)thumbs
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"removePhotos phase.0");
        // 0) hold blocks containing delete target photos (=AlbumThumbnailView.block)
        NSMutableSet *set_of_iso_days = [NSMutableSet set];
        for( AlbumThumbnailView *thumb in thumbs ){
            [set_of_iso_days addObject:thumb.iso_day];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"removePhotos phase.1");
            // 1) remove thumb/preview
            for( AlbumThumbnailView *thumb in thumbs ){
                [thumb removeThumbAndPreview];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"removePhotos phase.2");
                // 2) make trash space as ~/Documents/Trash/iso_day_of_deleting, and move photo/meta in there
                NSString *trash_folder_name = [AlbumUtility folderNameForTodaysPhoto];
                [AlbumUtility ensureTrashDateFolder:trash_folder_name];
                NSString *trash_path = [AlbumUtility pathOfTrashDateFolder:trash_folder_name];
                for( AlbumThumbnailView *thumb in thumbs ){
                    [thumb removeMetaAndPhotoWithTrashPath:trash_path]; // MUST call with AlbumContainer.rebuildAlbum
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"removePhotos phase.3");
                    // 3) delink with block
                    for( AlbumThumbnailView *thumb in thumbs ){
                        [thumb removeFromAlbumDayBlock];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"removePhotos phase.4");
                        // 4) check empty of iso_day, and remove empty folder
                        
                        for( NSString *iso_day in [set_of_iso_days objectEnumerator] ){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"removePhotos phase.5 (%@)",iso_day);
                                AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:iso_day];
                                [block modified]; // make rebuild flag on
                                [AlbumDataCenter notifyAlbumDayBlockChanged:block]; // sync manifest
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"removePhotos phase.6 (%@)",iso_day);
                                    [block removeDateFolderIfEmpty]; // MUST called with modified, but MUST after sync manifest, empty check will be for the manifest
                                });
                            });
                            
                        }// 4)
                        
                    });// 3)
                });// 2)
            });// 1)
        });// 0)
    });
}

// show and hide grid on snap

+ (BOOL) blockUI
{
    AlbumActionCenter *instance = [self sharedInstance];
    return instance.blockUI;
}

+ (void) getUIBlock
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.blockUI = YES;
}

+ (void) releaseUIBlock
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.blockUI = NO;

}

// show and hide grid on snap

+ (void) toggleHidableSnapDecoration
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance.snapViewController toggleHidableSnapDecoration];
}

+ (void) hideHidableSnapDecoration
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance.snapViewController hideHidableSnapDecoration];
}

+ (void) showHidableSnapDecoration
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance.snapViewController showHidableSnapDecoration];
}

// show and hide snapView navigationbar and toolbar

+ (void) toggleSnapViewNaviAndTool
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.snapViewController.navigationController.navigationBar.alpha = instance.snapViewController.navigationController.navigationBar.alpha ? 0.0 : 1.0;
    instance.snapViewController.navigationController.toolbar.alpha = instance.snapViewController.navigationController.toolbar.alpha ? 0.0 : 1.0;
}

+ (void) hideSnapViewNaviAndTool
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.snapViewController.navigationController.navigationBar.alpha = 0.0;
    instance.snapViewController.navigationController.toolbar.alpha = 0.0;
}

+ (void) showSnapViewNaviAndTool
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.snapViewController.navigationController.navigationBar.alpha = 1.0;
    instance.snapViewController.navigationController.toolbar.alpha = 1.0;
}

+ (BOOL) isSnapViewNaviAndToolVisible
{
    AlbumActionCenter *instance = [self sharedInstance];
    return (instance.snapViewController.navigationController.navigationBar.alpha > 0);
}

// rebuilding block

+ (void) immediateRebuildAlbum
{
    AlbumViewController *albumViewController = [AlbumViewController sharedInstance];
    [albumViewController.albumContainer rebuildAlbum];
}

+ (void) requestRebuildBlock:(NSString *)iso_day
{
    // 
    // the iso_day might be fresh one, if this method is called from camera.
    // 
    AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:iso_day];
    [block modified]; // make rebuild flag on
}

+ (void) requestRebuildAlbumBeforeAppear
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.shouldRebuildAlbum = YES;
}

+ (void) withdrawRequestRebuildAlbum
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.shouldRebuildAlbum = NO;
}

+ (BOOL) shouldRebuildAlbum
{
    AlbumActionCenter *instance = [self sharedInstance];
    return instance.shouldRebuildAlbum;
}

+ (void) forceRebuildAlbum
{
    AlbumActionCenter *instance = [self sharedInstance];
    
    NSLog(@"# ");
    NSLog(@"# album data structure was changed!");
    NSLog(@"# ");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    [instance.albumViewController.albumContainer rebuildAlbum];
    [UIView commitAnimations];
    
    [AlbumActionCenter withdrawRequestRebuildAlbum];
}

// scroll to bottom

+ (void) requestScrollToBottomOfAlbum
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.shouldScrollToBottomOfAlbum = YES;
}

+ (void) withdrawScrollToBottomOfAlbum
{
    AlbumActionCenter *instance = [self sharedInstance];
    instance.shouldScrollToBottomOfAlbum = NO;
}

+ (BOOL) shouldScrollToBottomOfAlbum
{
    AlbumActionCenter *instance = [self sharedInstance];
    return instance.shouldScrollToBottomOfAlbum;
}

// view control

+ (void) presentSnapViewControllerWithThumb:(AlbumThumbnailView *)thumb
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance.albumViewController.snapViewController acceptAlbumThumbnailView:thumb];
    [instance.albumViewController.navigationController pushViewController:instance.albumViewController.snapViewController animated:YES];
}

+ (void) requestLoadingPhotoInSnap
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance.snapViewController loadRawPhoto];
}

+ (void) withdrawLoadingPhotoInSnap
{
    // not yet
}

// support select mode 

+ (BOOL) isMultiSelectionMode
{
    AlbumActionCenter *instance = [self sharedInstance];
    return [instance isMultiSelectionMode];
}

+ (void) enableMultiSelectionMode
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance enableMultiSelectionMode];
}

+ (void) disableMultiSelectionMode
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance disableMultiSelectionMode];
}

// support select mode

+ (NSArray *) getSelectedThumbs
{
    AlbumActionCenter *instance = [self sharedInstance];
    return instance.selectedThumbs; // return type is not mutable
}

+ (void) clearPhotosSelection
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance clearPhotosSelection];
}

+ (void) selectPhoto:(AlbumThumbnailView *)thumb
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance selectPhoto:thumb];
}

+ (void) deselectPhoto:(AlbumThumbnailView *)thumb
{
    AlbumActionCenter *instance = [self sharedInstance];
    [instance deselectPhoto:thumb];
}

#pragma mark
#pragma mark === singleton ===
#pragma mark

+ (id) sharedInstance
{
	@synchronized(self){
		if( !sharedInstance ){
			sharedInstance = [[AlbumActionCenter alloc] init];
		}
	}
    return sharedInstance;
}

@end
