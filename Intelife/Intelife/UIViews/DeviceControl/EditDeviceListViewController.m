//
//  EditDeviceListViewController.m
//  Intelife
//
//  Created by LiuBin on 4/26/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "EditDeviceListViewController.h"
#import "CustomEditTableViewCell.h"
#import "EditDeviceInfoViewController.h"
#import "EditApplianceInfoViewController.h"

#define SECTION_SMART_DEVICE    0
#define SECTION_APPLIANCE       1

@interface EditDeviceListViewController ()

@end

@implementation EditDeviceListViewController
@synthesize tableEditDeviceList = _tableEditDeviceList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = [[UIApplication sharedApplication] delegate];
    self.tableEditDeviceList.dataSource = self;
    self.tableEditDeviceList.delegate = self;
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
    static NSString *cellIdentifier = @"EditDeviceListCell";
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    CustomEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[CustomEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (section) {
        case SECTION_SMART_DEVICE:
            cell.labelName.text = (NSString *)[appDelegate.gDeviceList objectAtIndex:row];
            break;
        case SECTION_APPLIANCE:
            cell.labelName.text = (NSString *)[appDelegate.gApplianceList objectAtIndex:row];
            break;
            
        default:
            break;
    }
    [cell.btnEdit addTarget:self action:@selector(btnEditDeviceInfoClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDelete addTarget:self action:@selector(btnDeleteDeviceClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnEditDeviceListBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnEditDeviceInfoClick:(id)sender {
    UIStoryboard *deviceStoryboard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    EditDeviceInfoViewController *editDeviceInfoViewController = [deviceStoryboard instantiateViewControllerWithIdentifier:@"EditDeviceInfoPage"];
    [self presentViewController:editDeviceInfoViewController animated:YES completion:nil];

}

- (IBAction)btnDeleteDeviceClick:(id)sender {
    SHOW_ALERT_VIEW(@"Delete device?", @"Are you sure you want to delete this device?", @"Cancel", @"Yes", UIAlertViewStyleDefault, 0);

}

@end
