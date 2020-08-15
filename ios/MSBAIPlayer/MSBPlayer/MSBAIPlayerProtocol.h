//
//  MSBAIPlayerProtocol.h
//  MSBAIPlayer
//
//  Created by yanzhen on 2020/6/21.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MSBAIEnum.h"
/**
 1. 需要直接播放
 2. seek接口只有一个参数
 3. 去掉手势
 4. 新播放状态
 5. MSBStreamPlayer不能使用CGAffineTransform 
 */


@protocol MSBAIPlayerProtocol <NSObject>

@property (nonatomic, readonly) NSURL *URL;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) UIImage *currentImage;

@property (nonatomic, readonly) MSBAIPlaybackStatus status;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL isEnded;

@property (nonatomic, assign) NSTimeInterval playbackTimeInterval;
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

//cancel
@property (nonatomic, copy) void (^playerStatus)(AVPlayerStatus status, NSError *error);
@property (nonatomic, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, copy) void (^playbackStatus)(MSBAIPlaybackStatus status);
@property (nonatomic, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);

- (void)attachToView:(UIView *)view;

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

- (void)seekToTime:(NSTimeInterval)time;

@end



