
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>

#import "CameraController.h"
#import "CameraHelper.h"
#import "CameraSession.h"
#import "PreviewHelper.h"
#import "PreviewContainer.h"
#import "SnapHelper.h"
#import "CameraUtility.h"
#import "TorchButton.h"
#import "SnapButton.h"
#import "PreviewToolBar.h"
#import "UnifiedModeNotifier.h"
#import "AlbumDataCenter.h"
#import "WhiteBalanceConverter.h"
#import "ApplicationConfig.h"
#import "DeviceConfig.h"
#import "ApplicationActionCenter.h"
#import "ApplicationDecoration.h"
#import "AlbumUtility.h"
#import "PhotoMetaData.h"

static CameraController *sharedInstance = nil;

@interface CameraController(Private)
- (void) backtoPreview;
- (void) regressPreview;
- (void) saveSnap:(UIImage *)image withMetadata:(CFDictionaryRef)meta;
- (void) runAutoWhiteBalanceBlockWithCompletionBlock:(void (^)(void))completionBlock;
- (void) bringupPhotoLibrary;
- (void) bringupPreviewFinderToolBarButtonItems;
- (void) animationDidStart:(CAAnimation *)anim;
- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
- (void) terminateCubeAnimation;
@end

@implementation CameraController
@synthesize previewContainer;
@synthesize notificationBoxRed, notificationBoxBlue;
@synthesize unifiedModeNotifier;

#pragma mark
#pragma mark === photo library ===
#pragma mark

- (void) bringupPhotoLibrary
{
    NSLog(@"*** bringupPhotoLibrary");
    
    [self.previewContainer blockEnterWhitepointSelection];
    
    [ApplicationActionCenter bringupAlbum];
}

- (void) bringupPreviewFinderToolBarButtonItems
{
    previewToolBar.hidden = NO;
}

#pragma mark
#pragma mark === gears ===
#pragma mark

- (void) gearsAppear
{
	// show gears container
	gearContainer.hidden = NO;
}

- (void) gearsDisappear
{
	// hide gears container
	gearContainer.hidden = YES;
	
	// reset alignments
	[gearContainer allButtonsOff];
	[gearContainer resetCenterOfAlignments];
}

#pragma mark
#pragma mark === snap ===
#pragma mark

- (void) snap
{
    NSLog(@"# CameraController.snap()");
    
    // immediately block wb point selection
    [previewContainer blockEnterWhitepointSelection];
    
    // also immediately block button ui
    [previewToolBar enterSnappingBlock];
    
    // save orientation at the time of shot
    snapOrientation = currentOrientation;
    
    // advanced shared queue for more snap performance
    ApplicationConfig *app_config = [ApplicationConfig sharedInstance];
    dispatch_queue_t preview_queue = [app_config finderPreviewQueue];
    
    // hide root background image
    blackMaskView.hidden = NO;
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    dispatch_async(preview_queue, ^{
        
        [previewContainer dimmFinder];
        [gearContainer dimmGears];
        
        // show snapping notification (indicator and label)
        [snappingNotifier performSelectorOnMainThread:@selector(showNotification) withObject:nil waitUntilDone:NO];
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        //dispatch_async(preview_queue, ^{
            [SnapHelper snapStillImageWithALAssetOrientation:snapOrientation];
        //});
    });
}

