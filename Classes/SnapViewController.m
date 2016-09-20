
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "SnapViewController.h"
#import "CameraController.h"
#import "CameraHelper.h"
#import "CameraSession.h"
#import "CameraUtility.h"
#import "PreviewHelper.h"
#import "AlbumActionCenter.h"
#import "AlbumDecoration.h"
#import "AlbumDataCenter.h"
#import "AlbumUtility.h"
#import "ApplicationActionCenter.h"
#import "SnapDayLabel.h"
#import "SnapImageView.h"


@interface SnapViewController(Private)
- (void) actionHandler;
- (void) trashHandler;
- (void) backtoPreview;
- (void) bringupLibraryViewNavigationBarButtonItems;
- (void) bringupLibraryViewToolBarButtonItems;
- (void) resetComponent;
- (void) checkNextPrevAvailability;
- (BOOL) isNextSnapAvailable;
- (BOOL) isPrevSnapAvailable;
@end


#pragma mark
#pragma mark === UIActionSheetDelegate objects ===
#pragma mark

@implementation SnapViewControllerActionSheetHandlerForAction
@synthesize snapViewController;
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 
    // use current image as white balance
    // 
    if( buttonIndex == 0 ){
        NSLog(@"Action : use for WB");
        
        // ensure manual whitebalance
        [CameraSession ensureManualWhiteBalanceMode];
        
        // get current image object
        UIImage *image = [snapViewController.snapContainer getSnapImage];
        
        // request CameraController to adjust whitebalance by the selected image
        // the CameraController will execute this block by sending it to runAutoWhiteBalanceBlockWithCompletionBlock
        [ApplicationActionCenter requestWhitebalanceByImageWithBlock:^(void){
            NSLog(@"Action : WB by slected image");
            
            // update whitebalance parameter with selected image
            [CameraHelper notifyWhiteBalanceImage:image];
            
            // then backto preview with selected whitebalance
            [CameraController changeWBModeNotificationToManual];
            
            // withdraw request
            [ApplicationActionCenter withdrawRequestWhitebalanceByImage];
            
        }];
        
        // then, back to camera
        [ApplicationActionCenter bringupCamera];
    }
    else if( buttonIndex == 1 ){
        // 
        // copy current photo to Camera Roll
        // 
        NSLog(@"Action : save to Camera Roll");
        
        // disable ui action
        [snapViewController disableSnapActionButtons];
        [snapViewController disableSnapToolbarButtons];
        
        AlbumThumbnailView *thumb = snapViewController.thumb;
        NSArray *selected_photos = [NSArray arrayWithObjects:thumb,nil];;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // get and start indicator
            //AlbumActionCopyToCameraRollProgressBar *progress = [AlbumActionCenter getCopyToCameraRollProgressBarWithFrame:snapViewController.view.frame withNumber:selected_photos.count];
            AlbumActionCopyToCameraRollProgressBar *progress = [AlbumActionCenter getCopyToCameraRollProgressBarWithFrame:[DeviceConfig screenRect] withNumber:selected_photos.count];
            [snapViewController.view addSubview:progress];
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
                                               //[snapViewController backtoAlbumView];
                                               NSLog(@"Action : copy done.");
                                               
                                               // regress ui action
                                               [snapViewController enableSnapActionButtons];
                                               [snapViewController enableSnapToolbarButtons];
                                               
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
    // 
    // cancel
    // 
    else if( buttonIndex == actionSheet.cancelButtonIndex ){
        NSLog(@"Action : cancel");
    }
}
@end

