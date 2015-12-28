//
//  GlobalMusicInstance.h
//  SoundBoxControl
//
//  Created by neldtv on 15/3/16.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFSoundManager.h"
#import "AudioPlayer.h"
#import "NowPlayingViewController.h"

@interface GlobalMusicInstance : NSObject {
    AFSoundQueue *queue;
}

@property   (nonatomic,retain) MPMusicPlayerController      *musicPlayer;
@property   (nonatomic,retain) MPMediaItemCollection        *mediaCollection;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) NSMutableArray *netArray;

@property (nonatomic, retain) AFSoundQueue *queue;

@property (nonatomic, retain) NowPlayingViewController *nowPlayingViewController;
@property (nonatomic, retain) AudioPlayer *APPPlayer;

+ (GlobalMusicInstance *)sharedSingleton;

@end