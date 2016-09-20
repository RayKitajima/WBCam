
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "AlbumContainer.h"
#import "PhotoMetaData.h"

@class AlbumDayBlock;

@interface AlbumThumbnailView : UIView
{
    BOOL selected; // for multi-selection mode
    
    NSString *fileName;    // image file name : <UNIXTIME.jpg>
    NSString *metaName;    // meta file name : <UNIXTIME.meta>
    NSString *dayDir;      // full path
    NSString *iso_day;     // iso_day folder name
    NSString *thumbPath;   // ~/thumb/<UNIXTIME.jpg>
    NSString *previewPath; // ~/thumb/<UNIXTIME.jpg>
    NSString *photoPath;   // ~/photo/<UNIXTIME.jpg>
    NSString *metaPath;    // ~/meta/<UNIXTIME.meta>
    
    UIView *dummyRect;
    UIImageView *selectionImageView;
    UIImageView *shadowImageView;
    UIImageView *thumbImageView;
    UIImageView *previewImageView;
    UIImageView *photoImageView; // deprecated, memory consuming
    
    AlbumDayBlock *block; // parent
    
    AlbumContainer *albumContainer;
}

@property (retain) NSString *fileName;
@property (retain) NSString *metaName;
@property (retain) NSString *dayDir;
@property (retain) NSString *iso_day;
@property (retain) NSString *thumbPath;
@property (retain) NSString *previewPath;
@property (retain) NSString *photoPath;
@property (retain) NSString *metaPath;

@property (retain) AlbumDayBlock *block;

- (BOOL) selected;
- (void) showThumb;
- (void) hideThumb;
- (void) toggleSelection;
- (id) initWithFrame:(CGRect)frame dir:(NSString *)dir file:(NSString *)file;

- (AlbumThumbnailView *) getPrev;
- (AlbumThumbnailView *) getNext;

// direct data access
- (NSData *) photoData;
- (NSData *) previewData;
- (NSData *) thumbData;
- (PhotoMetaData *) metaObj;

// cached data access
- (UIImageView *) photoImageView;
- (UIImageView *) allocPhotoImageView;
- (UIImageView *) previewImageView;
- (UIImageView *) thumbImageView;

// file management, should be called by set
- (void) removeThumbAndPreview;
- (void) removeMetaAndPhotoWithTrashPath:(NSString *)path;
- (void) removeFromAlbumDayBlock;

- (void) trashAnimation;

@end


