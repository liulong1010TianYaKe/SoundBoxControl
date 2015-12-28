//
//  GuaidSettingStep1ViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "GuaidSettingStep1ViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "Constants.h"
#import "iToast.h"
#import "GuidSettingViewController.h"
#include <SystemConfiguration/CaptiveNetwork.h>

@interface GuaidSettingStep1ViewController ()

@end

@implementation GuaidSettingStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPageView];
}

-(void)setupPageView{
    UIScrollView *connectedHotPageView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    connectedHotPageView.backgroundColor = [UIColor clearColor];
    connectedHotPageView.directionalLockEnabled = YES;
    connectedHotPageView.pagingEnabled = NO;
    connectedHotPageView.showsVerticalScrollIndicator = YES;
    connectedHotPageView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    connectedHotPageView.showsHorizontalScrollIndicator = NO;
    connectedHotPageView.contentInset = UIEdgeInsetsMake([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0 ? -36 : -18, 0, 0, 0);
    [connectedHotPageView setContentSize:CGSizeMake(SCREEN_WIDTH, 800)];
    
    [self.view addSubview:connectedHotPageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 200, 40)];
    title.center = CGPointMake(self.view.bounds.size.width / 2, 96);
    title.textAlignment = NSTextAlignmentCenter;
    title.text= @"连接设备";
    title.font = [UIFont systemFontOfSize:24.0f];
    title.textColor = APP_THEME_COLOR;
    [connectedHotPageView addSubview:title];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 168, 183, 40)];
    subTitle.center = CGPointMake(self.view.bounds.size.width / 2, 156);
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.text= @"手机音乐设备连接";
    subTitle.font = [UIFont systemFontOfSize:18.0f];
    subTitle.textColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
    [connectedHotPageView addSubview:subTitle];
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 34, 140)];
    detail.center = CGPointMake(self.view.bounds.size.width / 2, 223);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"1.进入桌面点击：设置“图标”"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail.attributedText = str;
    detail.font = [UIFont systemFontOfSize:15.0f];
    detail.numberOfLines = 0;
    detail.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [connectedHotPageView addSubview:detail];
    
    UIImageView *guaid_1 = [[UIImageView alloc] initWithFrame:CGRectMake(41, 250, 240, 75)];
    [guaid_1 setImage:[UIImage imageNamed:@"guaid_2"]];
    [connectedHotPageView addSubview:guaid_1];
    
    UILabel *detail2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 34, 140)];
    detail2.center = CGPointMake(self.view.bounds.size.width / 2, 368);
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"2.点击Wi－Fi进入wifi设置页面，选择您需要设置的设备"];
    [str2 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str2.length) ];
    detail2.attributedText = str2;
    detail2.font = [UIFont systemFontOfSize:15.0f];
    detail2.numberOfLines = 0;
    detail2.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [connectedHotPageView addSubview:detail2];
    
    UIImageView *guaid_2 = [[UIImageView alloc] initWithFrame:CGRectMake(41, 415, 232, 90)];
    [guaid_2 setImage:[UIImage imageNamed:@"guaid_3"]];
    [connectedHotPageView addSubview:guaid_2];
    
    UILabel *detail3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 34, 140)];
    detail3.center = CGPointMake(self.view.bounds.size.width / 2, 547);
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:@"3.输入设备密码，默认设备密码贴在产品外观标签上"];
    [str3 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail3.attributedText = str3;
    detail3.font = [UIFont systemFontOfSize:15.0f];
    detail3.numberOfLines = 0;
    detail3.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [connectedHotPageView addSubview:detail3];
    
    UIImageView *guaid_3 = [[UIImageView alloc] initWithFrame:CGRectMake(41, 600, 231, 55)];
    [guaid_3 setImage:[UIImage imageNamed:@"guaid_1"]];
    [connectedHotPageView addSubview:guaid_3];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 37)];
    if(self.isFromMainPage){
        button.center = CGPointMake(SCREEN_WIDTH - SCREEN_WIDTH/3, 707);
    }else{
        button.center = CGPointMake(SCREEN_WIDTH/2, 707);
    }
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.titleLabel.textColor = APP_THEME_COLOR;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    [button.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button addTarget:self action:@selector(gotoStep2) forControlEvents:UIControlEventTouchUpInside];
    [connectedHotPageView addSubview:button];
    
    if(self.isFromMainPage){
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 37)];
    button2.center = CGPointMake(SCREEN_WIDTH/3, 707);
    [button2 setTitle:@"退出" forState:UIControlStateNormal];
    [button2 setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor clearColor];
    button2.titleLabel.textAlignment = NSTextAlignmentCenter;
    button2.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button2.titleLabel.textColor = APP_THEME_COLOR;
    button2.layer.cornerRadius = 5.0;
    button2.layer.borderWidth = 1.0;
    [button2.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button2 addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [connectedHotPageView addSubview:button2];
    }
    
    [self.view addSubview:connectedHotPageView];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotoStep2{
#warning ....
//    if ([self hasConnectedHot]){        
        GuidSettingViewController *guaidSetting = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"guaidSetting"];
        guaidSetting.isFromHotPage = NO;
        [self.navigationController pushViewController:guaidSetting animated:YES];
//    }else{
//        [[[iToast makeText:@"请连接音箱热点!"] setGravity:iToastGravityBottom] show];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)hasConnectedHot{
    BOOL hasConnected = NO;
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs){
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if(info && [info count]){
            NSString *ssid = [[info objectForKey:@"SSID"] lowercaseString];
            if ([[DEVICE_HOT_NAME lowercaseString] isEqualToString:ssid])
                hasConnected = YES;
            break;
        }
    }
    return hasConnected;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
