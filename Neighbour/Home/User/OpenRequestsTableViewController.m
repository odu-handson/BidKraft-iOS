

#import "OpenRequestsTableViewController.h"
#import "User.h"
#import "RequestTableViewCell.h"
#import "RequestDetailViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "ResultsSearchTableViewController.h"


@interface OpenRequestsTableViewController ()<ServiceProtocol,UISearchResultsUpdating,UISearchBarDelegate>

@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *userRequests;
@property (nonatomic,strong) RequestDetailViewController *requestDetailController;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,assign) NSInteger requestIdToBeDeleted;
@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic, strong) ResultsSearchTableViewController *resultsSearchTableViewController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation OpenRequestsTableViewController


- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}

-(void)awakeFromNib
{
     [super awakeFromNib];
    [self prepareSearchBarAndSetDelegate];
    [self hideSearchBar];
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self prepareSearchBarAndSetDelegate];
//    [self hideSearchBar];
//    if (self.searchControllerWasActive) {
//        self.searchController.active = self.searchControllerWasActive;
//        _searchControllerWasActive = NO;
//        
//        if (self.searchControllerSearchFieldWasFirstResponder) {
//            [self.searchController.searchBar becomeFirstResponder];
//            _searchControllerSearchFieldWasFirstResponder = NO;
//        }
//    }
//
//    
//
//   
//}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar {
        return NO;
}
- (void)presentSearchController:(UISearchController *)searchController
{
    
}

-(void) hideSearchBar
{
    CGFloat yOffset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGPoint point = CGPointMake(0, self.searchController.searchBar.frame.size.height + yOffset);
    self.tableView.contentOffset = point;
}

-(void) prepareSearchBarAndSetDelegate
{
    self.resultsSearchTableViewController = [[ResultsSearchTableViewController alloc] init];
    self.searchController =[[UISearchController alloc] initWithSearchResultsController:self.resultsSearchTableViewController];
    self.searchController.searchResultsUpdater = self;
    //self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView =self.searchController.searchBar;
    
    self.tableView.tableHeaderView.userInteractionEnabled = YES;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    self.userRequests = self.userData.userOpenRequests;
    return self.userRequests.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier;
    cellIdentifier = @"RequestCell";
     return [self prepareUserRequestsCell:self.tableView WithIdentifier:cellIdentifier atIndexPath:indexPath];
}

-(RequestTableViewCell *) prepareUserRequestsCell:(UITableView *) tableView WithIdentifier:(NSString *) cellIdentifier atIndexPath:(NSIndexPath *)indexPath
{
    RequestTableViewCell *cell =(RequestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    if(self.userRequests.count>0)
    {
        [cell prepareCellForTabelView:tableView atIndex:indexPath];
        [cell prepareTableCellData:cell withIndexPath :indexPath];
        
    }
    else
    {
        cell.textLabel.text = @"No Sources available.";
        cell.detailTextLabel.text = @"Please add sources and fund account.";
    }
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 25.0f;
    if(indexPath.section <2)
    {
        cell.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:84.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    }
    else
    {
        cell.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    RequestTableViewCell *tableCell = (RequestTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.requestDetailController = (RequestDetailViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"RequestDetailViewController"];
    self.requestDetailController.requestId =  tableCell.requestId;
    [self.homeViewController.navigationController pushViewController:self.requestDetailController animated:YES];

}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *returnValue;
    
    UITableViewRowAction *cancelAction;
    
        cancelAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                          title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                              [self performDelete:indexPath onTableView:tableView];
                                                          }];
        cancelAction.backgroundColor = [UIColor colorWithRed:251.0f/255.0f green:2.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
        
        returnValue = @[cancelAction];
    
    return returnValue;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void) performDelete:(NSIndexPath *)indexPath onTableView:(UITableView *)tableView
{
    [self.userRequests removeObjectAtIndex:indexPath.row];
    RequestTableViewCell *tableCell = (RequestTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.requestIdToBeDeleted = tableCell.requestId ;
    NSString *url;
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSMutableDictionary *parameters = [self prepareParmeters];
    self.indexPath = indexPath;
    url = [ServiceURLProvider getURLForServiceWithKey:kDeleteRequest];
    [self.manager serviceCallWithURL:url andParameters:parameters];
}

-(NSMutableDictionary *) prepareParmeters
{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[NSNumber numberWithInteger:self.requestIdToBeDeleted] forKey:@"requestId"];
    [parameters setValue:[self.userData userId] forKey:@"userId"];
    return parameters;
    
}

#pragma mark - ServiceProtocol Methods


- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSLog(@"data%@",responsedata);
    NSString *status = [response valueForKey:@"status"];
    if([status isEqualToString:@"success"])
    {
        
        NSDictionary *data = [response valueForKey:@"data"];
        NSMutableArray *openRequests = [data valueForKey:@"openRequests"];
        NSMutableArray *acceptedRequests = [data valueForKey:@"acceptedRequests"];
        if(acceptedRequests)
            [self.userData saveUserAcceptedRequestsData:acceptedRequests];
        if(openRequests)
            [self.userData saveUserOpenRequestsData:openRequests];
       
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPath]
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {
        NSString *error = [response valueForKey:@"message"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@" Error!"
                                                            message:error.description
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }
    
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
