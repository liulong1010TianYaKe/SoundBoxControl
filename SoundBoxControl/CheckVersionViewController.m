//
//  CheckVersionViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/1.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "CheckVersionViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "UIPlaceHolderTextView.h"

@implementation CheckVersionViewController

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
    titleL.textAlignment = UITextAlignmentCenter;
    titleL.center = CGPointMake(SCREEN_WIDTH/2, titleView.bounds.size.height/2);
    [titleL setText:@"检查升级"];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    label.center = CGPointMake(SCREEN_WIDTH/2, 30);
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = [UIColor blackColor];
    label.text = @"Home音乐全新升级";
    
    [pageView addSubview:label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 219, 48)];
    button.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 110);
    [button setTitle:@"立即升级" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = APP_THEME_COLOR;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    [button.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button addTarget:self action:@selector(upgrade:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button];
    
    
    UIPlaceHolderTextView *detail = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 350)];
    detail.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 50);
    detail.backgroundColor = [UIColor whiteColor];
    detail.layer.cornerRadius = 5.0;
    detail.layer.borderWidth = 1.0;
    [detail.layer setBorderColor: [UIColor clearColor].CGColor];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@""\
                                      "1.更好的操作界面"\
                                      "\n完美适配ios8，全新设计，清新简洁，点划之间尽享愉悦的操作体验。"\
                                      "\n\n2.随身携带的手机KTV"\
                                      "\n超过300万首海量伴奏，VIPER音频渲染技术，让你开嗓即成天籁。"\
                                      "\n\n3.乐库体验大有不同"\
                                      "\n耳目一新的乐库，新歌速递、权威榜单、精选歌单，你要找的，都在这里。"
                                      "\n\n4.个性化的皮肤"\
                                      "\n主题色随着背景而改变，更有多款主题任君选择，只为与众不同的你。"
                                      ];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail.attributedText = str;
    detail.editable = NO;
    detail.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
    detail.font = [UIFont systemFontOfSize:15.0f];
    [pageView addSubview:detail];
}
-(void)upgrade:(id)sender{
    
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
