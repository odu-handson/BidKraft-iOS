//
//  VendorTableViewController.m
//  Neighbour
//
//  Created by ravi pitapurapu on 12/16/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "VendorPreferencesTableViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "User.h"
#import "VendorData.h"

@interface VendorPreferencesTableViewController ()<ServiceProtocol>

@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) VendorData *vendorData;


@end

@implementation VendorPreferencesTableViewController

- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}
- (VendorData *)vendorData
{
    if(!_vendorData)
        _vendorData = [VendorData sharedData];
    
    return _vendorData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    
    return cell;
}
- (IBAction)updateBtnTapped:(id)sender
{
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSMutableDictionary *parameters = [self prepareParametersVendorPreferences];
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kUpdatePreferences];
    [self.manager serviceCallWithURL:url andParameters:parameters];
    
}
-(NSMutableDictionary *) prepareParametersVendorPreferences
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self.userData roleId] forKey:@"roleId"];
    [parameters setValue:[self.vendorData vendorRadius] forKey:@"requesterRadius"];
    [parameters setValue:[self.vendorData userSettingId] forKey:@"userSettingId"];
    
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
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Updated VendorSettings!"
                                                            message:@"Successfully"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alertView setDelegate:self];
        [alertView show];
        
    }
    else if([status isEqualToString:@"error"])
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials!"
                                                            message:@"Username or password doesn't match"
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



@end
