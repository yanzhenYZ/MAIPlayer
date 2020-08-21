//
//  MSBStreamPlayer.m
//  MSBAIPlayer
//
//  Created by yanzhen on 2020/6/20.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import "MSBStreamPlayer.h"
#import "IJKFFMoviePlayerController.h"
#import "MSBIJKAVManager.h"
#import "MSBAVScaleManager.h"

@interface MSBStreamPlayer ()<MSBAVScaleManagerDelegate>
@property (nonatomic, assign) IJKMPMoviePlaybackState ijkStatus;
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, assign) MSBAIPlaybackStatus videoStatus;

@property (nonatomic, assign) int tStatus;
@property (nonatomic, assign) BOOL shutDown;

@property (nonatomic, strong) MSBAVScaleManager *manage;
@end

@implementation MSBStreamPlayer
@synthesize loadedTime = _loadedTime;
@synthesize playbackTime = _playbackTime;
@synthesize videoGravity = _videoGravity;
@synthesize playerStatus = _playerStatus;
@synthesize playbackStatus = _playbackStatus;
@synthesize playbackTimeInterval = _playbackTimeInterval;
@synthesize audioDataBlock = _audioDataBlock;
@synthesize videoDataBlock = _videoDataBlock;
@synthesize yuvDataBlock = _yuvDataBlock;

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[MSBStreamPlayer alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL mode:MSBVideoDecoderModeToolBoxSync];
}

- (instancetype)initWithURL:(NSURL *)URL mode:(MSBVideoDecoderMode)mode {
    if (self = [super init]) {
        _videoUrl = URL;
        _videoGravity = AVLayerVideoGravityResizeAspect;
        _playbackTimeInterval = 1.0f;
        IJKFFOptions *ffOptions = [IJKFFOptions optionsByDefault];
        
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
        
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:URL withOptions:ffOptions];
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoStatus = MSBAIPlaybackStatusBuffering;
        _ijkStatus = IJKMPMoviePlaybackStatePaused;
        _player.scalingMode = IJKMPMovieScalingModeAspectFit;
        _player.shouldAutoplay = NO;
        [self addObserver];
        [_player prepareToPlay];
    }
    return self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusDidChange:)
                                                 name:PlayerStatusDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStoppedWithError:)
                                                 name:PlayerStoppedWithErrorNotification object:_player];
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerVideoDecoderOpen:) name:IJKMPMoviePlayerVideoDecoderOpenNotification object:_player];
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(playerVideoFrameRenderedStart:) name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification object:_player];
}

- (void)playerStatusDidChange:(NSNotification *)notification {
    if (notification.object != self.player) {
        return;
    }
    int status = [[[notification userInfo] valueForKey:@"PlayerStatus"] intValue];
    if (_tStatus == status) {
        return;
    }
    _tStatus = status;
    MSBAIPlaybackStatus oldStatus = _videoStatus;
    if (_tStatus == 2) {
        [self startTimer];
        if (_playerStatus) {
            _playerStatus(AVPlayerStatusReadyToPlay, nil);
        }
    } else if (_tStatus == 3) {
        _videoStatus = MSBAIPlaybackStatusBuffering;
    } else if (_tStatus == 4) {
        _videoStatus = MSBAIPlaybackStatusPlaying;
    } else if (_tStatus == 5) {
        _videoStatus = MSBAIPlaybackStatusPaused;
    } else if (_tStatus == 6) {
        _videoStatus = MSBAIPlaybackStatusEnded;
    } else if (_tStatus == 7) {
        if (_playerStatus) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"未知错误", nil)};
            NSError *error = [NSError errorWithDomain:@"com.meishubao.art.ErrorDomain" code:100 userInfo:userInfo];
            _playerStatus(AVPlayerStatusFailed, error);
        }
    } else {
        return;
    }
    if (_videoStatus == oldStatus) {
        return;
    }
    if (_playbackStatus) {
        _playbackStatus(_videoStatus);
    }
}

