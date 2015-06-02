

#import "OpenRequestsTableViewController.h"
#import "User.h"
#import "RequestTableViewCell.h"
#import "RequestDetailViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "ResultsSearchTableViewController.h"


@interface OpenRequestsTableViewController ()<ServiceProtocol>

@property (nonatomic,strong) User *userData;
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
     self.userData.userRequestMode = OpenMode;
     self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void) viewWillAppear:(BOOL)animated
{
    self.userData.userRequestMode = OpenMode;
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    self.userRequests = self.userData.userOpenRequests;
    if(self.userRequests.count == 0)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    return self.userRequests.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.backgroundView = nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
    [self.userRequests removeObjectAtIndex:indexPath.section];
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
        [self.tableView reloadData];
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

@end
