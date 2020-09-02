//
//  MSBArtPlayer.h
//  MSBPlayer
//
//  Created by yanzhen on 2020/9/2.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MSBAIEnum.h"
/**
 原生播放
 软件播放
 
 模拟器支持
 */
@interface MSBArtPlayer : NSObject

@property (nonatomic, readonly) UIView *playerView;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) UIImage *currentImage;

@property (nonatomic, readonly) MSBArtPlaybackStatus status;
//default is 1s
@property (nonatomic, assign) NSTimeInterval playbackTimeInterval;
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

@property (nonatomic, copy) void (^videoDataBlock)(CVPixelBufferRef pixelBuffer);
@property (nonatomic, copy) void (^audioDataBlock)(int sampleRate, int channels, void *data, int size);
@property (nonatomic, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, copy) void (^playbackStatus)(MSBAIPlaybackStatus status);
@property (nonatomic, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url mode:(MSBVideoDecoderMode)mode;
//please use property: playerView
- (void)attachToView:(UIView *)view;

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time;

+ (NSString *)getVersion;
@end