- (void)playerStoppedWithError:(NSNotification *)notification {
    if (notification.object != self.player) {
        return;
    }
    if (_playerStatus) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"连接服务器失败或者错误的URL", nil)};
        NSError *error = [NSError errorWithDomain:@"com.meishubao.art.ErrorDomain" code:100 userInfo:userInfo];
        _playerStatus(AVPlayerStatusFailed, error);
    }
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_playbackTimeInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerAction {
    if (_playbackTime) {
        _playbackTime(_player.currentPlaybackTime, _player.duration);
    }
    
    if (_loadedTime) {
        _loadedTime(_player.playableDuration, _player.duration);
    }
}

#pragma mark - property readonly
- (NSURL *)URL {
    return _videoUrl;
}

- (NSTimeInterval)currentTime {
    return _player.currentPlaybackTime;
}

- (NSTimeInterval)duration {
    return _player.duration;
}

- (MSBAIPlaybackStatus)status {
    return _videoStatus;
}

- (BOOL)isPlaying {
    return _videoStatus == MSBAIPlaybackStatusPlaying;
}

- (BOOL)isEnded {
    return _videoStatus == MSBAIPlaybackStatusEnded;
}

- (BOOL)isPaused {
    return _videoStatus == MSBAIPlaybackStatusPaused;
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

- (void)setAudioDataBlock:(void (^)(int, int, void *, int))audioDataBlock {
    _audioDataBlock = audioDataBlock;
    if (_audioDataBlock) {
        __weak MSBStreamPlayer *weakSelf = self;
        MSBIJKAVManager.manager.audioDataBlock = ^(int sampleRate, int channels, void *data, int size) {
            __strong MSBStreamPlayer *strongSelf = weakSelf;
            if (strongSelf.audioDataBlock) {
                strongSelf.audioDataBlock(sampleRate, channels, data, size);
            }
        };
    } else {
        MSBIJKAVManager.manager.audioDataBlock = nil;
    }
}

- (void (^)(int, int, void *, int))audioDataBlock {
    return _audioDataBlock;
}

- (void)setVideoDataBlock:(void (^)(CVPixelBufferRef))videoDataBlock {
    _videoDataBlock = videoDataBlock;
    if (videoDataBlock) {
        __weak MSBStreamPlayer *weakSelf = self;
        MSBIJKAVManager.manager.videoDataBlock = ^(CVPixelBufferRef pixelBuffer) {
            __strong MSBStreamPlayer *strongSelf = weakSelf;
            if (strongSelf.videoDataBlock) {
                strongSelf.videoDataBlock(pixelBuffer);
            }
        };
    } else {
        MSBIJKAVManager.manager.videoDataBlock = nil;
    }
}

- (void (^)(CVPixelBufferRef))videoDataBlock {
    return _videoDataBlock;
}

- (void)setYuvDataBlock:(void (^)(int, int, NSData *))yuvDataBlock {
    _yuvDataBlock = yuvDataBlock;
    if (yuvDataBlock) {
        _manage = [[MSBAVScaleManager alloc] init];
        _manage.delegate = self;
    } else {
        _manage = nil;
    }
}

- (void (^)(int, int, NSData *))yuvDataBlock {
    return _yuvDataBlock;
}

#pragma mark - funcs
- (void)attachToView:(UIView *)view {
    if (_view == view) {
        return;
    }
    _view = view;
    if (NSThread.isMainThread) {
        [_player.view removeFromSuperview];
        _player.view.frame = view.bounds;
        [view insertSubview:_player.view atIndex:0];
//        [view addSubview:_player.view];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_player.view removeFromSuperview];
            _player.view.frame = view.bounds;
            [view insertSubview:_player.view atIndex:0];
//            [view addSubview:_player.view];
        });
    }
}

- (void)play {
    [_player play];
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

- (UIImage *)currentImage {
    return [_player thumbnailImageAtCurrentTime];
}

- (void)dealloc
{
    if (NSThread.isMainThread) {
        [_player.view removeFromSuperview];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_player.view removeFromSuperview];
        });
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - MSBAVScaleManagerDelegate
- (void)manager:(MSBAVScaleManager *)manager videoData:(NSData *)data width:(int)width height:(int)height {
    if (_yuvDataBlock) {
        _yuvDataBlock(width, height, data);
    }
}
@end