- (void) saveSnap:(UIImage *)image withMetadata:(CFDictionaryRef)meta
{
    NSLog(@"# saving snap image (width:%f)",image.size.width);
    NSMutableDictionary *metadata = [(__bridge NSDictionary *)meta mutableCopy];
    
    // change snapping notification to saving
    [snappingNotifier performSelectorOnMainThread:@selector(showSaving) withObject:nil waitUntilDone:NO];
    
    //NSDate *now_prep = [NSDate date];
    
    //[image retain];
    
    NSArray *docPaths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath   = [docPaths objectAtIndex:0];
    NSString *iso_today = [AlbumUtility folderNameForTodaysPhoto];
    NSString *dir_today = [docPath stringByAppendingPathComponent:iso_today];
    
    NSString *dir_photo = [dir_today stringByAppendingPathComponent:@"photo"];
    NSString *dir_prev  = [dir_today stringByAppendingPathComponent:@"preview"];
    NSString *dir_thumb = [dir_today stringByAppendingPathComponent:@"thumb"];
    NSString *dir_meta  = [dir_today stringByAppendingPathComponent:@"meta"];
    
    NSString *unixtime       = [AlbumUtility currentUnixtimeAsString];
    NSString *filename_photo = [unixtime stringByAppendingString:@".jpg"];
    NSString *filename_prev  = [unixtime stringByAppendingString:@".jpg"];
    NSString *filename_thumb = [unixtime stringByAppendingString:@".jpg"];
    NSString *filename_meta  = [unixtime stringByAppendingString:@".meta"];
    
    NSString *path_photo = [dir_photo stringByAppendingPathComponent:filename_photo];
    NSString *path_prev  = [dir_prev stringByAppendingPathComponent:filename_prev];
    NSString *path_thumb = [dir_thumb stringByAppendingPathComponent:filename_thumb];
    NSString *path_meta  = [dir_meta stringByAppendingPathComponent:filename_meta];
    
    [AlbumUtility ensureAlbumDateFolders:iso_today]; // ensure above dirs
    
    // 
    // EXIF
    // (CFDictionaryRef and NSDictionary is Toll-Free Bridging)
    // 
    NSMutableDictionary *EXIFDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
    if( !EXIFDictionary ){
        //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
        NSLog(@"EXIFDictionary is empty");
        EXIFDictionary = [NSMutableDictionary dictionary];
    }else{
        //NSLog(@"EXIFDictionary : %@", EXIFDictionary);
    }
    if( !GPSDictionary ){
        NSLog(@"GPSDictionary is empty");
        GPSDictionary = [NSMutableDictionary dictionary];
    }
    
    CLLocationDegrees lon  = [ApplicationActionCenter currentLongitude];
    CLLocationDegrees lat  = [ApplicationActionCenter currentLatitude];
    CLLocationDistance alt = [ApplicationActionCenter currentAltitude];
    NSString *lon_ref = [ApplicationActionCenter currentLongitudeRef];
    NSString *lat_ref = [ApplicationActionCenter currentLatitudeRef];
    NSString *alt_ref = [ApplicationActionCenter currentAltitudeRef];
    
    [GPSDictionary setValue:[NSNumber numberWithFloat:lat] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [GPSDictionary setValue:[NSNumber numberWithFloat:lon] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    [GPSDictionary setValue:lat_ref forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [GPSDictionary setValue:lon_ref forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [GPSDictionary setValue:[NSNumber numberWithFloat:alt] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    [GPSDictionary setValue:alt_ref forKey:(NSString*)kCGImagePropertyGPSAltitudeRef]; 
    //[GPSDictionary setValue:[NSNumber numberWithFloat:_heading] forKey:(NSString*)kCGImagePropertyGPSImgDirection];
    //[GPSDictionary setValue:[NSString stringWithFormat:@"%c",_headingRef] forKey:(NSString*)kCGImagePropertyGPSImgDirectionRef];
    
    [metadata setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadata setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    // 
    // orientation issue is alrady resolved at the wb processing phase.
    // so, the meta orientation is always UIImageOrientationRight
    // 
    NSString *orientationString = [CameraUtility alAssetOrientationToStringOrientation:snapOrientation];
    
    // meta obj
    PhotoMetaData *metaObj = [[PhotoMetaData alloc] init];
    metaObj.photo_orientation = orientationString;
    metaObj.comment = nil;
    metaObj.iso_day = iso_today;
    metaObj.file_name = filename_meta;
    metaObj.meta = metadata;
    
    // adjust orientation
    [metadata setValue:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyOrientation];
    
    NSLog(@"saving photo size:%f in folder:%@",image.size.width,iso_today);
    
    // advanced shared queue for more snap performance
    ApplicationConfig *app_config = [ApplicationConfig sharedInstance];
    dispatch_queue_t preview_queue = [app_config finderPreviewQueue]; // for front process
    //dispatch_queue_t background_queue = [app_config backgroundQueue]; // for low priority
    
    //NSDate *then_prep = [NSDate date];
    //NSLog(@"delay of prep : %1.3fsec", [then_prep timeIntervalSinceDate:now_prep]);
    
    //dispatch_async(background_queue, ^{
    dispatch_async(preview_queue, ^{
        NSLog(@"-------------------------");
        NSLog(@"snap main block start");
        NSLog(@"-------------------------");
        [previewToolBar enterSavingBlock];
        
        //dispatch_async(background_queue, ^{
        dispatch_async(preview_queue, ^{
            // photo
            //NSDate *now1 = [NSDate date];
            NSData *data_photo = UIImageJPEGRepresentation(image, 0.8);
            //NSDate *then1 = [NSDate date];
            //NSLog(@"delay of photo: %1.3fsec", [then1 timeIntervalSinceDate:now1]);
            
            // preview
            //NSDate *now2 = [NSDate date];
            UIImage *prev = [CameraUtility makePreviewFor:image];
            NSData *data_prev = [[NSData alloc] initWithData:UIImageJPEGRepresentation(prev, 0.6)];
            //NSDate *then2 = [NSDate date];
            //NSLog(@"delay of prev : %1.3fsec", [then2 timeIntervalSinceDate:now2]);
            
            // thumbnail
            //NSDate *now3 = [NSDate date];
            UIImage *thumb = [CameraUtility makeThumbnailFor:prev];
            NSData *data_thumb = [[NSData alloc] initWithData:UIImageJPEGRepresentation(thumb, 0.4)];
            //NSDate *then3 = [NSDate date];
            //NSLog(@"delay of thumb: %1.3fsec", [then3 timeIntervalSinceDate:now3]);
            
            [self backtoPreview];
            
            //dispatch_async(background_queue, ^{
            dispatch_async(preview_queue, ^{
                // save
                //NSLog(@"saving exif : %@", metadata);
                
                // data only
                //NSDate *now_dest1 = [NSDate date];
                [data_photo writeToFile:path_photo atomically:YES];
                //NSDate *then_dest1 = [NSDate date];
                //NSLog(@"delay of photo : %1.3fsec", [then_dest1 timeIntervalSinceDate:now_dest1]);
                // with metadata
                /*NSDate *now_dest1 = [NSDate date];
                NSMutableData *dest_data = [NSMutableData data];
                CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data_photo, NULL);
                CFStringRef UTI = CGImageSourceGetType(source);
                CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
                CGImageDestinationAddImageFromSource( destination, source, 0, (CFDictionaryRef)metadata);
                CGImageDestinationFinalize(destination);
                [dest_data writeToFile:path_photo atomically:YES];
                CFRelease(destination);
                CFRelease(source);
                NSDate *then_dest1 = [NSDate date];
                NSLog(@"delay of photo : %1.3fsec", [then_dest1 timeIntervalSinceDate:now_dest1]);*/
                
                //NSDate *now_dest2 = [NSDate date];
                [data_prev writeToFile:path_prev atomically:YES];
                [data_thumb writeToFile:path_thumb atomically:YES];
                [NSKeyedArchiver archiveRootObject:metaObj toFile:path_meta];
                //NSDate *then_dest2 = [NSDate date];
                //NSLog(@"delay of dest2: %1.3fsec", [then_dest2 timeIntervalSinceDate:now_dest2]);
                
                //dispatch_async(background_queue, ^{
                dispatch_async(preview_queue, ^{
                    //[data_photo release];
                    //[data_prev release];
                    //[data_thumb release];
                    //[metaObj release];
                    
                    //[EXIFDictionary release]; releasing this cause crash, the dic is released?
                    //[GPSDictionary release];
                    //[metadata release];
                    
                    //dispatch_async(background_queue, ^{
                    dispatch_async(preview_queue, ^{
                        //
                        // hide saving indicator, and regress to normal mode
                        // 
                        [previewToolBar exitSavingBlock];
                        
                        //
                        // requesting rebuild of album.
                        // 
                        [AlbumActionCenter requestRebuildAlbumBeforeAppear];
                        
                        // 
                        // requesting which album block should be rebuilded.
                        // application still does not know the instance of AlbumDayBlock,
                        // so kick the rebuild request via the AlbumActionCenter.
                        // * usualy this will be done by calling [block modified]
                        // 
                        [AlbumActionCenter requestRebuildBlock:iso_today];
                        
                        // 
                        // request scroll to the bottom of the album
                        // 
                        [AlbumActionCenter requestScrollToBottomOfAlbum];
                        
                        // 
                        // ensure iso_day folder on the filesystem
                        // 
                        [AlbumDataCenter commitNewIsoDayIfNotExist:iso_today withFileName:filename_photo];
                        
                        // release the snap image
                        //[image release];
                        
                        // request update LibIcon
                        [ApplicationActionCenter requestShouldUpdateLibIcon];
                        
                    });
                });
            });
        });
    });
}

#pragma mark
#pragma mark === WB/AE/AF management ===
#pragma mark

// run auto whitebalance and then execute completionBlock
- (void) runAutoWhiteBalanceBlockWithCompletionBlock:(void (^)(void))completionBlock
{
    [unifiedModeNotifier showWBAuto];
    
    // advanced shared queue
    ApplicationConfig *app_config = [ApplicationConfig sharedInstance];
    dispatch_queue_t my_queue = [app_config backgroundQueue]; // for background process
    
    dispatch_async(my_queue, ^{
        NSLog(@"*** runAutoWhiteBalanceBlockWithCompletionBlock phase.(1)");
        // ensure manual whitebalance
        [CameraSession ensureManualWhiteBalanceMode];
        
        // enable auto whitebalance
        [CameraSession enableAutoWhiteBalance];
        
        // ui disabling process should be called immediately
        // after entering this auto whitebalancing block.
        dispatch_async(dispatch_get_main_queue(), ^{
            // block manual whitebalance action
            // change whitebalance notification
            [unifiedModeNotifier showWBAdjusting];
            
            [previewContainer blockEnterWhitepointSelection];
            [previewToolBar disableButtonAction];
            
            dispatch_async(my_queue, ^{
                // wait to auto whitebalance by device itself.
                // it requires several frames, but wait 1 sec to ensure to be done.
                sleep(1);
                
                // regression process should be called 
                // immediately after the auto whitebalance adjustment
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"*** runAutoWhiteBalanceBlockWithCompletionBlock phase.(2)");
                    // disable auto whitebalance
                    [CameraSession disableAutoWhiteBalance];
                    
                    // enable manual whitebalance and action
                    [previewContainer enableEnterWhitepointSelection];
                    [previewToolBar enableButtonAction];
                    
                    // change whitebalance notification
                    [unifiedModeNotifier showWBLocked];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock();
                        
                    });
                });
            });
        });
    });
}

#pragma mark
#pragma mark === state change listners ===
#pragma mark

- (void) willResingActiveWorks
{
    NSLog(@"*** CameraController.willResingActiveWorks called");
    
    // set viewWillAppear flag off
    [ApplicationActionCenter flagoffViewWillAppearAlreadyCalled];
    
    // [finder animation with grid]
    [self.view bringSubviewToFront:finderHideView];
    finderHideView.hidden = NO;
    finderGrid.layer.opacity = 0.0;
	torchButton.layer.opacity = 0.0;
	
	// gear is also animate
	gearContainer.layer.opacity = 0.0;
	[self gearsDisappear];
	[previewToolBar gearButtonOff];
	
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         finderHideView.layer.opacity = 1.0;
                     } 
                     completion:^(BOOL finished){
                     }];
}

