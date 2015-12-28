//
//  ViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/5.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "GlobalMusicInstance.h"
#import "NowPlayingViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "TFHpple.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "AFSoundItem.h"
#import "AFSoundPlayback.h"
#import "MarqueeLabel.h"
#import "Constants.h"
@import MediaPlayer;


@interface ViewController ()

@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic) NSOperationQueue *playOperation;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"1" forKey:APP_FIRST_ENTER_MAIN];
    
    [self.view setBackgroundColor:APP_THEME_COLOR];
    
//    [self.view setBackgroundColor:[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    
//    [self.view setBackgroundColor:[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0]];
    
    [self setupPlayingBar];
    [self initPlayerNotification];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.updateTimer != nil){
        [self.updateTimer setFireDate:[NSDate distantPast]];
    } else {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayerTime) userInfo:nil repeats:YES];
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([GlobalMusicInstance sharedSingleton].queue != nil && [GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
    }else{
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        
        if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil &&
            [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil
            && [GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePlaying){
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.updateTimer != nil){
        [self.updateTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)setupAiplayBtn{
    
    self.airPlayButton = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    self.airPlayButton.showsVolumeSlider = NO;
    [self.airPlayButton sizeToFit];
    self.airPlayButton.backgroundColor = [UIColor clearColor];// colorWithRed:32/255.0 green:32/255.0 blue:31/255.0 alpha:1.0];
    self.airPlayButton.frame = CGRectMake(10, 16, 36, 28);
    [self.airPlayButton setRouteButtonImage:[UIImage imageNamed:@"mvplayer_airplay_black"] forState:UIControlStateNormal];
    [self.airPlayButton setRouteButtonImage:[UIImage imageNamed:@"mvplayer_airplay_blue"] forState:UIControlStateSelected];
    [_bottomView addSubview:self.airPlayButton];
}

-(void)viewDidLayoutSubviews{
    
    [_bottomView setFrame:CGRectMake(0, SCREEN_HEIGHT - 56, SCREEN_WIDTH, 56)];
}

-(void)setupPlayingBar{
//    self.playBarlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
//    self.playBarlabel.text = @"DLNA";
//    self.playBarlabel.textColor = [UIColor blackColor];
//    [_bottomView addSubview:self.playBarlabel];
    [_bottomView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]];
    
    [self setupAiplayBtn];
    
    self.playSlider = [[UISlider alloc] initWithFrame:CGRectMake(-2,0, SCREEN_WIDTH + 4, 1)];
    
    self.playSlider.minimumValue = 0.0;
    self.playSlider.maximumValue = 1.0;
    self.playSlider.value = 0;
    
    [self.playSlider setThumbImage:[UIImage alloc] forState:UIControlStateNormal];
    self.playSlider.minimumTrackTintColor = APP_THEME_COLOR;//[UIColor colorWithRed:236/255.0 green:100/255.0 blue:0/255.0 alpha:1];
    self.playSlider.maximumTrackTintColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1];
    
    [_bottomView addSubview:self.playSlider];
    
    /*
    self.playBarprevBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 0, 70, 50)];
    [self.playBarprevBtn setTitle:@"上一首" forState:UIControlStateNormal];
    [self.playBarprevBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.playBarprevBtn addTarget:self action:@selector(prev:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:self.playBarprevBtn];
    */
    self.playBarplayBtn = [[UIButton alloc] initWithFrame:CGRectMake(230, 12, 36, 36)];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
//    [self.playBarplayBtn setTitle:@"播放" forState:UIControlStateNormal];
//    [self.playBarplayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.playBarplayBtn addTarget:self action:@selector(playOrStop:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:self.playBarplayBtn];
    
    self.playBarnextBtn = [[UIButton alloc] initWithFrame:CGRectMake(280, 14, 30, 30)];
//    [self.playBarnextBtn setTitle:@"下一首" forState:UIControlStateNormal];
//    [self.playBarnextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.playBarnextBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_next_n"] forState:UIControlStateNormal];
    [self.playBarnextBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_next_h"] forState:UIControlStateHighlighted];
    [self.playBarnextBtn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:self.playBarnextBtn];
    
    _bottomView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playBartapped:)];
    [_bottomView addGestureRecognizer:tap];
    
    self.nonPlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 3, 180, 50)];
    self.nonPlayLabel.text = @"极致音乐，尽在WiFi音响";
    [self.nonPlayLabel setTextColor:[UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:0.5]];
    [self.nonPlayLabel setTextAlignment:NSTextAlignmentCenter];
    self.nonPlayLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [_bottomView addSubview:self.nonPlayLabel];
    
    self.playbarTitle = [[UILabel alloc] initWithFrame:CGRectMake(58, 12, 170, 20)];
    [self.playbarTitle setTextColor:[UIColor colorWithRed:48/255.0 green:48/255.0 blue:48/255.0 alpha:1.0]];
    [self.playbarTitle setTextAlignment:NSTextAlignmentLeft];
    self.playbarTitle.font = [UIFont systemFontOfSize:13.0f];
    [_bottomView addSubview:self.playbarTitle];
    
    self.playbarArtisName = [[UILabel alloc] initWithFrame:CGRectMake(58, 30, 180, 20)];
    [self.playbarArtisName setTextColor:[UIColor colorWithRed:161/255 green:161/255 blue:161/255 alpha:0.5]];
    [self.playbarArtisName setTextAlignment:NSTextAlignmentLeft];
    self.playbarArtisName.font = [UIFont systemFontOfSize:11.0f];
    [_bottomView addSubview:self.playbarArtisName];
    
    
    if ([GlobalMusicInstance sharedSingleton].musicPlayer == nil ||
        [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem == nil){
        
        [self updatePlaybarLabel:nil];
    }
}

