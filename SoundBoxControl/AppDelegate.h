//
//  AppDelegate.h
//  SoundBoxControl
//
//  Created by neldtv on 15/3/5.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL *isReachable;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL *isReachable;

@end

