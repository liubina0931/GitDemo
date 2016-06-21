//
//  MainViewController.m
//  Intelife
//
//  Created by LiuBin on 5/3/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize scrollIntroduce = _scrollIntroduce;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    self.scrollIntroduce.contentSize = CGSizeMake(SCREEN_WIDTH * 4, 180);
    NSString *introduceString = @"Control your home automation from your mobile device and operate your aircon,TV and lighting.";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2; //行距
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:paragraphStyle};
    UITextView *textView1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.scrollIntroduce.frame.size.width, self.scrollIntroduce.frame.size.height)];
    textView1.attributedText = [[NSAttributedString alloc]initWithString: introduceString attributes:attributes];
    textView1.textAlignment = NSTextAlignmentCenter;
    textView1.editable = NO;
    UITextView *textView2 = [[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, self.scrollIntroduce.frame.size.width, self.scrollIntroduce.frame.size.height)];
    textView2.attributedText = [[NSAttributedString alloc]initWithString: introduceString attributes:attributes];
    textView2.textAlignment = NSTextAlignmentCenter;
    textView2.editable = NO;
    UITextView *textView3 = [[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, self.scrollIntroduce.frame.size.width, self.scrollIntroduce.frame.size.height)];
    textView3.attributedText = [[NSAttributedString alloc]initWithString: introduceString attributes:attributes];
    textView3.textAlignment = NSTextAlignmentCenter;
    textView3.editable = NO;
    UITextView *textView4 = [[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 3, 0, self.scrollIntroduce.frame.size.width, self.scrollIntroduce.frame.size.height)];
    textView4.attributedText = [[NSAttributedString alloc]initWithString: introduceString attributes:attributes];
    textView4.textAlignment = NSTextAlignmentCenter;
    textView4.editable = NO;
    [self.scrollIntroduce addSubview:textView1];
    [self.scrollIntroduce addSubview:textView2];
    [self.scrollIntroduce addSubview:textView3];
    [self.scrollIntroduce addSubview:textView4];
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
