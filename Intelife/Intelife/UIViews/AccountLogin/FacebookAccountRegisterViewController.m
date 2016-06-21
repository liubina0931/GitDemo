//
//  FacebookAccountRegisterViewController.m
//  Intelife
//
//  Created by LiuBin on 5/3/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "FacebookAccountRegisterViewController.h"

@interface FacebookAccountRegisterViewController ()

@end

@implementation FacebookAccountRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)btnFacebookRegisterCancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnFacebookRegisterOKClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
