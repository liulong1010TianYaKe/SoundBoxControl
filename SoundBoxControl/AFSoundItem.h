//
//  AFSoundItem.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 20/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AFSoundItem : NSObject

typedef NS_ENUM(NSInteger, AFSoundItemType) {
    
    AFSoundItemTypeLocal,
    AFSoundItemTypeStreaming
};

-(id)initWithLocalResource:(NSString *)name atPath:(NSString *)path;
-(id)initWithStreamingURL:(NSURL *)URL;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) UIImage *artwork;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, readonly) NSInteger type;

@property (nonatomic) NSInteger duration;
@property (nonatomic) NSInteger timePlayed;

@property (nonatomic, strong) MPMediaItem *mMPMediaItem;

-(void)setInfoFromItem:(AVPlayerItem *)item;

@end
