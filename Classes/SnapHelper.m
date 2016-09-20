
#import "SnapHelper.h"
#import "CameraController.h"
#import "CameraSession.h"
#import "PreviewHelper.h"
#import "WhiteBalanceConverter.h"
#import "ApplicationUtility.h"

@interface SnapHelper(Private)
- (void) snapRawStillImageWithALAssetOrientation:(ALAssetOrientation)orientation;
- (void) snapJpegStillImageWithALAssetOrientation:(ALAssetOrientation)orientation;
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
@end

@implementation SnapHelper
@synthesize stillImageOutput;
@synthesize checked;

static SnapHelper *sharedInstance = nil;


#pragma mark
#pragma mark === snap controll ===
#pragma mark

//[PRODUCTION]
// snap as raw, with orientation and neon wb
- (void) snapRawStillImageWithALAssetOrientation:(ALAssetOrientation)orientation
{
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[stillImageOutput connections]];
    
    NSLog(@"# snap !");
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                      if (imageDataSampleBuffer != NULL) {
                                                          WhiteBalanceConverter *whiteBalanceConverter = [WhiteBalanceConverter sharedInstance];
                                                          
                                                          //NSDate *now = [NSDate date];
                                                          
                                                          CGImageRef imageRef = [whiteBalanceConverter allocCGImageApplyingWhiteBalanceForCMSampleBufferRef:imageDataSampleBuffer withALAssetOrientation:orientation];
                                                          UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
                                                          
                                                          //NSDate *then = [NSDate date];
                                                          //NSLog(@"RAW PROC: %1.3fsec", [then timeIntervalSinceDate:now]);
                                                          
                                                          // meta data
                                                          CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
                                                          
                                                          [CameraController saveSnap:image withMetadata:attachments];
                                                          
                                                          CGImageRelease(imageRef);
                                                          CFRelease(attachments);
                                                      }
                                                  }];
}

// snap as jpeg, with orientation and neon wb
- (void) snapJpegStillImageWithALAssetOrientation:(ALAssetOrientation)orientation
{
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[stillImageOutput connections]];
    
    NSLog(@"# snap !");
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                      if (imageDataSampleBuffer != NULL) {
                                                          
                                                          //NSDate *now_jpg = [NSDate date];
                                                          
                                                          NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                          UIImage *jpegImage = [[UIImage alloc] initWithData:imageData];
                                                          
                                                          //NSDate *then_jpg = [NSDate date];
                                                          //NSLog(@"RETRIEVE JPEG: %1.3fsec", [then_jpg timeIntervalSinceDate:now_jpg]);
                                                          
                                                          // get bitmap
                                                          
                                                          //NSDate *now = [NSDate date];
                                                          
                                                          CGImageRef cgImage = jpegImage.CGImage;
                                                          CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
                                                          CFDataRef dataRef = CGDataProviderCopyData(dataProvider); // crash in 4S
                                                          
                                                          //NSDate *then = [NSDate date];
                                                          //NSLog(@"BITMAP from JPEG: %1.3fsec", [then timeIntervalSinceDate:now]);
                                                          
                                                          // adjust wb
                                                          WhiteBalanceConverter *whiteBalanceConverter = [WhiteBalanceConverter sharedInstance];
                                                          CGImageRef imageRef = [whiteBalanceConverter allocCGImageApplyingWhiteBalanceForCFDataRef:dataRef withALAssetOrientation:orientation];
                                                          UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
                                                          CFRelease(dataRef);
                                                          
                                                          // meta data
                                                          CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
                                                          
                                                          [CameraController saveSnap:image withMetadata:attachments];
                                                          
                                                          // release CGImageRef owned by whiteBalanceConverter
                                                          // whitout this CGImageRelease makes leak.
                                                          CGImageRelease(imageRef);
                                                          
                                                          CFRelease(attachments);
                                                          
                                                          //CGDataProviderRelease(dataProvider);
                                                          //CGImageRelease(cgImage);
                                                      }
                                                  }];
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for( AVCaptureConnection *connection in connections ){
        for( AVCaptureInputPort *port in [connection inputPorts] ){
            if( [[port mediaType] isEqual:mediaType] ){
                return connection;
            }
        }
    }
    return nil;
}

#pragma mark
#pragma mark === object setting ===
#pragma mark

- (id) init
{
	self = [super init];
    
    NSLog(@"SnapHelper : initializing");
    
    // prep output
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    BOOL asJpeg = NO;
    //BOOL asJpeg = YES;
    
    NSDictionary *outputSetting;
    if ( asJpeg ) {
        // jpeg output
        outputSetting = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    }else{
        // raw output
        outputSetting = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    }
    [stillImageOutput setOutputSettings:outputSetting];
    
    // ********************************************
    //  iOS5 supports dual resolution
    //  stillImageOutput object is once added here
    //  and presist while application alive
    // ********************************************
    NSLog(@"adding stillImageOutput to the global session");
    AVCaptureSession *session = [CameraSession session];
    [session beginConfiguration];
    if( [session canAddOutput:stillImageOutput] ){
        [session addOutput:stillImageOutput];
    }else{
        NSLog(@"SnapHelper : # fail to prepare stillImageOutput");
    }
    [session commitConfiguration];
    
    
    NSLog(@"SnapHelper : output ready");
    
	return self;
}

#pragma mark
#pragma mark === singleton interface ===
#pragma mark

+ (id) sharedInstance
{
    @synchronized(self){
        if(!sharedInstance){ 
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

// gate for raw|jpeg
+ (void) snapStillImageWithALAssetOrientation:(ALAssetOrientation)orientation
{
    SnapHelper *instance = [self sharedInstance];
    //[instance snapJpegStillImageWithALAssetOrientation:orientation];
    [instance snapRawStillImageWithALAssetOrientation:orientation];
}
// raw snap
+ (void) snapRawStillImageWithALAssetOrientation:(ALAssetOrientation)orientation
{
    SnapHelper *instance = [self sharedInstance];
    [instance snapRawStillImageWithALAssetOrientation:orientation];
}
// jpeg snap
+ (void) snapJpegStillImageWithALAssetOrientation:(ALAssetOrientation)orientation
{
    SnapHelper *instance = [self sharedInstance];
    [instance snapJpegStillImageWithALAssetOrientation:orientation];
}

// dummy
+ (void) checkInstance
{
    SnapHelper *instance = [self sharedInstance];
    instance.checked = YES;
}

@end
