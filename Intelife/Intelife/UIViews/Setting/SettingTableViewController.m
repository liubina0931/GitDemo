//
//  SettingTableViewController.m
//  Intelife
//
//  Created by LiuBin on 4/28/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "SettingTableViewController.h"

#define ROW_SETTING_USERS           0
#define ROW_SETTING_GATEWAY         1
#define ROW_SETTING_LANGUAGE        2
#define ROW_SETTING_WIFI            3
#define ROW_SETTING_TIMEZONE        4
#define ROW_SETTING_DEVICELOGS      5
#define ROW_SETTING_SCENELOGS       6
#define ROW_SETTING_LOGOUT          7

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 8;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingListCell";
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (row) {
        case ROW_SETTING_USERS:
            cell.textLabel.text = @"Users";
            break;
        case ROW_SETTING_GATEWAY:
            cell.textLabel.text = @"Factory Setting";
            break;
        case ROW_SETTING_LANGUAGE:
            cell.textLabel.text = @"Language";
            break;
        case ROW_SETTING_WIFI:
            cell.textLabel.text = @"Wifi";
            break;
        case ROW_SETTING_TIMEZONE:
            cell.textLabel.text = @"TimeZone";
            break;
        case ROW_SETTING_DEVICELOGS:
            cell.textLabel.text = @"Device Logs";
            break;
        case ROW_SETTING_SCENELOGS:
            cell.textLabel.text = @"Scene Logs";
            break;
        case ROW_SETTING_LOGOUT:
            cell.textLabel.text = @"Logout";
            break;
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSettingBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
