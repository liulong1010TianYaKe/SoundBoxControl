//
//  OnLineMusicTableViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/10.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "OnLineMusicTableViewController.h"
#import "OnLineMusicModule.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "TFHpple.h"
#import "iToast.h"
#import "NowPlayingViewController.h"
#import "GlobalMusicInstance.h"
#import "LayoutParameters.h"

static NSString *const kCellIdentifier = @"kCellIdentifier1";

@interface OnLineMusicTableViewController ()
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *items;

@end

UIActivityIndicatorView *spinner;

@implementation OnLineMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label setText:self.titleStr];
    [self.view addSubview:label];
    
    [self.navigationController.navigationBar.topItem setTitleView:label];
    
    //    [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    
     self.navigationController.navigationBar.topItem.backBarButtonItem = backItem;*/
    self.view.backgroundColor = APP_THEME_COLOR;//[UIColor colorWithRed:16/255.0 green:15/255.0 blue:15/255.0 alpha:1.0];
       
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    
    UIImage *bottombg = [UIImage imageNamed:@"bottombg"];
    [titleView setBackgroundColor:[UIColor clearColor]];
    
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleL.textColor = [UIColor whiteColor];
    titleL.textAlignment = UITextAlignmentCenter;
    titleL.center = CGPointMake(SCREEN_WIDTH/2, titleView.bounds.size.height/2);
    [titleL setText:self.titleStr];
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
    
    //    self.navigationController.navigationBar.hidden = YES;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    _table= [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - MAIN_TABBAR_HEIGHT)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _table.tableFooterView = [[UIView alloc] init];
//    _table.contentInset = UIEdgeInsetsMake(-64, 0, 64, 0);
    _table.backgroundColor = [UIColor whiteColor];
    _table.sectionIndexBackgroundColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1.0];
    _table.sectionIndexColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0];
    [_table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [_table setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:_table];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)]; // I do this because I'm in landscape mode
    spinner.frame = CGRectMake(0, STATUS_BAR_HEIGHT + NAV_TAB_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAV_TAB_BAR_HEIGHT);
    spinner.color = APP_THEME_COLOR;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    //    [self setupHeader];
    //    [self setupFooter];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        dispatch_async(concurrentQueue, ^{
            NSMutableArray *array = [self getMusicList:self.getDataUrl];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (array){
                    _items = [[NSMutableArray alloc] initWithArray:array];
                
                    [_table reloadData];
                    [spinner stopAnimating];
                    [spinner removeFromSuperview];
                }else{
                    [self getDataFail];
                }
            });
            
        });
        
    });
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _items = [[NSMutableArray alloc] init];
        [self getMusicList:self.getDataUrl];
        [_table reloadData];
        [spinner stopAnimating];
        [spinner removeFromSuperview];
    });
     */
    
    [self performSelectorOnMainThread:@selector(getMessageFromMain) withObject:nil waitUntilDone:NO];
}

-(void)getMessageFromMain{
    [self performSelector:@selector(getDataFail) withObject:nil afterDelay:6.0f];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:animated];
    }
}

-(void)getDataFail{
    if (_items == nil || _items.count == 0) {
        [[[iToast makeText:@"数据获取失败!"] setGravity:iToastGravityBottom] show];
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        return;
    }
}