@implementation SnapViewControllerActionSheetHandlerForTrash
@synthesize snapViewController;
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 ){
        // delete
        NSLog(@"Trash : delete");
        
        // before move, hide day label
        [snapViewController hideHidableSnapDecoration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // prepare
            AlbumThumbnailView *last  = [AlbumDataCenter loadLatestPhotoAsAlbumThumbnailView];
            AlbumThumbnailView *thumb = snapViewController.thumb;
            AlbumThumbnailView *swap  = nil;
            if( [thumb.fileName isEqualToString:last.fileName] && [thumb.iso_day isEqualToString:last.iso_day] ){
                // now at the last
                swap = [thumb getPrev];
            }else{
                swap = [thumb getNext];
            }
            
            // check preview of previous photo
            // if there is no more photo in the album, set flag
            UIImageView *previewImageView = [swap previewImageView];
            
            BOOL hasNabe = NO;
            BOOL nomorePhoto = NO;
            if( previewImageView != nil ){ 
                hasNabe = YES;
            }
            if( [swap isEqual:thumb] ){ 
                // only one photo in the album
                nomorePhoto = YES;
                hasNabe = NO;
                swap = nil;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // crop
                UIGraphicsBeginImageContext( snapViewController.snapContainer.bounds.size );
                CGContextRef resizedContext = UIGraphicsGetCurrentContext();
                CGContextTranslateCTM(resizedContext, -snapViewController.snapContainer.imageScrollView.contentOffset.x, -snapViewController.snapContainer.imageScrollView.contentOffset.y);
                [snapViewController.snapContainer.imageScrollView.layer renderInContext:resizedContext];
                UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                UIImageView *imageView = [[UIImageView alloc] initWithImage:cropImage];
                [snapViewController.view addSubview:imageView];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [snapViewController.snapContainer hideSnapImage];
                    [snapViewController acceptAlbumThumbnailViewObjectOnly:swap];
                    snapViewController.snapContainer.layer.opacity = 0.0f;
                    [snapViewController.snapContainer showSnapImage];
                    
                    [snapViewController cleanupHidingImageView];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int cropWidth  = snapViewController.snapContainer.bounds.size.width;
                        int cropHeight = snapViewController.snapContainer.bounds.size.height;
                        int trash_margin    = 20;
                        CGPoint trash_point = CGPointMake(cropWidth - trash_margin, cropHeight);
                        CGRect faded_rect   = CGRectMake(cropWidth - trash_margin, cropHeight, 1, 1);
                        
                        // fade out to the trash icon location at right bottom
                        [UIView animateWithDuration:0.5f animations:^{
                            imageView.center = trash_point;
                            imageView.layer.opacity = 0;
                            imageView.bounds = faded_rect;
                            snapViewController.snapContainer.layer.opacity = 1.0f;
                        }];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]]; // wait animation
                            
                            // do delete
                            [AlbumActionCenter removePhotos:[NSArray arrayWithObject:thumb] withCompletionBlock:^(void){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    // request album view update
                                    //[AlbumActionCenter immediateRebuildAlbum]; // cause empty iso_day display
                                    [AlbumActionCenter requestRebuildAlbumBeforeAppear];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        // 
                                        // dont call albumDayBlockForIsoDay here!
                                        // the method creates new iso_day entry in the manifest, that should be deleted by removePhoto
                                        // 
                                        // check empty of the iso_day, and request rebuild the block 
                                        //AlbumDayBlock *block = [AlbumDataCenter albumDayBlockForIsoDay:thumb.iso_day];
                                        //[block modified];
                                        //[block removeDateFolderIfEmpty]; // MUST called with modified
                                        
                                        if( hasNabe ){
                                            // re-accept new thumb, if there is swap target photo
                                            //NSLog(@"# moved to swap target snap");
                                            [snapViewController cleanupUpdatedImageView];
                                            [snapViewController showHidableSnapDecoration];
                                            [imageView removeFromSuperview];
                                        }else{
                                            // return to album, if not
                                            //NSLog(@"# no more snap on the album");
                                            [imageView removeFromSuperview];
                                            [snapViewController.navigationController popViewControllerAnimated:YES];
                                        }
                                        
                                        // check next prev button availability
                                        [snapViewController checkNextPrevAvailability];
                                        
                                        // request update LibIcon
                                        [ApplicationActionCenter requestShouldUpdateLibIcon];
                                    });
                                });
                            }];
                            
                        });
                    });
                });
            });
        });
    }
    else if( buttonIndex == actionSheet.cancelButtonIndex ){
        // cancel
        NSLog(@"Trash : cancel");
    }
}
@end


@implementation SnapViewController
@synthesize snapContainer, thumb;

#pragma mark
#pragma mark === gate for UIActionSheetDelegate ===
#pragma mark

- (void) actionHandler
{
    // make handler
    snapViewControllerActionSheetHandlerForAction = [[SnapViewControllerActionSheetHandlerForAction alloc] init];
    snapViewControllerActionSheetHandlerForAction.snapViewController = self;
    
    NSString *useForWhitebalanceStr = NSLocalizedString(@"Use for White Balance", @"Snap view action sheet, use for whitebalance action");
    NSString *copyToCameraRollStr   = NSLocalizedString(@"Copy to Camera Roll", @"Album action sheet, copy to camera roll action");
    NSString *cancelStr             = NSLocalizedString(@"Cancel", @"General Cancel action");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = snapViewControllerActionSheetHandlerForAction;
    [sheet addButtonWithTitle:useForWhitebalanceStr];
    [sheet addButtonWithTitle:copyToCameraRollStr];
    [sheet addButtonWithTitle:cancelStr];
    sheet.cancelButtonIndex = 2;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [sheet showInView:self.view];
}

