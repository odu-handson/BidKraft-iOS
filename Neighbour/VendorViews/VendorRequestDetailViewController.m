//
//  VendorRequestDetailViewController.m
//  Neighbour
//
//  Created by Bharath kongara on 10/6/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "VendorRequestDetailViewController.h"
#import "OffersTabelViewDelegate.h"
#import "OffersTableViewDatasource.h"
#import "OffersTableViewCell.h"
#import "User.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "HomeViewController.h"
#import "VendorData.h"

@interface VendorRequestDetailViewController ()<UIAlertViewDelegate,ServiceProtocol>

@property (weak, nonatomic) IBOutlet UIButton *btnPlaceBid;
@property (weak, nonatomic) IBOutlet UITableView *tblListOfBids;
@property (weak, nonatomic) IBOutlet UILabel *requestServiceDescription;
@property (weak, nonatomic) IBOutlet UILabel *requestOnDate;
@property (weak, nonatomic) IBOutlet UITableView *totalBidsListView;

@property (strong,nonatomic) OffersTabelViewDelegate *tblOffersViewDelegate;
@property (strong,nonatomic) OffersTableViewDatasource *tblOffersViewDataSource;


@property (strong,nonatomic) NSMutableArray *requestArray;
@property (strong,nonatomic) UserRequests *usrRequest;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) NSString *amount;
@property (nonatomic,strong) HomeViewController *homeViewController;
@property (nonatomic,strong) VendorData *vendorData;

@end

@implementation VendorRequestDetailViewController

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
    self.navigationItem.title = @"Place a Bid";
    self.btnPlaceBid.layer.cornerRadius = 5;
    [self initializeDelegatesAndDatasource];

    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    self.requestServiceDescription.text = self.requestDescription;
    self.requestOnDate.text = self.requestDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) initializeDelegatesAndDatasource
{
    self.tblOffersViewDataSource = [[OffersTableViewDatasource alloc]init];
    self.tblOffersViewDelegate = [[OffersTabelViewDelegate alloc]init];
    [self setDelegatesAndDataSource];
    
}
-(void) setDelegatesAndDataSource
{
    self.totalBidsListView.delegate = self.tblOffersViewDelegate;
    self.totalBidsListView.dataSource = self.tblOffersViewDataSource;
    self.tblOffersViewDataSource.requestId = self.requestId;
    
}

- (IBAction)placeBidTapped:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirmation!" message:@"Please enter your Bid Amount:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField.placeholder = @" Bid Amount";
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1 && ![[[alertView textFieldAtIndex:0] text] isEqualToString:@""])
    {
        self.amount = [[alertView textFieldAtIndex:0] text];
        self.manager = [ServiceManager defaultManager];
        self.manager.serviceDelegate = self;
        NSMutableDictionary *parameters = [self prepareParmeters];
        [self.manager serviceCallWithURL:@"http://rikers.cs.odu.edu:8080/bidding/bid/create" andParameters:parameters];
    }
}

-(NSMutableDictionary *) prepareParmeters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[@(self.requestId) stringValue] forKey:@"requestId"];
    [parameters setObject:[self.userData userId] forKey:@"offererUserId"];
    [parameters setObject:self.amount forKey:@"bidAmount"];
    return parameters;
}

#pragma mark - ServiceProtocol Methods


- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSDictionary *data = [response valueForKey:@"data"];
    NSLog(@"data%@",responsedata);
     NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"status"]];
    if([status isEqualToString:@"success"])
    {
        self.userData.isVendorViewShown = YES;
        NSMutableArray *openBids =  [data valueForKey:@"openBids"];
        NSMutableArray *placedBids =  [data valueForKey:@"placedBids"];
        [self.vendorData saveEachVendorOpenRequestData:openBids];
        [self.vendorData saveVendorData:placedBids];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}


@end