-(NSMutableArray *)getMusicList:(NSString *)urlString{
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    /*
    //第一步，创建URL
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    
    //第二步，通过URL创建网络请求
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
    
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
    /*
    其中缓存协议是个枚举类型包含：
    
    NSURLRequestUseProtocolCachePolicy（基础策略）
    
    NSURLRequestReloadIgnoringLocalCacheData（忽略本地缓存）
    
    NSURLRequestReturnCacheDataElseLoad（首先使用缓存，如果没有本地缓存，才从原地址下载）
    
    NSURLRequestReturnCacheDataDontLoad（使用本地缓存，从不下载，如果本地没有缓存，则请求失败，此策略多用于离线操作）
    
    NSURLRequestReloadIgnoringLocalAndRemoteCacheData（无视任何缓存策略，无论是本地的还是远程的，总是从原地址重新下载）
    
    NSURLRequestReloadRevalidatingCacheData（如果本地缓存是有效的则不下载，其他任何情况都从原地址重新下载）
    
    //第三步，连接服务器
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    
    
    NSString *title = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    */
    NSString *title=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    if (title == nil) {
//        [[[iToast makeText:@"数据获取失败!"] setGravity:iToastGravityBottom] show];
//        [spinner stopAnimating];
//        [spinner removeFromSuperview];
        return nil;
    }
    
    NSRange range=[title rangeOfString:@"<ul id=\"musicList\">"];
    
    NSMutableString *needTidyString=[NSMutableString stringWithString:[title substringFromIndex:range.location+range.length]];
    
    NSRange range2=[needTidyString rangeOfString:@"<div class=\"page\" id=\"ge_page\">"];
    
    NSMutableString *needTidyString2=[NSMutableString stringWithString:[needTidyString substringToIndex:range2.location]];
    
//    NSLog(@"%@", needTidyString2);
    
    NSData *data = [needTidyString2 dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *parser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray *array = [parser searchWithXPathQuery:@"//li"];
    for (TFHppleElement *element in array){
        OnLineMusicModule *item = [[OnLineMusicModule alloc] init];
        NSArray *contetnt = [element children];
        
        //mid
        TFHppleElement *e10 = contetnt[0];
        NSArray *contetnt10 = [e10 children];
        TFHppleElement *e100 = contetnt10[0];
        item.mid = [e100 objectForKey:@"mid"];
//        NSLog(@"%@", [e100 objectForKey:@"mid"]);
        
        //name
        TFHppleElement *e0 = contetnt[1];
        NSArray *contetnt0 = [e0 children];
        TFHppleElement *e00 = contetnt0[0];
        item.title = [e00 content];
        item.href = [e00 objectForKey:@"href"];
//        NSLog(@"%@", [e00 content]);
//        NSLog(@"%@", [e00 objectForKey:@"href"]);
        //albume
        TFHppleElement *e3 = contetnt[3];
        NSArray *contetnt3 = [e3 children];
        TFHppleElement *e003 = contetnt3[0];
        item.albume = [e003 content];
//        NSLog(@"%@", [e003 content]);
        
        [datas addObject:item];
    }
    return datas;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     OnLineCategoryModule *item = [_items objectAtIndex:indexPath.row];
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
     
     if ( !cell ) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
     
     DBImageView *imageView = [[DBImageView alloc] initWithFrame:(CGRect){ 10, 1, 45, 45 }];
     [imageView setPlaceHolder:[UIImage imageNamed:@"home_music_logo_76"]];
     [imageView setBackgroundColor:[UIColor clearColor]];
     [imageView setTag:101];
     [cell.contentView addSubview:imageView];
     }
     
     [(DBImageView *)[cell viewWithTag:101] setImageWithPath:item.image];
     */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    OnLineMusicModule *item = [_items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.detailTextLabel.text = [item albume];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [GlobalMusicInstance sharedSingleton].netArray = _items;
    [GlobalMusicInstance sharedSingleton].selectedIndex = indexPath.row;
    OnLineMusicModule *item = [_items objectAtIndex:indexPath.row];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clickItem:) object:nil];
    [self performSelector:@selector(clickItem:) withObject:item afterDelay:0.8f];
    /*
    if([GlobalMusicInstance sharedSingleton].nowPlayingViewController == nil)
        [GlobalMusicInstance sharedSingleton].nowPlayingViewController = [[NowPlayingViewController alloc] init];
    
    [[GlobalMusicInstance sharedSingleton].nowPlayingViewController playNetLink:item];
    */
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:YES];
    }
//    [self.parentViewController.navigationController pushViewController:viewController animated:YES];

}

-(void)clickItem:(OnLineMusicModule *)item{
    if([GlobalMusicInstance sharedSingleton].nowPlayingViewController == nil)
        [GlobalMusicInstance sharedSingleton].nowPlayingViewController = [[NowPlayingViewController alloc] init];
    
    [[GlobalMusicInstance sharedSingleton].nowPlayingViewController playNetLink:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back:(id *)sender{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
