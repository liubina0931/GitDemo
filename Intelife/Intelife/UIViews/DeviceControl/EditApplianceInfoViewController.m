//
//  EditApplianceInfoViewController.m
//  Intelife
//
//  Created by LiuBin on 4/26/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "EditApplianceInfoViewController.h"

@interface EditApplianceInfoViewController ()

@end

@implementation EditApplianceInfoViewController

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

- (IBAction)btnEditApplianceInfoBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSaveApplianceInfoClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
