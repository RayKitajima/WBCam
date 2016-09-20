
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SnapButton.h"
#import "GearButton.h"
#import "LibIcon.h"


@interface PreviewToolBar : UIView {
    
    SnapButton *snapButton;
	GearButton *gearButton;
    LibIcon *libIcon;
    
    UIImageView *backgroundImage;
    UIImageView *backgroundShadow;
    
    UIActivityIndicatorView *indicator; // while saving photo
    
}

- (void) updateIcon;

- (void) gearButtonOn;
- (void) gearButtonOff;

- (void) disableButtonAction;
- (void) enableButtonAction;

- (void) enterSnappingBlock;
- (void) enterSavingBlock;
- (void) exitSavingBlock;

@end