- (void) didEnterBackgroundWorks
{
    NSLog(@"*** CameraController.didEnterBackgroundWorks called");
    
    if( [CameraSession isRunning] ){
        [CameraSession stopRunning];
    }
    
    [CameraHelper clearPipeline];
}

- (void) willEnterForegroundWorks
{
    // before enter foreground check application context,
    // and if the context is camera calls viewWillAppear
    ApplicationContextType context = [ApplicationActionCenter getCurrentApplicationContext];
    if( context == kApplicationContext_Camera ){
        NSLog(@"*** ");
        NSLog(@"*** context is camera");
        NSLog(@"*** kicking viewWillAppear");
        NSLog(@"*** ");
        [self viewWillAppear:YES];
    }
}

- (void) didBecomeActiveWorks
{
    // [finder animation with grid]
    // 
    // no need to call this block if already called viewWillAppear.
    // usually it is called, except for the situation 
    // that user double click home button but did not go to other app.
    // 
    if( ![ApplicationActionCenter isViewWillAppearAlreadyCalled] ){
        [self.view bringSubviewToFront:finderHideView];
        finderHideView.hidden = NO;
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             finderHideView.layer.opacity = 0.0;
                             finderGrid.layer.opacity = 1.0;
							 torchButton.layer.opacity = 1.0;
							 gearContainer.layer.opacity = 1.0;
                         } 
                         completion:^(BOOL finished){
                         }];
    }
}

