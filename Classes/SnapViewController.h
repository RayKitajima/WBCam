
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "SnapContainer.h"
#import "AlbumThumbnailView.h"
#import "SnapDayLabel.h"

@class SnapViewControllerActionSheetHandlerForAction;
@class SnapViewControllerActionSheetHandlerForTrash;

// SnapViewController itself
@interface SnapViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIBarButtonItem *doneButtonItem;
    
    UIBarButtonItem *prevButton;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *trashButton;
    UIBarButtonItem *actionButton;
    
    UIImageView *background_imageView;
    UIImageView *grid_imageView;
    SnapDayLabel *snapDayLabel;
    SnapContainer *snapContainer;
    AlbumThumbnailView *thumb; // current target AlbumThumbnailView object
    
    // keep action sheet handler
    SnapViewControllerActionSheetHandlerForAction *snapViewControllerActionSheetHandlerForAction;
    SnapViewControllerActionSheetHandlerForTrash *snapViewControllerActionSheetHandlerForTrash;
}
@property (retain) SnapContainer *snapContainer;
@property (retain) AlbumThumbnailView *thumb;
- (void) toggleHidableSnapDecoration;
- (void) hideHidableSnapDecoration;
- (void) showHidableSnapDecoration;
- (void) setupGridView;
- (void) setupDayLabel;
- (void) setupDayLabelWithCompletionBlock:(void (^)(void))completionBlock;
- (void) setupBackgroundView;
- (void) acceptAlbumThumbnailView:(AlbumThumbnailView *)thumb;
- (void) acceptAlbumThumbnailViewObjectOnly:(AlbumThumbnailView *)thumb; // specialized for trash animation
- (void) cleanupHidingImageView; // specialized for next/prev animation
- (void) cleanupUpdatedImageView; // specialized for trash animation
- (void) cleanupUpdatedImageViewWithCompletionBlock:(void (^)(void))completionBlock;
- (void) loadRawPhoto;
- (void) enableSnapToolbarButtons;
- (void) disableSnapToolbarButtons;
- (void) enableSnapActionButtons;
- (void) disableSnapActionButtons;
@end

// ActionSheet handlers
@interface SnapViewControllerActionSheetHandlerForAction : NSObject <UIActionSheetDelegate>
{
    SnapViewController *snapViewController;
}
@property (retain) SnapViewController *snapViewController;
@end
@interface SnapViewControllerActionSheetHandlerForTrash : NSObject <UIActionSheetDelegate>
{
    SnapViewController *snapViewController;
}
@property (retain) SnapViewController *snapViewController;
@end



