
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "AlbumThumbnailView.h"
#import "AlbumDecoration.h"
#import "AlbumActionCenter.h"

@interface AlbumThumbnailView(Private)
- (void) toggleSelection;
@end

@implementation AlbumThumbnailView
@synthesize fileName, metaName, dayDir, iso_day, thumbPath, previewPath, photoPath, metaPath;
@synthesize block;

#pragma mark
#pragma mark === Touch handling  ===
#pragma mark

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"detect touch on file:%@",fileName);
    return;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( [AlbumActionCenter isMultiSelectionMode] ){
        [self toggleSelection];
    }else{
        // show snap view
        [AlbumActionCenter presentSnapViewControllerWithThumb:self];
    }
}

#pragma mark
#pragma mark === thumbnail manager ===
#pragma mark

- (void) toggleSelection
{
    if( selected ){
        selected = NO;
        selectionImageView.hidden = YES;
        [AlbumActionCenter deselectPhoto:self];
        //NSLog(@"AlbumThumbnailView.toggleSelection : de-selected file:%@",fileName);
        //NSLog(@"AlbumThumbnailView.toggleSelection : subviews:%@",[self subviews]);
    }else{
        selected = YES;
        selectionImageView.hidden = NO;
        [AlbumActionCenter selectPhoto:self];
        //NSLog(@"AlbumThumbnailView.toggleSelection : selected file:%@",fileName);
        //NSLog(@"AlbumThumbnailView.toggleSelection : subviews:%@",[self subviews]);
    }
}

// logical action for controller : deprecated
- (void) toggleSelectionOnlyView
{
    selectionImageView.hidden = !selected;
}

// selection checker
- (BOOL) selected
{
    return selected;
}

#pragma mark
#pragma mark === visibility controller ===
#pragma mark

- (AlbumThumbnailView *) getPrev
{
    // seek my index
    int index = 0;
    for( int i=0; i<block.files.count; i++ ){
        if( [[block.files objectAtIndex:i] isEqualToString:self.fileName] ){
            index = i;
            break;
        }
    }
    
    AlbumThumbnailView *prev = nil;
    if( index != 0 ){
        prev = [block.thumbs objectAtIndex:(index-1)];
    }else{
        AlbumDayBlock *prev_block = block.prev;
        if( !prev_block.loaded ){
            [prev_block buildDayBlock];
        }
        if( prev_block != nil ){
            //prev = [block.prev.thumbs objectAtIndex:(block.prev.thumbs.count-1)]; // unsafe
            prev = [block.prev lastThumb];
        }
    }
    
    return prev;
}

- (AlbumThumbnailView *) getNext
{
    // seek my index
    int index = 0;
    for( int i=0; i<block.files.count; i++ ){
        if( [[block.files objectAtIndex:i] isEqualToString:self.fileName] ){
            index = i;
            break;
        }
    }
    
    AlbumThumbnailView *next = nil;
    if( index != block.files.count-1 ){
        next = [block.thumbs objectAtIndex:(index+1)];
    }else{
        AlbumDayBlock *next_block = block.next;
        if( !next_block.loaded ){
            [next_block buildDayBlock];
        }
        if( next_block != nil ){
            //next = [block.next.thumbs objectAtIndex:0]; // unsafe
            next = [block.next firstThumb];
        }
    }
    
    return next;
}

- (void) loadThumbView
{
    //NSLog(@"# loading thumbnail view file:%@ iso_day:%@", fileName,iso_day);
    
    UIImage *selectionImage = [AlbumDecoration selectionImage];
    selectionImageView = [[UIImageView alloc] initWithImage:selectionImage];
    selectionImageView.frame = CGRectMake(1, 1, 75, 75);
    selectionImageView.hidden = !selected;
    
    thumbImageView = [self thumbImageView];
    thumbImageView.frame = CGRectMake(1, 1, 75, 75);
    thumbImageView.hidden = YES;
    
    //UIImage *shadowImage = [AlbumDecoration shadowImage];
    //shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    //shadowImageView.frame = CGRectMake(0, 0, 78, 78);
    
    //[self addSubview:shadowImageView];
    [self addSubview:thumbImageView];
    [self addSubview:selectionImageView];
}

- (void) unloadView
{
    //NSLog(@"# unloading thumbnail view file:%@ iso_day:%@", fileName,iso_day);
    
    [thumbImageView removeFromSuperview];
    [selectionImageView removeFromSuperview];
    
    selectionImageView = nil;
    thumbImageView = nil;
}

- (void) showThumb
{
    //NSLog(@"# showThumb of file:%@ iso_day:%@",fileName,iso_day);
    
    // 
    // bug point, why the thumbImageView is nil?
    // 
    if( thumbImageView == nil ){
        //NSLog(@"### thumbImageView for %@ is null, loading image file",fileName);
        [self loadThumbView];
    }
    NSArray *subs = [self subviews];
    //NSLog(@"### thumb obj %@ has %d subviews",fileName,subs.count);
    if( subs.count == 0 ){
        //NSLog(@"### no subviews in the thumb, re-adding");
        [self addSubview:thumbImageView];
        [self addSubview:selectionImageView];
    }
    thumbImageView.hidden = NO;
}

