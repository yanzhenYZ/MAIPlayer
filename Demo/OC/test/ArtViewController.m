//
//  ArtViewController.m
//  test
//
//  Created by yanzhen on 2020/9/2.
//  Copyright © 2020 yanzhen. All rights reserved.
//

#import "ArtViewController.h"
#import <MSBPlayer/MSBPlayer.h>

@interface ArtViewController ()<MSBArtPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;
@property (nonatomic, strong) MSBArtPlayer *player;
@end

@implementation ArtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self playVideo];
}

- (IBAction)playOrPause:(UIButton *)sender {
    if (sender.isSelected) {
        [_player resume];
    } else {
        [_player pause];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)sliderAction:(UISlider *)sender {
    [_player seekToTime:sender.value];
}

- (void)playVideo {
    NSString *path = [NSBundle.mainBundle pathForResource:@"3" ofType:@"mp4"];
    NSURL *pathUrl = [NSURL fileURLWithPath:path];
    
    NSURL *url = [NSURL URLWithString:@"http://39.107.116.40/res/tpl/default/file/guoke.mp4"];
    
    _player = [[MSBArtPlayer alloc] initWithURL:url mode:MSBVideoDecoderModeDisplayLayer];
    _player.delegate = self;
    _player.playerView.frame = self.view.bounds;
    [self.view insertSubview:_player.playerView atIndex:0];
    
    __weak ArtViewController *weakSelf = self;
    [_player play];
    _player.playbackStatus = ^(MSBArtPlaybackStatus status, NSError *error) {
        NSLog(@"22 playbackStatus: %ld:%@", (long)status, error);
    };
    
    _player.playbackTime = ^(NSTimeInterval time, NSTimeInterval duration) {
        weakSelf.slider.maximumValue = duration;
        weakSelf.slider.value = time;
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%.f/%.f", time, duration];
    };
    
    _player.loadedTime = ^(NSTimeInterval time, NSTimeInterval duration) {
//        NSLog(@"44 loadedTime: %f/%f", time, duration);
    };
    
    
//    _player.audioDataBlock = ^(int sampleRate, int channels, void *data, int size) {
//        NSLog(@"55 audioDataBlock: %d, %d, %d", sampleRate, channels, size);
//    };
    
    
//    _player.videoDataBlock = ^(CVPixelBufferRef pixelBuffer) {
//        [weakSelf displayVideo:pixelBuffer];
//    };
    
    
//    _player.yuvDataBlock = ^(int width, int height, NSData *data) {
//        @autoreleasepool {//must do this
//            [weakSelf autoBGRA:width height:height data:data];
//        }
//    };
    
}


#pragma mark - MSBArtPlayerDelegate
-(void)player:(MSBArtPlayer *)player statusDidChange:(MSBArtPlaybackStatus)status error:(NSError *)error {
    NSLog(@"-------statusDidChange:%d:%@", status, error);
}

- (void)player:(MSBArtPlayer *)player loadedTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    NSLog(@"-------loadedTime:%f:%f", time, duration);
}

- (void)player:(MSBArtPlayer *)player playbackTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    NSLog(@"-------playbackTime:%f:%f", time, duration);
}

- (void)player:(MSBArtPlayer *)player audioData:(void *)data size:(int)size sampleRate:(int)sampleRate channels:(int)channels {
    NSLog(@"-------audioData:%d:%d:%d", size, sampleRate, channels);
}

-(void)player:(MSBArtPlayer *)player videoData:(CVPixelBufferRef)pixelBuffer {
    NSLog(@"-------videoData:%@", pixelBuffer);
}
@end
