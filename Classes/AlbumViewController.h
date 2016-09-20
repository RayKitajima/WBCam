
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "SnapViewController.h"
#import "AlbumContainer.h"

@class AlbumViewControllerActionSheetHandlerForSaveOfActionMode;
@class AlbumViewControllerActionSheetHandlerForTrashOfActionMode;

@interface AlbumViewController : UIViewController <UINavigationControllerDelegate>
{
    SnapViewController *snapViewController;
    AlbumContainer *albumContainer;
    
    UIBarButtonItem *cancelButtonItem;
    UIBarButtonItem *deleteButton;
    UIBarButtonItem *shareButton;
    
    NSString *titleAlbumView;
    NSString *titleSelectPhoto;
    
    // keep action sheet handerl
    AlbumViewControllerActionSheetHandlerForSaveOfActionMode *albumViewControllerActionSheetHandlerForSaveOfActionMode;
    AlbumViewControllerActionSheetHandlerForTrashOfActionMode *albumViewControllerActionSheetHandlerForTrashOfActionMode;
}

@property (retain) SnapViewController *snapViewController;
@property (retain) AlbumContainer *albumContainer;
@property (retain) NSString *titleAlbumView;
@property (retain) NSString *titleSelectPhoto;

- (void) backtoAlbumView;
- (void) albumViewActionHandler;

- (void) enableAlbumToolbarButtons;
- (void) disableAlbumToolbarButtons;

- (void) enableAlbumActionButtons;
- (void) disableAlbumActionButtons;

+ (id) sharedInstance;

@end

// ActionSheet handlers for action mode
@interface AlbumViewControllerActionSheetHandlerForSaveOfActionMode : NSObject <UIActionSheetDelegate>
{
    AlbumViewController *albumViewController;
}
@property (retain) AlbumViewController *albumViewController;
@end

@interface AlbumViewControllerActionSheetHandlerForTrashOfActionMode : NSObject <UIActionSheetDelegate>
{
    AlbumViewController *albumViewController;
}
@property (retain) AlbumViewController *albumViewController;
@end

