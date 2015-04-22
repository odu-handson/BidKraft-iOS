//
//  VendorSearchTableViewController.m
//  Neighbour
//
//  Created by ravi pitapurapu on 12/2/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "VendorSearchTableViewController.h"
#import "User.h"
#import "VendorTableViewCell.h"
#import "VendorData.h"
#import "VendorBidRequest.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "PaymentTableViewCell.h"

@interface VendorSearchTableViewController ()

@property (nonatomic,strong) VendorData *vendorData;
@property (nonatomic,strong) NSMutableArray *vendorRequests;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,assign) NSInteger requestIdToBeDeleted;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) NSArray *searchResults;


@end

@implementation VendorSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"RequestCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"VendorTableCell" bundle:nil] forCellReuseIdentifier:@"VendorTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.vendorRequests = [[ NSMutableArray alloc] init];
    if(self.vendorData.vendorRequestMode == VendorOpenMode)
        self.vendorRequests = self.vendorData.vendorOpenRequests;
    else if(self.vendorData.vendorRequestMode == VendorPlacedBidsMode)
        self.vendorRequests = self.vendorData.vendorBids;
    else if(self.vendorData.vendorRequestMode == VendorBidsOwnMode)
        self.vendorRequests = self.vendorData.vendorOwnBids;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return  self.vendorRequests.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier;
    cellIdentifier = @"VendorTableViewCell";
    if(self.vendorData.vendorRequestMode == VendorPlacedBidsMode)
        return [self prepareVendorTableForPlacedOwn:tableView withIdentifier:cellIdentifier atIndexPath:indexPath];
    else
        return [self prepareVendorTableForOpenRequests:tableView withIdentifier:cellIdentifier atIndexPath:indexPath];
}

-(VendorTableViewCell *) prepareVendorTableForPlacedOwn:(UITableView *) tableView withIdentifier:(NSString *) cellIdentifier atIndexPath:(NSIndexPath *)indexPath
{
    VendorTableViewCell *vendorCell =(VendorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    vendorCell.vendorRequestedMode = VendorRequestedOwn;
    if(self.vendorData.vendorBids.count>0)
    {
        [vendorCell prepareCellForTabelView:tableView atIndex:indexPath withData:self.vendorData.vendorBids];
        [vendorCell prepareTableCellData:vendorCell withIndexPath : indexPath withData:self.vendorData.vendorBids];
    }
    else
    {
        vendorCell.textLabel.text = @"No Sources available.";
        vendorCell.detailTextLabel.text = @"Please add sources and fund account.";
    }
    return vendorCell;
}

-(VendorTableViewCell *) prepareVendorTableForOpenRequests:(UITableView *) tableView withIdentifier:(NSString *) cellIdentifier atIndexPath:(NSIndexPath *)indexPath
{
    VendorTableViewCell *vendorCell =(VendorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(self.vendorRequests.count>0)
    {
        [vendorCell prepareCellForTabelView:tableView atIndex:indexPath];
        [vendorCell prepareTableCellData:vendorCell withIndexPath : indexPath];
    }
    else
    {
        vendorCell.textLabel.text = @"No Sources available.";
        vendorCell.detailTextLabel.text = @"Please add sources and fund account.";
    }
    return vendorCell;
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
        
        
        self.searchResults = [[self.vendorRequests  filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
        
        self.vendorRequests= [self.searchResults mutableCopy];
        
//        if(self.userData.userRequestMode == OpenMode)
//            self.userData.userOpenRequests =  [self.searchResults mutableCopy];
//        else if(self.userData.userRequestMode == ActiveMode)
//            self.userData.userAcceptedRequests =  [self.searchResults mutableCopy];
//        else if(self.userData.userRequestMode == CompletedMode)
//            self.userData.userCompletedRequests =  [self.searchResults mutableCopy];
        
        
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