- (void) trashHandler
{
    // make handler
    snapViewControllerActionSheetHandlerForTrash = [[SnapViewControllerActionSheetHandlerForTrash alloc] init];
    snapViewControllerActionSheetHandlerForTrash.snapViewController = self;
    
    NSString *deleteStr = NSLocalizedString(@"Delete this photo", @"Snap view action sheet, delete this photo action");
    NSString *cancelStr = NSLocalizedString(@"Cancel", @"General Cancel action");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = snapViewControllerActionSheetHandlerForTrash;
    [sheet addButtonWithTitle:deleteStr];
    [sheet addButtonWithTitle:cancelStr];
    sheet.destructiveButtonIndex = 0;
    sheet.cancelButtonIndex = 1;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [sheet showInView:self.view];
}


#pragma mark
#pragma mark === gate ===
#pragma mark

- (void) backtoPreview
{
    [ApplicationActionCenter bringupCamera];
}

- (void) checkNextPrevAvailability
{
    if( [self isNextSnapAvailable] ){
        nextButton.enabled = YES;
    }else{
        nextButton.enabled = NO;
    }
    if( [self isPrevSnapAvailable] ){
        prevButton.enabled = YES;
    }else{
        prevButton.enabled = NO;
    }
}

- (BOOL) isNextSnapAvailable
{
    BOOL nextSnapAvailable = NO;
    AlbumThumbnailView *last = [AlbumDataCenter loadLatestPhotoAsAlbumThumbnailView];
    if( [thumb.fileName isEqualToString:last.fileName] && [thumb.iso_day isEqualToString:last.iso_day] ){
        // now at the last
        nextSnapAvailable = NO;
    }else{
        nextSnapAvailable = YES;
    }
    return nextSnapAvailable;
}

- (BOOL) isPrevSnapAvailable
{
    BOOL prevSnapAvailable = NO;
    AlbumThumbnailView *first = [AlbumDataCenter loadFirstPhotoAsAlbumThumbnailView];
    if( [thumb.fileName isEqualToString:first.fileName] && [thumb.iso_day isEqualToString:first.iso_day] ){
        // now at the last
        prevSnapAvailable = NO;
    }else{
        prevSnapAvailable = YES;
    }
    return prevSnapAvailable;
}

- (void) nextSnap
{
    nextButton.enabled = NO;
    
    AlbumThumbnailView *next = [thumb getNext];
    
    if( next == nil ){ return; }
    
    // check preview of previous photo
    // if there is no more photo in the album, set flag
    UIImageView *previewImageView = [next previewImageView];
    BOOL hasNabe = NO;
    if( previewImageView != nil ){ hasNabe = YES; }
    
    // before move, hide day label
    [self hideHidableSnapDecoration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // crop
        UIGraphicsBeginImageContext( snapContainer.bounds.size );
        CGContextRef resizedContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(resizedContext, -snapContainer.imageScrollView.contentOffset.x, -snapContainer.imageScrollView.contentOffset.y);
        [snapContainer.imageScrollView.layer renderInContext:resizedContext];
        UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cropImage];
        [self.view addSubview:imageView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [snapContainer hideSnapImage];
            [self acceptAlbumThumbnailViewObjectOnly:next];
            snapContainer.layer.opacity = 0.0f;
            [snapContainer showSnapImage];
            
            [self cleanupHidingImageView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int cropWidth  = snapContainer.bounds.size.width;
                int cropHeight = snapContainer.bounds.size.height;
                
                // fade out to the left side
                [UIView animateWithDuration:0.5f animations:^{
                    imageView.center = CGPointMake(-(cropWidth/2), cropHeight/2);
                    imageView.layer.opacity = 0;
                    snapContainer.layer.opacity = 1.0f;
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    nextButton.enabled = YES;
                    
                    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
                    
                    if( hasNabe ){
                        // re-accept new thumb, if there is previous photo
                        //NSLog(@"# moved to previous snap");
                        [self cleanupUpdatedImageViewWithCompletionBlock:^(void){
                            [self showHidableSnapDecoration];
                        }];
                        [imageView removeFromSuperview];
                    }else{
                        // return to album, if not
                        //NSLog(@"# no more snap on the album");
                        //[self dismissModalViewControllerAnimated:YES]; // deprecated
						[self dismissViewControllerAnimated:YES completion:nil];
                        [imageView removeFromSuperview];
                    }
                    
                    // check next prev button availability
                    [self checkNextPrevAvailability];
                });
            });
        });
    });
}

