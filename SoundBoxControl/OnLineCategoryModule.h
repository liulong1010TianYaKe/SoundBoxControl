//
//  OnLineCategoryModule.h
//  SoundBoxControl
//
//  Created by neldtv on 15/4/10.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnLineCategoryModule : NSObject
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * href;
@property (nonatomic,copy) NSString * image;
@property (nonatomic,copy) NSString * number;

-(NSMutableArray *)items;

@end
