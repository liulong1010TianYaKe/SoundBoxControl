//
//  SearchDevicesViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "SearchDevicesViewController.h"
#import "arpa/inet.h"
//#import <SystemConfiguration/CaptiveNetwork.h>
#import "ViewController.h"
#import "Constants.h"
#import "LoadingView.h"
#import "IntroControll.h"
#import "CommonMacro.h"
#import "GPLoadingButton.h"
#import "iToast.h"
#import "LayoutParameters.h"
#import "GuidSettingViewController.h"
#import "GuaidSettingStep1ViewController.h"
#include <SystemConfiguration/CaptiveNetwork.h>

@interface SearchDevicesViewController ()

@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;

@property (nonatomic, strong) NSMutableArray *airPlayDevices;

@end
UIAlertView *baseAlert;
UIScrollView *scrollView;
UIImageView *loadingImageView;
UILabel *searchLabel;

UILabel *contactLabel;
UIButton *researchBtn;
UIButton *settingBtn;
UILabel *title;
UILabel *searchDetail;

UIView *noWifiPageView;
UIView *searchPageView;
UIView *connectedHotPageView;
UIView *firstInstalledPageView;

@implementation SearchDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(void)createPageView{
    if (searchPageView){
        searchPageView.hidden = NO;
        if (noWifiPageView) noWifiPageView.hidden = YES;
        if (connectedHotPageView) connectedHotPageView.hidden = YES;
        if (firstInstalledPageView) firstInstalledPageView.hidden = YES;
        return;
    }
    if (noWifiPageView) noWifiPageView.hidden = YES;
    if (connectedHotPageView) connectedHotPageView.hidden = YES;
    if (firstInstalledPageView) firstInstalledPageView.hidden = YES;
    
    searchPageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    searchPageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:searchPageView];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 150, 40)];
    title.center = CGPointMake(self.view.bounds.size.width / 2, 96);
    title.textAlignment = NSTextAlignmentCenter;
    title.text= @"搜索设备";
    title.font = [UIFont systemFontOfSize:24.0f];
    title.textColor = APP_THEME_COLOR;
    [searchPageView addSubview:title];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 168, SCREEN_WIDTH - 100, 40)];
    subTitle.center = CGPointMake(self.view.bounds.size.width / 2, 156);
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.text= @"欢迎使用庭悦音乐设备";
    subTitle.font = [UIFont systemFontOfSize:18.0f];
    subTitle.textColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
    [searchPageView addSubview:subTitle];
    
    searchDetail = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 100, 140)];
    searchDetail.center = CGPointMake(self.view.bounds.size.width / 2, 270);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请确保: "\
                                       "\n1.设备连上电源"\
                                       "\n2.手机已经连接需要配置的WiFi"\
                                       "\n3.设备置于WiFi的有效范围内"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    searchDetail.attributedText = str;
    searchDetail.font = [UIFont systemFontOfSize:15.0f];
    searchDetail.numberOfLines = 0;
    searchDetail.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [searchPageView addSubview:searchDetail];
    
    loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    loadingImageView.center = CGPointMake(self.view.bounds.size.width/2, 408);
    [loadingImageView setImage:[UIImage imageNamed:@"icon_device_search_loading"]];
    [searchPageView addSubview:loadingImageView];
    [self rotate360DegreeWithImageView:loadingImageView];
    
    /*
    loadingView = [[GPLoadingButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    loadingView.center = CGPointMake(self.view.bounds.size.width/2, 400);
    loadingView.rotatorColor = [UIColor colorWithRed:236/255.0 green:100/255.0 blue:0/255.0 alpha:1];
    [loadingView startActivity];
    [self.view addSubview:loadingView];*/
    
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 183, 40)];
    searchLabel.center = CGPointMake(self.view.bounds.size.width / 2, SCREEN_HEIGHT - 100);
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.text= @"搜索设备中，请稍后...";
    searchLabel.font = [UIFont systemFontOfSize:15.0f];
    searchLabel.textColor = [UIColor blackColor];
    [searchPageView addSubview:searchLabel];
    
    contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 183, 40)];
    contactLabel.center = CGPointMake(self.view.bounds.size.width / 2, 400);
    contactLabel.textAlignment = NSTextAlignmentCenter;
    contactLabel.text= @"客服电话：0755-61363398";
    contactLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    contactLabel.textColor = [UIColor colorWithRed:48/255.0 green:48/255.0 blue:48/255.0 alpha:1];
    contactLabel.hidden = YES;
    [searchPageView addSubview:contactLabel];
    
    researchBtn = [[UIButton alloc] initWithFrame:CGRectMake(58, 420, 80, 37)];
    researchBtn.center = CGPointMake(self.view.bounds.size.width - self.view.bounds.size.width / 3, 460);
    [researchBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
    [researchBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    researchBtn.backgroundColor = [UIColor clearColor];
    researchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    researchBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    researchBtn.titleLabel.textColor = APP_THEME_COLOR;
    researchBtn.layer.cornerRadius = 5.0;
    researchBtn.layer.borderWidth = 1.0;
    [researchBtn.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [researchBtn addTarget:self action:@selector(startResearch:) forControlEvents:UIControlEventTouchUpInside];
    researchBtn.hidden = YES;
    [searchPageView addSubview:researchBtn];
    
    settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(58, 420, 80, 37)];
    settingBtn.center = CGPointMake(self.view.bounds.size.width / 3, 460);
    [settingBtn setTitle:@"连接设备" forState:UIControlStateNormal];
    [settingBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    settingBtn.backgroundColor = [UIColor clearColor];
    settingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    settingBtn.titleLabel.textColor = APP_THEME_COLOR;
    settingBtn.layer.cornerRadius = 5.0;
    settingBtn.layer.borderWidth = 1.0;
    [settingBtn.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [settingBtn addTarget:self action:@selector(gotoSettingWifiPageWithBack:) forControlEvents:UIControlEventTouchUpInside];
    settingBtn.hidden = YES;
    [searchPageView addSubview:settingBtn];
    
    [self performSelector:@selector(searchFailedView) withObject:nil afterDelay:10.0f];

}

- (void)createScrollView
{
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 3, 0)];
    [scrollView setPagingEnabled:YES];  //视图整页显示
        [scrollView setBounces:NO]; //避免弹跳效果,避免把根视图露出来
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview setImage:[UIImage imageNamed:@"image1.jpg"]];
    [scrollView addSubview:imageview];
    [imageview release];
    
    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(320, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview1 setImage:[UIImage imageNamed:@"image2.jpg"]];
    [scrollView addSubview:imageview1];
    [imageview1 release];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(640, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview2 setImage:[UIImage imageNamed:@"image3.jpg"]];
    imageview2.userInteractionEnabled = YES;    //打开imageview3的用户交互;否则下面的button无法响应
    [scrollView addSubview:imageview2];
    [imageview2 release];
    
//    UIImageView *imageview3 = [[UIImageView alloc] initWithFrame:CGRectMake(960, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    [imageview3 setImage:[UIImage imageNamed:@"image1.jpg"]];
//    imageview3.userInteractionEnabled = YES;    //打开imageview3的用户交互;否则下面的button无法响应
//    [scrollView addSubview:imageview3];
//    [imageview3 release];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//在imageview3上加载一个透明的button
    [button setTitle:@"立刻体验" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(46, SCREEN_HEIGHT - 100, 230, 37)];
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    [button addTarget:self action:@selector(firstpressed) forControlEvents:UIControlEventTouchUpInside];
    [imageview2 addSubview:button];
    
    [self.view addSubview:scrollView];
}

