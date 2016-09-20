
#import <Foundation/Foundation.h>

typedef enum {
    kApplicationContext_Camera,
    kApplicationContext_Album
} ApplicationContextType;

@class DeviceConfig;

@interface ApplicationConfig : NSObject
{
    DeviceConfig *deviceConfig;
    dispatch_queue_t finderPreviewQueue;
    dispatch_queue_t backgroundQueue;
    NSLock *shared_lock;
}
@property (retain) DeviceConfig *deviceConfig;
@property (nonatomic) dispatch_queue_t finderPreviewQueue; // main thread
@property (nonatomic) dispatch_queue_t backgroundQueue;    // background thread
@property (retain) NSLock *shared_lock;

+ (void) bootup;
- (void) validate;

+ (id) sharedInstance;

+ (DeviceConfig *) deviceConfig;

+ (dispatch_queue_t) finderPreviewQueue; // main thread
+ (dispatch_queue_t) foregroundQueue;    // main thread
+ (dispatch_queue_t) backgroundQueue;    // background thread

+ (NSLock *) sharedLock;

@end

