//
//  HelpViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/1.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "HelpViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupViews];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setupViews{
    self.view.backgroundColor = APP_THEME_COLOR;//[UIColor colorWithRed:16/255.0 green:15/255.0 blue:15/255.0 alpha:1.0];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    
    UIImage *bottombg = [UIImage imageNamed:@"bottombg"];
    [titleView setBackgroundColor:APP_THEME_COLOR];//[UIColor colorWithPatternImage:[self imageWithImage:bottombg scaledToSize:CGSizeMake(SCREEN_WIDTH, titleView.bounds.size.height)]]];
    
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleL.textColor = [UIColor whiteColor];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.center = CGPointMake(SCREEN_WIDTH/2, titleView.bounds.size.height/2);
    [titleL setText:@"帮助文档"];
    [titleView addSubview:titleL];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, titleView.bounds.size.height)];
    //    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_btn_bg"] forState:UIControlStateNormal];
    backBtn.center = CGPointMake(30, titleView.bounds.size.height/2);
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_btn_bg"]];
    backImage.center = CGPointMake(30, backBtn.bounds.size.height/2);
    [backBtn addSubview:backImage];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backBtn];
    
    [self.view addSubview:titleView];
    
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    pageView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [self.view addSubview:pageView];
    
    UIScrollView *connectedHotPageView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    connectedHotPageView.backgroundColor = [UIColor clearColor];
    connectedHotPageView.directionalLockEnabled = YES;
    connectedHotPageView.pagingEnabled = NO;
    connectedHotPageView.showsVerticalScrollIndicator = YES;
    connectedHotPageView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    connectedHotPageView.showsHorizontalScrollIndicator = NO;
    [connectedHotPageView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    [pageView addSubview:connectedHotPageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(SCREEN_WIDTH/2, 30);
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0];
    label.text = @"庭悦音乐操作指南";
    
    [connectedHotPageView addSubview:label];
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 42, 140)];
    detail.center = CGPointMake(self.view.bounds.size.width / 2, 100);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"一.下载庭悦音乐APP"\
                                      "\n1.1打开APP根据设置向导将设备接入互联网，界面如下："];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail.attributedText = str;
    detail.font = [UIFont systemFontOfSize:15.0f];
    detail.numberOfLines = 0;
    detail.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
    [connectedHotPageView addSubview:detail];
    
    UIImageView *guaid_1 = [[UIImageView alloc] initWithFrame:CGRectMake(28, 164, 118, 210)];
    [guaid_1 setImage:[UIImage imageNamed:@"help1"]];
    [connectedHotPageView addSubview:guaid_1];
    
    UIImageView *guaid_2 = [[UIImageView alloc] initWithFrame:CGRectMake(172, 164, 118, 210)];
    [guaid_2 setImage:[UIImage imageNamed:@"help2"]];
    [connectedHotPageView addSubview:guaid_2];

    UILabel *detail2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 42, 140)];
    detail2.center = CGPointMake(self.view.bounds.size.width / 2, 430);
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"2.随身携带的手机KTV"\
                                       "\n超过300万首海量伴奏，VIPER音频渲染技术，让你开嗓即成天籁。"];
    [str2 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str2.length) ];
    detail2.attributedText = str2;
    detail2.font = [UIFont systemFontOfSize:15.0f];
    detail2.numberOfLines = 0;
    detail2.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
    [connectedHotPageView addSubview:detail2];

}

-(void)back:(id *)sender{
    [self.navigationController popViewControllerAnimated:YES];
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

@end
