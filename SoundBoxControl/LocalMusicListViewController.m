//
//  LocalMusicListViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "LocalMusicListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NowPlayingViewController.h"
#import "GlobalMusicInstance.h"
#import "AFSoundManager.h"
#import "CommonMacro.h"
#import "NameIndex.h"
#import "iToast.h"
#import "LayoutParameters.h"
#include "pinyin.h"

static NSString *const kCellIdentifier = @"kCellIdentifierLocal";

@interface LocalMusicListViewController ()

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSDictionary *nameDic;
@property (nonatomic, retain) NSArray *keys;

@end

NSMutableArray *myItems;
NSMutableArray * existTitles;
NSMutableArray * musicArrays;
NSInteger lastRow = -1;
NSInteger lastSection = -1;
MPMediaItem *nowPlayingItemTmp;
NSOperationQueue *playOperation;

@implementation LocalMusicListViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        // Lets create some dummy Data
        _nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                     [[NSMutableArray alloc] init],@"A",
                     [[NSMutableArray alloc] init],@"B",
                     [[NSMutableArray alloc] init],@"C",
                     [[NSMutableArray alloc] init],@"D",
                     [[NSMutableArray alloc] init],@"E",
                     [[NSMutableArray alloc] init],@"F",
                     [[NSMutableArray alloc] init],@"G",
                     [[NSMutableArray alloc] init],@"H",
                     [[NSMutableArray alloc] init],@"I",
                     [[NSMutableArray alloc] init],@"J",
                     [[NSMutableArray alloc] init],@"K",
                     [[NSMutableArray alloc] init],@"L",
                     [[NSMutableArray alloc] init],@"M",
                     [[NSMutableArray alloc] init],@"N",
                     [[NSMutableArray alloc] init],@"O",
                     [[NSMutableArray alloc] init],@"P",
                     [[NSMutableArray alloc] init],@"Q",
                     [[NSMutableArray alloc] init],@"R",
                     [[NSMutableArray alloc] init],@"S",
                     [[NSMutableArray alloc] init],@"T",
                     [[NSMutableArray alloc] init],@"U",
                     [[NSMutableArray alloc] init],@"V",
                     [[NSMutableArray alloc] init],@"W",
                     [[NSMutableArray alloc] init],@"X",
                     [[NSMutableArray alloc] init],@"Y",
                     [[NSMutableArray alloc] init],@"Z",
                     [[NSMutableArray alloc] init],@"#",
                     nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label setText:@"手机本地"];
    [self.view addSubview:label];
    
    [self.navigationController.navigationBar.topItem setTitleView:label];
    
//    [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [self.view setBackgroundColor:APP_THEME_COLOR];//[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = backItem;
    
//    self.navigationController.navigationBar.hidden = YES;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    _table= [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _table.tableFooterView = [[UIView alloc] init];
    _table.contentInset = UIEdgeInsetsMake(-64, 0, 64, 0);
    _table.backgroundColor = [UIColor whiteColor];
    _table.sectionIndexBackgroundColor = [UIColor clearColor];//[UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1.0];
    _table.sectionIndexColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0];
    [_table setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [_table setSeparatorInset:UIEdgeInsetsZero];
    
    [self.view addSubview:_table];
    
    nowPlayingItemTmp = [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
    
    [self initMusicItems];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:animated];
    }
    if(_table && lastRow >=0 && lastSection >= 0)
        [_table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:lastRow inSection:lastSection], nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updatePlayingItem];
}

-(void)updatePlayingItem{
    
//    [self initMusicItems];
    //    [_table reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) getFirstName:(NSString *)name {
    if ([name canBeConvertedToEncoding: NSASCIIStringEncoding]) {//如果是英文
        return [NSString stringWithFormat:@"%c",[name characterAtIndex:0]];;
    }
    else { //如果是非英文
        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([name characterAtIndex:0])];
    }
}


#pragma mark - Table view data source

