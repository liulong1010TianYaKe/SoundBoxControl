//
//  OnLineMusicTableViewController.h
//  SoundBoxControl
//
//  Created by neldtv on 15/4/10.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnLineMusicTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString  *titleStr;
@property (nonatomic, strong) NSString  *getDataUrl;

@end
