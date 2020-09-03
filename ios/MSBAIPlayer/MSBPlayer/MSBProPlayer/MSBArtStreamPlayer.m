//
//  MSBArtStreamPlayer.m
//  MSBPlayer
//
//  Created by yanzhen on 2020/9/2.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBArtStreamPlayer.h"
#import "IJKFFMoviePlayerController.h"
#import "MSBIJKAVManager.h"
/**
 1. 状态
 2. audio
 3. video
 4. timer
 */
@interface MSBArtStreamPlayer ()
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@property (nonatomic, assign) MSBVideoDecoderMode mode;
@property (nonatomic, assign) MSBArtPlaybackStatus videoStatus;
@property (nonatomic, assign) BOOL readPlay;//如果多线程，需要加锁
@property (nonatomic, assign) BOOL shutDown;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation MSBArtStreamPlayer
@synthesize delegate = _delegate;
@synthesize loadedTime = _loadedTime;
@synthesize playbackTime = _playbackTime;
@synthesize videoGravity = _videoGravity;
@synthesize playbackStatus = _playbackStatus;
@synthesize playbackTimeInterval = _playbackTimeInterval;
@synthesize audioDataBlock = _audioDataBlock;
@synthesize videoDataBlock = _videoDataBlock;

- (instancetype)initWithURL:(NSURL *)url mode:(MSBVideoDecoderMode)mode {
    self = [super init];
    if (self) {
        _videoGravity = AVLayerVideoGravityResizeAspect;
        IJKFFOptions *ffOptions = [IJKFFOptions optionsByDefault];
        _mode = mode;
        switch (mode) {
            case MSBVideoDecoderModeToolBoxSync:
                [ffOptions setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
                MSBIJKAVManager.manager.videoToolbox = YES;
                break;
            case MSBVideoDecoderModeToolBoxAsync:
                [ffOptions setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
                [ffOptions setPlayerOptionIntValue:1 forKey:@"videotoolbox-async"];
                MSBIJKAVManager.manager.videoToolbox = YES;
                break;
            default:
                break;
        }
        
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:ffOptions];
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoStatus = MSBArtPlaybackStatusBuffering;
//        _ijkStatus = IJKMPMoviePlaybackStatePaused;
        _player.scalingMode = IJKMPMovieScalingModeAspectFit;
        [self addObserver];
        self.playbackTimeInterval = 1.0f;
    }
    return self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusDidChange:)
                                                 name:PlayerStatusDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStoppedWithError:)
                                                 name:PlayerStoppedWithErrorNotification object:_player];
}

- (void)playerStatusDidChange:(NSNotification *)notification {
    
}

- (void)playerStoppedWithError:(NSNotification *)notification {
    if (notification.object != self.player) { return; }
//    if (_playerStatus) {
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"连接服务器失败或者错误的URL", nil)};
//        NSError *error = [NSError errorWithDomain:@"com.meishubao.art.ErrorDomain" code:100 userInfo:userInfo];
//        _playerStatus(AVPlayerStatusFailed, error);
//    }
}

#pragma mark - timer
- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:_playbackTimeInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerAction {
    NSTimeInterval duration = _player.duration;
    if (_playbackTime) {
        _playbackTime(_player.currentPlaybackTime, duration);
    }
    if ([_delegate respondsToSelector:@selector(playerPlaybackTime:duration:)]) {
        [_delegate playerPlaybackTime:_player.currentPlaybackTime duration:duration];
    }
    
    if (_loadedTime) {
        _loadedTime(_player.playableDuration, duration);
    }
    if ([_delegate respondsToSelector:@selector(playerLoadedTime:duration:)]) {
        [_delegate playerLoadedTime:_player.playableDuration duration:duration];
    }
}
#pragma mark - method
- (void)play {
    if (_readPlay) {
        [_player play];
    } else {
        _readPlay = YES;
        [_player prepareToPlay];
    }
}

- (void)pause {
    [_player pause];
}

- (void)resume {
    [_player play];
}

- (void)stop {
    if (!_shutDown) {
        _shutDown = YES;
        [self stopTimer];
        [_player shutdown];
    }
}

- (void)seekToTime:(NSTimeInterval)time {
    _player.currentPlaybackTime = time;
}
#pragma mark - property
- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    if (_playbackTimeInterval == playbackTimeInterval) {
        return;
    }
    _playbackTimeInterval = playbackTimeInterval;
    [self startTimer];
}

- (NSTimeInterval)playbackTimeInterval {
    return _playbackTimeInterval;
}

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

- (AVLayerVideoGravity)videoGravity {
    return _videoGravity;
}

- (void)setVideoDataBlock:(void (^)(CVPixelBufferRef))videoDataBlock {
    _videoDataBlock = videoDataBlock;
}

- (void (^)(CVPixelBufferRef))videoDataBlock {
    return _videoDataBlock;
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

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    _loadedTime = loadedTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    return _loadedTime;
}

- (void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    _playbackTime = playbackTime;
}

- (void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    return _playbackTime;
}

- (void)setDelegate:(id<MSBArtPlayerGeneralDelegate>)delegate {
    _delegate = delegate;
}

- (id<MSBArtPlayerGeneralDelegate>)delegate {
    return _delegate;
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

- (UIImage *)currentImage {
    return _player.thumbnailImageAtCurrentTime;
}

- (MSBArtPlaybackStatus)status {
    return _videoStatus;
}
@end
