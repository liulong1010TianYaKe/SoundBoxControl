//
//  SearchNetMusicViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/5/19.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "SearchNetMusicViewController.h"
#import "LayoutParameters.h"
#import "CommonMacro.h"
#import "iToast.h"
#import "TFHpple.h"
#import "OnLineMusicModule.h"
#import "SDRefreshFooterView.h"
#import "GlobalMusicInstance.h"
#import "NowPlayingViewController.h"


static NSString *const kCellIdentifier = @"kCellIdentifier2";

@interface SearchNetMusicViewController ()

@property (nonatomic, strong) SDRefreshFooterView *refreshFooter;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *items;

@property (retain, nonatomic) UITextField *keyTextField;

@property (nonatomic) NSInteger page;
@property (nonatomic) NSString *keyStr;

@end

UIActivityIndicatorView *spinner;

@implementation SearchNetMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label setText:@"搜索"];
    [self.view addSubview:label];
    
    [self.navigationController.navigationBar.topItem setTitleView:label];
    
    [self.view setBackgroundColor:APP_THEME_COLOR];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = backItem;
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    [self setupPage];
}

-(void)setupPage{
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - MAIN_TABBAR_HEIGHT)];
    pageView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    
    _keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH - 90, 37)];
    _keyTextField.textColor = [UIColor blackColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    _keyTextField.leftView = paddingView;
    _keyTextField.leftViewMode = UITextFieldViewModeAlways;
    _keyTextField.backgroundColor = [UIColor whiteColor];
    _keyTextField.font = [UIFont systemFontOfSize:15.0f];
    _keyTextField.layer.cornerRadius = 2.0;
    _keyTextField.layer.borderWidth = 1;
    [_keyTextField.layer setBorderColor: APP_THEME_COLOR.CGColor];
    _keyTextField.textAlignment = NSTextAlignmentLeft;
    _keyTextField.placeholder = @"请输入关键字";
    [pageView addSubview:_keyTextField];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(_keyTextField.frame.origin.x + _keyTextField.bounds.size.width, 10, 60, 37)];
    [button2 setTitle:@"搜索" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button2.backgroundColor = APP_THEME_COLOR;
    button2.titleLabel.textAlignment = NSTextAlignmentCenter;
    button2.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button2.layer.cornerRadius = 2.0;
    button2.layer.borderWidth = 1.0;
    [button2.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button2 addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button2];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2)];
    spinner.frame = CGRectMake(0, _keyTextField.frame.origin.x + _keyTextField.bounds.size.height + 5, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAV_TAB_BAR_HEIGHT);
    spinner.color = APP_THEME_COLOR;
    [pageView addSubview:spinner];
    
    _table= [[UITableView alloc] initWithFrame:CGRectMake(0, _keyTextField.frame.origin.x + _keyTextField.bounds.size.height + 5, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - MAIN_TABBAR_HEIGHT - _keyTextField.frame.origin.x - _keyTextField.bounds.size.height - 5)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _table.tableFooterView = [[UIView alloc] init];
    _table.backgroundColor = [UIColor whiteColor];
    _table.sectionIndexBackgroundColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1.0];
    _table.sectionIndexColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0];
    [_table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [_table setSeparatorInset:UIEdgeInsetsZero];
    
    [pageView addSubview:_table];
    [self setupFooter];
    
    [self.view addSubview:pageView];
}

-(void)showIndicator{
    spinner.hidden = NO;
    _table.hidden = YES;
    [spinner startAnimating];
}

-(void)hideIndicator{
    spinner.hidden = YES;
    [spinner stopAnimating];
    _table.hidden = NO;
}

-(void)startSearch:(id *)sender{
    if(_keyTextField.text.length == 0){
        [[[iToast makeText:@"请输入关键字!"] setGravity:iToastGravityBottom] show];
        return;
    }
    
    [_keyTextField resignFirstResponder];
    [self showIndicator];
    _page = 1;
//    _keyStr = [_keyTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        dispatch_async(concurrentQueue, ^{
            NSString *urlString = [NSString stringWithFormat:@"http://sou.kuwo.cn/ws/NSearch?type=music&key=%@&pn=%d", [_keyTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], _page];
            NSMutableArray *array = [self getSearchData:urlString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (array){
                    _items = [[NSMutableArray alloc] initWithArray:array];
                    [_table reloadData];
                    [self hideIndicator];
                }else{
                    [self getDataFail];
                }
            });
            
        });
        
    });
    
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
        [self hideIndicator];
        return;
    }
}

-(NSMutableArray *)getSearchData:(NSString *)urlString{
    NSLog(@"%@", urlString);
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSString *title=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    if (title == nil) {
        
        return nil;
    }
    
    NSRange range=[title rangeOfString:@"<div class=\"list\">"];
    
    NSMutableString *needTidyString=[NSMutableString stringWithString:[title substringFromIndex:range.location+range.length]];
    
    NSRange range2=[needTidyString rangeOfString:@"<div class=\"sider fl\">"];
    
    NSMutableString *needTidyString2=[NSMutableString stringWithString:[needTidyString substringToIndex:range2.location]];
    
    
    
    NSData *data = [needTidyString2 dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *parser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray *array = [parser searchWithXPathQuery:@"//li"];
    for (TFHppleElement *element in array){
        NSArray *contetnt = [element children];
        
        OnLineMusicModule *item = [[OnLineMusicModule alloc] init];
        
        //mid
        TFHppleElement *e10 = contetnt[0];
        NSArray *contetnt10 = [e10 children];
        TFHppleElement *e100 = contetnt10[0];
        item.mid = [e100 objectForKey:@"mid"];
        
        //name
        TFHppleElement *e0 = contetnt[1];
        NSArray *contetnt0 = [e0 children];
        TFHppleElement *e00 = contetnt0[0];
        item.title = [e00 objectForKey:@"title"];
        item.href = [e00 objectForKey:@"href"];
        
        //albume
        TFHppleElement *e3 = contetnt[2];
        NSArray *contetnt3 = [e3 children];
        if(contetnt3 && contetnt3.count > 0){
            TFHppleElement *e003 = contetnt3[0];
            item.albume = [e003 objectForKey:@"title"];
        }else{
            item.albume = @"";
        }
        
        [datas addObject:item];
    }
    return datas;
}

- (void)setupFooter
{
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.table];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
}


- (void)footerRefresh
{
    _page++;
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        dispatch_async(concurrentQueue, ^{
            NSString *urlString = [NSString stringWithFormat:@"http://sou.kuwo.cn/ws/NSearch?type=music&key=%@&pn=%d", [_keyTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], _page];
            NSMutableArray *array = [self getSearchData:urlString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshFooter endRefreshing];
                if (array){
                    [_items addObjectsFromArray:array];
                    [_table reloadData];
                    [self hideIndicator];
                }else{
                    [self getDataFail];
                }
            });
            
        });
        
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    OnLineMusicModule *item = [_items objectAtIndex:indexPath.row];
    [GlobalMusicInstance sharedSingleton].netArray = [[NSMutableArray alloc] initWithObjects:item, nil];
    [GlobalMusicInstance sharedSingleton].selectedIndex = indexPath.row;
    
    /*
    if([GlobalMusicInstance sharedSingleton].nowPlayingViewController == nil)
    [GlobalMusicInstance sharedSingleton].nowPlayingViewController = [[NowPlayingViewController alloc] init];
    
    [[GlobalMusicInstance sharedSingleton].nowPlayingViewController playNetLink:item];
    */
        
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(clickItem:) withObject:item afterDelay:0.8f];
    
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:YES];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
