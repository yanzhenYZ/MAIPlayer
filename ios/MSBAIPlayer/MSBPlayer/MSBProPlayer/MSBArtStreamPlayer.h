//
//  MSBArtStreamPlayer.h
//  MSBPlayer
//
//  Created by yanzhen on 2020/9/2.
//  Copyright © 2020 MSBAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBArtPlayerProtocol.h"
#import "MSBAIEnum.h"

@interface MSBArtStreamPlayer : NSObject<MSBArtPlayerProtocol>
- (instancetype)initWithURL:(NSURL *)url mode:(MSBVideoDecoderMode)mode;
@end

