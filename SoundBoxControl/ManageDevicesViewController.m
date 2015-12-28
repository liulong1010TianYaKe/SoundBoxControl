//
//  ManageDevicesViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/1.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "ManageDevicesViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "Constants.h"

@implementation ManageDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupViews];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setupViews{
    self.view.backgroundColor = APP_THEME_COLOR;//[UIColor colorWithRed:16/255.0 green:15/255.0 blue:15/255.0 alpha:1.0];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    
    UIImage *bottombg = [UIImage imageNamed:@"bottombg"];
    [titleView setBackgroundColor:APP_THEME_COLOR];//[UIColor colorWithPatternImage:[self imageWithImage:bottombg scaledToSize:CGSizeMake(SCREEN_WIDTH, titleView.bounds.size.height)]]];
    
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleL.textColor = [UIColor whiteColor];
    titleL.textAlignment = UITextAlignmentCenter;
    titleL.center = CGPointMake(SCREEN_WIDTH/2, titleView.bounds.size.height/2);
    [titleL setText:@"音箱设备管理"];
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
    
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    pageView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [self.view addSubview:pageView];
    
    UITableView *table= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [table setDelegate:self];
    [table setDataSource:self];
    table.tableFooterView = [[UIView alloc] init];
    table.backgroundColor = [UIColor clearColor];
    [table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [table setSeparatorInset:UIEdgeInsetsZero];
    [pageView addSubview:table];
}

-(void)back:(id *)sender{
    [self.navigationController popViewControllerAnimated:YES];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, cell.contentView.bounds.size.height)];
    label.center = CGPointMake(62, cell.contentView.bounds.size.height/2);
    label.font = [UIFont systemFontOfSize:15.0f];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, cell.contentView.bounds.size.height)];
    label2.center = CGPointMake(150, cell.contentView.bounds.size.height/2);
    label2.font = [UIFont systemFontOfSize:15.0f];
    label2.textColor = [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1.0];
    
    switch (indexPath.row) {
        case 0:
        {
            label.text = @"设备名称：";
            label2.text = @"HomeMusic";
        }
            break;
        case 1:
        {
            label.text = @"加密方式：";
            label2.text = @"不加密";
        }
            
            break;
        case 2:
        {
            label.text = @"IP地址：";
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            label2.text = [ud objectForKey:DEVICE_HOT_IP_NAME];
        }
            
            break;
        case 3:
        {
            label.text = @"APP版本：";
            label2.text = @"V1.1";
        }
            
            break;
        case 4:
        {
            label.text = @"MAC地址：";
            label2.text = @"845DD7A0A6BB";
        }
            
            break;
            
        default:
            break;
    }
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:label2];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}


@end
