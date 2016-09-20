
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CameraController.h"
#import "CameraUtility.h"
#import "AlbumViewController.h"
#import "AlbumContainer.h"
#import "AlbumThumbnailView.h"
#import "AlbumActionCenter.h"
#import "AlbumUtility.h"
#import "AlbumDataCenter.h"
#import "ApplicationActionCenter.h"
#import "ApplicationDecoration.h"

#pragma mark
#pragma mark ***** UIActionSheetDelegate objects *****
#pragma mark

@implementation AlbumViewControllerActionSheetHandlerForSaveOfActionMode
@synthesize albumViewController;
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 ){
        // 
        // copy selected photos to Camera Roll
        // 
        NSLog(@"Action : save to Camera Roll");
        
        // disable ui action
        [albumViewController disableAlbumActionButtons];
        [albumViewController disableAlbumToolbarButtons];
        
        // get selected photo from action center
        NSArray *selected_photos = [NSArray arrayWithArray:[AlbumActionCenter getSelectedThumbs]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // get and start indicator
            AlbumActionCopyToCameraRollProgressBar *progress = [AlbumActionCenter getCopyToCameraRollProgressBarWithFrame:albumViewController.view.frame withNumber:selected_photos.count];
            [albumViewController.view addSubview:progress];
            [progress showAndStart];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // copy to camera roll
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AlbumUtility copyPhotosToCameraRoll:selected_photos 
                                         withProgressBar:progress 
                                       withProgressBlock:^(void){
                                           
                                           [progress countDown];
                                           if( [progress completed] ){
                                               NSLog(@"progress completed");
                                               [progress hideAndEnd];
                                               
                                               // go back to album view mode
                                               [albumViewController backtoAlbumView];
                                               NSLog(@"Action : copy done.");
                                               
                                               // regress ui action
                                               [albumViewController enableAlbumActionButtons];
                                               [albumViewController enableAlbumToolbarButtons];
                                               
                                               //dispatch_async(dispatch_get_main_queue(), ^{
                                               [progress removeFromSuperview];
                                               
                                           }else{
                                               NSLog(@"processing...");
                                           }
                                           
                                       }];
                });
            });
        });
    }
    else if( buttonIndex == actionSheet.cancelButtonIndex ){
        // cancel
        NSLog(@"Action : cancel");
    }
}
@end

@implementation AlbumViewControllerActionSheetHandlerForTrashOfActionMode
@synthesize albumViewController;
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 ){
        // delete selected photos
        NSLog(@"### Action : deleting selected photos");
        
        // get delete targets
        NSArray *delete_photos = [NSArray arrayWithArray:[AlbumActionCenter getSelectedThumbs]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"# phase.1");
            
            // AlbumActionCenter removePhotos get global lock
            [AlbumActionCenter removePhotos:delete_photos withCompletionBlock:^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"# phase.2");
                    // animate trashing, fadeout deleted photos, and with day title if the folder also should delete
                    for( AlbumThumbnailView *thumb in delete_photos ){
                        [thumb trashAnimation];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"# phase.3.0");
                        [UIView animateWithDuration:0.37f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                                         animations:^{
                                             NSLog(@"# phase.3.1");
                                             [albumViewController.albumContainer rebuildAlbum];
                                         } 
                                         completion:^(BOOL finished){
                                             NSLog(@"# phase.4");
                                             [albumViewController backtoAlbumView];
                                             
                                             // request update LibIcon
                                             [ApplicationActionCenter requestShouldUpdateLibIcon];
                                         }];
                    });
                    
                    /*
                     dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"# phase.3");
                     // rebuild album, with UIAnimation
                     [UIView beginAnimations:nil context:NULL];
                     [UIView setAnimationDuration:0.3f];
                     [albumViewController.albumContainer rebuildAlbum];
                     [UIView commitAnimations];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"# phase.4");
                     // go back to album view mode
                     [albumViewController backtoAlbumView];
                     
                     NSLog(@"# Action : delete done.");
                     });
                     });
                     */
                });
            }];
        });
    }
    else if( buttonIndex == actionSheet.cancelButtonIndex ){
        // cancel
        NSLog(@"Action : cancel");
    }
}
@end


