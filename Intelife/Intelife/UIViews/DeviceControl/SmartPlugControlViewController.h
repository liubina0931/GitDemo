//
//  SmartPlugControlViewController.h
//  Intelife
//
//  Created by LiuBin on 4/26/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFLUISegmentedControl.h"

@interface SmartPlugControlViewController : UIViewController <LFLUISegmentedControlDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong ,nonatomic)LFLUISegmentedControl * segmentSwitch;


@end
