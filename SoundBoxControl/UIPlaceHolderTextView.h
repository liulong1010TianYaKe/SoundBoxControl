//
//  UIPlaceHolderTextView.h
//  SoundBoxControl
//
//  Created by neldtv on 15/4/1.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