#pragma mark
#pragma mark ***** AlbumViewController *****
#pragma mark

@interface AlbumViewController(Private)
// ui transition
- (void) backtoPreview;
- (void) albumViewActionHandler;
- (void) albumActionSaveHandler;
- (void) albumActionTrashHandler;
// navigationbar and toolbar controll
- (void) bringupAlbumViewNavigationBarButtonItems;
- (void) bringupAlbumViewToolBarButtonItems;
- (void) bringdownAlbumViewToolBarButtonItems;
- (void) bringupAlbumActionNavigationBarButtonItems;
- (void) bringupAlbumActionToolbarButtonItems;
- (void) bringdownAlbumActionToolbarButtonItems;
- (void) terminateCubeAnimation;
@end

@implementation AlbumViewController
@synthesize albumContainer, snapViewController;
@synthesize titleAlbumView, titleSelectPhoto;

static AlbumViewController *sharedInstance = nil;

#pragma mark
#pragma mark === ui transition, UIActionSheetDelegate/UIButton ===
#pragma mark

- (void) enableAlbumToolbarButtons
{
    cancelButtonItem.enabled = YES;
}
- (void) disableAlbumToolbarButtons
{
    cancelButtonItem.enabled = NO;
}

- (void) enableAlbumActionButtons
{
    shareButton.enabled = YES;
    deleteButton.enabled = YES;
}
- (void) disableAlbumActionButtons
{
    shareButton.enabled = NO;
    deleteButton.enabled = NO;
}
// state change
- (void) photoSelected
{
    [self enableAlbumActionButtons];
}
- (void) photoNotSelected
{
    [self disableAlbumActionButtons];
}

- (void) backtoPreview
{
    [ApplicationActionCenter bringupCamera];
}

- (void) backtoAlbumView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // clear action
        [AlbumActionCenter disableMultiSelectionMode];
        [AlbumActionCenter clearPhotosSelection];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // switch navigationbar and toolbar to view mode
            [self bringdownAlbumActionToolbarButtonItems];
            [self bringupAlbumViewToolBarButtonItems];
            [self bringupAlbumViewNavigationBarButtonItems];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // there might be unloaded iso_days
                [albumContainer delayedThumbnailLoad:albumContainer];
            });
        });
    });
}

- (void) albumViewActionHandler
{
    // switch navigationbar and toolbar to action mode
    [self bringdownAlbumViewToolBarButtonItems];
    [self bringupAlbumActionToolbarButtonItems];
    [self bringupAlbumActionNavigationBarButtonItems];
    [AlbumActionCenter enableMultiSelectionMode];
}

- (void) albumActionShareHandler
{
    albumViewControllerActionSheetHandlerForSaveOfActionMode = [[AlbumViewControllerActionSheetHandlerForSaveOfActionMode alloc] init];
    albumViewControllerActionSheetHandlerForSaveOfActionMode.albumViewController = self;
    
    NSString *copyToCameraRollStr = NSLocalizedString(@"Copy to Camera Roll", @"Album action sheet, copy to camera roll action");
    NSString *cancelStr           = NSLocalizedString(@"Cancel", @"Album action sheet, cancel action");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = albumViewControllerActionSheetHandlerForSaveOfActionMode;
    [sheet addButtonWithTitle:copyToCameraRollStr];
    [sheet addButtonWithTitle:cancelStr];
    sheet.cancelButtonIndex = 1;
    //sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent; // same as UIActionSheetStyleBlackOpaque (not translucent), ios5 bug?
    [sheet showFromToolbar:self.navigationController.toolbar];
}

