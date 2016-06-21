//
//  LandingViewController.m
//  Intelife
//
//  Created by LiuBin on 16-6-2.
//  Copyright (c) 2016年 richdataco. All rights reserved.
//

#import "LandingViewController.h"

@interface LandingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageLandingRound;

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
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
    NSMutableArray *starImageArray = [@[] mutableCopy];
    for (int i = 0; i < 26; i++) {
        NSString *imageName = [NSString stringWithFormat:@"logo_%d", i];
        UIImage *starImage = [UIImage imageNamed:imageName];
        [starImageArray addObject:starImage];
    }
    self.imageLandingRound.animationImages = starImageArray;
    self.imageLandingRound.animationRepeatCount = 1;
    self.imageLandingRound.animationDuration = 0.867;
    
    self.imageLandingRound.image = starImageArray[0];
    [self.imageLandingRound startAnimating];
    [self.imageLandingRound setImage:[self.imageLandingRound.animationImages lastObject]];
    [self performSelector:@selector(starAnimationDidFinish) withObject:nil afterDelay:self.imageLandingRound.animationDuration];
}

- (void)starAnimationDidFinish {
    NSArray *reversedImages = [[self.imageLandingRound.animationImages reverseObjectEnumerator] allObjects];
    self.imageLandingRound.animationImages = reversedImages;
    [self performSegueWithIdentifier:@"SegueGetStarted" sender:self];
}

@end
