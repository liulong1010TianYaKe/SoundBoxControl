//
//  QPlayViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/13.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "QPlayViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"

@interface QPlayViewController ()

@end

@implementation QPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label setText:@"QQ音乐"];
    
    [self.navigationController.navigationBar.topItem setTitleView:label];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"back_btn_bg"]];
    
    [self.view setBackgroundColor:APP_THEME_COLOR];//[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    
//    [_nonOpenBtn addTarget:self action:@selector(nonOpen:) forControlEvents:UIControlEventTouchUpInside];
//    [_openBtn addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];

    
    [self setupViews];
}

-(void)setupViews{
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    pageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pageView];
    
    UIImage *image = [UIImage imageNamed:@"icon_qqmusic"];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    iconImageView.center = CGPointMake(SCREEN_WIDTH/2, 35+iconImageView.bounds.size.height/2);
    iconImageView.image = image;
    [pageView addSubview:iconImageView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    label1.center = CGPointMake(SCREEN_WIDTH/2, 110);
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0f];
    label1.text = @"将跳转到QQ音乐";
    label1.font = [UIFont systemFontOfSize:15.0f];
    [pageView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 450, 40)];
    label2.center = CGPointMake(SCREEN_WIDTH/2, 130);
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0f];
    label2.text = @"如未安装将跳转至QQ音乐安装页面";
    label2.font = [UIFont systemFontOfSize:15.0f];
    [pageView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, 165, 400, 80)];
//    label3.center = CGPointMake(SCREEN_WIDTH/2, 195);
    label3.textAlignment = NSTextAlignmentCenter;
    label3.textColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0f];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"在QQ音乐的歌曲播放控制页面，点击以下按钮，\n   即可选择庭悦音乐设备播放QQ音乐的内容。"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    label3.attributedText = str;
    label3.font = [UIFont systemFontOfSize:13.0f];
    label3.numberOfLines = 0;
    [pageView addSubview:label3];
    
    UIImage *image2 = [UIImage imageNamed:@"icon_third_player_hint"];
    UIImageView *iconImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    iconImageView2.center = CGPointMake(SCREEN_WIDTH/2, 255+iconImageView.bounds.size.height/2);
    iconImageView2.image = image2;
    [pageView addSubview:iconImageView2];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(45, 360, 80, 38)];
    [button setTitle:@"不要跳转" forState:UIControlStateNormal];
    [button setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.titleLabel.textColor = APP_THEME_COLOR;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    [button.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button addTarget:self action:@selector(nonOpen:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45 - 80, 360, 80, 38)];
    [button2 setTitle:@"确认跳转" forState:UIControlStateNormal];
    button2.titleLabel.textColor = APP_THEME_COLOR;
    [button2 setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button2.layer.cornerRadius = 5.0;
    button2.layer.borderWidth = 1.0;
    button2.layer.borderColor = APP_THEME_COLOR.CGColor;
    [button2 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button2];
}

-(void)open:(id)sender{
    NSURL *url = [NSURL URLWithString:@"QQMusic://"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url];
    else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/QQMusic/id414603431?mt=8"]];
    }
}

-(void)nonOpen:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    //[super dealloc];
}
@end