- (void) albumActionTrashHandler
{
    albumViewControllerActionSheetHandlerForTrashOfActionMode = [[AlbumViewControllerActionSheetHandlerForTrashOfActionMode alloc] init];
    albumViewControllerActionSheetHandlerForTrashOfActionMode.albumViewController = self;
    
    NSString *deleteStr = NSLocalizedString(@"Delete selected photos", @"Album action sheet, delete selected photos action");
    NSString *cancelStr = NSLocalizedString(@"Cancel", @"Album action sheet, cancel action");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = albumViewControllerActionSheetHandlerForTrashOfActionMode;
    [sheet addButtonWithTitle:deleteStr];
    [sheet addButtonWithTitle:cancelStr];
    sheet.destructiveButtonIndex = 0;
    sheet.cancelButtonIndex = 1;
    //sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent; // same as UIActionSheetStyleBlackOpaque (not translucent), ios5 bug?
    [sheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark
#pragma mark === observing button availability ===
#pragma mark

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"detect key change");
    if( [keyPath isEqualToString:@"selectedCount"] ){
        AlbumActionCenter *action = (AlbumActionCenter *)object;
        NSLog(@"detect count change:%d",action.selectedCount);
        if( action.selectedCount > 0 ){
            [self enableAlbumActionButtons];
            // update view title
            NSString *countStr = [NSString stringWithFormat:@" (%d)",action.selectedCount];
            NSString *newTitleStr = [titleSelectPhoto stringByAppendingString:countStr];
            [self.navigationItem setTitle:newTitleStr];
        }else{
            [self disableAlbumActionButtons];
            // update view title
            [self.navigationItem setTitle:titleSelectPhoto];
        }
    }
}

#pragma mark
#pragma mark === support CubeAnimation ===
#pragma mark

- (void) terminateCubeAnimation
{
    if( [ApplicationDecoration cubeAnimationRunning] ){
        //[ApplicationDecoration stopCubeAnimation];
        [ApplicationDecoration forceTerminateCubeAnim];
    }
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
    self = [super init];
    sharedInstance = self;
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    // 
    // [safty invocation of view appearance procedure]
    // 
    // in the appearance of Album view,
    // there might be no confliction in graphics context.
    // but to get safty invocation of procedure, make it serialize.
    // 
    // 
    NSLog(@"*** AlbumViewController viewWillAppear called ***");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"*** phase.1");
        [super viewWillAppear:animated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"*** phase.2");
            // 
            // initialize AlbumContainer if not yet initalized
            // 
            if( albumContainer == nil ){
                NSLog(@"# enter init AlbumContainer");
                CGRect finderRect = [DeviceConfig screenRect];
                albumContainer = [[AlbumContainer alloc] initWithFrame:finderRect];
                [self.view addSubview:albumContainer];
            }
            
            // 
            // initialize SnapViewController if not yet initialized
            // 
            if( snapViewController == nil ){
                NSLog(@"# enter init SnapViewController");
                snapViewController = [[SnapViewController alloc] init];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"*** phase.3");
                // 
                // skipping shouldRebuildAlbum causes hidden-selectionImage-issue.
                // so invoke this.
                // 
                if( [AlbumActionCenter shouldRebuildAlbum] ){
                    NSLog(@"# ");
                    NSLog(@"# album data structure was changed!");
                    NSLog(@"# ");
                    
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:1.0f];
                    [albumContainer rebuildAlbum];
                    [UIView commitAnimations];
                    
                    [AlbumActionCenter withdrawRequestRebuildAlbum];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"*** phase.4");
                    // 
                    // terminate CubeAnimation if running
                    // 
                    [self terminateCubeAnimation];
                    
                    // album view was loaded.
                    // offset is now defined by offset
                    [AlbumActionCenter withdrawScrollToBottomOfAlbum];
                    
                    // 
                    // viewController called by ApplicationActionCenter is successfully appeared.
                    // 
                    [ApplicationActionCenter successToBooting];
                });
            });
        });
    });
}

- (void) viewDidLoad 
{
    NSLog(@"*** AlbumViewController viewDidLoad called ***");
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // setup localized view title
    titleAlbumView = NSLocalizedString(@"Album view title", @"The title of Album View");
    titleSelectPhoto = NSLocalizedString(@"Album select mode title", @"The title of Album in Select Mode");
    
    // to enable toolBar and navigationBar configuration,
    // at least one subview should be added in this viewDidLoad phase?
    
    UIImageView *album_bg = [[UIImageView alloc] initWithImage:[DeviceConfig AlbumBgImage]];
    [self.view addSubview:album_bg];
    
    //albumContainer = [[AlbumContainer alloc] initWithFrame:finderRect];
    //[self.view addSubview:albumContainer];
    
    // setup view controller it self
    self.view.multipleTouchEnabled = YES;
//    self.wantsFullScreenLayout = YES; // DEPRECATED in ios7
	
    // navigationbar
	self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    
    // toolbar
	self.navigationController.toolbarHidden = NO;
	self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	self.navigationController.toolbar.translucent = YES;
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    // prepare snapViewController
    //snapViewController = [[SnapViewController alloc] init];
    
    // then, bringup toolBar and navigationBar
    [self bringupAlbumViewToolBarButtonItems];
    [self bringupAlbumViewNavigationBarButtonItems];
    
    // scroll to the bottom of the album view at the first time
    [AlbumActionCenter requestScrollToBottomOfAlbum];
    
    // observing
    AlbumActionCenter *albumActionCenter = [AlbumActionCenter sharedInstance];
    [albumActionCenter addObserver:self forKeyPath:@"selectedCount" options:NSKeyValueObservingOptionNew context:NULL]; // watch selection
    albumActionCenter.albumViewController = self; // watch navigation
}