- (void)firstpressed
{
    [scrollView removeFromSuperview];
    [self normalStart];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"0" forKey:APP_FIRST_OPEN];
    /*
    [self createPageView];
    [self searchAirplayServices];
    
    [self performSelector:@selector(dialogDismiss) withObject:nil afterDelay:2.0f];
     */
}

-(void) showProgressDialog{
    baseAlert = [[UIAlertView alloc] initWithTitle:@"Searching devices..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [baseAlert show];
    
    [self performSelector:@selector(dialogDismiss) withObject:nil afterDelay:1.0f];
    
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
//    indicator.center = self.view.center;
//    [self.view addSubview:indicator];
//    [indicator bringSubviewToFront:self.view];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
//    
//    [indicator startAnimating];
}

-(void)dialogDismiss{
//    [baseAlert dismissWithClickedButtonIndex:0 animated:NO];
    [loadingImageView.layer removeAllAnimations];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if([ud objectForKey:DEVICE_HOT_IP_NAME] != nil){
        ViewController *homeViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"mainView"]; //[[ViewController alloc] init];
        [self.navigationController pushViewController:homeViewController animated:NO];
    
    } else{
        [[[iToast makeText:@"device not found!"] setGravity:iToastGravityBottom] show];
    }
}

-(void)createNoWifiView{
    if (noWifiPageView){
        noWifiPageView.hidden = NO;
        if (searchPageView) searchPageView.hidden = YES;
        if (connectedHotPageView) connectedHotPageView.hidden = YES;
        if (firstInstalledPageView) firstInstalledPageView.hidden = YES;
        return;
    }
    if (searchPageView) searchPageView.hidden = YES;
    if (connectedHotPageView) connectedHotPageView.hidden = YES;
    if (firstInstalledPageView) firstInstalledPageView.hidden = YES;
    
    noWifiPageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    noWifiPageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:noWifiPageView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    imageView.image = [UIImage imageNamed:@"nowifi_bg"];
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 183, 40)];
    searchLabel.center = CGPointMake(self.view.bounds.size.width / 2, 440);
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.text= @"连接WiFi网络才能工作哦~";
    searchLabel.font = [UIFont systemFontOfSize:15.0f];
    searchLabel.textColor = [UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1];
    [imageView addSubview:searchLabel];
    
    UILabel *searchLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 183, 40)];
    searchLabel2.center = CGPointMake(self.view.bounds.size.width / 2, SCREEN_HEIGHT - 20);
    searchLabel2.textAlignment = NSTextAlignmentCenter;
    searchLabel2.text= @"V1.0";
    searchLabel2.font = [UIFont systemFontOfSize:15.0f];
    searchLabel2.textColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1];
    [imageView addSubview:searchLabel2];
    
    
    [noWifiPageView addSubview:imageView];
}

