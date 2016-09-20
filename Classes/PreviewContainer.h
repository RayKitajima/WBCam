
#import <UIKit/UIKit.h>

@interface PreviewContainer : UIView {
    
    bool canEnterWhitePointSelection;
    bool canEnterColorSelection;
    BOOL canEnterAEAFLock;
    
    CGPoint lastTouchPoint; // for preventing continuous touch event after/while press
    
	UIView *finderView;
}

@property (retain) UIView *finderView;

- (BOOL) finderDimmed;
- (void) dimmFinder;
- (void) illumFinder;
- (void) hideFinder;

- (void) releaseLastTouchPoint;

- (BOOL) canEnterWhitePointSelection;
- (void) blockEnterWhitepointSelection;
- (void) enableEnterWhitepointSelection;

- (BOOL) canEnterColorSelection;
- (void) blockEnterColorSelection;
- (void) enableEnterColorSelection;

- (BOOL) canEnterAEAFLock;
- (void) blockEnterAEAFLock;
- (void) enableEnterAEAFLock;

@end
