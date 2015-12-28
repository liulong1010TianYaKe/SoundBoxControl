//
//  GlobalMusicInstance.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/16.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "GlobalMusicInstance.h"

@implementation GlobalMusicInstance

@synthesize musicPlayer;
@synthesize mediaCollection;

@synthesize selectedIndex;

@synthesize queue;

@synthesize nowPlayingViewController;
@synthesize APPPlayer;

+ (GlobalMusicInstance *)sharedSingleton
{
    static GlobalMusicInstance *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[GlobalMusicInstance alloc] init];
        }
        
        return sharedSingleton;
    }
}
@end
