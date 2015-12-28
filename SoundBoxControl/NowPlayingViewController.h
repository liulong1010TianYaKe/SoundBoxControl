//
//  NowPlayingViewController.h
//  SoundBoxControl
//
//  Created by neldtv on 15/3/16.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SGFocusImageFrame.h"
#import "OnLineMusicModule.h"

@interface NowPlayingViewController : UIViewController<SGFocusImageFrameDelegate, UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) MPMediaItem *playingMediaItem;
@property (nonatomic, strong) OnLineMusicModule *playingNetMediaItem;

-(void)playNetLink:(OnLineMusicModule *)item;
-(void)playLocal:(MPMediaItem *)item;

-(void)playOrStop:(id)sender;
-(void)next:(id)sender;
-(void)prev:(id)sender;

@end
