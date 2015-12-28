//
//  DiscoveryMusicViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/13.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "DiscoveryMusicViewController.h"
#import "CommonMacro.h"
#import "KugooViewController.h"
#import "QPlayViewController.h"
#import "IntroControll.h"
#import "CategoryTableViewController.h"

@interface DiscoveryMusicViewController ()

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *sourceArray0;

@end

UITableView *table;

@implementation DiscoveryMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
}

-(void)setupViews{
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH - 10, 100)];
//    imageView.image = [UIImage imageNamed:@"IMG_0063.JPG"];
    //    [self.view addSubview:imageView];
    [self createScrollView];
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 142, SCREEN_WIDTH, SCREEN_HEIGHT - 105)];
    [table setDelegate:self];
    [table setDataSource:self];
    table.tableFooterView = [[UIView alloc] init];
    table.backgroundColor = [UIColor clearColor];
    [table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [table setSeparatorInset:UIEdgeInsetsZero];
    table.sectionFooterHeight = 0;
    table.sectionHeaderHeight = 0;
//    [table setSeparatorColor:[UIColor redColor]];
    [self.view addSubview:table];
    
    _sourceArray0 = [[NSMutableArray alloc] initWithObjects:@"胎教", @"有声电台", @"有声读物", nil];
    _sourceArray = [[NSMutableArray alloc] initWithObjects:@"酷狗音乐", @"QQ音乐", nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (table.indexPathForSelectedRow){
        [table deselectRowAtIndexPath:table.indexPathForSelectedRow animated:animated];
    }
}

- (void)createScrollView
{
    
    SGFocusImageItem *item1 = [[SGFocusImageItem alloc] initWithTitle:@"title1" image:[UIImage imageNamed:@"image2.png"] tag:0];
    SGFocusImageItem *item2 = [[SGFocusImageItem alloc] initWithTitle:@"title2" image:[UIImage imageNamed:@"image1.png"] tag:1];
    SGFocusImageItem *item3 = [[SGFocusImageItem alloc] initWithTitle:@"title3" image:[UIImage imageNamed:@"image0.png"] tag:2];
//    SGFocusImageItem *item4 = [[SGFocusImageItem alloc] initWithTitle:@"title4" image:[UIImage imageNamed:@"image3.png"] tag:4];
    
    SGFocusImageFrame *bottomImageFrame = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 142.0) delegate:self focusImageItems:item1, item2, item3, nil];
    bottomImageFrame.autoScrolling = YES;
    [self.view addSubview:bottomImageFrame];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    /*
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"" description:@"" image:@"image3.png"];
    
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"" description:@"" image:@"image2.png"];
    
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"" description:@"" image:@"image0.png"];
    
    IntroControll  * scrollView = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150) pages:@[model1, model2, model3]];
    [self.view addSubview:scrollView];
     */
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _sourceArray0.count;
        case 1:
            return _sourceArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) return 0;
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImage *image = nil;
    
    if (indexPath.section == 0){
        image = [UIImage imageNamed:@"icon_home_music_res"];
        [cell.imageView setImage:image];
        
        cell.textLabel.text = [_sourceArray0 objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.text = @"";
        switch (indexPath.row) {
            case 0:
                image = [UIImage imageNamed:@"taijiao"];
                break;
            case 1:
                image = [UIImage imageNamed:@"diantai"];
                break;
            case 2:
                image = [UIImage imageNamed:@"duwu"];
                break;
                
            default:
                break;
        }
        if(image != nil)
            [cell.imageView setImage:image];
        
        return cell;
    }
    
    switch (indexPath.row) {
        case 0:
            image = [UIImage imageNamed:@"icon_kugoo"];
            break;
        case 1:
            image = [UIImage imageNamed:@"icon_qq"];
            break;
        case 2:
            image = [UIImage imageNamed:@"icon_xiami"];
            break;
        case 3:
            image = [UIImage imageNamed:@"icon_ximalaya"];
            break;
            
        default:
            break;
    }
    if(image != nil)
        [cell.imageView setImage:image];
    
    cell.textLabel.text = [_sourceArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.detailTextLabel.text = @"";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        CategoryTableViewController *kugooViewController = [[CategoryTableViewController alloc] init];
        kugooViewController.titleStr = _sourceArray0[indexPath.row];
        switch (indexPath.row) {
            case 0:
            {
                kugooViewController.getDataUrl = @"http://yinyue.kuwo.cn/yy/cate_71.htm";
            }
                break;
            case 1:
            {
                kugooViewController.getDataUrl = @"http://yinyue.kuwo.cn/yy/cate_78519.htm";
            }
                break;
            case 2:
            {
                kugooViewController.getDataUrl = @"http://yinyue.kuwo.cn/yy/cate_17250.htm";
            }
                break;
        }
        [self.navigationController pushViewController:kugooViewController animated:YES];
        [self.navigationController setNavigationBarHidden:NO];
        
        return;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            KugooViewController *kugooViewController = [[KugooViewController alloc] init];
            [self.navigationController pushViewController:kugooViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO];
        }
            break;
        case 1:
        {
            QPlayViewController *qqViewController = [[QPlayViewController alloc] init];
            [self.navigationController pushViewController:qqViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO];
        }
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
