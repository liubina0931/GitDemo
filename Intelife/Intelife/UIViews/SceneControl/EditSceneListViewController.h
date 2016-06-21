//
//  EditSceneListViewController.h
//  Intelife
//
//  Created by LiuBin on 4/29/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface EditSceneListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UITableView *tableEditSceneList;

- (IBAction)btnEditSceneListClick:(id)sender;

@end
