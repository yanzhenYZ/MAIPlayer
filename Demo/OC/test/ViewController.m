//
//  ViewController.m
//  test
//
//  Created by yanzhen on 2020/8/21.
//  Copyright © 2020 yanzhen. All rights reserved.
//

#import "ViewController.h"
#import <MSBPlayer/MSBPlayer.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) CIContext *context;

@property (nonatomic, strong) MSBAIPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self playVideo];
    
}

- (void)playVideo {
    NSString *path = [NSBundle.mainBundle pathForResource:@"1" ofType:@"mp4"];
    NSURL *pathUrl = [NSURL fileURLWithPath:path];
    
    NSURL *url = [NSURL URLWithString:@"http://39.107.116.40/res/tpl/default/file/guoke.mp4"];
    
    _player = [[MSBAIPlayer alloc] initWithURL:pathUrl mode:MSBVideoDecoderModeSoftware];
    [_player attachToView:self.view];
    
    __weak ViewController *weakSelf = self;
    _player.playerStatus = ^(AVPlayerStatus status, NSError *error) {
        NSLog(@"11 playerStatus: %ld : %@", (long)status, error);
        if (status == AVPlayerStatusReadyToPlay) {
            [weakSelf.player play];
        }
    };
    
    _player.playbackStatus = ^(MSBAIPlaybackStatus status) {
        NSLog(@"22 playbackStatus: %ld", (long)status);
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
    
    
    _player.videoDataBlock = ^(CVPixelBufferRef pixelBuffer) {
        [weakSelf displayVideo:pixelBuffer];
    };
    
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

- (void)displayVideo:(CVPixelBufferRef)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixelBuffer];
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGImageRef imageRef = [self.context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    if (!imageRef) {
        NSLog(@"Create Image fail with CVPixelBufferRef");
        return;
    }
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.smallPlayer.image = image;
    });
    
}

-(CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

@end
