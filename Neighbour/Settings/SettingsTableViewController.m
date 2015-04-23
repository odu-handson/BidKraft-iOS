//
//  SettingsTableViewController.m
//  Neighbour
//
//  Created by ravi pitapurapu on 12/15/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ProfileTableViewController.h"
#import "UserPeferencesTableViewController.h"
#import "VendorPreferencesTableViewController.h"
#import "ProfileViewController.h"
#import "CustomerCareViewController.h"

@interface SettingsTableViewController ()

@property (nonatomic, strong) NSMutableArray *setttingsNamesArray;
//@property (nonatomic,strong) ProfileTableViewController *profileViewController;
@property (nonatomic,strong) ProfileViewController *profileViewController;
@property (nonatomic,strong) UserPeferencesTableViewController *userPeferencesTableViewController;
@property (nonatomic,strong) VendorPreferencesTableViewController *vendorPreferencesTableViewController;
@property (nonatomic,strong)  CustomerCareViewController  *customerCareViewController;


@property (nonatomic,strong) UIStoryboard *storyBoard;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareLabels];
}

-(void) prepareLabels
{
    self.setttingsNamesArray = [[NSMutableArray alloc] init];
    [self.setttingsNamesArray addObject:@"Profile"];
    [self.setttingsNamesArray addObject:@"User Preferences"];
    [self.setttingsNamesArray addObject:@"Vendor Preferences"];
    [self.setttingsNamesArray addObject:@"Customer Support"];
    [self.setttingsNamesArray addObject:@"About Us"];
    self.navigationController.title =@"Settings";
    
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    self.userPeferencesTableViewController = [self.storyBoard instantiateViewControllerWithIdentifier:@"UserPeferencesTableViewController"];
    self.vendorPreferencesTableViewController = [self.storyBoard instantiateViewControllerWithIdentifier:@"VendorPreferencesTableViewController"];
    self.customerCareViewController = [self.storyBoard instantiateViewControllerWithIdentifier:@"CustomerCareViewController"];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.setttingsNamesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.setttingsNamesArray objectAtIndex:indexPath.item];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.item == 0)
        [self.navigationController pushViewController:self.profileViewController animated:YES];
    else if(indexPath.item == 1)
        [self.navigationController pushViewController:self.userPeferencesTableViewController animated:YES];
    
    else if(indexPath.item == 2)
         [self.navigationController pushViewController:self.vendorPreferencesTableViewController animated:YES];
    
    else if(indexPath.item == 3)
          [self.navigationController pushViewController:self.customerCareViewController animated:YES];
     
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
