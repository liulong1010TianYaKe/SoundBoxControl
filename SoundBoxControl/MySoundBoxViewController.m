//
//  MySoundBoxViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "MySoundBoxViewController.h"
#import "CommonMacro.h"
#import "GuaidSettingStep1ViewController.h"

@interface MySoundBoxViewController ()
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *sourceArray;

@end

@implementation MySoundBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _table= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _table.tableFooterView = [[UIView alloc] init];
    _table.backgroundColor = [UIColor clearColor];
    [_table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [self.view addSubview:_table];
    
    //    _sourceArray = [[NSMutableArray alloc] initWithObjects:@"手机本地", @"音箱本地", nil];
    _sourceArray = [[NSMutableArray alloc] initWithObjects:@"连接／添加音乐设备", nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:animated];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [_sourceArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    [cell.imageView setImage:[UIImage imageNamed:@"icon_add_device"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            GuaidSettingStep1ViewController *guaidSetting = [self.parentViewController.parentViewController.parentViewController.navigationController.storyboard instantiateViewControllerWithIdentifier:@"guaidSettingstep1"];
            guaidSetting.isFromMainPage = YES;
            [self.parentViewController.parentViewController.parentViewController.navigationController pushViewController:guaidSetting animated:YES];
        }
            break;
            
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
