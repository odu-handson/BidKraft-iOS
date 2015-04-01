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

@interface SettingsTableViewController ()

@property (nonatomic, strong) NSMutableArray *setttingsNamesArray;
//@property (nonatomic,strong) ProfileTableViewController *profileViewController;
@property (nonatomic,strong) ProfileViewController *profileViewController;
@property (nonatomic,strong) UserPeferencesTableViewController *userPeferencesTableViewController;
@property (nonatomic,strong) VendorPreferencesTableViewController *vendorPreferencesTableViewController;

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
    [self.setttingsNamesArray addObject:@"UserPreferences"];
    [self.setttingsNamesArray addObject:@"VendorPreferences"];
    [self.setttingsNamesArray addObject:@"Customer Support"];
    [self.setttingsNamesArray addObject:@"About Us"];
    self.navigationController.title =@"Settings";
    
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    self.userPeferencesTableViewController = [self.storyBoard instantiateViewControllerWithIdentifier:@"UserPeferencesTableViewController"];
    self.vendorPreferencesTableViewController = [self.storyBoard instantiateViewControllerWithIdentifier:@"VendorPreferencesTableViewController"];
    
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
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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

@end
