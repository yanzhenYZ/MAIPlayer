//
//  MSBIJKAVManager.h
//  MSBPlayer
//
//  Created by yanzhen on 2020/8/17.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSBIJKAVManager : NSObject

@property (nonatomic, copy) void (^audioDataBlock)(int sampleRate, int channels, void *data, int size);

+ (instancetype)manager;

- (void)audio:(int)freq channels:(int)channels data:(void * const)mAudioData size:(UInt32)size;

@end


