//
//  AFSoundQueue.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 21/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "AFSoundQueue.h"
#import "AFSoundManager.h"
#import "NSTimer+AFSoundManager.h"

#import <objc/runtime.h>
#import "AudioPlayer.h"
#import "GlobalMusicInstance.h"

@interface AFSoundQueue ()

@property (nonatomic, strong) AFSoundPlayback *queuePlayer;
@property (nonatomic, strong) AudioPlayer *myPlayer;
@property (nonatomic, strong) NSMutableArray *soundItems;

@property (nonatomic, strong) NSTimer *feedbackTimer;

@end

@implementation AFSoundQueue

-(id)initWithItems:(NSMutableArray *)items {
    
    if (self == [super init]) {
        
        if (items) {
            
            _soundItems = [NSMutableArray arrayWithArray:items];
            
//            _queuePlayer = [[AFSoundPlayback alloc] initWithItem:items.firstObject];
            self.currentItem = items.firstObject;
//            if ([GlobalMusicInstance sharedSingleton].APPlayer == nil)
                _myPlayer = [[AudioPlayer alloc] init];
//            _myPlayer.delegate = self;
//            else{
//                _myPlayer = [GlobalMusicInstance sharedSingleton].APPlayer;
//            }
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        }
    }
    
    return self;
}

-(BOOL)isNet{
    if(self.currentItem){
        if([[NSString stringWithFormat:@"%@", self.currentItem.URL] rangeOfString:@"http"].location != NSNotFound){
            return YES;
        }
        return NO;
    }
    return NO;
}

-(void)changeItems:(NSMutableArray *)items {
    if (items) {
        [_feedbackTimer pauseTimer];
        _soundItems = [NSMutableArray arrayWithArray:items];
        self.currentItem = items.firstObject;
    }
}

-(void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block {
    
    _feedbackTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
        /*
        _queuePlayer.currentItem.timePlayed = [_queuePlayer.statusDictionary[AFSoundStatusTimeElapsed] integerValue];
        _queuePlayer.currentItem.duration = [_queuePlayer.statusDictionary[AFSoundStatusDuration] integerValue];
        if (_queuePlayer.statusDictionary[AFSoundStatusDuration] == _queuePlayer.statusDictionary[AFSoundStatusTimeElapsed]) {
            
            [_feedbackTimer pauseTimer];
            
//            [self playNextItem];
        }

        if (block) {
            self.status = _queuePlayer.status;
            self.statusDictionary = [_queuePlayer statusDictionary];
            block([_queuePlayer statusDictionary]);
        }*/
        [_myPlayer unmute];
        _currentItem.timePlayed = _myPlayer.progress;
        _currentItem.duration = _myPlayer.duration;
        if (_myPlayer.progress == _myPlayer.duration) {
            
//            [_feedbackTimer pauseTimer];
        }
        
        if (block) {
            block(nil);
        };
    } repeats:YES];
}

-(void)addItem:(AFSoundItem *)item {
    
    [self addItem:item atIndex:_soundItems.count];
}

-(void)addItem:(AFSoundItem *)item atIndex:(NSInteger)index {
    
    [_soundItems insertObject:item atIndex:(_soundItems.count >= index) ? _soundItems.count : index];
}

-(void)removeItem:(AFSoundItem *)item {
    
    if ([_soundItems containsObject:item]) {
        
        [self removeItemAtIndex:[_soundItems indexOfObject:item]];
    }
}

-(void)removeItemAtIndex:(NSInteger)index {

    if (_soundItems.count >= index) {
        
        AFSoundItem *item = _soundItems[index];
        [_soundItems removeObject:item];
        
        if (_queuePlayer.currentItem == item) {
            
            [self playNextItem];
            
            [_feedbackTimer resumeTimer];
        }
    }
}

-(AudioPlayerState)getPlayerState{
    if(_myPlayer) return _myPlayer.state;
    return -1;
}

