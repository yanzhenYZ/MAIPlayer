//
//  MSBAVScaleManager.h
//  MSBPlayer
//
//  Created by yanzhen on 2020/8/20.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSBAVScaleManager;
@protocol MSBAVScaleManagerDelegate <NSObject>

- (void)manager:(MSBAVScaleManager *)manager videoData:(NSData *)data width:(int)width height:(int)height;

@end

@interface MSBAVScaleManager : NSObject
@property (nonatomic, weak) id<MSBAVScaleManagerDelegate> delegate;
@end
