//
//  GuidSettingViewController.h
//  SoundBoxControl
//
//  Created by neldtv on 15/3/14.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface GuidSettingViewController : UIViewController<GCDAsyncSocketDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property(strong)  GCDAsyncSocket *socket;

@property (nonatomic) BOOL isFromHotPage;
//- (IBAction)send:(id)sender;

@end