// will be called by viewWillAppear
- (void) regressPreview
{
    [self backtoPreview];
}

// restart preview
- (void) backtoPreview
{
    if( [previewContainer finderDimmed] ){
        NSLog(@"### CameraController.backtoPreview() : detect finder dimm");
        [previewContainer illumFinder];
        [gearContainer illumGears];
    }
    
    // prepare root background image
    blackMaskView.hidden = YES;
    
    // regress ui
    [self bringupPreviewFinderToolBarButtonItems];
    
    // start allow whitebalance point selection
    [previewContainer enableEnterWhitepointSelection];
    
    // force hide snapping notification (indicator and label)
    [snappingNotifier hideNotification];
    
    // check session videoOutput
    if( ![CameraSession isRunning] ){
        NSLog(@"### CameraController.backtoPreview() : detect session not running");
        [CameraSession ensureCameraSessionRunning];
    }
    
    NSLog(@"### preview regressed");
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

- (void) viewWillAppear:(BOOL)animated
{
    // 
    // [safty invocation of view appearance procedure]
    // 
    // processes of view appearance should be serialized.
    // otherwise you got EXC_BAD_ACCESS in drawInContext of preview layer.
    // this might be caused by conflict of graphics context.
    // 
    NSLog(@"*** CameraController.viewWillAppear() called");
    
    // before show the view, bring up finder hide view.
    // this view will be hidden at the end of this method.
    [self.view bringSubviewToFront:finderHideView];
    finderHideView.hidden = NO;
    finderHideView.layer.opacity = 1.0f;
    
    // before show the view, hide finder grid view.
    // this view will be shown at the end of this method.
    finderGrid.layer.opacity = 0.0;
	torchButton.layer.opacity = 0.0;
	
	// gear is also hidden
	gearContainer.layer.opacity = 0.0;
	[self gearsDisappear];
	[previewToolBar gearButtonOff];
    
    // set viewWillAppear flag on
    [ApplicationActionCenter flagonViewWillAppearAlreadyCalled];
    
    // disable ui action, wait to ready camera (thread safe)
    [previewToolBar disableButtonAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"*** phase.0");
        // get start session
        if( ![CameraSession isRunning] ){
            [CameraSession startRunning];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"*** phase.1");
            // 
            // clear latest view before appear
            // 
            [CameraHelper clearPipeline];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"*** phase.2");
                [super viewWillAppear:animated];
                
                //[self performSelectorOnMainThread:@selector(regressPreview) withObject:nil waitUntilDone:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"*** phase.3");
                    // regress preview
                    [self regressPreview];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //NSLog(@"*** phase.4");
                        // 
                        // restore to AE/AF Auto mode
                        // 
                        [CameraSession enableContinuousAEAF];
                        [CameraController changeAEAFModeNotificationToAuto];
						// 
                        // restore exposure adjustment if defined
						//
						PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
						if( [previewHelper exposureAdjustmentLevel] != 0 ){
							// same as changeExposureModeNotificationToManual
							[self.unifiedModeNotifier showExposureManual];
						}
						
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //NSLog(@"*** phase.5");
                            // 
                            // terminate CubeAnimation if running
                            // 
                            [self terminateCubeAnimation];
                            
                            // initial orientation
                            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
                            currentOrientation = [CameraUtility uiDeviceOrientationToALAssetOrientation:orientation];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //NSLog(@"*** phase.6");
                                // view is ready,
                                // enable ui action
                                // 
                                // !!! CAUTION !!!
                                // 
                                // viewWillAppear executes runAutoWhiteBalanceBlockWithCompletionBlock
                                // so no need to enable button action in here.
                                // the button action is enabled by whitebalance block.
                                // 
                                //[previewToolBar enableButtonAction];
                                
                                //calling runAutoWhiteBalanceBlock force reset whitebalance
                                //however user selected manual whitebalance photo
                                //[CameraHelper cancelWhiteBalance];
                                //[CameraController runAutoWhiteBalanceBlock];
                                
                                if( [ApplicationActionCenter shouldWhitebalanceByImage] ){
                                    NSLog(@"*** detect shouldWhitebalanceByImage");
                                    ApplicationActionCenter *applicationActionCenter = [ApplicationActionCenter sharedInstance];
                                    WhitebalanceByImageBlock block = applicationActionCenter.currentWhitebalanceByImageBlock;
                                    [self runAutoWhiteBalanceBlockWithCompletionBlock:block];
                                }else{
                                    NSLog(@"*** got run awb block");
                                    [self runAutoWhiteBalanceBlockWithCompletionBlock:^{
                                        // 
                                        // otherwise, go auto whitebalance.
                                        // if you want to restore latest whitebalance
                                        // execute following block.
                                        // 
                                        /* 
                                        PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
                                        if( previewHelper.shouldAdjustWhiteBalance ){
                                            NSLog(@"*** restore latest whitebalance");
                                            int restoreWhitebalanceParameterReal[3];
                                            restoreWhitebalanceParameterReal[0] = previewHelper.currentWhiteBalanceParameterBp;
                                            restoreWhitebalanceParameterReal[1] = previewHelper.currentWhiteBalanceParameterGp;
                                            restoreWhitebalanceParameterReal[2] = previewHelper.currentWhiteBalanceParameterRp;
                                            [previewHelper enableWhiteBalanceWithRealParameter:restoreWhitebalanceParameterReal];
                                            
                                            NSLog(@"[restored WB param] : %1.3d, %1.3d, %1.3d", restoreWhitebalanceParameterReal[0], restoreWhitebalanceParameterReal[1], restoreWhitebalanceParameterReal[2]);
                                            
                                            NSLog(@"*** restore wbmode notification to manual");
                                            [CameraController changeWBModeNotificationToManual];
                                        }
                                        */
                                    }];
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    // 
                                    // this is in the cold boot process.
                                    // delay:0.5f is required to show all 0.3f animation.
                                    // at least 0.3f is consumed by above block.
                                    // 
                                    [UIView animateWithDuration:0.3f delay:0.5f options:UIViewAnimationOptionCurveEaseInOut 
                                                     animations:^{
                                                         finderHideView.layer.opacity = 0.0;
                                                     } 
                                                     completion:^(BOOL finished){
                                                     }];
                                    
                                    // show finder grind
                                    [UIView animateWithDuration:0.3f delay:0.5f options:UIViewAnimationOptionCurveEaseInOut 
                                                     animations:^{
                                                         finderGrid.layer.opacity = 1.0;
														 torchButton.layer.opacity = 1.0;
														 gearContainer.layer.opacity = 1.0;
                                                     } 
                                                     completion:^(BOOL finished){
                                                     }];
                                    
                                    // 
                                    // viewController called by ApplicationActionCenter is successfully appeared.
                                    // 
                                    [ApplicationActionCenter successToBooting];
                                });
                                
                            });
                        });
                    });
                });
            });
        });
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"*** CameraController.viewWillDisappear() called");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view bringSubviewToFront:finderHideView];
        finderHideView.hidden = NO;
        finderGrid.layer.opacity = 0.0;
		torchButton.layer.opacity = 0.0;
		// disappear gears
		gearContainer.layer.opacity = 0.0;
		[self gearsDisappear];
		[previewToolBar gearButtonOff];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CameraSession stopRunning];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [CameraHelper clearPipeline];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [super viewWillDisappear:animated];
                });
            });
        });
    });
}

