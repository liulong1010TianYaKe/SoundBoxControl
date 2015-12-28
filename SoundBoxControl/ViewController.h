//
//  ViewController.h
//  SoundBoxControl
//
//  Created by neldtv on 15/3/5.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnLineMusicModule.h"
@import MediaPlayer;

@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *bottomView;

@property (retain, nonatomic) MPVolumeView *airPlayButton;
@property (retain, nonatomic) UIButton *playBarplayBtn;
@property (retain, nonatomic) UIButton *playBarnextBtn;
@property (retain, nonatomic) UIButton *playBarprevBtn;

@property (retain, nonatomic) UISlider *playSlider;
@property (retain, nonatomic) NSTimer  *updateTimer;

@property (retain, nonatomic) UILabel *nonPlayLabel;
@property (retain, nonatomic) UILabel *playbarTitle;
@property (retain, nonatomic) UILabel *playbarArtisName;

@property (nonatomic, strong) OnLineMusicModule *playingNetMediaItem;

@end

