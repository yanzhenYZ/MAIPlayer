//
//  MSBAVScaleManager.m
//  MSBPlayer
//
//  Created by yanzhen on 2020/8/20.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBAVScaleManager.h"
//#import "MSBIJKAVManager.h" //todo
#import "MSBMedia.h"

static int MSBVideoScaleCallBack(uint8_t* data, int width, int height) {
    NSData *videoData = [NSData dataWithBytes:data length:width * height * 3 / 2];
    [NSNotificationCenter.defaultCenter postNotificationName:@"MSBAVSCALEVUDEODATA" object:videoData userInfo:@{@"width" : @(width), @"height" : @(height)}];
    return 0;
}

@implementation MSBAVScaleManager {
    MSBMedia::MSBMediaScale *_mediaScale;
   
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mediaScale = createMediaScale();
        _mediaScale->video_init(&MSBVideoScaleCallBack);
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(ktvVideoDataCallBack:) name:@"MSBAVSCALEVUDEODATA" object:nil];
    }
    return self;
}

- (void)ktvVideoDataCallBack:(NSNotification *)note {
    NSData *data = note.object;
    int width = [note.userInfo[@"width"] intValue];
    int height = [note.userInfo[@"height"] intValue];
    uint8_t *buffer = (uint8_t *)data.bytes;
//    [MSBIJKAVManager.manager yuv420PToPixelBuffer:buffer vBuffer:buffer + width * height * 5 / 4 uBuffer:buffer + width * height  width:width height:height];
    
    if ([_delegate respondsToSelector:@selector(manager:videoData:width:height:)]) {
        [_delegate manager:self videoData:data width:width height:height];
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    releaseMediaScale();
}
@end
