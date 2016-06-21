//
//  UserAccountRegisterViewController.m
//  Intelife
//
//  Created by LiuBin on 5/3/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "UserAccountRegisterViewController.h"
#import "CommonConfig.h"

@interface UserAccountRegisterViewController ()

@end

@implementation UserAccountRegisterViewController
@synthesize textFieldFirstName = _textFieldFirstName, textFieldLastName = _textFieldLastName, textFieldRegistEmail = _textFieldRegistEmail, textFieldRegistPassword = _textFieldRegistPassword, textFieldConfirmPassword = _textFieldConfirmPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTempKeyMsg:) name:@"GetTempKeyMsg" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getTempKeyMsg:(NSNotification *)notification {
    NSString *getTempKeyFlag = (NSString *)[notification object];
    NSString *username = [CommonUtils removeSpaceAndNewline:self.textFieldRegistEmail.text];
    NSString *password = [CommonUtils removeSpaceAndNewline:self.textFieldRegistPassword.text];
    NSString *registEmail = [CommonUtils removeSpaceAndNewline:self.textFieldRegistEmail.text];
    NSMutableArray *tempEmailArray = (NSMutableArray *)[username componentsSeparatedByString:@"@"];
    username = (NSString *)[tempEmailArray objectAtIndex:0];
    if ((tempKeyType == TYPE_TEMP_KEY_REGIST) && [getTempKeyFlag isEqualToString:GET_UDP_TEMP_KEY_SUCCESS]) {
        [JY_P2P_INSTANCE registAccountwithUserName:username withPassword:password withEmail:registEmail];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initView {
    //注册点击屏幕手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tapGesture];
    [self.textFieldRegistEmail addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.textFieldRegistPassword addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.textFieldFirstName addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.textFieldLastName addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.textFieldConfirmPassword addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (IBAction)btnUserAccountRegisterBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnUserAccountRegisterClick:(id)sender {
    NSString *username = [CommonUtils removeSpaceAndNewline:self.textFieldRegistEmail.text];
    NSString *password = [CommonUtils removeSpaceAndNewline:self.textFieldRegistPassword.text];
    NSString *confirmPassword = [CommonUtils removeSpaceAndNewline:self.textFieldConfirmPassword.text];
    NSString *registEmail = [CommonUtils removeSpaceAndNewline:self.textFieldRegistEmail.text];
    NSMutableArray *tempEmailArray = (NSMutableArray *)[username componentsSeparatedByString:@"@"];
    username = (NSString *)[tempEmailArray objectAtIndex:0];
    if (username.length == 0) {
        [JY_PROGRESS_HUD ShowTips:@"Email is required." delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
    if (password.length == 0) {
        [JY_PROGRESS_HUD ShowTips:@"Password is required." delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
    if (confirmPassword.length == 0) {
        [JY_PROGRESS_HUD ShowTips:@"Confirm Password is required." delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
    if (registEmail.length == 0) {
        [JY_PROGRESS_HUD ShowTips:@"Email is required." delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
    if(![password isEqualToString:confirmPassword]) {
        [JY_PROGRESS_HUD ShowTips:@"Password and confirm password is not equal." delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
//    if (![CommonUtils isValidateEmail:registEmail]) {
//        [JY_PROGRESS_HUD ShowTips:@"Email is required." delayTime:SHOWTOAST_TIME atView:self.view];
//        return;
//    }
    tempKeyType = TYPE_TEMP_KEY_REGIST;
//    [JY_NETWORK_INSTANCE creatTcpConnect:SERVER_IP port:SERVER_PORT];
    [JY_P2P_INSTANCE getUdpTempLoginKey];
//    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)backgroundTap:(id)sender {
    [self.textFieldFirstName resignFirstResponder];
    [self.textFieldLastName resignFirstResponder];
    [self.textFieldRegistEmail resignFirstResponder];
    [self.textFieldRegistPassword resignFirstResponder];
    [self.textFieldConfirmPassword resignFirstResponder];
}

- (IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

@end
