//
//  MSBIJKAVManager.m
//  MSBPlayer
//
//  Created by yanzhen on 2020/8/17.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBIJKAVManager.h"

#define AUDIO 0

@interface MSBIJKAVManager ()
#if AUDIO
@property (nonatomic, strong) NSFileHandle *audioHandle;
#endif
@end

@implementation MSBIJKAVManager
static id _managet;
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _managet = [[MSBIJKAVManager alloc] init];
    });
    return _managet;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _managet = [super allocWithZone:zone];
    });
    return _managet;
}

- (BOOL)softOut {
    return !_videoToolbox && _videoDataBlock;
}

- (id)copyWithZone:(NSZone *)zone {
    return _managet;
}

-(void)audio:(int)freq channels:(int)channels data:(void *const)mAudioData size:(UInt32)size {
#if AUDIO
    if (!_audioHandle) {
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.pcm"];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        [NSFileManager.defaultManager createFileAtPath:path contents:nil attributes:nil];
        _audioHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        NSLog(@"4321---%@:%@", path, _audioHandle);
    }
    NSData *data = [NSData dataWithBytes:mAudioData length:size];
    [_audioHandle writeData:data];
#endif
    
    if (_audioDataBlock) {
        _audioDataBlock(freq, channels, mAudioData, size);
    }
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (_videoDataBlock) {
        _videoDataBlock(pixelBuffer);
    }
}

- (void)yuv420PToPixelBuffer:(uint8_t *)yBuffer vBuffer:(uint8_t *)uBuffer uBuffer:(uint8_t *)vBuffer width:(int)width height:(int)height {
    [self convert_5_Error02:yBuffer vBuffer:uBuffer uBuffer:vBuffer width:width height:height];
}

- (void)convert_5_Error02:(unsigned char *)yBuffer vBuffer:(unsigned char *)uBuffer uBuffer:(unsigned char *)vBuffer width:(int)width height:(int)height {
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            width,
                                            height,
                                            kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"Unable to create cvpixelbuffer %d", result);
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t dstStrideY  = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    size_t dstStrideUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    //size_t dstHY = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    //size_t dstHUV = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    unsigned char *yDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t offset = (dstStrideY - width) / 2;
    for (int i = 0; i < height; i++) {
        memcpy(yDestPlane + dstStrideY * i + offset, yBuffer + width * i, width);
    }
    
    unsigned char *uvDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    offset = (dstStrideUV - width / 2) / 2;
    for (int i = 0; i < height / 2; i++) {
        for (int j = 0; j < width / 2; j++) {
            uvDestPlane[dstStrideUV * i + offset + j * 2] = uBuffer[width / 2 * i + j];
            uvDestPlane[dstStrideUV * i + offset + j * 2 + 1] = vBuffer[width / 2 * i + j];
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    [MSBIJKAVManager.manager displayPixelBuffer:pixelBuffer];
    CVPixelBufferRelease(pixelBuffer);
}

@end
