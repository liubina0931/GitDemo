//
//  EditSceneListViewController.m
//  Intelife
//
//  Created by LiuBin on 4/29/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "EditSceneListViewController.h"
#import "CustomEditTableViewCell.h"

#define SECTION_SMART_DEVICE    0
#define SECTION_APPLIANCE       1

@interface EditSceneListViewController ()

@end

@implementation EditSceneListViewController
@synthesize tableEditSceneList = _tableEditSceneList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = [[UIApplication sharedApplication] delegate];
    self.tableEditSceneList.dataSource = self;
    self.tableEditSceneList.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.gSceneList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EditSceneListCell";
    NSInteger row = indexPath.row;
    CustomEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[CustomEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.labelName.text = (NSString *)[appDelegate.gSceneList objectAtIndex:row];
    [cell.btnEdit addTarget:self action:@selector(btnEditSceneInfoClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDelete addTarget:self action:@selector(btnDeleteSceneClick:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (IBAction)btnEditSceneListClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnEditSceneInfoClick:(id)sender {
    
}

- (IBAction)btnDeleteSceneClick:(id)sender {
    SHOW_ALERT_VIEW(@"Delete scene?", @"Are you sure you want to delete this scene?", @"Cancel", @"Yes", UIAlertViewStyleDefault, 0);
    
}

@end