- (void) prevSnap
{
    prevButton.enabled = NO;
    
    AlbumThumbnailView *prev = [thumb getPrev];
    
    if( prev == nil ){ return; }
    
    // check preview of previous photo
    // if there is no more photo in the album, set flag
    UIImageView *previewImageView = [prev previewImageView];
    BOOL hasNabe = NO;
    if( previewImageView != nil ){ hasNabe = YES; }
    
    // before move, hide day label
    [self hideHidableSnapDecoration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // crop
        UIGraphicsBeginImageContext( snapContainer.bounds.size );
        CGContextRef resizedContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(resizedContext, -snapContainer.imageScrollView.contentOffset.x, -snapContainer.imageScrollView.contentOffset.y);
        [snapContainer.imageScrollView.layer renderInContext:resizedContext];
        UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cropImage];
        [self.view addSubview:imageView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [snapContainer hideSnapImage];
            [self acceptAlbumThumbnailViewObjectOnly:prev];
            snapContainer.layer.opacity = 0.0f;
            [snapContainer showSnapImage];
            
            [self cleanupHidingImageView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int cropWidth  = snapContainer.bounds.size.width;
                int cropHeight = snapContainer.bounds.size.height;
                
                // fade out to the right side
                [UIView animateWithDuration:0.5f animations:^{
                    imageView.center = CGPointMake(cropWidth*1.5, cropHeight/2);
                    imageView.layer.opacity = 0;
                    snapContainer.layer.opacity = 1.0f;
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    prevButton.enabled = YES;
                    
                    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
                    
                    if( hasNabe ){
                        // re-accept new thumb, if there is previous photo
                        //NSLog(@"# moved to previous snap");
                        [self cleanupUpdatedImageViewWithCompletionBlock:^(void){
                            [self showHidableSnapDecoration];
                        }];
                        [imageView removeFromSuperview];
                    }else{
                        // return to album, if not
                        //NSLog(@"# no more snap on the album");
                        //[self dismissModalViewControllerAnimated:YES];
						[self dismissViewControllerAnimated:YES completion:nil];
                        [imageView removeFromSuperview];
                    }
                    
                    // check next prev button availability
                    [self checkNextPrevAvailability];
                });
            });
        });
    });
}

#pragma mark
#pragma mark === target snap loader preview/raw ===
#pragma mark

// specialized for next/prev animation
// clear all decoration
- (void) cleanupHidingImageView
{
    // clear other subviews
    NSArray *views = self.snapContainer.imageScrollView.imageViewWrapper.imageView.subviews;
    for( int i=0; i<views.count; i++ ){
        UIView *subView = [views objectAtIndex:i];
        [subView removeFromSuperview];
    }
}

// specialized for trash animation
// clear decoration and re-apply them (shadow and background)
- (void) cleanupUpdatedImageView
{
    // clear other subviews
    NSArray *views = self.view.subviews;
    for( int i=0; i<views.count; i++ ){
        UIView *subView = [views objectAtIndex:i];
        if( ![subView isEqual:snapContainer] ){
            [subView removeFromSuperview];
        }
    }
    
    [snapContainer updateShadow];
    [self setupGridView];
    [self setupDayLabel];
    [self setupBackgroundView];
}
- (void) cleanupUpdatedImageViewWithCompletionBlock:(void (^)(void))completionBlock
{
    // clear other subviews
    NSArray *views = self.view.subviews;
    for( int i=0; i<views.count; i++ ){
        UIView *subView = [views objectAtIndex:i];
        if( ![subView isEqual:snapContainer] ){
            [subView removeFromSuperview];
        }
    }
    
    [snapContainer updateShadow];
    [self setupGridView];
    [self setupDayLabelWithCompletionBlock:completionBlock];
    [self setupBackgroundView];
}

// specialized for trash animation
// only update image,
// should be called with cleanupUpdatedImageView and checkNextPrevAvailability
- (void) acceptAlbumThumbnailViewObjectOnly:(AlbumThumbnailView *)newThumb
{
    NSLog(@"acceptAlbumThumbnailViewObjectOnly : %@/%@",newThumb.iso_day,newThumb.fileName);
    // reset scrollView (reset, raw photo status)
    [self.snapContainer.imageScrollView resetScrollView];
    
    thumb = newThumb;
    
    // load preview
    UIImageView *previewImageView = [thumb previewImageView];
    UIImage *previewImage = previewImageView.image;
    [snapContainer setSnapImageObjectOnly:previewImage];
}

