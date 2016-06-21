//
//  EditDeviceInfoViewController.m
//  Intelife
//
//  Created by LiuBin on 4/26/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "EditDeviceInfoViewController.h"

@interface EditDeviceInfoViewController ()

@end

@implementation EditDeviceInfoViewController

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

- (IBAction)btnEditDeviceInfoBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSaveDeviceInfoClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