- (id) init
{
    self = [super init];
    
    sharedInstance = self; // quick and dirty singleton access
    
    return self;
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
    
    // define the finder and preview rect
    CGRect previewRect = [DeviceConfig previewRect];
    
    // setup view controller it self
    self.view.multipleTouchEnabled = YES;
//    self.wantsFullScreenLayout = YES; // DEPRECATED in ios7
	
    // navigationbar
	self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    // toolbar
	self.navigationController.toolbarHidden = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	self.navigationController.toolbar.translucent = YES;
    //[self.navigationItem setHidesBackButton:NO animated:YES];
    
    // set background color as black
    self.view.backgroundColor = [UIColor blackColor];
    
    // root background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[DeviceConfig FinderHideImage]]; // same image as finder hider
    bg.frame = [DeviceConfig previewRect];
    [self.view addSubview:bg];
    
    // black mask to hide background while snapping
    blackMaskView = [[UIView alloc] initWithFrame:[DeviceConfig previewRect]];
    blackMaskView.backgroundColor = [UIColor blackColor];
    blackMaskView.hidden = YES;
    [self.view addSubview:blackMaskView];
    
    // prepare snapping notification
    //CGPoint previewCenter = CGPointMake(previewRect.origin.x + (previewRect.size.width)/2, previewRect.origin.y + (previewRect.size.height/2));
    CGPoint previewCenter = CGPointMake([DeviceConfig screenWidth]/2, [DeviceConfig previewHeight]/2);
    snappingNotifier = [SnappingNotifier sharedInstanceWithFrame:previewRect withCenter:previewCenter];
    
    // initial notification
    [unifiedModeNotifier showAEAFAuto];
    [unifiedModeNotifier showWBAuto];
    
    // 
    // setup live preview container
    // 
    previewContainer = [[PreviewContainer alloc] initWithFrame:previewRect];
    
    // build view
    [self.view addSubview:snappingNotifier];
    [self.view addSubview:previewContainer];
    
    // notification box (red for touch)
    UIImage *boxImage_red = [UIImage imageNamed:@"interestBoxRedbg_114x114.png"];
    notificationBoxRed = [[UIImageView alloc] initWithImage:boxImage_red];
    notificationBoxRed.center = CGPointMake(0.0f, 0.0f);
    notificationBoxRed.hidden = YES;
    [self.view addSubview:notificationBoxRed];
    
    // notification box (blue for press) 
    UIImage *boxImage_blue = [UIImage imageNamed:@"interestBoxBluebgSlim_108x108.png"];
    notificationBoxBlue = [[UIImageView alloc] initWithImage:boxImage_blue];
    notificationBoxBlue.center = CGPointMake(0.0f, 0.0f);
    notificationBoxBlue.hidden = YES;
    [self.view addSubview:notificationBoxBlue];
    
    // grid
    UIImage *gridImage = [DeviceConfig FinderGridImage];
    finderGrid = [[UIImageView alloc] initWithImage:gridImage];
    finderGrid.frame = [DeviceConfig previewRect];
    finderGrid.hidden = NO;
    finderGrid.layer.opacity = 1.0;
    [self.view addSubview:finderGrid];
    
    // get toolbar for preview finder initially on the top of the view
    CGRect toolbarRect = [DeviceConfig previewToolBarRect];
    previewToolBar = [[PreviewToolBar alloc] initWithFrame:toolbarRect];
    int previewToobarHeight = [DeviceConfig previewToolbarHeight] + [DeviceConfig previewToolbarShadowHeight];
    previewToolBar.center = CGPointMake([DeviceConfig screenWidth]/2.0f, [DeviceConfig screenHeight]-previewToobarHeight/2.0f);
    previewToolBar.hidden = YES;
    [self.view addSubview:previewToolBar];
    [self bringupPreviewFinderToolBarButtonItems];
    
	// gears
	gearContainer = [[GearContainer alloc] initWithFrame:CGRectMake(0, 0, [DeviceConfig screenWidth], [DeviceConfig screenHeight]-53)];
	gearContainer.hidden = YES;
	gearContainer.layer.opacity = 1.0;
	[self.view addSubview:gearContainer];
	
    // torch
    torchButton = [[TorchButton alloc] initWithFrame:CGRectMake(8, 8, 50, 30)];
	torchButton.layer.opacity = 1.0;
    [self.view addSubview:torchButton];
    
    // prepare AE/AF/WB notification
    //CGRect unifiedModeNotificationRect = CGRectMake(0, 0, 130, 14);
    //CGPoint unifiedModeNotificationCenter = CGPointMake([DeviceConfig screenWidth]/2, self.view.frame.size.height-60-4);
    CGRect unifiedModeNotificationRect = [DeviceConfig unifiedModeNotificationRect];
    CGPoint unifiedModeNotificationCenter = [DeviceConfig unifiedModeNotificationCenter];
    //unifiedModeNotifier = [[UnifiedModeNotifier alloc] initWithFrame:unifiedModeNotificationRect];
	unifiedModeNotifier = [UnifiedModeNotifier sharedInstanceWithFrame:unifiedModeNotificationRect];
    unifiedModeNotifier.center = unifiedModeNotificationCenter;
    unifiedModeNotifier.initialCenter = unifiedModeNotificationCenter;
    [self.view addSubview:unifiedModeNotifier];
	
    // prepare finder hider
    UIImage *defaultpng = [DeviceConfig FinderHideImage];
    finderHideView = [[UIImageView alloc] initWithImage:defaultpng];
    finderHideView.frame = [DeviceConfig previewRect];
    finderHideView.layer.opacity = 0.0;
    [self.view addSubview:finderHideView];
    
    //
    // camera device initialization
    //
    [CameraHelper checkInstance];
    [SnapHelper checkInstance];
    
    
    // observing device orientation
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(rotated:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    // observing application state change
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didEnterBackgroundWorks) 
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(willResingActiveWorks) 
                                                 name:UIApplicationWillResignActiveNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didBecomeActiveWorks) 
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(willEnterForegroundWorks) 
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:NULL];
    
    // prepare hider hiding animation in willResingActive phase
    [self.view bringSubviewToFront:finderHideView];
}

