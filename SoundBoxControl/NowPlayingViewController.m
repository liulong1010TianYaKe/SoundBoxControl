//
//  NowPlayingViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/16.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "CommonMacro.h"
#import "GlobalMusicInstance.h"
#import "TFHpple.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "AFSoundItem.h"
#import "AFSoundPlayback.h"
#import "MarqueeLabel.h"
#import "LayoutParameters.h"
#import "iToast.h"

@interface NowPlayingViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (retain, nonatomic) UISlider *playSlider;
@property (retain, nonatomic) UILabel *musicNameL;
@property (retain, nonatomic) UILabel *musicArtistL;
@property (retain, nonatomic) UILabel *currentTime;
@property (retain, nonatomic) UILabel *totalTime;
@property (retain, nonatomic) UIButton *playBarplayBtn;

@property (retain, nonatomic) MarqueeLabel *titleL;

@property (retain, nonatomic) NSTimer  *updateTimer;

@property (nonatomic) NSOperationQueue *playOperation;

@end

@implementation NowPlayingViewController

NSInteger scrollIndex;
UIAlertView *baseAlert;
Boolean getNetMusicSuccess;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupViews];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startTimer];
    self.navigationController.navigationBarHidden = YES;
    
    NSTimer *scrollTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setAutoScrollBg) userInfo:nil repeats:YES];
}

-(void)setAutoScrollBg{
    CGPoint pt = _scrollView.contentOffset;
    if (pt.x == SCREEN_WIDTH){
        pt.x = 0;
    }else{
        pt.x= SCREEN_WIDTH;
    }
    [_scrollView setContentOffset:pt animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

-(BOOL)isVisble{
    return (self.isViewLoaded && self.view.window);
}

-(void)startTimer{
    if(![self isVisble]){
        return;
    }
    if (self.updateTimer != nil){
        [self.updateTimer setFireDate:[NSDate distantPast]];
    } else {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayerTime) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer{
    if (self.updateTimer != nil){
        [self.updateTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)setupViews{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *topImage = [UIImage imageNamed:@"play_page_title_bg"];
    
    UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    [tmp setBackgroundColor:[UIColor colorWithPatternImage:[self imageWithImage:topImage scaledToSize:CGSizeMake(SCREEN_WIDTH, 64)]]];
    [self.view addSubview:tmp];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 2, 0)];
    [_scrollView setPagingEnabled:YES];  //视图整页显示
    [_scrollView setBounces:NO]; //避免弹跳效果,避免把根视图露出来
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    
    _scrollView.delegate = self;
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview setImage:[UIImage imageNamed:@"player_bg_1.png"]];
    [_scrollView addSubview:imageview];
    
    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview1 setImage:[UIImage imageNamed:@"player_bg_2.png"]];
    [_scrollView addSubview:imageview1];
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    [_scrollView addGestureRecognizer:tapGestureRecognize];

    
    [self.view addSubview:_scrollView];
    
    [self setupPlayingBar];
    [self setupLrc];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 45, 20)];
    _pageControl.center = CGPointMake(SCREEN_WIDTH/2 + 20, SCREEN_HEIGHT - 133);
    _pageControl.numberOfPages = 2;
    _pageControl.currentPage = 0;
    [self.view addSubview:_pageControl];
    
    UIView *tmp2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    [tmp2 setBackgroundColor:[UIColor colorWithPatternImage:[self imageWithImage:topImage scaledToSize:CGSizeMake(SCREEN_WIDTH, 64)]]];
    [self.view addSubview:tmp2];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    
    [titleView setBackgroundColor:[UIColor clearColor]];
    
    _titleL = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30) duration:8.0 andFadeLength:10.0f];
    _titleL.textColor = [UIColor whiteColor];
    _titleL.textAlignment = NSTextAlignmentCenter;
    _titleL.center = CGPointMake(SCREEN_WIDTH/2, titleView.bounds.size.height/2);
    
    if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        [_titleL setText:item.title];
    }else {
        NSString *titleName = self.playingMediaItem != nil ? [self.playingMediaItem title] : [self.playingNetMediaItem title];//[NSString stringWithFormat:@"%@-%@",[self.playingMediaItem title], [self.playingMediaItem artist]];
        [_titleL setText:titleName];
    }
    [titleView addSubview:_titleL];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, titleView.bounds.size.height)];
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_btn_bg"] forState:UIControlStateNormal];
    backBtn.center = CGPointMake(30, titleView.bounds.size.height/2);
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_btn_bg"]];
    backImage.center = CGPointMake(30, backBtn.bounds.size.height/2);
    [backBtn addSubview:backImage];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backBtn];
    
    [self.view addSubview:titleView];
}

