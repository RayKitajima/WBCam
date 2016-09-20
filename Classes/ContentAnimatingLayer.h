
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>

@interface ContentAnimatingLayer : CALayer
{
@private
    NSMutableArray *_activeContentAnimations;
    NSTimer *_updateTimer;
}

+ (NSSet *)keyPathsForValuesAffectingContent;

- (BOOL)isContentAnimation:(CAAnimation *)anim;
- (CABasicAnimation *)basicAnimationForKey:(NSString *)key;
- (id <CAAction>)actionForContents;

#define CurrentAnimationValue(field) ({ __typeof__(self) p = (id)self.presentationLayer; p.field; })

@end