-(void)searchFailedView{
    loadingImageView.hidden = YES;
    searchLabel.hidden = YES;
    contactLabel.hidden = YES;
    researchBtn.hidden = NO;
    settingBtn.hidden = NO;
    title.text= @"未搜索到设备";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"未搜索到音响设备，可能原因: "\
                                      "\n1.未发现设备，请点击“重新搜索”"\
                                      "\n2.设备未连接到网络，请点击“连接设备”进行网络配置"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    searchDetail.attributedText = str;
}

-(void)startResearch:(id)sender{
    contactLabel.hidden = YES;
    researchBtn.hidden = YES;
    settingBtn.hidden = YES;
    loadingImageView.hidden = NO;
    searchLabel.hidden = NO;
    title.text= @"搜索设备";
    
    [self performSelector:@selector(searchFailedView) withObject:nil afterDelay:10.0f];
    [self searchAirplayServices];
    
//    [self gotoHomePage:nil];
}

-(void)connectedHotView{
    if (connectedHotPageView){
        connectedHotPageView.hidden = NO;
        if (searchPageView) searchPageView.hidden = YES;
        if (noWifiPageView) noWifiPageView.hidden = YES;
        if (firstInstalledPageView) firstInstalledPageView.hidden = YES;
        return;
    }
    if (searchPageView) searchPageView.hidden = YES;
    if (noWifiPageView) noWifiPageView.hidden = YES;
    if (firstInstalledPageView) firstInstalledPageView.hidden = YES;
    
    connectedHotPageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    connectedHotPageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:connectedHotPageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 200, 40)];
    title.center = CGPointMake(self.view.bounds.size.width / 2, 96);
    title.textAlignment = NSTextAlignmentCenter;
    title.text= @"已连接设备热点";
    title.font = [UIFont boldSystemFontOfSize:24.0f];
    title.textColor = APP_THEME_COLOR;
    [connectedHotPageView addSubview:title];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 168, SCREEN_WIDTH - 100, 40)];
    subTitle.center = CGPointMake(self.view.bounds.size.width / 2, 156);
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.text= @"欢迎使用庭悦音乐设备";
    subTitle.font = [UIFont boldSystemFontOfSize:18.0f];
    subTitle.textColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
    [connectedHotPageView addSubview:subTitle];
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 100, 140)];
    detail.center = CGPointMake(self.view.bounds.size.width / 2, 240);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"已连接home-music热点"\
                                      "\n请点击\"配置网络\"使设备连接网络"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail.attributedText = str;
    detail.font = [UIFont boldSystemFontOfSize:15.0f];
    detail.numberOfLines = 0;
    detail.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [connectedHotPageView addSubview:detail];
    
    /*
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(58, 420, 80, 38)];
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    [button setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    button.titleLabel.textColor = APP_THEME_COLOR;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    [button.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button addTarget:self action:@selector(gotoHomePage:) forControlEvents:UIControlEventTouchUpInside];
    [connectedHotPageView addSubview:button];*/
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 58 - 80, 420, 100, 37)];
    button2.center = CGPointMake(SCREEN_WIDTH/2, 460);
    [button2 setTitle:@"配置网络" forState:UIControlStateNormal];
    button2.titleLabel.textColor = APP_THEME_COLOR;
    [button2 setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button2.layer.cornerRadius = 5.0;
    button2.layer.borderWidth = 1.0;
    button2.layer.borderColor = APP_THEME_COLOR.CGColor;
    [button2 addTarget:self action:@selector(gotoSettingWifiPage2:) forControlEvents:UIControlEventTouchUpInside];
    [connectedHotPageView addSubview:button2];
}

