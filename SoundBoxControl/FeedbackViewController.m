//
//  FeedbackViewController.m
//  SoundBoxControl
//
//  Created by neldtv on 15/4/1.
//  Copyright (c) 2015年 neldtv. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CommonMacro.h"
#import "LayoutParameters.h"
#import "UIPlaceHolderTextView.h"
#import "iToast.h"

@implementation FeedbackViewController

UIPlaceHolderTextView *contentFile;
UIPlaceHolderTextView *contactField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupViews];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [textView.layer setBorderColor: APP_THEME_COLOR.CGColor];
    
    if (textView.tag == 101){
        NSTimeInterval animationDuration=0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = contactField.frame.size.width;
        float height = contactField.frame.size.height;
        //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
        float Y = 15.0f;
        CGRect rect=CGRectMake(10.0f,Y,width,height);
        contactField.frame=rect;
        [UIView commitAnimations];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView.layer setBorderColor: [UIColor clearColor].CGColor];
    if (textView.tag == 101){
        NSTimeInterval animationDuration=0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = contactField.frame.size.width;
        float height = contactField.frame.size.height;
        //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
        float Y = 350.0f - height/2;
        CGRect rect=CGRectMake(10.0f,Y,width,height);
        contactField.frame=rect;
        [UIView commitAnimations];
    }
}

-(void)setupViews{
    self.view.backgroundColor = APP_THEME_COLOR;//[UIColor colorWithRed:16/255.0 green:15/255.0 blue:15/255.0 alpha:1.0];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    
    [titleView setBackgroundColor:APP_THEME_COLOR];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleL.textColor = [UIColor whiteColor];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.center = CGPointMake(SCREEN_WIDTH/2, titleView.bounds.size.height/2);
    [titleL setText:@"用户反馈"];
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
    
    contentFile = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 255)];
    contentFile.center = CGPointMake(SCREEN_WIDTH/2, 140);
    contentFile.textColor = [UIColor blackColor];
    contentFile.backgroundColor = [UIColor whiteColor];
    contentFile.font = [UIFont systemFontOfSize:15.0f];
    contentFile.layer.cornerRadius = 5.0;
    contentFile.layer.borderWidth = 1.0;
    contentFile.tag = 100;
    contentFile.delegate = self;
    [contentFile.layer setBorderColor: [UIColor clearColor].CGColor];
    contentFile.placeholder = @"十分感谢您的意见与建议，请输入您的反馈信息。";
    [pageView addSubview:contentFile];
    
    contactField = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 130)];
    contactField.center = CGPointMake(SCREEN_WIDTH/2, 350);
    contactField.textColor = [UIColor blackColor];
    contactField.backgroundColor = [UIColor whiteColor];
    contactField.font = [UIFont systemFontOfSize:15.0f];
    contactField.layer.cornerRadius = 5.0;
    contactField.layer.borderWidth = 1;
    contactField.tag = 101;
    contactField.delegate = self;
    [contactField.layer setBorderColor: [UIColor clearColor].CGColor];
    contactField.placeholder = @"请输入您的联系方式（手机或邮箱）。";
    [pageView addSubview:contactField];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(45, 440, 80, 38)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = APP_THEME_COLOR;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    [button.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45 - 80, 440, 80, 38)];
    [button2 setTitle:@"确认" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button2.backgroundColor = APP_THEME_COLOR;
    button2.titleLabel.textAlignment = NSTextAlignmentCenter;
    button2.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button2.layer.cornerRadius = 5.0;
    button2.layer.borderWidth = 1.0;
    [button2.layer setBorderColor: APP_THEME_COLOR.CGColor];
    [button2 addTarget:self action:@selector(sendMail:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button2];
    
    
    UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *barbutton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *barbutton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    
    NSArray *buttonsArray = [NSArray arrayWithObjects:barbutton1, barbutton2, doneBtn, nil];
    [topView setItems:buttonsArray];
    [contactField setInputAccessoryView:topView];
    [contentFile setInputAccessoryView:topView];
}

-(IBAction)dismissKeyBoard{
    [contentFile resignFirstResponder];
    [contactField resignFirstResponder];
}

-(void)sendMail:(id *)sender{
    
    if(contentFile.text.length == 0){
        [[[iToast makeText:@"请输入反馈信息!"] setGravity:iToastGravityBottom] show];
        return;
    }
    
    if(contactField.text.length == 0){
        [[[iToast makeText:@"请输入联系方式!"] setGravity:iToastGravityBottom] show];
        return;
    }
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"eMail主题"];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"ychuang@neldtv.org"];
    //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com", nil];
    [mailPicker setToRecipients: toRecipients];
    //[picker setCcRecipients:ccRecipients];
    //[picker setBccRecipients:bccRecipients];
    
    NSString *emailBody = [self _feedbackBody];
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController: mailPicker animated:YES];
    [mailPicker release];
}

- (NSString*)_feedbackSubject
{
    return [NSString stringWithFormat:@"%@: %@", @"HomeMusic", @"Feedback", nil];
}

- (NSString*)_feedbackBody
{
//    NSString *body = [NSString stringWithFormat:@"%@\n\n\nDevice:\n%@\n\niOS:\n%@\n\nApp:\n%@ %@",
//                      contentFile.text,
//                      [self _platformString],
//                      [UIDevice currentDevice].systemVersion,
//                      [self _appName],
//                      [self _appVersion], nil];
    
    return contentFile.text;
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


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            [self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void) alertWithTitle: (NSString *)_title_ msg: (NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title_
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


@end
