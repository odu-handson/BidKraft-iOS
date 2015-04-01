//
//  ResultsSearchTableViewController.m
//  Neighbour
//
//  Created by ravi pitapurapu on 11/24/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "ResultsSearchTableViewController.h"
#import "RequestTableViewCell.h"
#import "User.h"
#import "VendorTableViewCell.h"
#import "VendorData.h"
#import "VendorBidRequest.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "PaymentTableViewCell.h"

@interface ResultsSearchTableViewController () <ServiceProtocol>


@property (nonatomic,strong) VendorData *vendorData;
@property (nonatomic,strong) NSMutableArray *vendorRequests;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,assign) NSInteger requestIdToBeDeleted;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) NSArray *searchResults;



@end

@implementation ResultsSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"RequestCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"VendorTableCell" bundle:nil] forCellReuseIdentifier:@"VendorTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


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
- (id)init
{
    self = [super init];
    if(self)
    {
        //Custom actions here
        [self prepareDataObjects];
    }
    
    return self;
}

-(void) prepareDataObjects
{
    
    self.userRequests = [[ NSMutableArray alloc] init];
    if(self.userData.userRequestMode == OpenMode)
        self.userRequests = self.userData.userOpenRequests;
    else if(self.userData.userRequestMode == ActiveMode)
        self.userRequests = self.userData.userAcceptedRequests;
    else if(self.userData.userRequestMode == CompletedMode)
        self.userRequests = self.userData.userCompletedRequests;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    [self prepareDataObjects];
    return self.userRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier;
    
        cellIdentifier = @"RequestCell";
        return [self prepareUserRequestsCell:tableView WithIdentifier:cellIdentifier atIndexPath:indexPath];
}

-(RequestTableViewCell *) prepareUserRequestsCell:(UITableView *) tableView WithIdentifier:(NSString *) cellIdentifier atIndexPath:(NSIndexPath *)indexPath
{
    RequestTableViewCell *cell =(RequestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(self.userRequests.count>0)
    {
        cell.isTableReload = self.isTableReload;
        [cell prepareCellForTabelView:tableView atIndex:indexPath];
        [cell prepareTableCellData:cell withIndexPath :indexPath];
    }
    else
    {
        cell.textLabel.text = @"No Sources available.";
        cell.detailTextLabel.text = @"Please add sources and fund account.";
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(NSMutableDictionary *) prepareParmeters
{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(self.self.vendorData.vendorRequestMode == VendorPlacedBidsMode)
        [parameters setValue:[NSNumber numberWithInteger:self.requestIdToBeDeleted] forKey:@"requestId"];
    else
        [parameters setValue:[NSNumber numberWithInteger:self.requestIdToBeDeleted] forKey:@"requestId"];
    
    return parameters;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchText = searchController.searchBar.text;
    [self prepareDataObjects];
    NSMutableArray *searchItemsPredicate = [NSMutableArray array];
    
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    NSExpression *lhs = [NSExpression expressionForKeyPath:@"categoryName"];
    NSExpression *rhs = [NSExpression expressionForConstantValue:searchText];
    NSPredicate *finalPredicate = [NSComparisonPredicate
                                   predicateWithLeftExpression:lhs
                                   rightExpression:rhs
                                   modifier:NSDirectPredicateModifier
                                   type:NSContainsPredicateOperatorType
                                   options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];
    
    NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
    [andMatchPredicates addObject:orMatchPredicates];
    
    NSCompoundPredicate *finalCompoundPredicate = nil;
    
    // match up the fields of the Product object
    finalCompoundPredicate =
    (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    
    //NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"categoryName == %@",searchText];
    
    
    if([searchText isEqualToString:@""])
    {
        
    }
    else
    {
        
        
        self.searchResults = [[self.userRequests  filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
        
        if(self.userData.userRequestMode == OpenMode)
            self.userData.userOpenRequests =  [self.searchResults mutableCopy];
        else if(self.userData.userRequestMode == ActiveMode)
            self.userData.userAcceptedRequests =  [self.searchResults mutableCopy];
        else if(self.userData.userRequestMode == CompletedMode)
            self.userData.userCompletedRequests =  [self.searchResults mutableCopy];
        
      
        [self.tableView reloadData];
        
    }
}


#pragma mark - ServiceProtocol Methods


- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSLog(@"data%@",responsedata);
    NSString *status = [response valueForKey:@"status"];
    if(status)
    {
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPath]
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}

@end
