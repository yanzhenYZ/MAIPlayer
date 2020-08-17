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
@end
