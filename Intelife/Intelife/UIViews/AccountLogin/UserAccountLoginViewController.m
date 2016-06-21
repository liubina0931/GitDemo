//
//  UserAccountLoginViewController.m
//  Intelife
//
//  Created by LiuBin on 5/3/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "UserAccountLoginViewController.h"
#import "CommonUtils.h"
#import "GlobalVariable.h"
#import "JYProgressHud.h"
#import "JYP2PConnect.h"
#import "SignInWaitingViewController.h"


@interface UserAccountLoginViewController ()

@end

@implementation UserAccountLoginViewController
@synthesize textFieldLoginEmail = _textFieldLoginEmail, textFieldLoginPassword = _textFieldLoginPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountLoginMsg:) name:@"AccountLoginMsg" object:nil];
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

- (void)initView {
    //注册点击屏幕手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tapGesture];
    [self.textFieldLoginEmail addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.textFieldLoginPassword addTarget:self action:@selector(textFiledReturnEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (IBAction)btnUserAccountLoginBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnUserAccountLoginClick:(id)sender {
    loginUsername = [CommonUtils removeSpaceAndNewline:self.textFieldLoginEmail.text];
    loginPassword = [CommonUtils removeSpaceAndNewline:self.textFieldLoginPassword.text];
    if (loginUsername.length == 0)
    {
        [JY_PROGRESS_HUD ShowTips:@"The Email is required" delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
    
    if (loginPassword.length == 0)
    {
        [JY_PROGRESS_HUD ShowTips:@"The Password is required" delayTime:SHOWTOAST_TIME atView:self.view];
        return;
    }
    [JY_P2P_INSTANCE clientLoginAccount];
}

- (IBAction)btnForgotPasswordClick:(id)sender {
    
}

- (void)accountLoginMsg:(NSNotification *)notification {
    NSString *loginStatus = (NSString *)notification.object;
    if ([loginStatus isEqualToString:TCP_LOGIN_ACCOUNT_SUCCESS]) {
        DLog("Login Account Successful");
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SignInWaitingViewController *signInWaitingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignInWaitingPage"];
        [self presentViewController:signInWaitingViewController animated:YES completion:nil];
    }
}

- (IBAction)backgroundTap:(id)sender {
    [self.textFieldLoginEmail resignFirstResponder];
    [self.textFieldLoginPassword resignFirstResponder];
}

- (IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

@end
