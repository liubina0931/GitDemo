//
//  DeviceControlTableViewController.m
//  Intelife
//
//  Created by LiuBin on 16-4-21.
//  Copyright (c) 2016年 richdataco. All rights reserved.
//

#import "DeviceControlTableViewController.h"
#import "EditDeviceListViewController.h"
#import "AddApplianceViewController.h"
#import "SmartPlugControlViewController.h"

#define SECTION_SMART_DEVICE    0
#define SECTION_APPLIANCE       1


@interface DeviceControlTableViewController ()

@end

@implementation DeviceControlTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appDelegate = [[UIApplication sharedApplication] delegate];
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(btnDeviceAddClick:)];
    UIBarButtonItem *btnMore = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(btnDeviceMoreClick:)];
    self.navigationItem.rightBarButtonItems = @[btnMore, btnAdd];
    //self.navigationItem.rightBarButtonItem = btnAdd;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case SECTION_SMART_DEVICE:
            return appDelegate.gDeviceList.count;
            break;
        case SECTION_APPLIANCE:
            return appDelegate.gApplianceList.count;
            break;
            
        default:
            break;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_SMART_DEVICE:
            return @"Smart Devices";
            break;
        case SECTION_APPLIANCE:
            return @"Appliances";
            break;
            
        default:
            break;
    }
    return @" ";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DeviceListCell";
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (section) {
        case SECTION_SMART_DEVICE:
            cell.textLabel.text = (NSString *)[appDelegate.gDeviceList objectAtIndex:row];
            break;
        case SECTION_APPLIANCE:
            cell.textLabel.text = (NSString *)[appDelegate.gApplianceList objectAtIndex:row];
            break;
            
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *deviceStoryboard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    SmartPlugControlViewController *smartPlugControlViewController = nil;
    switch (indexPath.section) {
        case 0:
            smartPlugControlViewController = [deviceStoryboard instantiateViewControllerWithIdentifier:@"SmartPlugControlPage"];
            [self.navigationController pushViewController:smartPlugControlViewController animated:YES];
            break;
            
        default:
            break;
    }
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
- (IBAction)btnDeviceAddClick:(id)sender {
    DLog("Add Button Click");
}

-(IBAction)btnDeviceMoreClick:(id)sender {
    DLog("More Button Click");
    SHOW_ACTION_SHEET(@"Cancel", nil, @"Add new appliance", @"Edit device list", 0);
}

- (IBAction)deviceControlBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIStoryboard *deviceStoryBoard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    EditDeviceListViewController *editDeviceListViewController = nil;
    AddApplianceViewController *addApplianceViewController = nil;
    switch (buttonIndex) {
        case 0:
            DLog(@"Add new appliance click");
            addApplianceViewController = [deviceStoryBoard instantiateViewControllerWithIdentifier:@"AddAppliancePage"];
            [self presentViewController:addApplianceViewController animated:YES completion:nil];
            break;
        case 1:
            DLog(@"Edit device list click");
            editDeviceListViewController = [deviceStoryBoard instantiateViewControllerWithIdentifier:@"EditDeviceListPage"];
            [self presentViewController:editDeviceListViewController animated:YES completion:nil];
            break;
        case 2:
            break;
            
        default:
            break;
    }
}

@end
