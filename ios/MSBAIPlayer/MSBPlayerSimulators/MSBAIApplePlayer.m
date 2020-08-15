//
//  MSBAIApplePlayer.m
//  MSBAIPlayer
//
//  Created by yanzhen on 2020/6/20.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBAIApplePlayer.h"

@interface MSBAIApplePlayer ()

@end



@implementation MSBAIApplePlayer
@synthesize videoGravity = _videoGravity;
@synthesize playbackStatus = _playbackStatus;

+(instancetype)playerWithURL:(NSURL *)URL {
    return [[MSBAIApplePlayer alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - property
//readonly
- (NSURL *)URL {
    return nil;
}

- (MSBAIPlaybackStatus)status {
    return MSBAIPlaybackStatusEnded;
}

- (NSTimeInterval)currentTime {
    return 0;
}

- (NSTimeInterval)duration {
    return 0;
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

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
}

- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    
}

- (NSTimeInterval)playbackTimeInterval {
    return 0;
}

-(void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    
}

- (void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    return nil;
}

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    
}

- (void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    return nil;
}

- (void)setPlayerStatus:(void (^)(AVPlayerStatus, NSError *))playerStatus {
   
}

- (void (^)(AVPlayerStatus, NSError *))playerStatus {
    return nil;
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

- (void)dealloc {
    
}
@end
