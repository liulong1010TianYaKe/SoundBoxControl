//
//  GuidSettingViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "GuidSettingViewController.h"
#import "CommonMacro.h"
#import "Constants.h"
#import "arpa/inet.h"
#import "ViewController.h"
#import "iToast.h"
#import "UIPlaceHolderTextView.h"
#import "LayoutParameters.h"
#import "JKAlertDialog.h"
#import "GuaidSettingStep1ViewController.h"

@interface GuidSettingViewController ()

@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;

@property (nonatomic, strong) NSMutableArray *airPlayDevices;


@property (retain, nonatomic) UITextField *wifiSSID;
@property (retain, nonatomic) UITextField *wifiPWD;

@end

@implementation GuidSettingViewController

@synthesize socket;

UIView *failedPageView;
UIView *settingPageView;
UIAlertView *baseAlert;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"引导设置"];
    [bar pushNavigationItem:navTitle animated:YES];
    [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self.view addSubview:bar];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
    navTitle.leftBarButtonItem = item;
    [bar setItems:[NSArray arrayWithObject:navTitle]];*/
    
    [self.view setBackgroundColor:[UIColor whiteColor]];}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupPageView];
    
    settingPageView.hidden = NO;
    if(failedPageView) failedPageView.hidden = YES;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:NET_SSID_NAME] != nil){
        self.wifiSSID.text = [ud objectForKey:NET_SSID_NAME];
    }    
}

