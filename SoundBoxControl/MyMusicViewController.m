//
//  MyMusicViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/13.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "MyMusicViewController.h"
#import "CommonMacro.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LocalMusicListViewController.h"
#import "AFSoundItem.h"
#import "AFSoundManager.h"
#import "GlobalMusicInstance.h"
#import "Constants.h"

@interface MyMusicViewController ()

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSString *localMusicCount;

@end

@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _localMusicCount = [NSString stringWithFormat:@"0%@", @"首"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *count = [ud objectForKey:LOCAL_MUSIC_COUNT];
    if (count){
        NSLog(@"database items count: %@", count);
        _localMusicCount = [NSString stringWithFormat:@"%@%@", count, @"首"];
    }
    
    
    [self setupViews];
    [self initMusicItems];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:animated];
    }
}

-(void)setupViews{
    _table= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _table.tableFooterView = [[UIView alloc] init];
    _table.backgroundColor = [UIColor clearColor];
    [_table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [self.view addSubview:_table];
    
//    _sourceArray = [[NSMutableArray alloc] initWithObjects:@"手机本地", @"音箱本地", nil];
    _sourceArray = [[NSMutableArray alloc] initWithObjects:@"手机本地", nil];
}

-(void)initMusicItems{
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(concurrentQueue, ^{
        NSMutableArray *items =[[NSMutableArray alloc] init];
        
        dispatch_async(concurrentQueue, ^{
            
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            for (MPMediaItemCollection *collection in query.collections) {
                for (MPMediaItem *item in collection.items) {
                    [items addObject:item];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[NSString stringWithFormat:@"%lu", (unsigned long)items.count] forKey:LOCAL_MUSIC_COUNT];
                [ud synchronize];
                
                _localMusicCount = [NSString stringWithFormat:@"%lu%@", (unsigned long)items.count, @"首"];
//                [GlobalMusicInstance sharedSingleton].queue = [[GlobalMusicInstance sharedSingleton].queue initWithItems:items];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [_table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            });
            if (![GlobalMusicInstance sharedSingleton].musicPlayer) {
                [GlobalMusicInstance sharedSingleton].musicPlayer = [[MPMusicPlayerController alloc] init];
            }
            
        });
        
    });
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

    if (indexPath.row == 0) {
        cell.detailTextLabel.text = _localMusicCount;
        [cell.imageView setImage:[UIImage imageNamed:@"icon_local_music"]];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1.0];
    } else if (indexPath.row == 1){
        cell.detailTextLabel.text = @"未连接";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            LocalMusicListViewController *viewController = [[LocalMusicListViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO];

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
