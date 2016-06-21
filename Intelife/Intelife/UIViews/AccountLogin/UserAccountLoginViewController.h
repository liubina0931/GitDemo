//
//  UserAccountLoginViewController.h
//  Intelife
//
//  Created by LiuBin on 5/3/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAccountLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textFieldLoginEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLoginPassword;

- (IBAction)btnUserAccountLoginBackClick:(id)sender;
- (IBAction)btnUserAccountLoginClick:(id)sender;
- (IBAction)btnForgotPasswordClick:(id)sender;

@end