-(void)setupLrc{
    
}

-(void)setupPlayingBar{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 180, SCREEN_HEIGHT, 180)];
    //bottomView.backgroundColor = [UIColor colorWithRed:16/255.0 green:15/255.0 blue:15/255.0 alpha:0.5];
    UIImage *bottomImage = [UIImage imageNamed:@"play_page_bottom"];
    UIImage *bottombg = [UIImage imageNamed:@"bottombg"];
//    [bottomView setBackgroundColor:[UIColor colorWithPatternImage:[self imageWithImage:bottomImage scaledToSize:CGSizeMake(SCREEN_WIDTH, 168)]]];
    
    UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 62)];
    [tmp setBackgroundColor:[UIColor colorWithPatternImage:[self imageWithImage:bottomImage scaledToSize:CGSizeMake(SCREEN_WIDTH, tmp.bounds.size.height)]]];
    [bottomView addSubview:tmp];
    
    UIView *tmp2 = [[UIView alloc] initWithFrame:CGRectMake(0, tmp.bounds.size.height - 2, SCREEN_WIDTH, bottomView.bounds.size.height - tmp.bounds.size.height + 2)];
    [tmp2 setBackgroundColor:[UIColor colorWithPatternImage:[self imageWithImage:bottombg scaledToSize:CGSizeMake(SCREEN_WIDTH, bottomView.bounds.size.height - tmp.bounds.size.height + 2)]]];
    [bottomView addSubview:tmp2];
    
    _musicNameL = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 130, 20)];
    _musicNameL.textColor = [UIColor whiteColor];
    _musicNameL.font = [UIFont systemFontOfSize:18.0f];
    
    if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        _musicNameL.text = item.album;
        
    }else {
        _musicNameL.text = self.playingMediaItem != nil ? [self.playingMediaItem artist] : [self.playingNetMediaItem albume];
    }
    [bottomView addSubview:_musicNameL];
    
    _musicArtistL = [[UILabel alloc] initWithFrame:CGRectMake(11, 20, 160, 20)];
    _musicArtistL.textColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1.0];
    _musicArtistL.font = [UIFont systemFontOfSize:13.0f];
    
    if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        _musicNameL.text = item.title;
        
    }else {
        _musicArtistL.text = self.playingMediaItem != nil ? [self.playingMediaItem title] : [self.playingNetMediaItem title];
    }
    [bottomView addSubview:_musicArtistL];
    
    MPVolumeView *airPlayButton = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    airPlayButton.showsVolumeSlider = NO;
    [airPlayButton sizeToFit];
    airPlayButton.backgroundColor = [UIColor clearColor];// colorWithRed:32/255.0 green:32/255.0 blue:31/255.0 alpha:1.0];
    airPlayButton.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 50, 50);
    [airPlayButton setRouteButtonImage:[UIImage imageNamed:@"mvplayer_airplay_white"] forState:UIControlStateNormal];
    [airPlayButton setRouteButtonImage:[UIImage imageNamed:@"mvplayer_airplay_blue"] forState:UIControlStateSelected];
    [bottomView addSubview:airPlayButton];
    
    self.playSlider = [[UISlider alloc] initWithFrame:CGRectMake(-1,58, SCREEN_WIDTH + 2, 2)];
    
    self.playSlider.minimumValue = 0.0;
    self.playSlider.maximumValue = 1.0;
    self.playSlider.value = 0;
    
    [self.playSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    //self.playSlider.minimumTrackTintColor = APP_THEME_COLOR;//[UIColor colorWithRed:236/255.0 green:100/255.0 blue:0/255.0 alpha:1];
    [self.playSlider setMinimumTrackImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    self.playSlider.maximumTrackTintColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1];
//    [self.playSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.playSlider addTarget:self action:@selector(sliderTappedDown) forControlEvents:UIControlEventTouchDragInside];
    [self.playSlider addTarget:self action:@selector(sliderTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.playSlider];
    
    _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(6, 62, 100, 20)];
    _currentTime.textColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1.0];
    _currentTime.font = [UIFont systemFontOfSize:11.0f];
    _currentTime.text = @"00:00";
    [bottomView addSubview:_currentTime];
    
    _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 38, 62, 35, 20)];
    _totalTime.textColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1.0];
    _totalTime.font = [UIFont systemFontOfSize:11.0f];
    _totalTime.text = @"00:00";
    [bottomView addSubview:_totalTime];
    
    self.playBarplayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 67)];
    self.playBarplayBtn.center = CGPointMake(SCREEN_WIDTH/2, 120);
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_n"] forState:UIControlStateNormal];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_h"] forState:UIControlStateHighlighted];
    //    [self.playBarplayBtn setTitle:@"播放" forState:UIControlStateNormal];
    //    [self.playBarplayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.playBarplayBtn addTarget:self action:@selector(playOrStop:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.playBarplayBtn];

    UIButton *playBarprevBtn = [[UIButton alloc] initWithFrame:CGRectMake(46, 120, 40, 40)];
    playBarprevBtn.center = CGPointMake(60, 120);
    [playBarprevBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pre_n"] forState:UIControlStateNormal];
    [playBarprevBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pre_h"] forState:UIControlStateHighlighted];
    [playBarprevBtn addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playBarprevBtn];
    
    UIButton *playBarnextBtn = [[UIButton alloc] initWithFrame:CGRectMake(230, 120, 40, 40)];
    playBarnextBtn.center = CGPointMake(260, 120);
    [playBarnextBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_next_n"] forState:UIControlStateNormal];
    [playBarnextBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_next_h"] forState:UIControlStateHighlighted];
    [playBarnextBtn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playBarnextBtn];
    
    [self.view addSubview:bottomView];
    
    
    if ([GlobalMusicInstance sharedSingleton].queue != nil && [GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
    } else if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil && [GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMoviePlaybackStatePlaying){
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
    }
}
-(void)sliderTapped{
    if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil && [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil){
        [GlobalMusicInstance sharedSingleton].musicPlayer.currentPlaybackTime= _playSlider.value;
    }
    
    [self startTimer];
}

-(void)sliderTappedDown{
    [self stopTimer];
}

-(void)playLocal:(MPMediaItem *)item{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMusicFailed) object:nil];
    
    if ([GlobalMusicInstance sharedSingleton].queue) {
        [[GlobalMusicInstance sharedSingleton].queue clearQueue];
        [[GlobalMusicInstance sharedSingleton].queue release];
        [GlobalMusicInstance sharedSingleton].queue = nil;
    }
    
    if(_playOperation == nil){
        _playOperation = [[NSOperationQueue alloc] init];
        _playOperation.maxConcurrentOperationCount = 1;
    }
    [_playOperation cancelAllOperations];
    
    NSLog(@"====playLocal======");
    /*
    BOOL useSystem = YES;
    if(!useSystem){
        OnLineMusicModule *netItem = [[OnLineMusicModule alloc] init];
        netItem.title = [item valueForProperty:MPMediaItemPropertyTitle];
        netItem.albume = [item valueForProperty:MPMediaItemPropertyAlbumArtist];
        self.playingMediaItem = nil;
        self.playingNetMediaItem = netItem;
        
        if (_musicNameL != nil)
            [_musicNameL setText:netItem.albume];
        if (_musicArtistL != nil)
            [_musicArtistL setText:netItem.title];
        if (_titleL != nil)
            [_titleL setText:item.title];
        [[GlobalMusicInstance sharedSingleton].queue clearQueue];
        [[GlobalMusicInstance sharedSingleton].queue release];
        [GlobalMusicInstance sharedSingleton].queue = nil;
        self.playSlider.maximumValue = 0;
        self.playSlider.minimumValue = 0;
        
        AFSoundItem *AFitem = [[AFSoundItem alloc] init];
        AFitem.URL = [item valueForProperty:MPMediaItemPropertyAssetURL];
        
        AFitem.title = self.playingNetMediaItem.title;
        AFitem.album = self.playingNetMediaItem.albume;
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:AFitem];
        [GlobalMusicInstance sharedSingleton].queue = [[AFSoundQueue alloc] initWithItems:array];
        [[GlobalMusicInstance sharedSingleton].queue playCurrentItem];
        [[GlobalMusicInstance sharedSingleton].queue listenFeedbackUpdatesWithBlock:^(NSDictionary *status) {
            
        }];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
        return;
    }*/
//    [_playOperation addOperationWithBlock:^{
    
    MPMediaItem *nowPlayingItem =[GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
    if (nowPlayingItem == nil) {
        [[GlobalMusicInstance sharedSingleton].musicPlayer setNowPlayingItem:item];
        [[GlobalMusicInstance sharedSingleton].musicPlayer play];
    } else if ([[NSString stringWithFormat:@"%@", [item valueForProperty:MPMediaItemPropertyPersistentID]] isEqualToString:[NSString stringWithFormat:@"%@", [nowPlayingItem valueForProperty:MPMediaItemPropertyPersistentID]]]) {
        if ([GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePaused) {
            [[GlobalMusicInstance sharedSingleton].musicPlayer play];
        }
    } else {
        [[GlobalMusicInstance sharedSingleton].musicPlayer stop];
        [[GlobalMusicInstance sharedSingleton].musicPlayer setNowPlayingItem:item];
        [[GlobalMusicInstance sharedSingleton].musicPlayer play];
    }
        
//    }];
}

-(void)playNetLink:(OnLineMusicModule *)item{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMusicFailed) object:nil];
    
    [self stopTimer];
    if ([GlobalMusicInstance sharedSingleton].musicPlayer){
        [[GlobalMusicInstance sharedSingleton].musicPlayer stop];
    }
    self.playingMediaItem = nil;
    self.playingNetMediaItem = item;
    
    if (_musicNameL != nil)
        [_musicNameL setText:item.albume];
    if (_musicArtistL != nil)
        [_musicArtistL setText:item.title];
    if (_titleL != nil)
        [_titleL setText:item.title];
    
    [[GlobalMusicInstance sharedSingleton].queue clearQueue];
    [[GlobalMusicInstance sharedSingleton].queue release];
    [GlobalMusicInstance sharedSingleton].queue = nil;
    self.playSlider.maximumValue = 0;
    self.playSlider.minimumValue = 0;
    /*
    baseAlert = [[UIAlertView alloc] initWithTitle:@"正在获取音乐，请稍后..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [baseAlert show];
     */
    
    getNetMusicSuccess = NO;
    [self performSelector:@selector(getMusicFailed) withObject:nil afterDelay:60.0f];
    
    if(_playOperation == nil){
        _playOperation = [[NSOperationQueue alloc] init];
        _playOperation.maxConcurrentOperationCount = 1;
    }
    [_playOperation cancelAllOperations];
    [_playOperation addOperationWithBlock:^{
        NSString *playUrl = [self getMusic:self.playingNetMediaItem.mid];
        
        if (playUrl){
            [self performSelectorOnMainThread:@selector(playNetMusic:) withObject:playUrl waitUntilDone:NO];
        }

    }];
    /*
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(concurrentQueue, ^{
            
            NSString *playUrl = [self getMusic:self.playingNetMediaItem.mid];
        
        if (playUrl){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playNetMusic:playUrl];
            });
        } else{
            if(baseAlert && baseAlert.isVisible) [baseAlert dismissWithClickedButtonIndex:0 animated:NO];
        }
        
    });
    */
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *playUrl = [self  getMusic:self.playingNetMediaItem.mid];
        [self playNetMusic:playUrl];
    });*/
}

