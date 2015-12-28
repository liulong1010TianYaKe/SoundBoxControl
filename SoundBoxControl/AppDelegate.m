//
//  AppDelegate.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/5.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "GlobalMusicInstance.h"
#import "iToast.h"
#import "NowPlayingViewController.h"

@interface AppDelegate ()
@property (nonatomic, retain) NSString *deviceOutputType;
@property (nonatomic, retain) NSString *airplayDeviceName;

@property (nonatomic, retain) Reachability *hostReach;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [GlobalMusicInstance sharedSingleton].queue = [[AFSoundQueue alloc] init];
    
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
    
    //开启网络状况的监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
//    self.hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
//    [self.hostReach startNotifier];  //开始监听，会启动一个run loop
    
//    [self isAirplayActive];
    
    return YES;
}

-(BOOL *)isNetworkReachable{
    return self.isReachable;
}

//网络链接改变时会调用的方法
-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    //如果没有连接到网络就弹出提醒实况
    self.isReachable = YES;
    if(status == NotReachable)
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络连接异常" message:@"暂无法访问书城信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        self.isReachable = NO;
//        [[[iToast makeText:@"无网络连接!"] setGravity:iToastGravityBottom] show];
    }
    else if (status == ReachableViaWiFi)
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络连接信息" message:@"网络连接正常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        self.isReachable = YES;
    }
}

//http://stackoverflow.com/questions/13044894/get-name-of-airplay-device-using-avplayer
- (BOOL)isAirplayActive {
    CFDictionaryRef currentRouteDescriptionDictionary = nil;
    UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, &currentRouteDescriptionDictionary);
    
    self.deviceOutputType = nil;
    self.airplayDeviceName = nil;
    
    if (currentRouteDescriptionDictionary) {
        CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);
        if(CFArrayGetCount(outputs) > 0) {
            CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);
            
            //Get the output type (will show airplay / hdmi etc
            CFStringRef outputType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);
            
            //If you're using Apple TV as your ouput - this will get the name of it (Apple TV Kitchen) etc
            CFStringRef outputName = CFDictionaryGetValue(currentOutput, @"RouteDetailedDescription_Name");
            
            self.deviceOutputType = (NSString *)outputType;
            self.airplayDeviceName = (NSString *)outputName;
            NSLog(@"use airplay: %@", self.airplayDeviceName);
            return (CFStringCompare(outputType, kAudioSessionOutputRoute_AirPlay, 0) == kCFCompareEqualTo);
        }
    }
    return NO;
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
                NowPlayingViewController *now = [[NowPlayingViewController alloc] init];
                [now playOrStop:nil];
            }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
            {
                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
                NowPlayingViewController *now = [[NowPlayingViewController alloc] init];
                [now next:nil];
//                [[GlobalMusicInstance sharedSingleton].queue  playNextItem];
            }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
                NowPlayingViewController *now = [[NowPlayingViewController alloc] init];
                [now prev:nil];
//                [[GlobalMusicInstance sharedSingleton].queue playPreviousItem];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if([GlobalMusicInstance sharedSingleton].musicPlayer != nil){
        [[GlobalMusicInstance sharedSingleton].musicPlayer pause];
    }
}

@end