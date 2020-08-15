//
//  MSBAIEnum.h
//  MSBPlayer
//
//  Created by yanzhen on 2020/6/29.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSBAIPlaybackStatus) {
    MSBAIPlaybackStatusBuffering,
    MSBAIPlaybackStatusPlaying,
    MSBAIPlaybackStatusSeeking,
    MSBAIPlaybackStatusPaused,
    MSBAIPlaybackStatusEnded,
};