-(void)getMusicFailed{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMusicFailed) object:nil];
    if(getNetMusicSuccess) return;
    if(baseAlert && baseAlert.isVisible) [baseAlert dismissWithClickedButtonIndex:0 animated:NO];
    [[[iToast makeText:@"播放失败!"] setGravity:iToastGravityBottom] show];
    getNetMusicSuccess = NO;

}

-(void)playNetMusic:(NSString *)playUrl{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMusicFailed) object:nil];
    [self startTimer];
    
    AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:playUrl]];
    item.title = self.playingNetMediaItem.title;
    item.album = self.playingNetMediaItem.albume;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:item];
    
    [GlobalMusicInstance sharedSingleton].queue = [[AFSoundQueue alloc] initWithItems:array];

    [[GlobalMusicInstance sharedSingleton].queue playCurrentItem];
    [[GlobalMusicInstance sharedSingleton].queue listenFeedbackUpdatesWithBlock:^(NSDictionary *status) {
    
//        NSLog(@"%@ - %@", status[AFSoundStatusTimeElapsed], status[AFSoundStatusDuration]);
//        self.playSlider.maximumValue = [status[AFSoundStatusDuration] floatValue];
//        
//        self.playSlider.value = [status[AFSoundStatusTimeElapsed] floatValue];
//        
//        self.currentTime.text = [self timeStringWithNumber:[status[AFSoundStatusTimeElapsed] floatValue]];
//        self.totalTime.text = [self timeStringWithNumber:[status[AFSoundStatusDuration] floatValue]];
    }];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
}

