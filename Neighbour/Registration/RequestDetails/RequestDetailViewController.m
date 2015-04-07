//
//  RequestDetailViewController.m
//  Neighbour
//
//  Created by bkongara on 9/10/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "RequestDetailViewController.h"
#import "OffersTabelViewDelegate.h"
#import "OffersTableViewDatasource.h"

#import "User.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "HomeViewController.h"
#import "RequestPaymentViewController.h"
#import "VendorData.h"
#import "ProfileViewController.h"
#import "PayListViewController.h"

@interface RequestDetailViewController ()<ServiceProtocol,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblOffersView;
@property (weak, nonatomic) IBOutlet UITextView *txtRequestDescriptioin;
@property (weak, nonatomic) IBOutlet UILabel *lblRequestStartDate;
@property (weak, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnTableControl;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblLowestBid;


@property (weak, nonatomic) IBOutlet UIButton *btnBid;
@property (weak, nonatomic) IBOutlet UITextField *btnBidAmount;
@property (weak, nonatomic) IBOutlet UIView *bottomBidView;

@property (strong,nonatomic) OffersTabelViewDelegate *tblOffersViewDelegate;
@property (strong,nonatomic) OffersTableViewDatasource *tblOffersViewDataSource;
@property (strong,nonatomic) NSMutableArray *requestArray;
@property (strong,nonatomic) UserRequests *usrRequest;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) HomeViewController *homeViewController;
@property (strong,nonatomic) RequestPaymentViewController *requestPaymentView;
@property (strong,nonatomic) VendorData *vendorData;
@property (strong,nonatomic) VendorBidRequest *vendorRequest;
@property (strong,nonatomic) UIStoryboard *storyBoard;
@property (strong,nonatomic) ProfileViewController *profileViewController;

@property BOOL showBidHistory;
@end

@implementation RequestDetailViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f]}];
    [self initializeDelegatesAndDatasource];
    [self setInitialUI];
    self.btnBid.layer.masksToBounds = YES;
    self.btnBid.layer.cornerRadius = 5.0f;
    if(self.userData.isVendorViewShown)
        self.bottomBidView.alpha = 1;
//    self.ratingView.delegate = self;
//    self.ratingView.emptySelectedImage = [UIImage imageNamed:@"StarEmpty"];
//    self.ratingView.fullSelectedImage = [UIImage imageNamed:@"StarFull"];
//    self.ratingView.contentMode = UIViewContentModeScaleAspectFill;
//    self.ratingView.editable = YES;
//    self.ratingView.halfRatings = YES;
//    self.ratingView.floatRatings = NO;
    [self setRequestData];
   
}
- (void)setInitialUI
{
    self.showBidHistory = NO;
    self.tblOffersView.frame = CGRectMake(self.tblOffersView.frame.origin.x, self.tblOffersView.frame.origin.y, self.tblOffersView.frame.size.width, 0);
    //self.btnBid.layer.cornerRadius = 10.0f;
}

-(void) setRequestData
{
    self.requestArray = [[NSMutableArray alloc] init];
    UserRequests *userRequest;
    VendorBidRequest *vendorRequest;
    if(!self.userData.isVendorViewShown)
    {
        if(self.userData.userRequestMode == OpenMode)
            self.requestArray = self.userData.userOpenRequests;
        else if(self.userData.userRequestMode == ActiveMode)
            self.requestArray = self.userData.userAcceptedRequests;
        else if(self.userData.userRequestMode == CompletedMode)
            self.requestArray = self.userData.userCompletedRequests;
    }
    else
    {
        if(self.vendorData.vendorRequestMode == VendorOpenMode)
            self.requestArray = self.vendorData.vendorOpenRequests;
        else if(self.vendorData.vendorRequestMode == VendorPlacedBidsMode)
            self.requestArray = self.vendorData.vendorBids;
    }
    
    for(int i=0;i<self.requestArray.count;i++)
    {
        
        if(!self.userData.isVendorViewShown)
        {
             userRequest = [self.requestArray objectAtIndex:i];
            if( userRequest.requestId == self.requestId)
            {
                self.usrRequest = userRequest;
                break;
            }
        }
        else
        {
            vendorRequest = [self.requestArray objectAtIndex:i];
            if( vendorRequest.requestId == self.requestId)
            {
                self.vendorRequest = vendorRequest;
                break;
            }
        }
    }
    if(!self.userData.isVendorViewShown)
    {
         self.txtRequestDescriptioin.text = self.usrRequest.requestDescription;
         self.lblRequestStartDate.text =[self getDateStringFromNSDate:(NSDate *)self.usrRequest.requestCreatedDate];
        self.lblJobTitle.text = self.usrRequest.jobTitle;
         self.lblLowestBid.text = [[@(self.usrRequest.lowestBid) stringValue] stringByAppendingString:@"$/hr"];
    }
    else
    {
         self.txtRequestDescriptioin.text = self.vendorRequest.requestDescription;
         self.lblJobTitle.text = self.vendorRequest.jobTitle;
         self.lblRequestStartDate.text =[self getDateStringFromNSDate:(NSDate *)self.vendorRequest.requestStartDate];
         self.lblLowestBid.text = [[@(self.vendorRequest.leastBidAmount) stringValue] stringByAppendingString:@"$/hr"];
    }
        
    //self.lblTimeLeft.text = self.usrRequest.
   
}
-(NSString *) getDateStringFromNSDate:(NSDate *)requestDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, dd MMM yyyy H:m:s z"];
    NSDate *newDate = [[NSDate alloc] init];
    newDate = [df dateFromString:(NSString *)requestDate];
    NSDateFormatter *requiredFormat = [[NSDateFormatter alloc]init];
    [requiredFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * requiredStringFormat = [ requiredFormat stringFromDate:newDate];
    return requiredStringFormat;
}

