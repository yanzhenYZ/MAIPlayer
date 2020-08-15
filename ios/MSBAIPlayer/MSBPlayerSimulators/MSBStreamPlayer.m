//
//  MSBStreamPlayer.m
//  MSBAIPlayer
//
//  Created by yanzhen on 2020/6/20.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBStreamPlayer.h"


@implementation MSBStreamPlayer
@synthesize loadedTime = _loadedTime;
@synthesize playbackTime = _playbackTime;
@synthesize videoGravity = _videoGravity;
@synthesize playerStatus = _playerStatus;
@synthesize playbackStatus = _playbackStatus;
@synthesize playbackTimeInterval = _playbackTimeInterval;

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[MSBStreamPlayer alloc] initWithURL:URL];
}


- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - property readonly
- (NSURL *)URL {
    return nil;
}

- (NSTimeInterval)currentTime {
    return 0;
}

- (NSTimeInterval)duration {
    return 0;
}

- (MSBAIPlaybackStatus)status {
    return MSBAIPlaybackStatusEnded;
}

- (BOOL)isPlaying {
    return NO;
}

- (BOOL)isEnded {
    return NO;
}

- (BOOL)isPaused {
    return NO;
}

#pragma mark - property
- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    
}

- (NSTimeInterval)playbackTimeInterval {
    return 0;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    
}

- (AVLayerVideoGravity)videoGravity {
    return _videoGravity;
}

- (void)setPlayerStatus:(void (^)(AVPlayerStatus, NSError *))playerStatus {
    _playerStatus = playerStatus;
}

- (void (^)(AVPlayerStatus, NSError *))playerStatus {
    return _playerStatus;
}

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    _loadedTime = loadedTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    return _loadedTime;
}

- (void)setPlaybackStatus:(void (^)(MSBAIPlaybackStatus))playbackStatus {
    _playbackStatus = playbackStatus;
}

- (void (^)(MSBAIPlaybackStatus))playbackStatus {
    return _playbackStatus;
}

- (void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    _playbackTime = playbackTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    return _playbackTime;
}

#pragma mark - funcs
- (void)attachToView:(UIView *)view {
    
}

- (void)play {
    
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    
}

- (void)seekToTime:(NSTimeInterval)time {
    
}

- (UIImage *)currentImage {
    return nil;
}

- (void)dealloc
{
    
}
@end
