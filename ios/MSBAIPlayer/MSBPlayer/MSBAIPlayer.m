//
//  MSBAIPlayer.m
//  MSBPlayer
//
//  Created by yanzhen on 2020/6/29.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBAIPlayer.h"
#import "MSBAIApplePlayer.h"
#import "MSBStreamPlayer.h"

/**
 //yanzhen 2020-06-29 MSB 缩放功能 M001
 //yanzhen 2020-07-30 MSB 加载，手动播放
 */

/**
1. 需要直接播放
2. seek接口只有一个参数
3. 去掉手势
4. 新播放状态
5. MSBStreamPlayer不能使用CGAffineTransform
*/



@interface MSBAIPlayer ()
@property (nonatomic, strong) id<MSBAIPlayerProtocol> player;
@end

@implementation MSBAIPlayer
- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        _URL = URL;
//        NSString *url = URL.absoluteString.lowercaseString;
        //[self createPlayer:![url containsString:@".m3u8"]];
        [self createPlayer:YES];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL apple:(BOOL)apple {
    if (self = [super init]) {
        _URL = URL;
        [self createPlayer:apple];
    }
    return self;
}


- (void)createPlayer:(BOOL)apple {
    if (apple) {
        _player = [[MSBAIApplePlayer alloc] initWithURL:_URL];
    } else {
        _player = [[MSBStreamPlayer alloc] initWithURL:_URL];
    }
    
}

#pragma mark - property readonly
- (NSTimeInterval)currentTime {
    return _player.currentTime;
}

- (NSTimeInterval)duration {
    return _player.duration;
}

- (UIImage *)currentImage {
    return _player.currentImage;
}

- (MSBAIPlaybackStatus)status {
    return _player.status;
}

- (BOOL)isPlaying {
    return _player.isPlaying;
}

- (BOOL)isPaused {
    return _player.isPaused;
}

- (BOOL)isEnded {
    return _player.isEnded;
}

#pragma mark - property

-(void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    _player.playbackTimeInterval = playbackTimeInterval;
}

- (NSTimeInterval)playbackTimeInterval {
    return _player.playbackTimeInterval;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _player.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return _player.videoGravity;
}

- (void)setPlayerStatus:(void (^)(AVPlayerStatus, NSError *))playerStatus {
    _player.playerStatus = playerStatus;
}

- (void (^)(AVPlayerStatus, NSError *))playerStatus {
    return _player.playerStatus;
}

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    _player.loadedTime = loadedTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    return _player.loadedTime;
}

- (void)setPlaybackStatus:(void (^)(MSBAIPlaybackStatus))playbackStatus {
    _player.playbackStatus = playbackStatus;
}

- (void (^)(MSBAIPlaybackStatus))playbackStatus {
    return _player.playbackStatus;
}

- (void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    _player.playbackTime = playbackTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    return _player.playbackTime;
}

- (void)setAudioDataBlock:(void (^)(int, int, void *, int))audioDataBlock {
    _player.audioDataBlock = audioDataBlock;
}

- (void (^)(int, int, void *, int))audioDataBlock {
    return _player.audioDataBlock;
}

#pragma mark - func
- (void)attachToView:(UIView *)view {
    [_player attachToView:view];
}

- (void)play {
    [_player play];
}

- (void)pause {
    [_player pause];
}

- (void)resume {
    [_player resume];
}

- (void)stop {
    [_player stop];
}

- (void)seekToTime:(NSTimeInterval)time {
    [_player seekToTime:time];
}

/**
 1.1 加载资源，手动播放
 */
+ (NSString *)getVersion {
    return @"1.1.0";
}
@end
