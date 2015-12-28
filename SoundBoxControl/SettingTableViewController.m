//
//  SettingTableViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ManageDevicesViewController.h"
#import "CheckVersionViewController.h"
#import "FeedbackViewController.h"
#import "HelpViewController.h"

@interface SettingTableViewController ()
@property (nonatomic, strong) NSMutableArray *sourceArray;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    _sourceArray = [[NSMutableArray alloc] initWithObjects:@"音箱设备管理", @"检测升级", @"使用反馈", @"帮助文档", nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.tableView.indexPathForSelectedRow){
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [_sourceArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:48/255.0 green:48/255.0 blue:48/255.0 alpha:1.0];
    UIImage *image = nil;
    switch (indexPath.row) {
        case 0:
            image = [UIImage imageNamed:@"icon_device_manage"];
            break;
        case 1:
            image = [UIImage imageNamed:@"icon_check_version"];
            break;
        case 2:
            image = [UIImage imageNamed:@"icon_feedback"];
            break;
        case 3:
            image = [UIImage imageNamed:@"icon_help"];
            break;
            
        default:
            break;
    }
    if(image != nil)
        [cell.imageView setImage:image];
    if (indexPath.row == 1){
        cell.detailTextLabel.text = @"最新版";
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1.0];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            ManageDevicesViewController *kugooViewController = [[ManageDevicesViewController alloc] init];
            [self.parentViewController.parentViewController.parentViewController.navigationController pushViewController:kugooViewController animated:YES];
        }
            break;
        case 1:
        {
            CheckVersionViewController *kugooViewController = [[CheckVersionViewController alloc] init];
            [self.parentViewController.parentViewController.parentViewController.navigationController pushViewController:kugooViewController animated:YES];
        }
            break;
        case 2:
        {
            FeedbackViewController *kugooViewController = [[FeedbackViewController alloc] init];
            [self.parentViewController.parentViewController.parentViewController.navigationController pushViewController:kugooViewController animated:YES];
        }
            break;
        case 3:
        {
            HelpViewController *kugooViewController = [[HelpViewController alloc] init];
            [self.parentViewController.parentViewController.parentViewController.navigationController pushViewController:kugooViewController animated:YES];
        }
            break;
            default:
            break;
    }
}

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
