//
//  DeviceControlTableViewController.h
//  Intelife
//
//  Created by LiuBin on 16-4-21.
//  Copyright (c) 2016年 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DeviceControlTableViewController : UITableViewController <UIActionSheetDelegate>
{
    AppDelegate *appDelegate;
}


- (IBAction)deviceControlBackClick:(id)sender;


@end