#pragma mark
#pragma mark === observing button availability ===
#pragma mark

// deprecated
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"detect key change:");
    
    @synchronized(self){
    if( [keyPath isEqualToString:@"adjustingExposure"] )
    {
        NSLog(@"adjustingExposure");
        [CameraController changeAEAFModeNotificationToAdjusting];
    }
    else if( [keyPath isEqualToString:@"adjustingFocus"] )
    {
        NSLog(@"adjustingFocus");
        [CameraController changeAEAFModeNotificationToAdjusting];
    }
    else
    {
        NSLog(@"exposure or focus regressed.");
        [CameraController changeAEAFModeNotificationToAuto];
    }
    }
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

+ (id) sharedInstance
{
    //NSLog(@"CameraController.sharedInstance() called");
    @synchronized(self){
        if(!sharedInstance){
            sharedInstance = [[self alloc] init]; // so always false
        }
    }
    return sharedInstance;
}

+ (void) snap
{
    CameraController *instance = [CameraController sharedInstance];
    [instance snap];
}

+ (void) saveSnap:(UIImage *)image withMetadata:(CFDictionaryRef)meta
{
    CameraController *instance = [CameraController sharedInstance];
    [instance saveSnap:image withMetadata:meta];
}

+ (void) runAutoWhiteBalanceBlockWithCompletionBlock:(void (^)(void))completionBlock
{
    CameraController *instance = [CameraController sharedInstance];
    [instance runAutoWhiteBalanceBlockWithCompletionBlock:completionBlock];
}

