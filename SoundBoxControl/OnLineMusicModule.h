//
//  OnLineMusicModule.h
//  SoundBoxControl
//
//  Created by neldtv on 15/4/10.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnLineMusicModule : NSObject

@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * href;
@property (nonatomic,copy) NSString * albume;
@property (nonatomic, retain) NSString * mid;

@end
