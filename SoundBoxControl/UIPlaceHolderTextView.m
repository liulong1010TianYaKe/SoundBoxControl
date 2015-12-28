//
//  UIPlaceHolderTextView.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/1.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "UIPlaceHolderTextView.h"
#import <Foundation/Foundation.h>

@interface UIPlaceHolderTextView ()
@property (nonatomic, retain) UILabel *placeHolderLabel;

@end

@implementation UIPlaceHolderTextView

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

CGRect originalContentViewFrame;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION animations:^{
        if([[self text] length] == 0)
        {
            [[self viewWithTag:999] setAlpha:1];
        }
        else
        {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

- (void)registerForKeyboardNotifications {
    originalContentViewFrame = self.frame;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWasShow:)
                                                name:UIKeyboardDidShowNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWillBeHidden:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
}

- (void)unregisterForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIKeyboardDidShowNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIKeyboardWillHideNotification
                                                 object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    // 取得键盘的frame，注意，因为键盘在window的层面弹出来的，所以它的frame坐标也是对应window窗口的。
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGPoint endOrigin = endRect.origin;
    // 把键盘的frame坐标系转换到与UITextView一致的父view上来。
    if ([UIApplication sharedApplication].keyWindow && self.superview) {
        endOrigin = [self.superview convertPoint:endRect.origin fromView:[UIApplication sharedApplication].keyWindow];
    }
    
    CGFloat adjustHeight = originalContentViewFrame.origin.y + originalContentViewFrame.size.height;
    // 根据相对位置调整一下大小，自己画图比划一下就知道为啥要这样计算。
    // 当然用其他的调整方式也是可以的，比如取UITextView的orgin，origin到键盘origin之间的高度作为UITextView的高度也是可以的。
    adjustHeight -= endOrigin.y;
    if (adjustHeight > 0) {
        
        CGRect newRect = originalContentViewFrame;
        newRect.size.height -= adjustHeight;
        [UIView beginAnimations:nil context:nil];
        self.frame = newRect;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification{
    // 恢复原理的大小
    [UIView beginAnimations:nil context:nil];
    self.frame = originalContentViewFrame;
    [UIView commitAnimations];
}

@end
