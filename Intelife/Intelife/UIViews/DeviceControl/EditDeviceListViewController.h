//
//  EditDeviceListViewController.h
//  Intelife
//
//  Created by LiuBin on 4/26/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface EditDeviceListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UITableView *tableEditDeviceList;

- (IBAction)btnEditDeviceListBackClick:(id)sender;

@end
