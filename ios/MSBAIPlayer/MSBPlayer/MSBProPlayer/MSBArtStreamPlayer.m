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
#import "MSBAVMedia.h"
/**
 4. timer
 模拟器支持
 */
 
@interface MSBArtStreamPlayer ()<MSBAVMediaDelegate>
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@property (nonatomic, assign) MSBVideoDecoderMode mode;
@property (nonatomic, assign) MSBArtPlaybackStatus videoStatus;
@property (nonatomic, assign) BOOL readPlay;//如果多线程，需要加锁
@property (nonatomic, assign) BOOL shutDown;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int tStatus;
@property (nonatomic, strong) MSBAVMedia *avMedia;
@end

@implementation MSBArtStreamPlayer
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
        _videoStatus = MSBArtPlaybackStatusUnknow;
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
    if (notification.object != self.player) { return; }
    int status = [[[notification userInfo] valueForKey:@"PlayerStatus"] intValue];
    _tStatus = status;
    MSBArtPlaybackStatus oldStatus = _videoStatus;
    if (_tStatus == 2) {
        [self startTimer];
        _videoStatus = MSBArtPlaybackStatusReady;
    } else if (_tStatus == 3) {
        _videoStatus = MSBArtPlaybackStatusBuffering;
    } else if (_tStatus == 4) {
        _videoStatus = MSBArtPlaybackStatusPlaying;
    } else if (_tStatus == 5) {
        _videoStatus = MSBArtPlaybackStatusPaused;
    } else if (_tStatus == 6) {
        _videoStatus = MSBArtPlaybackStatusEnded;
    } else {
        return;
    }
    if (_videoStatus == oldStatus) { return; }
    [self callBackPlaybackStatusError:nil];
}

- (void)playerStoppedWithError:(NSNotification *)notification {
    if (notification.object != self.player) { return; }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"连接服务器失败或者错误的URL", nil)};
    NSError *error = [NSError errorWithDomain:@"com.meishubao.art.ErrorDomain" code:-1000 userInfo:userInfo];
    [self callBackPlaybackStatusError:error];
}

- (void)callBackPlaybackStatusError:(NSError *)error {
    if (_playbackStatus) {
        _playbackStatus(_videoStatus, error);
    }
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
    
    if (_loadedTime) {
        _loadedTime(_player.playableDuration, duration);
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
    if (_mode == MSBVideoDecoderModeSoftware) {
        if (videoDataBlock) {
            _avMedia = [[MSBAVMedia alloc] init];
            _avMedia.delegate = self;
        } else {
            _avMedia = nil;
        }
    } else {
        if (videoDataBlock) {
            __weak MSBArtStreamPlayer *weakSelf = self;
            MSBIJKAVManager.manager.videoDataBlock = ^(CVPixelBufferRef pixelBuffer) {
                __strong MSBArtStreamPlayer *strongSelf = weakSelf;
                if (strongSelf.videoDataBlock) {
                    strongSelf.videoDataBlock(pixelBuffer);
                }
            };
        } else {
            MSBIJKAVManager.manager.videoDataBlock = nil;
        }
    }
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
    if (_audioDataBlock) {
        __weak MSBArtStreamPlayer *weakSelf = self;
        MSBIJKAVManager.manager.audioDataBlock = ^(int sampleRate, int channels, void *data, int size) {
            __strong MSBArtStreamPlayer *strongSelf = weakSelf;
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

#pragma mark - MSBAVMediaDelegate
//-(void)media:(MSBAVMedia *)media videoData:(NSData *)data width:(int)width height:(int)height {
//    if (_yuvDataBlock) {
//        _yuvDataBlock(width, height, data);
//    }
//}

- (void)media:(MSBAVMedia *)media buffer:(CVPixelBufferRef)pixelBuffer {
    if (_videoDataBlock) {
        _videoDataBlock(pixelBuffer);
    }
}
@end
