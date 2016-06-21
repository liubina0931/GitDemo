//
//  SceneControlTableViewController.h
//  Intelife
//
//  Created by LiuBin on 4/28/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SceneControlTableViewController : UITableViewController <UIActionSheetDelegate>
{
    AppDelegate *appDelegate;

}
- (IBAction)btnSceneControlBackClick:(id)sender;

@end