-(NSString *)getMusic:(NSString *)musicID{
    NSString *downUrl = nil;
    
    NSString *midUrl = [NSString stringWithFormat:@"http://player.kuwo.cn/webmusic/st/getNewMuiseByRid?rid=MUSIC_%@", musicID];
    
    NSString *title=[NSString stringWithContentsOfURL:[NSURL URLWithString:midUrl] encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [title dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *parser = [[TFHpple alloc]initWithXMLData:data];
    NSArray *array = [parser searchWithXPathQuery:@"//Song"];
    if (array == nil || array.count == 0) return nil;
    TFHppleElement *e0 = array[0];
    NSArray *contetnt = [e0 children];
    
    NSString *dl = nil;
    NSString *path;
    NSString *size;
    
    for(TFHppleElement *e in contetnt){
        NSString *tagName =[e tagName];
        if([tagName isEqualToString:@"mp3dl"]){
//            NSLog(@"%@", [e content]);
            dl = [e content];
        }else if([tagName isEqualToString:@"mp3path"]){
//            NSLog(@"%@", [e content]);
            path = [e content];
        }else if([tagName isEqualToString:@"mp3size"]){
//            NSLog(@"%@", [e content]);
            size = [e content];
        }
    }
    
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [[NSString stringWithFormat:@"%8x", (int)a] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
//    NSLog(@"%@", timeString);
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str setString:@"kuwo_web@1906/resource/"];
    
    [str appendString:path];
    [str appendString:timeString];
    //    NSString *str = [[NSMutableString stringWithFormat:@"kuwo_web@1906/resource/%@", path] appendString:timeString];
    NSString *mUrl = [self md5HexDigest:str];
//    NSLog(@"%@", mUrl);
    downUrl = [NSString stringWithFormat:@"http://%@/%@/%@/%@/%@", dl, mUrl, timeString, @"resource", path];
    
    
    NSLog(@"%@", downUrl);
    return downUrl;
}

-(NSString *)md5HexDigest:(NSString*)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

-(void)updatePlayerTime{
    if ([GlobalMusicInstance sharedSingleton].queue != nil) {
        
    if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        [_musicNameL setText:item.album];
        [_musicArtistL setText:item.title];
        NSString *titleName = item.title;//[NSString stringWithFormat:@"%@-%@",[self.playingMediaItem title], [self.playingMediaItem artist]];
        [_titleL setText:titleName];
        
        if (item.duration > 0) {
            getNetMusicSuccess = YES;
        }
        
        if (item.duration > 0 && baseAlert && baseAlert.isVisible) [baseAlert dismissWithClickedButtonIndex:0 animated:NO];
        
//        NSDictionary *status = [[GlobalMusicInstance sharedSingleton].queue statusDictionary];
//        if (status != nil && status.count > 0) {
        self.playSlider.maximumValue = item.duration;
        
        self.playSlider.value = item.timePlayed;
        NSLog(@"%d : %d", item.duration, item.timePlayed);
        
        self.currentTime.text = [self timeStringWithNumber:item.timePlayed];
        self.totalTime.text = [self timeStringWithNumber:item.duration];
//        }
        if (item.duration > 0 && (item.timePlayed == item.duration || item.timePlayed == item.duration - 1)){
            [self next:nil];
        }
        [self setNowPlayingInfo];
    }else{
        if ([[GlobalMusicInstance sharedSingleton].queue getCurrentItem] == nil) {
        self.playSlider.maximumValue = 0;
        self.playSlider.minimumValue = 0;
        }
    }
        
        return;
    }
    
    if (self.playingMediaItem == nil){
        return;
    }
    
    if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil && [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil){
        MPMediaItem *nowPlayingItem = [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
        self.playingMediaItem = nowPlayingItem;
        self.playSlider.maximumValue = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
        
        self.playSlider.value = [GlobalMusicInstance sharedSingleton].musicPlayer.currentPlaybackTime;
        
        self.currentTime.text = [self timeStringWithNumber:[GlobalMusicInstance sharedSingleton].musicPlayer.currentPlaybackTime];
        self.totalTime.text = [self timeStringWithNumber:[[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue]];
        
        [_musicNameL setText:nowPlayingItem.artist];
        [_musicArtistL setText:nowPlayingItem.title];
        NSString *titleName = [self.playingMediaItem title];//[NSString stringWithFormat:@"%@-%@",[self.playingMediaItem title], [self.playingMediaItem artist]];
        [_titleL setText:titleName];
        
        if ([GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePlaying){
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
        } else {
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_h"] forState:UIControlStateHighlighted];
        }
    } else{
        self.playSlider.value = 0;
    }
}

//方法类型：自定义方法
//编   写：
//方法功能：时间换算
-(NSString*)timeStringWithNumber:(float)theTime{
    NSString *minuteS=[NSString string];
    
    int minute=(theTime)/60;
    if(theTime<60){
        minuteS=@"00";
    }else if(minute<10){
        minuteS=[NSString stringWithFormat:@"0%i",(minute)];
    }else{
        minuteS=[NSString stringWithFormat:@"%i",(minute)];
    }
    
    NSString *playTimeS=[NSString string];
    if(theTime-60*minute<10){
        playTimeS=[NSString stringWithFormat:@"%@:0%0.0f",minuteS,theTime-60*minute];
    }else{
        playTimeS=[NSString stringWithFormat:@"%@:%0.0f",minuteS,theTime-60*minute];
    }
    return playTimeS;
}


-(void)playOrStop:(id)sender{
    if ([GlobalMusicInstance sharedSingleton].queue != nil) {
        if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
            [[GlobalMusicInstance sharedSingleton].queue pause];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_h"] forState:UIControlStateHighlighted];
        } else {
            [[GlobalMusicInstance sharedSingleton].queue playCurrentItem];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
        }
        return;
    }

    if ([[GlobalMusicInstance sharedSingleton].musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [[GlobalMusicInstance sharedSingleton].musicPlayer pause];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_play_h"] forState:UIControlStateHighlighted];
        
    } else{
        if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil &&  [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil){
            [[GlobalMusicInstance sharedSingleton].musicPlayer play];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"white_playing_btn_pause_h"] forState:UIControlStateHighlighted];
            
        }
    }
}

-(void)next:(id)sender{
    if ([GlobalMusicInstance sharedSingleton].queue != nil && [GlobalMusicInstance sharedSingleton].netArray !=nil
        && [GlobalMusicInstance sharedSingleton].netArray.count > 1){
        [GlobalMusicInstance sharedSingleton].selectedIndex++;
        if ([GlobalMusicInstance sharedSingleton].selectedIndex == [GlobalMusicInstance sharedSingleton].netArray.count){
            [GlobalMusicInstance sharedSingleton].selectedIndex = 0;
        }
        [[GlobalMusicInstance sharedSingleton].queue pause];
        [self playNetLink:[GlobalMusicInstance sharedSingleton].netArray[[GlobalMusicInstance sharedSingleton].selectedIndex]];
        return;
    }
    
    [[GlobalMusicInstance sharedSingleton].musicPlayer skipToNextItem];
    if ([GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePaused || [GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStateStopped){
        [[GlobalMusicInstance sharedSingleton].musicPlayer play];
    }
}
-(void)prev:(id)sender{
    if ([GlobalMusicInstance sharedSingleton].queue != nil && [GlobalMusicInstance sharedSingleton].netArray !=nil){
        [GlobalMusicInstance sharedSingleton].selectedIndex--;
        if ([GlobalMusicInstance sharedSingleton].selectedIndex == -1){
            [GlobalMusicInstance sharedSingleton].selectedIndex = [GlobalMusicInstance sharedSingleton].netArray.count - 1;
        }
        [[GlobalMusicInstance sharedSingleton].queue pause];
        [self playNetLink:[GlobalMusicInstance sharedSingleton].netArray[[GlobalMusicInstance sharedSingleton].selectedIndex]];
        return;
    }
    
    [[GlobalMusicInstance sharedSingleton].musicPlayer skipToPreviousItem];
    if ([GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePaused || [GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStateStopped){
        [[GlobalMusicInstance sharedSingleton].musicPlayer play];
    }
}

-(void)back:(id *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = (int)(self.scrollView.contentOffset.x / scrollView.frame.size.width);
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    [self resignFirstResponder];
}

-(BOOL) canBecomeFirstResponder{
    return YES;
}

//response to remote control events
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    NSLog(@"remoteControlReceivedWithEvent");
    if(event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                [self playOrStop:nil];
            }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
            {
                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
                [self next:nil];
            }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
                [self prev:nil];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)setNowPlayingInfo{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter){
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        if (item != nil) {
        [songInfo setObject:item.title forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:item.album forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[NSNumber numberWithDouble:item.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [songInfo setObject:[NSNumber numberWithDouble:item.timePlayed] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
