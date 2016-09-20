
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#import "ApplicationConfig.h"
#import "DeviceConfig.h"

#import "AlbumDayBlock.h"

@class AlbumDayBlock;
@class DeviceConfig;

@interface AlbumContainer : UIScrollView <UIScrollViewDelegate>
{
    UIView *albumView; // holding AlbumDayBlock objects as its subview
    int accumulatedBlockHeight;
    int last_offset; // to check delayedThumbnailLoad threshold, initial minus value, updated if delayedThumbnailLoad block runs
    int delayedThumbnailLoad_threshold; // rebuild album view if it moved more than this threshold
}

- (void) rebuildAlbum;
- (void) delayedThumbnailLoad:(UIScrollView *)scrollView;

@end
