//
//  CategoryTableViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/10.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "SDRefresh.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "TFHpple.h"
#import "OnLineCategoryModule.h"
#import "DBImageView.h"
#import "OnLineMusicTableViewController.h"
#import "SubCategoryViewController.h"
#import "iToast.h"
#import "UIImageView+WebCache.h"
#import "LayoutParameters.h"

static NSString *const kCellIdentifier = @"kCellIdentifier";

@interface CategoryTableViewController ()

@property (nonatomic, strong) SDRefreshFooterView *refreshFooter;
@property (nonatomic, assign) NSInteger totalRowCount;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *items;

@end

UIActivityIndicatorView *spinner;

@implementation CategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label setText:self.titleStr];
    [self.view addSubview:label];
    
    [self.navigationController.navigationBar.topItem setTitleView:label];
    
    //    [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [self.view setBackgroundColor:APP_THEME_COLOR];//[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = backItem;
    
    //    self.navigationController.navigationBar.hidden = YES;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.totalRowCount = 0;
    
    _table= [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _table.tableFooterView = [[UIView alloc] init];
    _table.contentInset = UIEdgeInsetsMake(-64, 0, 64, 0);
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
            NSMutableArray *array = [self getCategoryData:self.getDataUrl];
            
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
//        _items = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] initWithArray:[self getCategoryData:self.getDataUrl]];
        [self getCategoryData:self.getDataUrl];
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

-(BOOL)isVisble{
    return (self.isViewLoaded && self.view.window);
}

-(void)getDataFail{
    if ((_items == nil || _items.count == 0) && [self isVisble]) {
        [[[iToast makeText:@"数据获取失败!"] setGravity:iToastGravityBottom] show];
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        return;
    }
}

-(void)initTableView{
}

-(NSMutableArray *)getCategoryData:(NSString *)urlString{
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSString *title=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    if (title == nil) {
//        [[[iToast makeText:@"数据获取失败!"] setGravity:iToastGravityBottom] show];
//        [spinner stopAnimating];
//        [spinner removeFromSuperview];
        return nil;
    }
    
    NSRange range=[title rangeOfString:@"<div class=\"main fl\">"];
    
    NSMutableString *needTidyString=[NSMutableString stringWithString:[title substringFromIndex:range.location+range.length]];
    
    NSRange range2=[needTidyString rangeOfString:@"<div class=\"sider fl\">"];
    
    NSMutableString *needTidyString2=[NSMutableString stringWithString:[needTidyString substringToIndex:range2.location]];
    
    NSData *data = [needTidyString2 dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *parser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray *array = [parser searchWithXPathQuery:@"//li"];
    for (TFHppleElement *element in array){
        OnLineCategoryModule *item = [[OnLineCategoryModule alloc] init];
        NSArray *contetnt = [element children];
        //image
        TFHppleElement *e0 = contetnt[0];
        
        NSArray *contetnt0 = [e0 children];
        TFHppleElement *contetnt01 = [contetnt0 objectAtIndex:0];
        item.image = [contetnt01 objectForKey:@"lazy_src"];
//        NSLog(@"%@", [contetnt01 objectForKey:@"lazy_src"]);
        //title
        TFHppleElement *e1 = contetnt[1];
//        NSLog(@"%@", [e1 objectForKey:@"href"]);
        item.href = [[NSString stringWithFormat:@"http://yinyue.kuwo.cn%@", [e1 objectForKey:@"href"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        item.title = [e1 content];
//        NSLog(@"%@", [e1 content]);
        
        //number
        TFHppleElement *e2 = contetnt[2];
//        NSLog(@"%@", [e2 content]);
        item.number = [e2 content];
        [datas addObject:item];
    }
    return datas;
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    
    // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
    refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:self.table];
    
    SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.totalRowCount += 3;
            [self.table reloadData];
            [weakRefreshHeader endRefreshing];
        });
    };
    
    // 进入页面自动加载一次数据
    [refreshHeader beginRefreshing];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.totalRowCount += 2;
        [self.table reloadData];
        [self.refreshFooter endRefreshing];
    });
}

#pragma mark - Table view data source

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
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     }
    OnLineCategoryModule *item = [_items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:[UIImage imageNamed:@"home_music_logo_76"]];
    
//    cell.imageView.image=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.image]]];
    
//    cell.imageView.contentMode=UIViewContentModeScaleAspectFit;
    /*
    DBImageView *imageview = [[DBImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    imageview.center = CGPointMake(22, cell.contentView.bounds.size.height/2);
    [imageview setImageWithPath:item.image];
    [cell.contentView addSubview:imageview];
    */
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OnLineCategoryModule *item = [_items objectAtIndex:indexPath.row];
    
    if ([self.titleStr isEqualToString:@"有声读物"]){
        
        SubCategoryViewController *kugooViewController = [[SubCategoryViewController alloc] init];
        kugooViewController.titleStr = item.title;
        kugooViewController.getDataUrl = item.href;
        
        [self.navigationController pushViewController:kugooViewController animated:YES];
        [self.navigationController setNavigationBarHidden:YES];
        
        return;
    }
    
    OnLineMusicTableViewController *kugooViewController = [[OnLineMusicTableViewController alloc] init];
    kugooViewController.titleStr = item.title;
    kugooViewController.getDataUrl = item.href;
    
    [self.navigationController pushViewController:kugooViewController animated:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
