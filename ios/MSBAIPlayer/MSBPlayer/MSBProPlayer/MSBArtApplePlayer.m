//
//  MSBArtApplePlayer.m
//  MSBPlayer
//
//  Created by yanzhen on 2020/9/2.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBArtApplePlayer.h"
#import "IJKAVMoviePlayerController.h"

@interface MSBArtApplePlayer ()
@property (nonatomic, strong) IJKAVMoviePlayerController *player;
@property (nonatomic, assign) MSBArtPlaybackStatus videoStatus;
@property (nonatomic, assign) IJKMPMoviePlaybackState ijkStatus;
@end

@implementation MSBArtApplePlayer
@synthesize videoGravity = _videoGravity;
@synthesize playbackStatus = _playbackStatus;
@synthesize audioDataBlock = _audioDataBlock;
@synthesize videoDataBlock = _videoDataBlock;

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _videoGravity = AVLayerVideoGravityResizeAspect;
        _player = [[IJKAVMoviePlayerController alloc] initWithContentURL:url];
        __weak MSBArtApplePlayer *weakSelf = self;
        _player.playerStatus = ^(AVPlayerStatus status, NSError *error) {
            __strong MSBArtApplePlayer *strongSelf = weakSelf;
            if (status == AVPlayerStatusReadyToPlay) {
                if (strongSelf.playbackStatus) {
                    strongSelf.playbackStatus(MSBArtPlaybackStatusReady, nil);
                }
            }
        };
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoStatus = MSBArtPlaybackStatusUnknow;
        _ijkStatus = IJKMPMoviePlaybackStatePaused;//AVPlayer默认状态暂停
        _player.scalingMode = IJKMPMovieScalingModeAspectFit;
        _player.shouldAutoplay = NO;
        [self addObserver];
        [_player prepareToPlay];
    }
    return self;
}

- (void)addObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPlaybackStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPlaybackDidFinish:) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
}
/*
 IJKMPMoviePlaybackStateStopped
 IJKMPMoviePlaybackStateSeekingForward
 IJKMPMoviePlaybackStatePlaying
 IJKMPMoviePlaybackStatePaused
 */
- (void)playerPlaybackStateDidChange:(NSNotification *)note {
    if (note.object != self.player) { return; }
    if (_ijkStatus == _player.playbackState) { return; }
    _ijkStatus = _player.playbackState;
    switch (_ijkStatus) {
        case IJKMPMoviePlaybackStateStopped:
            _videoStatus = MSBArtPlaybackStatusEnded;
            break;
        case IJKMPMoviePlaybackStatePlaying:
            _videoStatus = MSBArtPlaybackStatusPlaying;
            break;
        case IJKMPMoviePlaybackStatePaused:
            _videoStatus = MSBArtPlaybackStatusPaused;
            break;
        case IJKMPMoviePlaybackStateInterrupted:
            _videoStatus = MSBArtPlaybackStatusInterrupted;
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward:
            _videoStatus = MSBArtPlaybackStatusSeeking;
            break;
        default:
            break;
    }
    if (_playbackStatus) {
        _playbackStatus(_videoStatus, nil);
    }
    
}

- (void)playerPlaybackDidFinish:(NSNotification *)note {
    if (note.object != self.player) { return; }
    int reason = [note.userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == IJKMPMovieFinishReasonPlaybackEnded && _videoStatus != MSBArtPlaybackStatusEnded) {
        _videoStatus = MSBArtPlaybackStatusEnded;
        if (_playbackStatus) {
            _playbackStatus(_videoStatus, nil);
        }
    } else if (reason == IJKMPMovieFinishReasonPlaybackError) {
        NSError *error = note.userInfo[@"error"];
        _videoStatus = MSBArtPlaybackStatusError;
        if (_playbackStatus) {
            _playbackStatus(_videoStatus, error);
        }
    }
}
#pragma mark - funcs

- (void)play {
    //init if set is NO, must play this 
    _player.shouldAutoplay = YES;
    [_player play];
}

- (void)pause {
    [_player pause];
}

- (void)resume {
    [_player play];
}

- (void)stop {
    [_player shutdown];
}

- (void)seekToTime:(NSTimeInterval)time {
    _player.currentPlaybackTime = time;
}

#pragma mark - property
- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    if ([videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        _player.scalingMode = IJKMPMovieScalingModeAspectFit;
    } else if ([videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        _player.scalingMode = IJKMPMovieScalingModeAspectFill;
    } else if ([videoGravity isEqualToString:AVLayerVideoGravityResize]) {
        _player.scalingMode = IJKMPMovieScalingModeFill;
    }
}

- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    self.player.playbackTimeInterval = playbackTimeInterval;
}

- (NSTimeInterval)playbackTimeInterval {
    return self.player.playbackTimeInterval;
}

-(void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    _player.playbackTime = playbackTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    return _player.playbackTime;
}

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    _player.loadedTime = loadedTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    return _player.loadedTime;
}

- (void)setPlayerStatus:(void (^)(AVPlayerStatus, NSError *))playerStatus {
    _player.playerStatus = playerStatus;
}

- (void (^)(AVPlayerStatus, NSError *))playerStatus {
    return _player.playerStatus;
}

-(void)setPlaybackStatus:(void (^)(MSBArtPlaybackStatus, NSError *))playbackStatus {
    _playbackStatus = playbackStatus;
}

- (void (^)(MSBArtPlaybackStatus, NSError *))playbackStatus {
    return _playbackStatus;
}

- (void)setAudioDataBlock:(void (^)(int, int, void *, int))audioDataBlock {
    _audioDataBlock = audioDataBlock;
}

- (void (^)(int, int, void *, int))audioDataBlock {
    return _audioDataBlock;
}

- (void)setVideoDataBlock:(void (^)(CVPixelBufferRef))videoDataBlock {
    _videoDataBlock = videoDataBlock;
}

- (void (^)(CVPixelBufferRef))videoDataBlock {
    return _videoDataBlock;
}

#pragma mark - property readOnly
- (UIView *)playerView {
    return _player.view;
}

- (NSTimeInterval)currentTime {
    return _player.currentPlaybackTime;
}

- (NSTimeInterval)duration {
    return _player.duration;
}

- (MSBArtPlaybackStatus)status {
    return _videoStatus;
}

- (UIImage *)currentImage {
    return _player.thumbnailImageAtCurrentTime;
}
@end