+ (void) bringupPhotoLibrary
{
    CameraController *instance = [CameraController sharedInstance];
    [instance bringupPhotoLibrary];
}

+ (void) regressPreview
{
    CameraController *instance = [CameraController sharedInstance];
    [instance regressPreview];
}


+ (void) gearsAppear
{
    CameraController *instance = [CameraController sharedInstance];
    [instance gearsAppear];
}

+ (void) gearsDisappear
{
    CameraController *instance = [CameraController sharedInstance];
    [instance gearsDisappear];
}

#pragma mark
#pragma mark === mode indicator ===
#pragma mark

// wb

+ (void) changeWBModeNotificationToAuto
{
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showWBAuto];
}

+ (void) changeWBModeNotificationToManual
{
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showWBManual];
}

// exposure

+ (void) changeExposureModeNotificationToAuto
{
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showExposureAuto];
}

+ (void) changeExposureModeNotificationToManual
{
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showExposureManual];
}

// focus

+ (void) changeFocusModeNotificationToAuto
{
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showFocusAuto];
}

+ (void) changeFocusModeNotificationToManual
{
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showFocusManual];
}

// ae/af (deprecated)

+ (void) changeAEAFModeNotificationToLock
{
	NSLog(@"* ");
	NSLog(@"* changeAEAFModeNotificationToLock is deprecated");
	NSLog(@"* ");
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showAEAFLocked];
}

+ (void) changeAEAFModeNotificationToAdjusting
{
	NSLog(@"* ");
	NSLog(@"* changeAEAFModeNotificationToAdjusting is deprecated");
	NSLog(@"* ");
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showAEAFAdjusting];
}

+ (void) changeAEAFModeNotificationToAuto
{
	NSLog(@"* ");
	NSLog(@"* changeAEAFModeNotificationToAuto is deprecated");
	NSLog(@"* ");
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier showAEAFAuto];
}

+ (void) changeAEAFModeNotificationToNone
{
	NSLog(@"* ");
	NSLog(@"* changeAEAFModeNotificationToNone is deprecated");
	NSLog(@"* ");
    CameraController *instance = [CameraController sharedInstance];
    [instance.unifiedModeNotifier clearAEAFNotification];
}

#pragma mark
#pragma mark === notification ===
#pragma mark

// red for touch
+ (void) showNotificationBoxAtPoint:(CGPoint)screenPoint
{
    CGPoint interestCenter = CGPointMake(screenPoint.x-45.0f, screenPoint.y-45.0f);
    
    CameraController *instance = [CameraController sharedInstance];
    instance.notificationBoxRed.hidden = YES;
    instance.notificationBoxRed.frame = CGRectMake(interestCenter.x, interestCenter.y, 106.0f, 106.0f);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.13f];
    instance.notificationBoxRed.hidden = NO;
    instance.notificationBoxRed.frame = CGRectMake(interestCenter.x+23.0f, interestCenter.y+23.0f, 60.0f, 60.0f);
    [UIView commitAnimations];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.duration = 0.2f;
    anim.repeatCount = 2;
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.autoreverses = YES;
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.delegate = instance;
    anim.removedOnCompletion = NO;
    [instance.notificationBoxRed.layer addAnimation:anim forKey:@"opacityAnim"];
}
- (void)animationDidStart:(CAAnimation *)anim
{
    return;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // hide red/blue box if visible
    
    CameraController *instance = [CameraController sharedInstance];
    
    if( instance.notificationBoxRed.layer.opacity > 0 ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
        instance.notificationBoxRed.layer.opacity = 0.0;
        [UIView commitAnimations];
    }
    if( instance.notificationBoxBlue.layer.opacity > 0 ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
        instance.notificationBoxBlue.layer.opacity = 0.0;
        [UIView commitAnimations];
    }
}