// simple fade version, used when comming from album view
- (void) acceptAlbumThumbnailView:(AlbumThumbnailView *)newThumb
{
    NSLog(@"acceptAlbumThumbnailView : %@/%@",newThumb.iso_day,newThumb.fileName);
    
    // reset image in the scrollView
    //[self resetComponent];
    
    // reset scrollView (reset, raw photo status)
    [self.snapContainer.imageScrollView resetScrollView];
    
    // clear other subviews
    NSArray *views = self.view.subviews;
    for( int i=0; i<views.count; i++ ){
        UIView *subView = [views objectAtIndex:i];
        if( ![subView isEqual:snapContainer] ){
            [subView removeFromSuperview];
        }
    }
    
    thumb = newThumb;
    
    // load preview
    UIImageView *previewImageView = [thumb previewImageView];
    UIImage *previewImage = previewImageView.image;
    [snapContainer setSnapImage:previewImage];
    
    snapContainer.layer.opacity = 0.5f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [snapContainer showSnapImage];
    snapContainer.layer.opacity = 1.0f;
    [UIView commitAnimations];
    
    // then reset grid and background
    [self setupGridView];
    [self setupDayLabel];
    [self setupBackgroundView];
    
    // check next prev button availability
    [self checkNextPrevAvailability];
}

- (void) resetComponent
{
    UIView *imageView = self.snapContainer.imageScrollView.imageViewWrapper.imageView;
    imageView.frame = snapContainer.imageScrollView.frame;
    imageView.layer.opacity = 1.0f;
}

- (void) loadRawPhoto
{
    NSLog(@"SnapViewController.loadRawPhoto() invoked.");
    
    // imediately down the flag
    snapContainer.imageScrollView.isRawPhotoLoaded = YES;
    
    //UIImageView *photoImageView = [thumb photoImageView];
    UIImageView *photoImageView = [thumb allocPhotoImageView];
    UIImage *photoImage = photoImageView.image;
    [snapContainer setSnapImage:photoImage];
    [self.view.layer setNeedsDisplay];
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"*** SnapViewController viewWillAppear called ***");
    
    if( [AlbumActionCenter shouldRebuildAlbum] )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // clear snap
            [snapContainer hideSnapImage];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"*** phase.1");
                // rebuild album directly by action center.
                // of course without animation.
                NSLog(@"# ");
                NSLog(@"# album data structure was changed !");
                NSLog(@"# ");
                [AlbumActionCenter forceRebuildAlbum];
                [AlbumActionCenter withdrawRequestRebuildAlbum];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // swap snap if needed
                    [self acceptAlbumThumbnailViewObjectOnly:[AlbumDataCenter loadLatestPhotoAsAlbumThumbnailView]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [snapContainer showSnapImage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self cleanupUpdatedImageViewWithCompletionBlock:^(void){
                                [super viewWillAppear:animated];
                            }];
                            
                            // check next prev button availability
                            [self checkNextPrevAvailability];
                        });
                    });
                });
            });
        });
    }
    else
    {
        [super viewWillAppear:animated];
    }
    
}

// show and hide snap decorations

- (void) toggleHidableSnapDecoration
{
    if( snapDayLabel.hidden ){
        [self showHidableSnapDecoration];
    }
    else{
        [self hideHidableSnapDecoration];
    }
}

- (void) hideHidableSnapDecoration
{
    [UIView animateWithDuration:0.5f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         grid_imageView.hidden = YES;
                         snapDayLabel.hidden = YES;
                     } 
                     completion:nil];
}

- (void) showHidableSnapDecoration
{
    [UIView animateWithDuration:0.5f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         grid_imageView.hidden = NO;
                         snapDayLabel.hidden = NO;
                     } 
                     completion:nil];
}

// before adding grid, you should clear your snap view.
- (void) setupGridView
{
    // add to the view.
    // setupGridView is called for each snap laod, 
    // but grid image is removed for each load.
    [self.view addSubview:grid_imageView]; // add on the top
}

- (void) setupDayLabel
{
    // add to the view.
    // also, setupDayLabel is called for each snap laod, 
    // but the image is removed for each load.
    [snapDayLabel updateWithIsoDay:self.thumb.iso_day withCompletionBlock:^(void){}];
    [self.view addSubview:snapDayLabel];
}

