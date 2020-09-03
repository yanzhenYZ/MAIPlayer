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
 模拟器支持
 */

@protocol MSBArtPlayerDelegate;
@interface MSBArtPlayer : NSObject

@property (nonatomic, weak) id<MSBArtPlayerDelegate> delegate;

@property (nonatomic, readonly) UIView *playerView;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) UIImage *currentImage;
@property (nonatomic, readonly) MSBArtPlaybackStatus status;

//default is 1s, just set once
@property (nonatomic, assign) NSTimeInterval playbackTimeInterval;
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;
//not support for MSBVideoDecoderModeDisplayLayer
@property (nonatomic, copy) void (^videoDataBlock)(CVPixelBufferRef pixelBuffer);
//not support for MSBVideoDecoderModeDisplayLayer
@property (nonatomic, copy) void (^audioDataBlock)(int sampleRate, int channels, void *data, int size);
@property (nonatomic, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, copy) void (^playbackStatus)(MSBArtPlaybackStatus status, NSError *error);
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

@protocol MSBArtPlayerDelegate <NSObject>

@optional
- (void)player:(MSBArtPlayer *)player statusDidChange:(MSBArtPlaybackStatus)status error:(NSError *)error;
- (void)player:(MSBArtPlayer *)player loadedTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)player:(MSBArtPlayer *)player playbackTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
//MSBVideoDecoderModeDisplayLayer not support
- (void)player:(MSBArtPlayer *)player videoData:(CVPixelBufferRef)pixelBuffer;
//MSBVideoDecoderModeDisplayLayer not support
- (void)player:(MSBArtPlayer *)player audioData:(void *)data size:(int)size sampleRate:(int)sampleRate channels:(int)channels;

@end
