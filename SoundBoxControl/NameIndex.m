//
//  NameIndex.m
//  SoundBoxControl
//
//  Created by neldtv on 15/3/27.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "NameIndex.h"

@implementation NameIndex
@synthesize _firstName, _lastName;
@synthesize _sectionNum, _originIndex;
@synthesize mMPMediaItem;

- (NSString *) getFirstName {
    if ([_firstName canBeConvertedToEncoding: NSASCIIStringEncoding]) {//如果是英文
        return _firstName;
    }
    else { //如果是非英文
        return @"";//[NSString stringWithFormat:@"%c",pinyinFirstLetter([_firstName characterAtIndex:0])];
    }
    
}
- (NSString *) getLastName {
    if ([_lastName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return _lastName;
    }
    else {
        return @"";//[NSString stringWithFormat:@"%c",pinyinFirstLetter([_lastName characterAtIndex:0])];
    }
    
}
- (void)dealloc {
    [_firstName release];
    [_lastName release];
    [super dealloc];
}
@end