-(void)firstInstalledView{
    if (firstInstalledPageView){
        firstInstalledPageView.hidden = NO;
        if (searchPageView) searchPageView.hidden = YES;
        if (noWifiPageView) noWifiPageView.hidden = YES;
        if (connectedHotPageView) connectedHotPageView.hidden = YES;
        return;
    }
    if (searchPageView) searchPageView.hidden = YES;
    if (noWifiPageView) noWifiPageView.hidden = YES;
    if (connectedHotPageView) connectedHotPageView.hidden = YES;
    
    firstInstalledPageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    connectedHotPageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:firstInstalledPageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 200, 40)];
    title.center = CGPointMake(self.view.bounds.size.width / 2, 96);
    title.textAlignment = NSTextAlignmentCenter;
    title.text= @"连接设备";
    title.font = [UIFont systemFontOfSize:24.0f];
    title.textColor = APP_THEME_COLOR;
    [firstInstalledPageView addSubview:title];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 168, SCREEN_WIDTH - 40, 40)];
    subTitle.center = CGPointMake(self.view.bounds.size.width / 2, 156);
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.text= @"欢迎使用庭悦音乐设备";
    subTitle.font = [UIFont systemFontOfSize:18.0f];
    subTitle.textColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
    [firstInstalledPageView addSubview:subTitle];
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 80, 140)];
    detail.center = CGPointMake(self.view.bounds.size.width / 2, 266);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"第一次使用NELDTV音响，系统将会引导您进行相关配置，全部操作大概占用您1分钟时间。"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail.attributedText = str;
    detail.font = [UIFont systemFontOfSize:15.0f];
    detail.numberOfLines = 0;
    detail.textColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1];
    [firstInstalledPageView addSubview:detail];

    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(58, 420, 100, 37)];
    button.center = CGPointMake(self.view.bounds.size.width / 2, SCREEN_HEIGHT - 132);
    [button setTitle:@"知道了" forState:UIControlStateNormal];
    [button setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.titleLabel.textColor = APP_THEME_COLOR;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    [button.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button addTarget:self action:@selector(gotoSettingWifiPage:) forControlEvents:UIControlEventTouchUpInside];
    [firstInstalledPageView addSubview:button];
}

-(void)gotoHomePage:(id)sender{
    ViewController *homeViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"mainView"]; //[[ViewController alloc] init];
    [self.navigationController pushViewController:homeViewController animated:YES];
}
-(void)gotoSettingWifiPageWithBack:(id)sender{
    GuaidSettingStep1ViewController *guaidSetting = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"guaidSettingstep1"];
    guaidSetting.isFromMainPage = YES;
    [self.navigationController pushViewController:guaidSetting animated:YES];
}

-(void)gotoSettingWifiPage:(id)sender{
    GuaidSettingStep1ViewController *guaidSetting = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"guaidSettingstep1"];
    guaidSetting.isFromMainPage = NO;
    [self.navigationController pushViewController:guaidSetting animated:YES];
}

-(void)gotoSettingWifiPage2:(id)sender{
    GuidSettingViewController *guaidSetting = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"guaidSetting"];
    guaidSetting.isFromHotPage = YES;
    [self.navigationController pushViewController:guaidSetting animated:YES];
}

