//
//  JobDetailViewController.m
//  BidKraft
//
//  Created by Bharath Kongara on 4/13/15.
//  Copyright (c) 2015 ODU_HANDSON. All rights reserved.
//

#import "JobDetailViewController.h"
#import "OffersTabelViewDelegate.h"
#import "OffersTableViewDatasource.h"
#import "User.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "HomeViewController.h"
#import "VendorData.h"
#import "ProfileViewController.h"
#import "UserProfile.h"

@interface JobDetailViewController ()<ServiceProtocol>


@property (weak, nonatomic) IBOutlet UIButton *btnBid;
@property (weak, nonatomic) IBOutlet UILabel *lblRequestedDate;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UITableView *tblBidDetailsVIew;
@property (weak, nonatomic) IBOutlet UITextField *txtBidAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnTableViewControl;
@property (weak, nonatomic) IBOutlet UILabel *lblLowestBidAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeLeft;
@property (weak, nonatomic) IBOutlet UIView *bidView;

@property (strong,nonatomic) NSString *requesterId;
@property (strong,nonatomic) OffersTabelViewDelegate *tblOffersViewDelegate;
@property (strong,nonatomic) OffersTableViewDatasource *tblOffersViewDataSource;
@property (strong,nonatomic) NSMutableArray *requestArray;
@property (strong,nonatomic) UserRequests *usrRequest;
@property (nonatomic,strong) ServiceManager *manager;
@property (strong,nonatomic) ProfileViewController *profileViewController;
@property (strong,nonatomic) UIStoryboard *storyBoard;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) UserProfile *userProfileData;

@property (strong,nonatomic) VendorData *vendorData;
@property (strong,nonatomic) VendorBidRequest *vendorRequest;



@property BOOL showBidHistory;
@property BOOL userNameTapped;

@end

@implementation JobDetailViewController


- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}

- (UserProfile *)userProfileData
{
    if(!_userProfileData)
        _userProfileData = [UserProfile sharedData];
    
    return _userProfileData;
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
    
    if(self.vendorData.vendorRequestMode == VendorBidsOwnMode || self.vendorData.vendorRequestMode == VendorPlacedBidsMode)
        self.bidView.alpha = 0;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f]}];
    [self initializeDelegatesAndDatasource];
    [self setInitialUI];
    self.btnBid.layer.masksToBounds = YES;
    self.btnBid.layer.cornerRadius = 5.0f;
    
    [self setRequestData];
}

-(void) setRequestData
{
    self.requestArray = [[NSMutableArray alloc] init];
    VendorBidRequest *vendorRequest;
   
        if(self.vendorData.vendorRequestMode == VendorOpenMode)
            self.requestArray = self.vendorData.vendorOpenRequests;
        else if(self.vendorData.vendorRequestMode == VendorPlacedBidsMode)
            self.requestArray = self.vendorData.vendorBids;
    
    for(int i=0;i<self.requestArray.count;i++)
    {
       
            self.vendorRequest = [self.requestArray objectAtIndex:i];
            if( vendorRequest.requestId == self.requestId)
            {
                self.vendorRequest = vendorRequest;
                break;
            }
    }
    self.txtDescription.text = self.vendorRequest.requestDescription;
    [self.btnUserName setTitle:self.vendorRequest.userName forState:UIControlStateNormal];
    //self.btnUserName.titleLabel.text = self.vendorRequest.userName;
    self.requesterId = self.vendorRequest.requesterId;
        //self.lblJobTitle.text = self.vendorRequest.jobTitle;
    self.lblRequestedDate.text =[self getDateStringFromNSDate:(NSDate *)self.vendorRequest.requestStartDate];
    self.lblLowestBidAmount.text = [[@(self.vendorRequest.leastBidAmount) stringValue] stringByAppendingString:@"$/hr"];
    [self timeLeftForBiding];
    
}
-(void) timeLeftForBiding
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, dd MMM yyyy H:m:s z"];
    NSDate *date1 = [[NSDate alloc] init];
    date1 = [df dateFromString:(NSString *)self.usrRequest.bidEndDateTime];
    
    NSDate* date2 = [NSDate date];
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    double secondsInAnHour = 3600;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    
    if(hoursBetweenDates <0)
    {
        self.lblTimeLeft.text = @"Binding Ended";
        self.bidView.alpha = 0;
    }
    else
        self.lblTimeLeft.text = [@(hoursBetweenDates) stringValue];
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
    self.tblBidDetailsVIew.delegate = self.tblOffersViewDelegate;
    self.tblBidDetailsVIew.dataSource = self.tblOffersViewDataSource;
    self.tblOffersViewDataSource.jobDetailViewController = self;
    self.tblOffersViewDataSource.requestId = self.requestId;
}