-(void)updatePlaybarLabel:(MPMediaItem *)item{
    if (item != nil){
        self.nonPlayLabel.hidden = YES;
        self.playbarTitle.hidden = NO;
        self.playbarArtisName.hidden = NO;
        self.playbarTitle.text = [item title];
        self.playbarArtisName.text = [item artist];
    }else {
        self.playbarTitle.hidden = YES;
        self.playbarArtisName.hidden = YES;
        self.nonPlayLabel.hidden = NO;
    }
}

-(void)initPlayerNotification{
    if (![GlobalMusicInstance sharedSingleton].musicPlayer) {
        [GlobalMusicInstance sharedSingleton].musicPlayer = [[MPMusicPlayerController alloc] init];
    }
    
    [[GlobalMusicInstance sharedSingleton].musicPlayer beginGeneratingPlaybackNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:[GlobalMusicInstance sharedSingleton].musicPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:[GlobalMusicInstance sharedSingleton].musicPlayer];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeIsChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

-(void)updatePlayerTime{
    if ([GlobalMusicInstance sharedSingleton].queue != nil){
    if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        [self.playbarArtisName setText:item.album];
        [self.playbarTitle setText:item.title];
        
        self.playSlider.maximumValue = item.duration;
        
        self.playSlider.value = item.timePlayed;
        
        self.nonPlayLabel.hidden = YES;
        self.playbarTitle.hidden = NO;
        self.playbarArtisName.hidden = NO;
        if (item.duration > 0 && (item.timePlayed == item.duration || item.timePlayed == item.duration - 1)){
            [self next:nil];
        }
        [self setNowPlayingInfo];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];

    }else{
        
    }
        return;
    }
    
    if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil && [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil){
        MPMediaItem *nowPlayingItem = [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
        
        self.playSlider.maximumValue = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
        
        self.playSlider.value = [GlobalMusicInstance sharedSingleton].musicPlayer.currentPlaybackTime;        
    } else{
        self.playSlider.value = 0;
    }
}

-(void) musicPlayerStateChanged: (NSNotification *) paramNotification{
    NSNumber *stateAsObject = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    NSInteger state = [stateAsObject integerValue];
    NSLog(@"musicPlayerStateChanged : %d", state);
    switch (state) {
        case MPMusicPlaybackStateStopped:
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
            break;
        case MPMusicPlaybackStatePlaying:
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
            break;
        case MPMusicPlaybackStatePaused:
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
            break;
        case MPMusicPlaybackStateInterrupted:
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
            break;
        case MPMusicPlaybackStateSeekingForward:
            break;
        case MPMusicPlaybackStateSeekingBackward:
            break;
            
        default:
            break;
    }
}

-(void)nowPlayingItemChanged: (NSNotification *) paramNotification{
    NSLog(@"nowPlayingItemChanged");
    self.playSlider.value = 0;
    if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil && [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil){
        [self updatePlaybarLabel:[GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem];
    }
}

-(void)volumeIsChanged: (NSNotification *) paramNotification{
//    NSLog(@"volumeIsChanged: %f", [[[paramNotification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue]);
    
}

-(void)playBartapped:(UITapGestureRecognizer *)gesture{
    
    NowPlayingViewController *viewController = [[NowPlayingViewController alloc] init];
    if (([GlobalMusicInstance sharedSingleton].queue != nil && [[GlobalMusicInstance sharedSingleton].queue getCurrentItem] != nil)
        || ([GlobalMusicInstance sharedSingleton].musicPlayer != nil &&  [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil)) {
        if ([GlobalMusicInstance sharedSingleton].queue != nil && [[GlobalMusicInstance sharedSingleton].queue getCurrentItem] != nil){
            viewController.playingMediaItem = nil;
            OnLineMusicModule *item = [[OnLineMusicModule alloc] init];
            item.title = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem].title;
            item.albume = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem].album;
            viewController.playingNetMediaItem = item;
        }else{
            viewController.playingMediaItem = [[GlobalMusicInstance sharedSingleton].musicPlayer nowPlayingItem];
        }
    
            [self.navigationController pushViewController:viewController animated:YES];
    }
//    [self.navigationController setNavigationBarHidden:NO];

}