-(void) initializeDelegatesAndDatasource
{
    self.tblOffersViewDataSource = [[OffersTableViewDatasource alloc]init];
    self.tblOffersViewDelegate = [[OffersTabelViewDelegate alloc]init];
    [self setDelegatesAndDataSource];
    
}
-(void) setDelegatesAndDataSource
{
    self.tblOffersView.delegate = self.tblOffersViewDelegate;
    self.tblOffersView.dataSource = self.tblOffersViewDataSource;
    self.tblOffersViewDataSource.requestDetailController = self;
    self.tblOffersViewDataSource.requestId = self.requestId;
    
}

- (IBAction)accordianAction:(id)sender
{
    if (self.showBidHistory == NO)
    {
        [UIView animateWithDuration:0.53
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.tblOffersView.frame = CGRectMake(self.tblOffersView.frame.origin.x, self.tblOffersView.frame.origin.y, self.tblOffersView.frame.size.width, 100);
                         }
                         completion:^(BOOL finished){
                             self.showBidHistory = YES;
                             self.btnTableControl.titleLabel.text = @"Up";
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.53
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.tblOffersView.frame = CGRectMake(self.tblOffersView.frame.origin.x, self.tblOffersView.frame.origin.y, self.tblOffersView.frame.size.width, 0);
                         }
                         completion:^(BOOL finished){
                             self.showBidHistory = NO;
                             self.btnTableControl.titleLabel.text = @"Down";
                         }];
    }
    
}

- (IBAction)bidButtonTapped:(id)sender
{
    
    if(![self.btnBidAmount.text isEqualToString:@""])
    {
        self.manager = [ServiceManager defaultManager];
        self.manager.serviceDelegate = self;
        NSMutableDictionary *parameters = [self prepareParmeters];
        [self.manager serviceCallWithURL:@"http://rikers.cs.odu.edu:8080/bidding/bid/create" andParameters:parameters];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter your Bid Amount:" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
    }
}

-(NSMutableDictionary *) prepareParmeters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[@(self.requestId) stringValue] forKey:@"requestId"];
    [parameters setObject:[self.userData userId] forKey:@"offererUserId"];
    [parameters setObject:self.btnBidAmount.text forKey:@"bidAmount"];
    return parameters;
}

#pragma mark - ServiceProtocol Methods

- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSDictionary *data = [response valueForKey:@"data"];
    NSLog(@"data%@",responsedata);
    NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"status"]];
    
    if(self.userData.isVendorViewShown)
    {
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
   
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}

- (IBAction)dismissRequestDetailView:(id)sender
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)acceptBid:(UIButton *)sender
{

    self.requestPaymentView = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestPaymentViewController"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    OffersTableViewCell *cell = (OffersTableViewCell *)[self.tblOffersView cellForRowAtIndexPath:indexPath];
    self.requestPaymentView.cellBidID = cell.bidId;
    self.requestPaymentView.requestID = self.requestId;
    self.requestPaymentView.bidAmount = cell.bidAmount;
    
//    NSInteger bidId = cell.bidId;
//        self.manager = [ServiceManager defaultManager];
//        self.manager.serviceDelegate = self;
//    
//    NSMutableDictionary *parameters = [self preparePostData:bidId];
//    
//        NSString *url = [ServiceURLProvider getURLForServiceWithKey:kAcceptBidKey];
//        [self.manager serviceCallWithURL:url andParameters:parameters];
     [self.navigationController pushViewController:self.requestPaymentView animated:YES];

}
//-(NSMutableDictionary *) preparePostData:(NSInteger) bidId
//{
//    NSMutableDictionary *parameters = [[ NSMutableDictionary alloc] init];
//    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)bidId] forKey:@"bidId"];
//    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)self.requestId] forKey:@"requestId"];
//    [parameters setObject:[self.userData userId] forKey:@"userId"];
//    return parameters;
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getProfileView:(NSDictionary *) profileResponse
{
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.profileViewController = (ProfileViewController *) [self.storyBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    self.profileViewController.isProfileShownModally =@"YES";
    
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    
    [self  presentViewController:navcontroller animated:YES completion:nil];
}

#pragma mark - Paymentprotocol method
- (void)getPaymentDetails:(NSMutableDictionary *)paymentDetails
{
    NSLog(@"%@",paymentDetails);
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    PayListViewController *payListViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PayListViewController"];
    payListViewController.bidAmount = [paymentDetails objectForKey:@"bidAmountPay"];
    payListViewController.bidId = [paymentDetails objectForKey:@"bidId"];
    payListViewController.requestId = [@(self.requestId) stringValue];
    [self.navigationController pushViewController:payListViewController animated:YES];
}

//#pragma ServiceProtocol methods
//
//- (void)serviceCallCompletedWithResponseObject:(id)response
//{
//    NSDictionary *responsedata = (NSDictionary *)response;
//    NSString *status =[responsedata objectForKey:@"status"];
//    responsedata = [responsedata objectForKey:@"data"];
//    NSMutableArray *requestedArray = [responsedata objectForKey:@"openRequests"];
//    if(requestedArray)
//        [self.userData saveUserOpenRequestsData:requestedArray];
//    if( [status isEqualToString:@"success"])
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation!"
//                                                            message:@"Bid accepted"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil, nil];
//        alertView.delegate = self;
//        [alertView show];
//    }
//    
//}
//
//- (void)serviceCallCompletedWithError:(NSError *)error
//{
//    NSLog(@"%@",error.description);
//}
//
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//   
//    if (buttonIndex == 0)
//    {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
//        self.homeViewController = (HomeViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
//        [self.navigationController showViewController:self.homeViewController sender:self];
//    }
//    
//}

@end
