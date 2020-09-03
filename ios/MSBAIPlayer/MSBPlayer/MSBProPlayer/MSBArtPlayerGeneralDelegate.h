//
//  MSBArtPlayerGeneralDelegate.h
//  MSBPlayer
//
//  Created by yanzhen on 2020/9/3.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBAIEnum.h"

@protocol MSBArtPlayerGeneralDelegate <NSObject>

@optional
- (void)playerStatusDidChange:(MSBArtPlaybackStatus)status error:(NSError *)error;
- (void)playerLoadedTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)playerPlaybackTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
//AVPlayer not support 
- (void)playerVideoData:(CVPixelBufferRef)pixelBuffer;
- (void)playerAudioData:(void *)data size:(int)size sampleRate:(int)sampleRate channels:(int)channels;
@end