-(void)playOrStop:(id)sender{
    if ([GlobalMusicInstance sharedSingleton].queue != nil) {
        if ([[GlobalMusicInstance sharedSingleton].queue getCurrentItem] != nil){
    if ([GlobalMusicInstance sharedSingleton].queue.status == AFSoundStatusPlaying){
        [[GlobalMusicInstance sharedSingleton].queue pause];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
    } else {
        [[GlobalMusicInstance sharedSingleton].queue playCurrentItem];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
    }
        }
        return;
    }
    
    if ([[GlobalMusicInstance sharedSingleton].musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [[GlobalMusicInstance sharedSingleton].musicPlayer pause];
//        [self.playBarplayBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];

    } else{
        if ([GlobalMusicInstance sharedSingleton].musicPlayer != nil &&  [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem != nil){
            [[GlobalMusicInstance sharedSingleton].musicPlayer play];
//            [self.playBarplayBtn setTitle:@"暂停" forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
            [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];

        }
    }
}
-(void)next:(id)sender{
    
    if ([GlobalMusicInstance sharedSingleton].queue != nil && [GlobalMusicInstance sharedSingleton].netArray !=nil && [GlobalMusicInstance sharedSingleton].netArray.count > 1){
        [GlobalMusicInstance sharedSingleton].selectedIndex++;
        if ([GlobalMusicInstance sharedSingleton].selectedIndex == [GlobalMusicInstance sharedSingleton].netArray.count){
            [GlobalMusicInstance sharedSingleton].selectedIndex = 0;
        }
        [[GlobalMusicInstance sharedSingleton].queue pause];
        [self playNetLink:[GlobalMusicInstance sharedSingleton].netArray[[GlobalMusicInstance sharedSingleton].selectedIndex]];
        return;
    }
    
    if([GlobalMusicInstance sharedSingleton].queue != nil && [GlobalMusicInstance sharedSingleton].netArray !=nil &&[GlobalMusicInstance sharedSingleton].netArray.count == 1){
        [GlobalMusicInstance sharedSingleton].selectedIndex = 0;
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
    [[GlobalMusicInstance sharedSingleton].musicPlayer skipToPreviousItem];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([[segue identifier] isEqualToString:@"HomeNaviControl"]){
//        NSLog(@"ffff");
//    }
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethodImp = class_getInstanceMethod(self, @selector(backBarButtonItem));
        Method destMethodImp = class_getInstanceMethod(self, @selector(myCustomBackButton_backBarbuttonItem));
        method_exchangeImplementations(originalMethodImp, destMethodImp);
    });
}

static char kCustomBackButtonKey;
-(UIBarButtonItem *)myCustomBackButton_backBarbuttonItem{
    NSLog(@"333");

    UIBarButtonItem *item = [self myCustomBackButton_backBarbuttonItem];
    if(item) {
        return item;
    }
    
    item = objc_getAssociatedObject(self, &kCustomBackButtonKey);
    if (!item) {
        item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:NULL];
        objc_setAssociatedObject(self, &kCustomBackButtonKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    objc_removeAssociatedObjects(self);
    [_bottomView release];
    [super dealloc];
}


-(void)playNetLink:(OnLineMusicModule *)item{
    self.playingNetMediaItem = item;    
    [[GlobalMusicInstance sharedSingleton].queue clearQueue];
    
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
        dispatch_async(concurrentQueue, ^{
            
            NSString *playUrl = [self getMusic:self.playingNetMediaItem.mid];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playNetMusic:playUrl];
            });
            
        });
        
    });
 */
}

-(void)playNetMusic:(NSString *)playUrl{
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
    }];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
    [self.playBarplayBtn setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
}

-(NSString *)getMusic:(NSString *)musicID{
    NSString *downUrl = nil;
    
    NSString *midUrl = [NSString stringWithFormat:@"http://player.kuwo.cn/webmusic/st/getNewMuiseByRid?rid=MUSIC_%@", musicID];
    
    NSString *title=[NSString stringWithContentsOfURL:[NSURL URLWithString:midUrl] encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [title dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *parser = [[TFHpple alloc]initWithXMLData:data];
    NSArray *array = [parser searchWithXPathQuery:@"//Song"];
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

-(void)setNowPlayingInfo{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter){
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        AFSoundItem *item = [[GlobalMusicInstance sharedSingleton].queue getCurrentItem];
        if (item != nil){
        [songInfo setObject:item.title forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:item.album forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[NSNumber numberWithDouble:item.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [songInfo setObject:[NSNumber numberWithDouble:item.timePlayed] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    }
}

@end