- (void) hideThumb
{
    //NSLog(@"# hideThumb of file:%@ iso_day:%@",fileName,iso_day);
    
    thumbImageView.hidden = YES;
    selectionImageView.hidden = YES;
    if( thumbImageView != nil ){
        [self unloadView];
    }
}

#pragma mark
#pragma mark === file management / data access  ===
#pragma mark

// return value should be retained?
- (NSData *) photoData
{
    return [[NSData alloc] initWithContentsOfFile:photoPath];
}
- (NSData *) previewData
{
    return [[NSData alloc] initWithContentsOfFile:previewPath];
}
- (NSData *) thumbData
{
    return [[NSData alloc] initWithContentsOfFile:thumbPath];
}
- (PhotoMetaData *) metaObj
{
    NSData *metaData = [[NSData alloc] initWithContentsOfFile:metaPath];
    PhotoMetaData *metaObj = (PhotoMetaData *)[NSKeyedUnarchiver unarchiveObjectWithData:metaData];
    return metaObj;
}

// returned imageView is retained
- (UIImageView *) previewImageView
{
    if( previewImageView ){
        return previewImageView;
    }
    NSData *previewData = [self previewData];
    UIImage *previewImage = [[UIImage alloc] initWithData:previewData];
    previewImageView = [[UIImageView alloc] initWithImage:previewImage];
    return previewImageView;
}
- (UIImageView *) thumbImageView
{
    if( thumbImageView ){
        return thumbImageView;
    }
    NSData *thumbData = [self thumbData];
    UIImage *thumbImage = [[UIImage alloc] initWithData:thumbData];
    thumbImageView = [[UIImageView alloc] initWithImage:thumbImage];
    return thumbImageView;
}

// [recommended] memory reduced
- (UIImageView *) allocPhotoImageView
{
    NSData *photoData = [self photoData];
    UIImage *photoImage = [[UIImage alloc] initWithData:photoData];
    UIImageView *newPhotoImageView = [[UIImageView alloc] initWithImage:photoImage];
    return newPhotoImageView;
}
// [deprecated] memory consuming
- (UIImageView *) photoImageView
{
    if( photoImageView ){
        return photoImageView;
    }
    NSData *photoData = [self photoData];
    UIImage *photoImage = [[UIImage alloc] initWithData:photoData];
    photoImageView = [[UIImageView alloc] initWithImage:photoImage];
    return photoImageView;
}

// destructive
- (void) removeThumbAndPreview
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:thumbPath error:NULL];
    [fileManager removeItemAtPath:previewPath error:NULL];
}

// destructive
// trash_path already ending with iso_day
- (void) removeMetaAndPhotoWithTrashPath:(NSString *)trash_path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *trashed_metaPath = [trash_path stringByAppendingPathComponent:metaName];
    NSString *trashed_photoPath = [trash_path stringByAppendingPathComponent:fileName];
    
    NSLog(@"moving file %@ to %@", photoPath, trashed_photoPath );
    NSLog(@"moving file %@ to %@", metaPath, trashed_metaPath );
    
    [fileManager moveItemAtPath:metaPath toPath:trashed_metaPath error:NULL];
    [fileManager moveItemAtPath:photoPath toPath:trashed_photoPath error:NULL];
}

// dectructive
- (void) removeFromAlbumDayBlock
{
    [block delinkWithThumb:self];
}

#pragma mark
#pragma mark === trashing animation ===
#pragma mark

- (void) trashAnimation
{
    NSLog(@"trash animation...");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    self.center = CGPointMake(self.frame.origin.x+20, self.frame.origin.y+self.frame.size.height/2);
    self.layer.opacity = 0.0;
    [UIView commitAnimations];
}

#pragma mark
#pragma mark === object setup ===
#pragma mark

// dir is full path
- (id) initWithFrame:(CGRect)frame dir:(NSString *)dir file:(NSString *)file
{
    //NSLog(@"instantiating Thumbnail : %@",file);
    
    self = [super initWithFrame:frame];
    
    fileName = file;
    dayDir = dir; // full path
    thumbPath = [[dayDir stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:file];
    previewPath = [[dayDir stringByAppendingPathComponent:@"preview"] stringByAppendingPathComponent:file];
    photoPath = [[dayDir stringByAppendingPathComponent:@"photo"] stringByAppendingPathComponent:file];
    
    metaName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"meta"];
    metaPath = [[dayDir stringByAppendingPathComponent:@"meta"] stringByAppendingPathComponent:metaName];
    
    iso_day = [dayDir lastPathComponent];
    
    thumbImageView = nil;
    selectionImageView = nil;
    //shadowImageView = nil;
    
    selected = NO;
    
    block = nil; // parent block
    
    return self;
}

@end