- (void)setInitialUI
{
    self.showBidHistory = NO;
    self.tblBidDetailsVIew.frame = CGRectMake(self.tblBidDetailsVIew.frame.origin.x, self.tblBidDetailsVIew.frame.origin.y, self.tblBidDetailsVIew.frame.size.width, 0);
    //self.btnBid.layer.cornerRadius = 10.0f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)accordianAction:(id)sender
{
    if (self.showBidHistory == NO)
    {
        [UIView animateWithDuration:0.53
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.tblBidDetailsVIew.frame = CGRectMake(self.tblBidDetailsVIew.frame.origin.x, self.tblBidDetailsVIew.frame.origin.y, self.tblBidDetailsVIew.frame.size.width, 100);
                         }
                         completion:^(BOOL finished){
                             self.showBidHistory = YES;
                             UIImage *buttonImage = [UIImage imageNamed:@"up_arrow.png"];
                             self.btnTableViewControl.imageView.image = buttonImage;
                             [self.btnTableViewControl setBackgroundImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.53
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.tblBidDetailsVIew.frame = CGRectMake(self.tblBidDetailsVIew.frame.origin.x, self.tblBidDetailsVIew.frame.origin.y, self.tblBidDetailsVIew.frame.size.width, 0);
                         }
                         completion:^(BOOL finished){
                             self.showBidHistory = NO;
                             [self.btnTableViewControl setBackgroundImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];

                         }];
    }
    
}

- (IBAction)bidTapped:(id)sender
{
    
    if(![self.txtBidAmount.text isEqualToString:@""])
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
- (IBAction)userNameTapped:(id)sender
{
    
    self.userNameTapped = YES;
    UIButton *button =(UIButton *)sender;
    OffersTableViewCell *cell =(OffersTableViewCell *)[self.tblBidDetailsVIew cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSMutableDictionary *parameters = [self prepareParmeters:self.requesterId];
    [self.manager serviceCallWithURL:@"http://rikers.cs.odu.edu:8080/bidding/user/get" andParameters:parameters];
    
}

-(NSMutableDictionary *) prepareParmeters:(NSString *) userId
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userId forKey:@"userId"];
    return parameters;
}

-(NSMutableDictionary *) prepareParmeters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[@(self.requestId) stringValue] forKey:@"requestId"];
    [parameters setObject:[self.userData userId] forKey:@"offererUserId"];
    [parameters setObject:self.txtBidAmount.text forKey:@"bidAmount"];
    return parameters;
}

-(void) showProfile:(NSDictionary *) data
{
    
    [self saveUserData:data];
    self.userNameTapped = NO;
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.profileViewController = (ProfileViewController *) [self.storyBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    self.profileViewController.isProfileShownModally =@"YES";
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    [self  presentViewController:navcontroller animated:YES completion:nil];
}

-(void) saveUserData:(NSDictionary *) response
{
    NSString *cellPhone = [response valueForKey:@"cellPhone"];
    NSString *description = [response valueForKey:@"description"];
    NSString *emailId = [response valueForKey:@"emailId"];
    NSString *userPoints = [response valueForKey:@"userPoints"];
    NSString *vendorPoints = [response valueForKey:@"vendorPoints"];
    NSString *userRatings = [response valueForKey:@"rating"];
    NSString *userName = [response valueForKey:@"name"];
    
    [self.userProfileData saveUserPoints:userPoints];
    [self.userProfileData saveVendorPoints:vendorPoints];
    [self.userProfileData savePhoneNumber:cellPhone];
    [self.userProfileData saveEmail:emailId];
    [self.userProfileData saveUserDescription:description];
    [self.userProfileData saveUserRating:userRatings];
    [self.userProfileData saveFullName:userName];
    
}


#pragma mark - ServiceProtocol Methods

- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSDictionary *data = [response valueForKey:@"data"];
    NSLog(@"data%@",responsedata);
    NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"status"]];
    
   if(self.userNameTapped)
       [self showProfile:data];
    else
    {
        if( [status isEqualToString:@"success"])
        {
            
            NSDictionary *responsedata = [response objectForKey:@"data"];
            NSMutableArray *placedBids=  [responsedata objectForKey:@"placedBids"];
            NSMutableArray *openRequests =  [responsedata objectForKey:@"openBids"];
            
            if(openRequests)
                [self.vendorData saveVendorData:openRequests];
            if(placedBids)
                [self.vendorData saveVendorOwnBidsData:placedBids];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation!"
                                                                message:@"Bid Placed"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            alertView.tag = 2;
            alertView.delegate = self;
            [alertView show];
        }
        else if([status isEqualToString:@"error"])
        {
            
             NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"message"]];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:status
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            alertView.tag = 2;
            alertView.delegate = self;
            [alertView show];
        }
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag ==2)
    {
        self.vendorData.reloadingAfterBidPlaced = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}


@end
