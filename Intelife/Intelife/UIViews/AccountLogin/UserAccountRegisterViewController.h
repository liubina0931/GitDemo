//
//  UserAccountRegisterViewController.h
//  Intelife
//
//  Created by LiuBin on 5/3/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAccountRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRegistEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRegistPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldConfirmPassword;

- (IBAction)btnUserAccountRegisterBackClick:(id)sender;
- (IBAction)btnUserAccountRegisterClick:(id)sender;

@end
