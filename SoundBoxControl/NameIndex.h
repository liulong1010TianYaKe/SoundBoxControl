//
//  NameIndex.h
//  SoundBoxControl
//
//  Created by neldtv on 15/3/27.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface NameIndex : NSObject {
    NSString *_lastName;
    NSString *_firstName;
    NSInteger _sectionNum;
    NSInteger _originIndex;
    MPMediaItem *mMPMediaItem;
}
@property (nonatomic, retain) NSString *_lastName;
@property (nonatomic, retain) NSString *_firstName;
@property (nonatomic) NSInteger _sectionNum;
@property (nonatomic) NSInteger _originIndex;
@property (nonatomic, strong) MPMediaItem *mMPMediaItem;
- (NSString *) getFirstName;
- (NSString *) getLastName;
@end
