//
//  UserPeferencesTableViewController.m
//  Neighbour
//
//  Created by ravi pitapurapu on 12/15/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "UserPeferencesTableViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "User.h"

@interface UserPeferencesTableViewController ()<ServiceProtocol>

@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) UITextField *radius;

@end

@implementation UserPeferencesTableViewController

- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if(indexPath.item == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"RadiusCell" forIndexPath:indexPath];
    else if(indexPath.item == 1)
         cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateCell" forIndexPath:indexPath];
    
    return cell;
}

- (IBAction)updateBtnTapped:(id)sender
{
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    
    NSMutableDictionary *parameters = [self prepareParametersUserPreferences];
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kUpdatePreferences];
    [self.manager serviceCallWithURL:url andParameters:parameters];
}
-(NSMutableDictionary *) prepareParametersUserPreferences
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[self.userData roleId] forKey:@"roleId"];
    [parameters setValue:[self.userData userSettingId] forKey:@"requesterRadius"];
    [parameters setValue:[self.userData requesterRadius] forKey:@"userSettingId"];
    return parameters;
}

#pragma mark - ServiceProtocol Methods

- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSLog(@"data%@",responsedata);
    NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"status"]];
    NSDictionary *responseDetails = [responsedata valueForKey:@"data"];
    if([status isEqualToString:@"success"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Preferences Updated!"
                                                            message:@"Successfully"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alertView setDelegate:self];
        [alertView show];

    }
    else if([status isEqualToString:@"error"])
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Enetered Fields Doesnt match"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alertView setDelegate:self];
        [alertView show];
        
    }
    
}



- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error!"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    [alertView setDelegate:self];
    [alertView show];
    
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