-(void)setupPageView{
//    if(settingPageView){
//        settingPageView.hidden = NO;
//        if(failedPageView) failedPageView.hidden = YES;
//        return;
//    }
    if(failedPageView) failedPageView.hidden = YES;
    
    settingPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [settingPageView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 200, 40)];
    title.center = CGPointMake(self.view.bounds.size.width / 2, 96);
    title.textAlignment = NSTextAlignmentCenter;
    title.text= @"连接设备";
    title.font = [UIFont systemFontOfSize:24.0f];
    title.textColor = APP_THEME_COLOR;
    [settingPageView addSubview:title];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 168, 183, 40)];
    subTitle.center = CGPointMake(self.view.bounds.size.width / 2, 157);
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.text= @"为音乐设备配置网络";
    subTitle.font = [UIFont systemFontOfSize:18.0f];
    subTitle.textColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
    [settingPageView addSubview:subTitle];
    
    _wifiSSID = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 100, 37)];
    _wifiSSID.center = CGPointMake(SCREEN_WIDTH/2, 250);
    _wifiSSID.textColor = [UIColor blackColor];
    _wifiSSID.backgroundColor = [UIColor whiteColor];
    _wifiSSID.font = [UIFont systemFontOfSize:15.0f];
    _wifiSSID.layer.cornerRadius = 5.0;
    _wifiSSID.layer.borderWidth = 1;
    [_wifiSSID.layer setBorderColor: APP_THEME_COLOR.CGColor];
    _wifiSSID.textAlignment = NSTextAlignmentCenter;
    _wifiSSID.placeholder = @"请输入Wi-Fi网络名称";
    [settingPageView addSubview:_wifiSSID];
    
    _wifiPWD = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 100, 37)];
    _wifiPWD.center = CGPointMake(SCREEN_WIDTH/2, 315);
    _wifiPWD.textColor = [UIColor blackColor];
    _wifiPWD.backgroundColor = [UIColor whiteColor];
    _wifiPWD.font = [UIFont systemFontOfSize:15.0f];
    _wifiPWD.layer.cornerRadius = 5.0;
    _wifiPWD.layer.borderWidth = 1;
    [_wifiPWD.layer setBorderColor: APP_THEME_COLOR.CGColor];
    _wifiPWD.textAlignment = NSTextAlignmentCenter;
    _wifiPWD.placeholder = @"请输入Wi-Fi网络密码";
    _wifiPWD.secureTextEntry = YES;
    [settingPageView addSubview:_wifiPWD];
    
    UIButton *tuisongImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    tuisongImageView.center = CGPointMake(self.view.bounds.size.width/2, 445);
    [tuisongImageView setImage:[UIImage imageNamed:@"icon_net_work_set_next"] forState:UIControlStateNormal];
    [tuisongImageView addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [settingPageView addSubview:tuisongImageView];
    
    [self.view addSubview:settingPageView];
    
    UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *barbutton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *barbutton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    
    NSArray *buttonsArray = [NSArray arrayWithObjects:barbutton1, barbutton2, doneBtn, nil];
    [topView setItems:buttonsArray];
    [_wifiSSID setInputAccessoryView:topView];
    [_wifiPWD setInputAccessoryView:topView];
}
-(void)setupFailedView{
    if(_netServiceBrowser) [_netServiceBrowser stop];
    if (baseAlert)
        [baseAlert dismissWithClickedButtonIndex:0 animated:NO];
//    if (failedPageView){
//        failedPageView.hidden = NO;
//        if (settingPageView) settingPageView.hidden = YES;
//        return;
//    }
    if (settingPageView) settingPageView.hidden = YES;
    
    failedPageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    failedPageView.backgroundColor = [UIColor clearColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 150, 40)];
    title.center = CGPointMake(self.view.bounds.size.width / 2, 96);
    title.textAlignment = NSTextAlignmentCenter;
    title.text= @"连接设备失败";
    title.font = [UIFont boldSystemFontOfSize:24.0f];
    title.textColor = APP_THEME_COLOR;
    [failedPageView addSubview:title];
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH - 100, 140)];
    detail.center = CGPointMake(self.view.bounds.size.width / 2, 227);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"网络设置未成功，可能原因: "\
                                      "\n1.Ｗi-Fi网络密码错误"\
                                      "\n2.路由器设置了MAC地址过滤或AP隔离"\
                                      "\n3.路由器设置了隐藏SSID"\
                                      "\n4.确保路由器的加密方式为WAP或WAP2"\
                                      "\n5.请重新配置网络"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
    detail.attributedText = str;
    detail.font = [UIFont systemFontOfSize:15.0f];
    detail.numberOfLines = 0;
    detail.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [failedPageView addSubview:detail];
    
    UIButton *researchBtn = [[UIButton alloc] initWithFrame:CGRectMake(58, 420, 100, 37)];
    researchBtn.center = CGPointMake(self.view.bounds.size.width / 2, 456);
    [researchBtn setTitle:@"知道了" forState:UIControlStateNormal];
    [researchBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    researchBtn.backgroundColor = [UIColor clearColor];
    researchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    researchBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    researchBtn.titleLabel.textColor = APP_THEME_COLOR;
    researchBtn.layer.cornerRadius = 5.0;
    researchBtn.layer.borderWidth = 1.0;
    [researchBtn.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [researchBtn addTarget:self action:@selector(navBackBt:) forControlEvents:UIControlEventTouchUpInside];
    [failedPageView addSubview:researchBtn];
    
    [self.view addSubview:failedPageView];
}

-(IBAction)dismissKeyBoard{
    [_wifiSSID resignFirstResponder];
    [_wifiPWD resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navBackBt:(id)sender{
    if(self.isFromHotPage){
        GuaidSettingStep1ViewController *guaidSetting = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"guaidSettingstep1"];
        guaidSetting.isFromMainPage = NO;
        [self.navigationController pushViewController:guaidSetting animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)send:(id)sender {
#warning .....
//    if ([_wifiSSID.text length] == 0){
//         [[[iToast makeText:@"请输入Wi-Fi网络名称!"] setGravity:iToastGravityBottom] show];
//        return;
//    }
//    if ([_wifiPWD.text length] == 0){
//        [[[iToast makeText:@"请输入Wi-Fi密码!"] setGravity:iToastGravityBottom] show];
//        return;
//    }else if ([_wifiPWD.text length] < 8){
//        [[[iToast makeText:@"请输入8位Wi-Fi密码!"] setGravity:iToastGravityBottom] show];
//        return;
//    }
    
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    if ([ud objectForKey:NET_SSID_NAME] != nil &&
//        [[ud objectForKey:NET_SSID_NAME] isEqualToString:_wifiSSID.text]){
//        [self pushSSIDAndPWD];
//    } else {
//        if ([ud objectForKey:NET_SSID_NAME] != nil){
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"您的音乐设备连接网络为"];
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n %@", _wifiSSID.text]]];
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n您的手机设备连接网络为"]];
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n %@", [ud objectForKey:NET_SSID_NAME]]]];
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n只有当音乐设备网络与手机网络在同一网络时才能正常播放"]];
//        
//        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//        style.lineSpacing = 5;
//        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length) ];
//        
//        JKAlertDialog *alert = [[JKAlertDialog alloc]initWithTitle:@"提示" message:str];
//        
//        [alert addButton:Button_OTHER withTitle:@"确认" handler:^(JKAlertDialogItem *item) {
//            [self pushSSIDAndPWD];
//        }];;
//        [alert addButton:Button_OTHER withTitle:@"取消" handler:^(JKAlertDialogItem *item) {
////            NSLog(@"click %@",item.title);
//            if ([ud objectForKey:NET_SSID_NAME] != nil){
//                self.wifiSSID.text = [ud objectForKey:NET_SSID_NAME];
//            }
//        }];
//        
//        [alert show];
//        } else{
//            [self pushSSIDAndPWD];
//        }
//    }
}

-(void)pushSSIDAndPWD{
#warning ....
//    socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    //socket.delegate = self;
//    NSError *err = nil;
//    if(![socket connectToHost:DEVICE_HOT_IP onPort:SOCKET_PORT error:&err])
//    {
//        NSLog(@"failed");
//    }else
//    {
//        NSLog(@"ok");
//    }
//    baseAlert = [[UIAlertView alloc] initWithTitle:@"正在配置..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [baseAlert show];
//
//    [self performSelector:@selector(setupFailedView) withObject:nil afterDelay:20.0f];
}


-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //    [self addText:[NSString stringWithFormat:@"连接到:%@",host]];
    NSString *message = [self jsonString];//[NSString stringWithFormat:@"connect:%@:%@", _wifiSSID.text, _wifiPWD.text];
    [socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    [socket readDataWithTimeout:-1 tag:0];
        [self searchAirplayServices];
//    [self performSelector:@selector(searchAirplayServices) withObject:nil afterDelay:3.0f];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
}


-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *newMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    [self addText:[NSString stringWithFormat:@"%@:%@",sock.connectedHost,newMessage]];
    //[socket readDataWithTimeout:-1 tag:0];
}

-(NSString *)jsonString{
    NSDictionary *o2 = [NSDictionary dictionaryWithObjectsAndKeys:
                        _wifiPWD.text, @"pwd",
                        _wifiSSID.text, @"ssid",
                        nil];
    NSDictionary *o1 = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"0x00", @"head",
                        @"10", @"type",
                        @"1",@"status",
                        o2, @"content",
                        nil];
    NSData *json;
    if([NSJSONSerialization isValidJSONObject:o1]){
        json = [NSJSONSerialization dataWithJSONObject:o1 options:NSJSONWritingPrettyPrinted error:nil];
        if(json != nil){
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            NSLog(@"%@", jsonString);
            return jsonString;
        }
    }
    return nil;
}

-(void)searchAirplayServices{
    [socket disconnect];
    
    //    [self showProgressDialog];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    _airPlayDevices = [[NSMutableArray alloc] init];
    
    _netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    _netServiceBrowser.delegate = self;
    [_netServiceBrowser searchForServicesOfType:@"_raop._tcp" inDomain:@"local."];
    
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

-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    
    NSString *ip = [self getStringFromAddressData:[sender.addresses objectAtIndex:0]];
    
    NSLog(@"%@ : %@ : %d", [sender name], ip, sender.port);
    if ([[sender name] rangeOfString:DEVICE_NAME].location != NSNotFound){        //save ip
        
        if(![ip isEqualToString:DEVICE_HOT_IP]){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupFailedView) object:nil];
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:ip forKey:DEVICE_HOT_IP_NAME];
            [_netServiceBrowser stop];
            [self performSelector:@selector(dialogDismiss) withObject:nil afterDelay:3.0f];
        }
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

-(void)dialogDismiss{
    if (baseAlert)
        [baseAlert dismissWithClickedButtonIndex:0 animated:NO];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if([ud objectForKey:DEVICE_HOT_IP_NAME] != nil){
        [_netServiceBrowser stop];
        ViewController *homeViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"mainView"]; //[[ViewController alloc] init];
        [self.navigationController pushViewController:homeViewController animated:YES];
        
    } else{
        [[[iToast makeText:@"device not found!"] setGravity:iToastGravityBottom] show];
    }
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
    [_wifiSSID release];
    [_wifiPWD release];
    [super dealloc];
}
@end
