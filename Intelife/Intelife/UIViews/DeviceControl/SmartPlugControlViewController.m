//
//  SmartPlugControlViewController.m
//  Intelife
//
//  Created by LiuBin on 4/26/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "SmartPlugControlViewController.h"
#import "CurrentPowerViewController.h"
#import "TotalPowerViewController.h"


@interface SmartPlugControlViewController ()

@end

@implementation SmartPlugControlViewController
@synthesize scrollView = _scrollView, segmentSwitch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    1.初次创建：
    segmentSwitch=[[LFLUISegmentedControl alloc]initWithFrame:CGRectMake(0, 250, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    segmentSwitch.delegate = self;
    //   2.设置显示切换标题数组
    NSArray* LFLarray=[NSArray arrayWithObjects:@"DAILY",@"MONTHLY",nil];
    [segmentSwitch AddSegumentArray:LFLarray];
    //   default Select the Button
    [segmentSwitch selectTheSegument:0];
    [self.view addSubview:segmentSwitch];
    [self createMainScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建正文ScrollView内容
- (void)createMainScrollView {
//    [self.view addSubview:self.mainScrollView];
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, 200);
    //设置代理
    self.scrollView.delegate = self;
    UIStoryboard *deviceStoryboard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    CurrentPowerViewController *currentPowerViewController = [deviceStoryboard instantiateViewControllerWithIdentifier:@"CurrentPowerView"];
    currentPowerViewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 300);
    TotalPowerViewController *totalPowerViewController = [deviceStoryboard instantiateViewControllerWithIdentifier:@"TotalPowerView"];
    totalPowerViewController.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, 300);
    [self.scrollView addSubview:currentPowerViewController.view];
    [self.scrollView addSubview:totalPowerViewController.view];
//    //添加滚动显示的三个对应的界面view
//    for (int i = 0; i < 2; i++) {
//        UIView *viewExample = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WITH *i, 0, SCREEN_WITH,SCREEN_HEIGHT)];
//        viewExample.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
//        [self.scrollView addSubview:viewExample];
//    }
}

#pragma mark --- UIScrollViewDelegate

static NSInteger pageNumber = 0;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    pageNumber = (int)(scrollView.contentOffset.x / SCREEN_WIDTH + 0.5);
    //    滑动SV里视图,切换标题
    [self.segmentSwitch selectTheSegument:pageNumber];
}

#pragma mark ---LFLUISegmentedControlDelegate
/**
 *  点击标题按钮
 *
 *  @param selection 对应下标 begain 0
 */
-(void)uisegumentSelectionChange:(NSInteger)selection{
    //    加入动画,显得不太过于生硬切换
    [UIView animateWithDuration:.2 animations:^{
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH *selection, 0)];
    }];
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