// AE/AF lock animation

// blue for press
+ (void) showAEAFLockAnimationAtPoint:(CGPoint)screenPoint withCompletionBlock:(void (^)(void))completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"showAEAFLockAnimationAtPoint:withCompletionBlock() called.");
        //CGPoint interestCenter = CGPointMake(screenPoint.x-45.0f, screenPoint.y-45.0f);
        CGPoint interestCenter = CGPointMake(screenPoint.x-95.0f, screenPoint.y-95.0f);
        
        CameraController *instance = [CameraController sharedInstance];
        instance.notificationBoxBlue.hidden = YES;
        //instance.notificationBoxBlue.frame = CGRectMake(interestCenter.x, interestCenter.y, 106.0f, 106.0f);
        instance.notificationBoxBlue.frame = CGRectMake(interestCenter.x, interestCenter.y, 206.0f, 206.0f);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.13f];
        instance.notificationBoxBlue.hidden = NO;
        //instance.notificationBoxBlue.frame = CGRectMake(interestCenter.x+23.0f, interestCenter.y+23.0f, 60.0f, 60.0f);
        instance.notificationBoxBlue.frame = CGRectMake(interestCenter.x+33.0f, interestCenter.y+33.0f, 140.0f, 140.0f);
        [UIView commitAnimations];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim.duration = 0.2f;
        anim.repeatCount = 4;
        anim.fromValue = [NSNumber numberWithFloat:0.0f];
        anim.autoreverses = YES;
        anim.toValue = [NSNumber numberWithFloat:1.0f];
        anim.delegate = instance;
        anim.removedOnCompletion = NO;
        [instance.notificationBoxBlue.layer addAnimation:anim forKey:@"opacityAnim"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"animation done.");
            completionBlock();
        });
    });
}

// ------->
// methods for repeated animation while adjusting exposure, currently not used
+ (void) showInterestPointNotificationAnimation {
    CameraController *instance = [CameraController sharedInstance];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.duration = 0.2f;
    anim.repeatCount = 2;
    anim.fromValue = [NSNumber numberWithFloat:1.0f];
    anim.autoreverses = YES;
    anim.toValue = [NSNumber numberWithFloat:0.5f];
    [instance.notificationBoxRed.layer addAnimation:anim forKey:@"opacityAnim"];
}
+ (void) repeatInterestPointNotificationAnimation {
    CameraController *instance = [CameraController sharedInstance];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.duration = 0.2f;
    //anim.repeatCount = 4;
    anim.repeatCount = HUGE_VALF;
    anim.fromValue = [NSNumber numberWithFloat:1.0f];
    anim.autoreverses = YES;
    anim.toValue = [NSNumber numberWithFloat:0.5f];
    [instance.notificationBoxRed.layer addAnimation:anim forKey:@"opacityAnim"];
}
+ (void) stopInterestPointNotificationAnimation {
    CameraController *instance = [CameraController sharedInstance];
    [instance.notificationBoxRed.layer removeAnimationForKey:@"opacityAnim"];
}
// <-------


#pragma mark
#pragma mark === device rotation observer ===
#pragma mark

- (void) rotated:(NSNotification *)notification
{
    //UIDeviceOrientation orientation = [[notification object] orientation];
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    // 
    // Device and object orientation
    // 
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // :                                                                 :                          :
    // : +---------+   +---------+   +----------+---+   +---+----------+ :                          :
    // : |         |   |    O    |   |          |   |   |   |          | :                          :
    // : |         |   +---------+   |          |   |   |   |          | :                          :
    // : |    1    |   |         |   |     3    | O |   | O |    4     | :                          :
    // : |         |   |         |   |          |   |   |   |          | :       device/obj         :
    // : |         |   |    2    |   |          |   |   |   |          | :                          :
    // : +---------+   |         |   +----------+---+   +---+----------+ :                          :
    // : |    O    |   |         |                                       :                          :
    // : +---------+   +---------+                                       :                          :
    // :                                                                 :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Portrate      Portrate      LandscapeRight     LandscapeLeft    : UIInterfaceOrientation   :
    // :                 UpsideDown                                      :                          :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Up(def)       Down          Left               Right            : ALAssetOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // : Right         Left          Up                 Down             : UIImageOrientation       :
    // + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + - - - - - - - - - - - - -+
    // 
    if( orientation == UIDeviceOrientationPortrait )
    {
        // 1
        currentOrientation = ALAssetOrientationUp;
    }
    else if( orientation == UIDeviceOrientationPortraitUpsideDown )
    {
        // 2
        currentOrientation = ALAssetOrientationDown;
    }
    else if( orientation == UIDeviceOrientationLandscapeRight )
    {
        // 3
        currentOrientation = ALAssetOrientationRight;
    }
    else if( orientation == UIDeviceOrientationLandscapeLeft )
    {
        // 4
        currentOrientation = ALAssetOrientationLeft;
    }
    else
    {
        // faceup,facedown,error
        // do nothing
        //NSLog(@"# rotated unsupported orientation");
    }
}

@end