- (void) setupDayLabelWithCompletionBlock:(void (^)(void))completionBlock
{
    // add to the view.
    // also, setupDayLabel is called for each snap laod, 
    // but the image is removed for each load.
    [snapDayLabel updateWithIsoDay:self.thumb.iso_day withCompletionBlock:completionBlock];
    [self.view addSubview:snapDayLabel];
}

- (void) setupBackgroundView
{
    // add to the view.
    // also, setupBackgroundView is called for each snap laod, 
    // but the image is removed for each load.
    [self.view insertSubview:background_imageView atIndex:0];
}

- (id)init
{
    self = [super init];
    
    NSLog(@"*** initializing SnapViewController");
    
    // prepare snapContainer
    CGRect finderRect = [DeviceConfig screenRect];
    snapContainer = [[SnapContainer alloc] initWithFrame:finderRect];
    
    // prepare gridview
    grid_imageView = [[UIImageView alloc] initWithImage:[AlbumDecoration gridImageForSnapOverlay]];
    grid_imageView.frame = [DeviceConfig screenRect];
    grid_imageView.hidden = NO;
    
    // prepare day label
    CGRect dayLabelRect = CGRectMake(0, 0, 130, 14);
    //CGPoint unifiedModeNotificationCenter = CGPointMake(160, self.view.frame.size.height-60-4);
    CGPoint unifiedModeNotificationCenter = CGPointMake([DeviceConfig screenWidth]/2, self.view.frame.size.height-60-4);
    snapDayLabel = [[SnapDayLabel alloc] initWithFrame:dayLabelRect];
    snapDayLabel.center = unifiedModeNotificationCenter;
    snapDayLabel.initialCenter = unifiedModeNotificationCenter;
    
    // prepare background
    background_imageView = [[UIImageView alloc] initWithImage:[AlbumDecoration backgroundImage]];
    
    return self;
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
    
    NSLog(@"*** SnapViewController viewDidLoad called.");
    
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
    
    // to enable toolBar and navigationBar configuration,
    // at least one subview should be added in this viewDidLoad phase
    [self.view addSubview:snapContainer];
    
    // setup grid and background.
    // dont setup day label here, not yet get target thumb.
    [self setupGridView];
    [self setupBackgroundView];
    
    // then, bringup toolBar and navigationBar
    [self bringupLibraryViewToolBarButtonItems];
    [self bringupLibraryViewNavigationBarButtonItems];
    
    // observing
    AlbumActionCenter *albumActionCenter = [AlbumActionCenter sharedInstance];
    albumActionCenter.snapViewController = self; // watch raw photo request
}

- (void) enableSnapToolbarButtons
{
    actionButton.enabled = YES;
    trashButton.enabled = YES;
    prevButton.enabled = YES;
    nextButton.enabled = YES;
}

- (void) disableSnapToolbarButtons
{
    actionButton.enabled = NO;
    trashButton.enabled = NO;
    prevButton.enabled = NO;
    nextButton.enabled = NO;
}

- (void) enableSnapActionButtons
{
    // !!! CAUTION !!!
    // current version of iOS(iOS5.0.1) cannot control the enable flag for leftBarButtonItem
    //
    //self.navigationItem.leftBarButtonItem.enabled = YES;
    doneButtonItem.enabled = YES;
}

- (void) disableSnapActionButtons
{
    // !!! CAUTION !!!
    // current version of iOS(iOS5.0.1) cannot control the enable flag for leftBarButtonItem
    // 
    //self.navigationItem.leftBarButtonItem.enabled = NO;
    doneButtonItem.enabled = NO;
}

- (void) bringupLibraryViewNavigationBarButtonItems
{
    doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(backtoPreview)];
    // color of camera button
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat darkred[] = {(float)35/256,(float)98/256,(float)222/256,1.0};
    CGColorRef darkredc = CGColorCreate(rgb,darkred);
    doneButtonItem.tintColor = [UIColor colorWithCGColor:darkredc];
    CGColorSpaceRelease(rgb);
    CGColorRelease(darkredc);
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
}
- (void) bringupLibraryViewToolBarButtonItems
{
    actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionHandler)];
    trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashHandler)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // imageNamed by auto retina
    prevButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbarPrevButton"] 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(prevSnap)];
    nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbarNextButton"] 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(nextSnap)];
    
    NSArray *buttons = [NSArray arrayWithObjects:actionButton,flexSpace,prevButton,flexSpace,nextButton,flexSpace,trashButton,nil];
    [self setToolbarItems:buttons animated:YES];
}

@end