-(void)initMusicItems{
    myItems = [[NSMutableArray alloc] init];
    _items =[[NSMutableArray alloc] init];
    
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    for (MPMediaItemCollection *collection in query.collections) {
        for (MPMediaItem *item in collection.items) {
            NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
            AFSoundItem *item1 = [[AFSoundItem alloc] init];
            
            item1.title = [item valueForProperty:MPMediaItemPropertyTitle];
            item1.URL = [item valueForProperty:MPMediaItemPropertyAssetURL];
            item1.mMPMediaItem = item;
//                        NSLog(@"%@: %@", title, [self getFirstName:title].uppercaseString);
            NSString *key = [self getFirstName:title].uppercaseString;
            NSArray *tmp = [_nameDic objectForKey:key];
            if (tmp == nil){
                tmp = [[NSMutableArray alloc] init];
            }
            
            [tmp addObject:item];
//            [_nameDic setValue:tmp forKey:key];
            
            
            [myItems addObject:item1];
            
            
            [_items addObject:item];
        }
    }
    
    existTitles = [NSMutableArray array];
    musicArrays = [[NSMutableArray alloc] init];
    NSArray *keys = [_nameDic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *key in sortedArray){
        NSMutableArray *array = _nameDic[key];
        if (array.count > 0){
            [existTitles addObject:key];
            [musicArrays addObject:array];
        }
    }
    
    if ([existTitles containsObject:@"#"]){
        [existTitles removeObject:@"#"];
        NSMutableArray *array = musicArrays[0];
        [musicArrays removeObjectAtIndex:0];
        [existTitles addObject:@"#"];
        [musicArrays addObject:array];
    }
    
    [_items removeAllObjects];
    
    for (NSMutableArray *array in musicArrays) {
        for (MPMediaItem *item in array){
            [_items addObject:item];
        }
    }
    /*
    [GlobalMusicInstance sharedSingleton].musicPlayer = [[MPMusicPlayerController alloc] init];

    if ([GlobalMusicInstance sharedSingleton].mediaCollection){
//    [GlobalMusicInstance sharedSingleton].queue = [[GlobalMusicInstance sharedSingleton].queue initWithItems:myItems];
     
     */
    MPMediaItemCollection *mic = [[MPMediaItemCollection alloc] initWithItems:_items];
    
    [GlobalMusicInstance sharedSingleton].mediaCollection = mic;
    
    if (![GlobalMusicInstance sharedSingleton].musicPlayer) {
        [GlobalMusicInstance sharedSingleton].musicPlayer = [MPMusicPlayerController systemMusicPlayer];//[[MPMusicPlayerController alloc] init];
    }
    
    
    [[GlobalMusicInstance sharedSingleton].musicPlayer setQueueWithItemCollection:mic];
    [[GlobalMusicInstance sharedSingleton].musicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [[GlobalMusicInstance sharedSingleton].musicPlayer setRepeatMode:MPMusicRepeatModeAll];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = existTitles[section];
    NSMutableArray *array = musicArrays[section];
    
    return array.count;//_items.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = musicArrays[indexPath.section];
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
//    AFSoundItem *item = _items[indexPath.row];
    MPMediaItem *item1 = array[indexPath.row];//_items[indexPath.row];
    
    cell.textLabel.text = [item1 title];//item.title;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    cell.detailTextLabel.text = [item1 artist];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    
    MPMediaItem *nowPlayingItem = [GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
    if ((nowPlayingItemTmp != nil && [[NSString stringWithFormat:@"%@" , [item1 valueForProperty:MPMediaItemPropertyPersistentID]] isEqualToString:[NSString stringWithFormat:@"%@" , [nowPlayingItemTmp valueForProperty:MPMediaItemPropertyPersistentID]]])
        ) {
    
        UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 5, 49)];//cell.contentView.bounds.size.height - 2)];
        indicator.backgroundColor = APP_THEME_COLOR;//[UIColor colorWithRed:236/255.0 green:100/255.0 blue:0 alpha:1.0];
        indicator.tag = 888;
        
        [cell.contentView addSubview:indicator];
        lastRow = indexPath.row;
        lastSection = indexPath.section;
    } else {
        if ([cell.contentView viewWithTag:888]){
            [cell.contentView viewWithTag:888].hidden = YES;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    [GlobalMusicInstance sharedSingleton].queue = [[GlobalMusicInstance sharedSingleton].queue initWithItems:myItems];
    [[GlobalMusicInstance sharedSingleton].queue playItem:(AFSoundItem *)myItems[indexPath.row]];
    AFSoundItem *item = myItems[indexPath.row];
    
    NowPlayingViewController *viewController = [[NowPlayingViewController alloc] init];
    
    viewController.playingMediaItem =item.mMPMediaItem;
    
    [self.navigationController pushViewController:viewController animated:YES];
     */
    
//    [GlobalMusicInstance sharedSingleton].queue = nil;
    /*
    MPMediaItemCollection *mic = [[MPMediaItemCollection alloc] initWithItems:_items];
    
    [GlobalMusicInstance sharedSingleton].mediaCollection = mic;
//    [GlobalMusicInstance sharedSingleton].musicPlayer = [[MPMusicPlayerController alloc] init];    
    [[GlobalMusicInstance sharedSingleton].musicPlayer setQueueWithItemCollection:mic];
    [[GlobalMusicInstance sharedSingleton].musicPlayer setRepeatMode:MPMusicRepeatModeAll];
    */
    
    NSMutableArray *array = musicArrays[indexPath.section];
    
    [GlobalMusicInstance sharedSingleton].netArray = _items;
    [GlobalMusicInstance sharedSingleton].selectedIndex = indexPath.section + indexPath.row;
    MPMediaItem *selectedItem = array[indexPath.row];
    /*
    MPMediaItem *nowPlayingItem =[GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
            if (nowPlayingItem == nil) {
                [[GlobalMusicInstance sharedSingleton].musicPlayer setNowPlayingItem:array[indexPath.row]];
                [[GlobalMusicInstance sharedSingleton].musicPlayer play];
            } else if ([selectedItem valueForProperty:MPMediaItemPropertyPersistentID]  == [nowPlayingItem valueForProperty:MPMediaItemPropertyPersistentID]) {
                if ([GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePaused) {
                    [[GlobalMusicInstance sharedSingleton].musicPlayer play];
                }
            } else {
                [[GlobalMusicInstance sharedSingleton].musicPlayer setNowPlayingItem:array[indexPath.row]];
                [[GlobalMusicInstance sharedSingleton].musicPlayer play];
            }
    */
    
    nowPlayingItemTmp = selectedItem;
    /*
    MPMediaItem *nowPlayingItem =[GlobalMusicInstance sharedSingleton].musicPlayer.nowPlayingItem;
    if (nowPlayingItem == nil) {
        [[GlobalMusicInstance sharedSingleton].musicPlayer setNowPlayingItem:array[indexPath.row]];
    } else if ([selectedItem valueForProperty:MPMediaItemPropertyPersistentID]  == [nowPlayingItem valueForProperty:MPMediaItemPropertyPersistentID]) {
        if ([GlobalMusicInstance sharedSingleton].musicPlayer.playbackState == MPMusicPlaybackStatePaused) {
            
        }
    } else {
        [[GlobalMusicInstance sharedSingleton].musicPlayer setNowPlayingItem:array[indexPath.row]];
    }
    */
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(clickItem:) withObject:selectedItem afterDelay:0.2f];
    
    if(lastRow >=0 && lastSection >=0)
        [_table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:lastRow inSection:lastSection], nil] withRowAnimation:UITableViewRowAnimationNone];
    
    [_table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    lastRow = indexPath.row;
    lastSection = indexPath.section;
    
    if (_table.indexPathForSelectedRow){
        [_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:YES];
    }
    
    //    [self.parentViewController.navigationController setNavigationBarHidden:NO];
    lastRow = indexPath.row;
    lastSection = indexPath.section;
//    [self.parentViewController.navigationController pushViewController:viewController animated:YES];
}

-(void)clickItem:(MPMediaItem *)item{
    if(playOperation == nil){
        playOperation = [[NSOperationQueue alloc] init];
        [playOperation setMaxConcurrentOperationCount:1];
    }
    
    [playOperation cancelAllOperations];
    
    [playOperation addOperationWithBlock:^{
        if([GlobalMusicInstance sharedSingleton].nowPlayingViewController == nil)
            [GlobalMusicInstance sharedSingleton].nowPlayingViewController = [[NowPlayingViewController alloc] init];
        [GlobalMusicInstance sharedSingleton].nowPlayingViewController.playingMediaItem = item;
        [[GlobalMusicInstance sharedSingleton].nowPlayingViewController playLocal:item];
    }];
}

-(void)deselectMyItem{
    
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return existTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return existTitles.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 1, 90, 22)];
    titleLabel.textColor = APP_THEME_COLOR;//[UIColor colorWithRed:236/255.0 green:100/255.0 blue:0 alpha:1.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0f];
    titleLabel.text = existTitles[section];
    [myView addSubview:titleLabel];
    
    return myView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [[[iToast makeText:existTitles[index]] setGravity:iToastMyPosition] show];
    return index;
}

@end
