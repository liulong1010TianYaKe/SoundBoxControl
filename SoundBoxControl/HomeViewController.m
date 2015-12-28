//
//  HomeViewController.m
//  TTTTTT
//
//  Created by neldtv on 15/3/11.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "HomeViewController.h"
#import "SCNavTabBarController.h"
#import "DiscoveryMusicViewController.h"
#import "MyMusicViewController.h"
#import "MySoundBoxViewController.h"
#import "SettingTableViewController.h"
#import "LayoutParameters.h"
#import "CommonMacro.h"
#import "SearchNetMusicViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController setNavigationBarHidden:YES];  
    
//    [self.view setBackgroundColor:[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    [self.view setBackgroundColor:APP_THEME_COLOR];
    
    DiscoveryMusicViewController *oneViewController = [[DiscoveryMusicViewController alloc] init];
    oneViewController.title = @"发现";
    oneViewController.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    
    MyMusicViewController *twoViewController = [[MyMusicViewController alloc] init];
    twoViewController.title = @"我的";
    twoViewController.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    
    MySoundBoxViewController *threeViewController = [[MySoundBoxViewController alloc] init];
    threeViewController.title = @"音箱";
    threeViewController.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    
    SettingTableViewController *fourViewController = [[SettingTableViewController alloc] init];
    fourViewController.title = @"设置";
    fourViewController.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    
    SCNavTabBarController *navTabBarController = [[SCNavTabBarController alloc] init];
    navTabBarController.subViewControllers = @[twoViewController, oneViewController, threeViewController, fourViewController];
    navTabBarController.showArrowButton = NO;
//    [navTabBarController.view setBackgroundColor:[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0]];
    [navTabBarController addParentController:self];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    UIImage *image = [UIImage imageNamed:@"back_btn_bg"];
    UIImage *backBtnImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0.0f) resizingMode:UIImageResizingModeStretch];
    [backItem setBackButtonBackgroundImage:backBtnImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [backItem setBackButtonTitlePositionAdjustment:UIOffsetMake(-100.f, 0) forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = backItem;
    
    [self setupSearchBtn];
}

-(void)setupSearchBtn{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:18.0];
    button.frame = CGRectMake(0, STATUS_BAR_HEIGHT, 64, MAIN_TABBAR_HEIGHT);
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    backImage.center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);
    [button addSubview:backImage];
    [self.view addSubview:button];
}

- (void)searchClick:(UIButton *)button
{    
    SearchNetMusicViewController *kugooViewController = [[SearchNetMusicViewController alloc] init];
    [self.navigationController pushViewController:kugooViewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [self.parentViewController.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}*/

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