// album view : navigation and toolbar
- (void) bringupAlbumViewNavigationBarButtonItems
{
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(backtoPreview)];
    // color of camera button
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat darkred[] = {(float)35/256,(float)98/256,(float)222/256,1.0};
    CGColorRef darkredc = CGColorCreate(rgb,darkred);
    doneButtonItem.tintColor = [UIColor colorWithCGColor:darkredc];
    CGColorSpaceRelease(rgb);
    CGColorRelease(darkredc);
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    NSLog(@"### bringupAlbumViewNavigationBarButtonItems with title %@",titleAlbumView);
    
	[self.navigationItem setTitle:titleAlbumView];
}
- (void) bringupAlbumViewToolBarButtonItems
{
    UIBarButtonItem *b0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(albumViewActionHandler)];
    UIBarButtonItem *bf = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:b0,bf,nil];
    [self setToolbarItems:buttons animated:YES];
}
- (void) bringdownAlbumViewToolBarButtonItems
{
    [self setToolbarItems:nil animated:YES];
}

// album action : navigation and toolbar
- (void) bringupAlbumActionNavigationBarButtonItems
{
    cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backtoAlbumView)];
    // color of cancel button
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat darkred[] = {(float)35/256,(float)98/256,(float)222/256,1.0};
    CGColorRef darkredc = CGColorCreate(rgb,darkred);
    cancelButtonItem.tintColor = [UIColor colorWithCGColor:darkredc];
    CGColorSpaceRelease(rgb);
    CGColorRelease(darkredc);
	[self.navigationItem setRightBarButtonItem:cancelButtonItem];
	[self.navigationItem setTitle:titleSelectPhoto];
}
- (void) bringupAlbumActionToolbarButtonItems
{
    NSString *shareStr  = NSLocalizedString(@"Share", @"Album action tool bar, share tool button");
    NSString *deleteStr = NSLocalizedString(@"Delete", @"Album action tool bar, delete tool button");
    
    shareButton = [[UIBarButtonItem alloc] initWithTitle:shareStr style:UIBarButtonItemStyleBordered target:self action:@selector(albumActionShareHandler)];
    deleteButton = [[UIBarButtonItem alloc] initWithTitle:deleteStr style:UIBarButtonItemStyleBordered target:self action:@selector(albumActionTrashHandler)];
    UIBarButtonItem *bf = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // disable buttons until selected a photo
    shareButton.enabled = NO;
    deleteButton.enabled = NO;
    // set autorelease
    // color of delete
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat darkred[] = {(float)160/256,(float)70/256,(float)70/256,1.0};
    CGColorRef darkredc = CGColorCreate(rgb,darkred);
    deleteButton.tintColor = [UIColor colorWithCGColor:darkredc];
    CGColorSpaceRelease(rgb);
    CGColorRelease(darkredc);
    NSArray *buttons = [NSArray arrayWithObjects:shareButton,bf,deleteButton,nil];
    [self setToolbarItems:buttons animated:YES];
}
- (void) bringdownAlbumActionToolbarButtonItems
{
    [self setToolbarItems:nil animated:YES];
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

+ (id) sharedInstance
{
    // shared instance is always initialized by viewDidLoad
    @synchronized(self){
        if( !sharedInstance ){
            sharedInstance = [[self alloc] init]; // so always false
        }
    }
    return sharedInstance;
}

@end
