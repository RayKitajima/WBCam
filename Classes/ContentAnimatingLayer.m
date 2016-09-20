
#import <objc/runtime.h>
#import <objc/message.h>
#import "ContentAnimatingLayer.h"
#import "PreviewHelper.h"

@interface ContentAnimatingLayer (/*Private*/)
- (void)_updateTimerFired:(NSTimer *)timer;
@end

@implementation ContentAnimatingLayer

// Ghetto support for -actionFor<Key>
static CFMutableDictionaryRef ActionNameToSelector = NULL;


#pragma mark
#pragma mark === object setting ===
#pragma mark

static SEL ActionSelectorForKey(NSString *key)
{
    // TODO: Locking, if you need it.
    // OBPRECONDITION([NSThread isMainThread]);
    
    SEL sel = (SEL)CFDictionaryGetValue(ActionNameToSelector, (__bridge_retained void *)key);
    if (sel == NULL) {
        NSString *selName = [NSString stringWithFormat:@"actionFor%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
        sel = NSSelectorFromString(selName);
        
        key = [key copy]; // Make sure it won't go away
        CFDictionarySetValue(ActionNameToSelector, (__bridge_retained void *)key, sel);
    }
    return sel;
}

static Boolean _equalStrings(const void *value1, const void *value2)
{
    return [(__bridge NSString *)value1 isEqualToString:(__bridge NSString *)value2];
}
static CFHashCode _hashString(const void *value)
{
    return CFHash((CFStringRef)value);
}

+ (void)initialize;
{
    if (self == [ContentAnimatingLayer class]) {
        CFDictionaryKeyCallBacks keyCallbacks;
        memset(&keyCallbacks, 0, sizeof(keyCallbacks));
        keyCallbacks.hash = _hashString;
        keyCallbacks.equal = _equalStrings;
        
        CFDictionaryValueCallBacks valueCallbacks;
        memset(&valueCallbacks, 0, sizeof(valueCallbacks));
        ActionNameToSelector = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallbacks, &valueCallbacks);
    }
}

#pragma mark
#pragma mark === NSObject (NSKeyValueObservingCustomization) ===
#pragma mark

// Might want to rename this instead of using the KVO method; or not.
+ (NSSet *)keyPathsForValuesAffectingContent;
{
    return [NSSet set];
}


#pragma mark
#pragma mark === NSObject subclass ===
#pragma mark

+ (BOOL)resolveInstanceMethod:(SEL)sel;
{
    // Called due to -respondsToSelector: in our -actionForKey:, but only if it doesn't have the method already (in which case we assume it does something reasonble).  Install a method that provides an animation for the property. Right now we are doing a forward lookup of key->sel since this shouldn't get called often, though we could invert the dictionary if needed.
    for (NSString *key in [self keyPathsForValuesAffectingContent]) {
        if (ActionSelectorForKey(key) == sel) {
            // Clone a default behavior over to this key.
            Method m = class_getInstanceMethod(self, @selector(basicAnimationForKey:));
            class_addMethod(self, sel, method_getImplementation(m), method_getTypeEncoding(m));
            return YES;
        }
    }
    
    return [super resolveInstanceMethod:sel];
}


#pragma mark
#pragma mark === CALayer subclass ===
#pragma mark

- (id <CAAction>)actionForKey:(NSString *)event;
{
    SEL sel = ActionSelectorForKey(event);
    if ([self respondsToSelector:sel])
        return objc_msgSend(self, sel, event); // NOTE that we pass the event here. This will be an extra hidden argument to -actionFor<Key> but will be used by the default -basicAnimationForKey:.
    return [super actionForKey:event];
}

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key;
{
    if ([self isContentAnimation:anim]) {
        // Sadly, even though we set it, removedOnCompletion seems to do nothing (and we can't really depend on subclasses remembering to do this), so keep track of the active animations here.
        // OBASSERT(anim.delegate == nil);
        // OBASSERT([_activeContentAnimations indexOfObjectIdentialTo:anim] == NSNotFound);
        anim.delegate = self;
    }
	
    [super addAnimation:anim forKey:key];
}

 
#pragma mark
#pragma mark === CAAnimation deleate ===
#pragma mark

- (void)animationDidStart:(CAAnimation *)anim;
{
    // Have to do the add here instead of in -addAnimation:forKey: since a copy is started, not the original passed in.
    if ([self isContentAnimation:anim]) {
        if (!_updateTimer)
        {
            PreviewHelper *previewHelper = [PreviewHelper sharedInstance];
            _updateTimer = [NSTimer scheduledTimerWithTimeInterval:previewHelper.manualPreviewFrameRate target:self selector:@selector(_updateTimerFired:) userInfo:nil repeats:YES];
        }
        if (!_activeContentAnimations){
            _activeContentAnimations = [[NSMutableArray alloc] init];
        }
        [_activeContentAnimations addObject:anim];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
    NSUInteger animIndex = [_activeContentAnimations indexOfObjectIdenticalTo:anim];
    if (animIndex == NSNotFound)
        return;
    
    [_activeContentAnimations removeObjectAtIndex:animIndex];
    if ([_activeContentAnimations count] == 0) {
        _activeContentAnimations = nil;
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
}


#pragma mark
#pragma mark === API ===
#pragma mark

- (BOOL)isContentAnimation:(CAAnimation *)anim;
{
    if (![anim isKindOfClass:[CAPropertyAnimation class]])
        return NO;
    
    // Will be fater if subclass +keyPathsForValuesAffectingContent don't autorelease each time we call them.  Better way to do this?
    CAPropertyAnimation *prop = (CAPropertyAnimation *)anim;
    return [[[self class] keyPathsForValuesAffectingContent] member:[prop keyPath]] != nil;
}

- (CABasicAnimation *)basicAnimationForKey:(NSString *)key;
{
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:key];
    // basic.removedOnCompletion = YES; Doesn't actually cause one of the remove methods to be called
    basic.fromValue = [self.presentationLayer valueForKey:key]; // without this set, when our timer fires, the presentation layer won't report any changes.  Bug in CA, I hear.
    return basic;
}

- (id <CAAction>)actionForContents;
{
    // We don't want to cross-fade between content images.
    return nil;
}


#pragma mark
#pragma mark === Private API ===
#pragma mark

- (void)_updateTimerFired:(NSTimer *)timer;
{
    [self setNeedsDisplay];
}

@end