-(void)normalStart{
#warning lianjie shebei
//    if ([self fetchSSIDInfo] == nil){
//        [self createNoWifiView];
//        return;
//    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *hasEnterMain = @"0";//yes:1, no 0
    if ([ud objectForKey:APP_FIRST_ENTER_MAIN] != nil){
        hasEnterMain = [ud objectForKey:APP_FIRST_ENTER_MAIN];
    }
    
    if([hasEnterMain isEqualToString:@"1"]){ //start search devices
        if ([self fetchSSIDInfo] != nil){
            if ([self hasConnectedHot]){ //connect hot
                [self connectedHotView];
            }else {
                [self createPageView];
                [self performSelector:@selector(searchAirplayServices) withObject:nil afterDelay:3.0f];
//                [self searchAirplayServices];
            }
        }else { //wifi close
            [self createNoWifiView];
        }
    } else {//enter net setting step 1
//        [self gotoSettingWifiPage:nil];
        [self firstInstalledView];
        [self searchAirplayServices];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self fetchSSIDInfo];
    [self normalStart];
    /*
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *firstOpen = @"1";
    if ([ud objectForKey:APP_FIRST_OPEN] != nil) {
        firstOpen = [ud objectForKey:APP_FIRST_OPEN];
    }
    
    if([firstOpen isEqualToString:@"1"]){
        [self createScrollView];
    } else {
        [self normalStart];
        
        if ([[ud objectForKey:NET_SSID_NAME] isEqualToString:DEVICE_HOT_NAME]){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            if (appDelegate.isReachable){
                [self connectedHotView];
//            }else{
//                [self createNoWifiView];
//            }
        }else{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.isReachable){
                [self createPageView];
                [self searchAirplayServices];
            }else {
                [self createNoWifiView];
            }
        }
//        [self performSelector:@selector(dialogDismiss) withObject:nil afterDelay:5.0f];
    }*/
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)searchAirplayServices{
    if([self hasConnectedHot]) return;
    if (_netServiceBrowser){
        [_netServiceBrowser stop];
        _netServiceBrowser = nil;
    }
    
//    [self showProgressDialog];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    _airPlayDevices = [[NSMutableArray alloc] init];
    
    _netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    _netServiceBrowser.delegate = self;
    [_netServiceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@"local."];
    
    [ud setObject:nil forKey:DEVICE_HOT_IP_NAME];
}

-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
    
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    NSString *serviceName = [NSString stringWithFormat:@"%@",aNetService];
    if ([serviceName rangeOfString:@"Allwinnertech-hklt-y3"].location != NSNotFound){
//        [self gotoHomePage:nil];
    }
    
//    NSLog(@"devices :%@", serviceName);
    
    [_airPlayDevices addObject:aNetService];
    [aNetService setDelegate:self];
    //    aNetService.delegate = self;
    [aNetService resolveWithTimeout:15.0];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
//    NSLog(@"remove: %@", aNetService);
    [_airPlayDevices removeObject:aNetService];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict{
    
}

-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
}

-(void)netServiceWillResolve:(NSNetService *)sender{
//    NSLog(@"netServiceWillResolve");    
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict{
//    NSLog(@"didNotResolve");
}

-(NSString *)gen_uuid:(NSString *)str
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    //NSDictionary *dic = [NSNetService dictionaryFromTXTRecordData:sender.TXTRecordData];
    
    //NSString *inden1 = [[NSString alloc] initWithData:dic[@"deviceid"] encoding:NSUTF8StringEncoding];
    
    
    NSString *ip = [self getStringFromAddressData:[sender.addresses objectAtIndex:0]];
    
    NSLog(@"%@ : %@ : %d", [sender name], ip, sender.port);
//    NSLog(@"text: %s", [[sender TXTRecordData] bytes]);
    if ([[sender name] rangeOfString:DEVICE_NAME].location != NSNotFound){
        //save ip
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:ip forKey:DEVICE_HOT_IP_NAME];
        [_netServiceBrowser stop];
        [self dialogDismiss];
//        ViewController *homeViewController = [[ViewController alloc] init];
//        [self.navigationController pushViewController:homeViewController animated:YES];
    }
}

-(NSString *)getStringFromAddressData:(NSData *) dataIn {
    struct sockaddr_in *socketAddress = nil;
    NSString *ipString = nil;
    
    socketAddress = (struct sockaddr_in *)[dataIn bytes];
    ipString = [NSString stringWithFormat:@"%s",
                inet_ntoa(socketAddress->sin_addr)];
    
    return ipString;
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

//获取当前连接的wifi

-(id)fetchSSIDInfo{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs){
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if(info && [info count]){
            NSString *ssid = [info objectForKey:@"SSID"];
            NSLog(@"%s: ssid => %@", __func__, ssid);
            if (![[DEVICE_HOT_NAME lowercaseString] isEqualToString:[ssid lowercaseString]]){
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:ssid forKey:NET_SSID_NAME];
                [ud synchronize];
            
                break;
            }
        }
    }
    return info;
}

-(UIImageView *)rotate360DegreeWithImageView:(UIImageView *)imageView{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 0.8;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VAL;//1000000;
    [imageView.layer addAnimation:rotationAnimation forKey:nil];
    
    return imageView;
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