-(void)clearQueue {
//    [_queuePlayer pause];
    [_myPlayer flushStop];
    [_myPlayer stop];
//    [_myPlayer dispose];
//    [_myPlayer dealloc];
    _queuePlayer.status = AFSoundStatusPaused;
    self.status = AFSoundStatusPaused;
    
    NSOperationQueue *deallocOperation = [[NSOperationQueue alloc] init];
    
    [deallocOperation addOperationWithBlock:^{
        [_myPlayer dispose];
        [_myPlayer dealloc];
        NSLog(@"player dealloc....");
    }];
//    [_soundItems removeAllObjects];
}

-(void)playCurrentItem {
    
//    [_queuePlayer play];
    if (self.status == AFSoundStatusPaused){
        [_myPlayer resume];
    }else{
        [_myPlayer play:_currentItem.URL];
    }
    _queuePlayer.status = AFSoundStatusPlaying;
    self.status = AFSoundStatusPlaying;
    [[MPRemoteCommandCenter sharedCommandCenter] playCommand];
    
    [_feedbackTimer resumeTimer];
}

-(void)pause {
    
//    [_queuePlayer pause];
    [_myPlayer pause];
    _queuePlayer.status = AFSoundStatusPaused;
    self.status = AFSoundStatusPaused;
    [[MPRemoteCommandCenter sharedCommandCenter] pauseCommand];
    
    [_feedbackTimer pauseTimer];
}

-(void)playNextItem {
        
    if ([_soundItems containsObject:_queuePlayer.currentItem]) {
        
        [self playItemAtIndex:([_soundItems indexOfObject:_queuePlayer.currentItem] + 1)];
        [[MPRemoteCommandCenter sharedCommandCenter] nextTrackCommand];
        
        [_feedbackTimer resumeTimer];
    }
}

-(void)playPreviousItem {
    
    if ([_soundItems containsObject:_queuePlayer.currentItem] && [_soundItems indexOfObject:_queuePlayer.currentItem] > 0) {
        
        [self playItemAtIndex:([_soundItems indexOfObject:_queuePlayer.currentItem] - 1)];
        [[MPRemoteCommandCenter sharedCommandCenter] previousTrackCommand];
    }
}

-(void)playItemAtIndex:(NSInteger)index {
    
    if (_soundItems.count > index) {
        
        [self playItem:_soundItems[index]];
    }
}

-(void)playItem:(AFSoundItem *)item {
    
    if ([_soundItems containsObject:item]) {
        
        if (_queuePlayer.status == AFSoundStatusNotStarted || _queuePlayer.status == AFSoundStatusPaused || _queuePlayer.status == AFSoundStatusFinished) {
            
            [_feedbackTimer resumeTimer];
        }

        _queuePlayer = [[AFSoundPlayback alloc] initWithItem:item];
        [_queuePlayer play];
        [[MPRemoteCommandCenter sharedCommandCenter] playCommand];
        
    }
}

-(AFSoundItem *)getCurrentItem {
    return _currentItem;
//    return _queuePlayer.currentItem;
}

-(NSInteger)indexOfCurrentItem {
    
    AFSoundItem *currentItem = [self getCurrentItem];
    
    if ([_soundItems containsObject:currentItem]) {
        
        return [_soundItems indexOfObject:currentItem];
    }
    
    return NAN;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPreviousItem];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNextItem];
                break;
                
            default:
                break;
        }
    }
}

-(NSMutableArray *)getItems{
    return _soundItems;
}

//deleget


-(void)audioPlayer:(AudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId{
    NSLog(@"==didFinishBufferingSourceWithQueueItemId=====%@", queueItemId);
    
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode{
    
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId{
     NSLog(@"==didStartPlayingQueueItemId=====%@", queueItemId);
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer internalStateChanged:(AudioPlayerInternalState)state{
    
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer logInfo:(NSString *)line{
    
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer stateChanged:(AudioPlayerState)state{
    if(state == AudioPlayerStateDisposed){
        [_myPlayer stop];
    }
    NSLog(@"==stateChanged=====%d", state);
}

@end
