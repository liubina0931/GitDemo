//
//  SignInWaitingViewController.m
//  Intelife
//
//  Created by LiuBin on 16-4-21.
//  Copyright (c) 2016年 richdataco. All rights reserved.
//

#import "SignInWaitingViewController.h"
#import "HomePageViewController.h"


@interface SignInWaitingViewController ()

@end

@implementation SignInWaitingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeToNavigate) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timeToNavigate {
    DLog(@"Jump to home page");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomePageViewController *homePageViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePage"];
    [self presentViewController:homePageViewController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
