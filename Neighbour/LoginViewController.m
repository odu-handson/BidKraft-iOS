//
//  ViewController.m
//  Neighbour
//
//  Created by bkongara on 8/28/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#define USER_NAME_ANIMATION_DISTANCE 240
#define PASSWORD_ANIMATION_DISTANCE 190
#define IMAGE_ANIMATION_DISTANCE 100
#define REGISTER_BUTTON_ANIMATION_DISTANCE 150
#define LOGIN_ANIMATION_DISTANCE 134



#import "LoginViewController.h"
#import "QuartzCore/QuartzCore.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookLogin.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "HomeViewController.h"
#import "UserRequests.h"
#import "BidDetails.h"
#import "RegistrationViewController.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "UserProfile.h"
#import "VendorData.h"


@interface LoginViewController () <FBLoginViewDelegate,UITextFieldDelegate,ServiceProtocol,UINavigationControllerDelegate>
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (strong,nonatomic) FacebookLogin *fbLoginView;
@property (weak, nonatomic) IBOutlet UIView *loginDetailsContainer;
@property (nonatomic,strong) RegistrationViewController *registrationController;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;

@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) HomeViewController *homeViewController;
@property (nonatomic,strong) UserRequests *usrRequests;
@property (nonatomic,strong) BidDetails *bidDetails;
@property (nonatomic, strong) UserProfile *userProfileData;
@property (nonatomic,strong) VendorData *vendorData;

@end

@implementation LoginViewController

- (UserProfile *)userProfileData
{
    if(!_userProfileData)
        _userProfileData = [UserProfile sharedData];
    
    return _userProfileData;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpKeyboardHandlerAndLocationManager];
    [self setScrollEnabled];
    [self prepareButtonsAndTextField];
    [self makeImageRoundCornerAndMoveCenter];
    [self facebookLogin];
    [self animationWithDuration:1 anddelay:2 andMovementDistance:0];
   
}

-(void) setUpKeyboardHandlerAndLocationManager
{
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
}
-(void)setScrollEnabled
{
    //[self.loginScrollView setScrollEnabled:YES];
    //[self.loginScrollView  setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height)];
}
-(void) prepareButtonsAndTextField
{
    self.navigationController.navigationBarHidden = YES;
    //self.btnLogin.layer.cornerRadius = 5;
    //self.btnRegister.layer.cornerRadius = 5;
     self.txtPassword.secureTextEntry = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (IBAction)performRegisteration:(id)sender
{
    [self loadRegistrationView];
}

- (IBAction)performLogin:(id)sender {
    
    [self.btnRegister setEnabled:NO];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    
    NSMutableDictionary *parameters = [self getUserLoginData];
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kLoginServiceKey];
    [self.manager serviceCallWithURL:url andParameters:parameters];
}


-(NSMutableDictionary *) getUserLoginData
{
    NSString *userName =[[NSString alloc]initWithString:self.txtUserName.text];
    NSString *password = [[NSString alloc] initWithString:self.txtPassword.text];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userName forKey:@"userName"];
    [parameters setObject:password forKey:@"password"];
     NSString *token = [[self.userData.notificationToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    if(token)
       
    [parameters setObject:token forKey:@"deviceId"];
    
    else
        [parameters setObject:@"" forKey:@"deviceId"];

    [parameters setObject:@"ios" forKey:@"deviceType"];
    return parameters;
}


-(void) loadAppropriateView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.homeViewController = (HomeViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController pushViewController:self.homeViewController animated:YES];
    
}


#pragma mark - ServiceProtocol Methods

- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSLog(@"data%@",responsedata);
    NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"status"]];
    [self initializeModals];
    [self initializeObjects:responsedata];
    [self.btnRegister setEnabled:NO];
     NSDictionary *responseDetails = [responsedata valueForKey:@"data"];
    if([status isEqualToString:@"success"])
    {
        [self.userData saveUserId:[responseDetails valueForKey:@"userId"]];
        [self.userProfileData saveUserId:[responseDetails valueForKey:@"userId"]];
        [self savePreferences:responseDetails];
        
        NSDictionary *address= [responseDetails valueForKey:@"addresses"];
        
        NSDictionary *userProfile = [responseDetails valueForKey:@"user"];
        [self saveUserProfile:userProfile];
        [self saveAddress:address];
        
        [self loadAppropriateView];
        
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

-(void) saveUserProfile:(NSDictionary *) response
{
    NSString *cellPhone = [response valueForKey:@"cellPhone"];
     NSString *description = [response valueForKey:@"description"];
    NSString *emailId = [response valueForKey:@"emailId"];
    NSString *userPoints = [response valueForKey:@"userPoints"];
    NSString *vendorPoints = [response valueForKey:@"vendorPoints"];
    NSString *userName = [response valueForKey:@"name"];
    NSString *rating = [response valueForKey:@"rating"];
    
    [self.userProfileData saveFullName:userName];
    
    [self.userProfileData saveUserPoints:userPoints];
    [self.userProfileData saveVendorPoints:vendorPoints];
    [self.userProfileData savePhoneNumber:cellPhone];
    [self.userProfileData saveEmail:emailId];
    [self.userProfileData saveUserDescription:description];
    [self.userProfileData saveUserRating:rating];    
  
}
-(void)savePreferences:(NSDictionary *) responseDetails
{
    NSDictionary *userPreferences = [responseDetails valueForKey:@"userPreferences"];
    NSDictionary *requesterPreferences = [userPreferences valueForKey:@"requesterSettings"];
    NSDictionary *vendorPreferences = [userPreferences valueForKey:@"vendorSettings"];
    
    [self.userData saveUserSettingId:[requesterPreferences valueForKey:@"userSettingId"]];
    [self.userData saveRequesterRadius:[requesterPreferences valueForKey:@"requesterRadius"]];
    
    [self.vendorData saveVendorSettingsId:[vendorPreferences valueForKey:@"userSettingId"]];
    [self.vendorData saveVendorRadius:[vendorPreferences valueForKey:@"vendorRadius"]];
}

-(void) saveAddress:(NSDictionary *) addresses
{
    NSDictionary *homeAddress = [addresses valueForKey:@"homeAddress"];
   [self.userData saveUserHomeAddress:[homeAddress valueForKey:@"address"]];
    [self.userData saveUserAddressId:[homeAddress valueForKey:@"userAddressId"]];
    
}


- (void)serviceCallCompletedWithError:(NSError *)error
{
    [self.btnRegister setEnabled:NO];
    NSLog(@"%@",error.description);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error!"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    [alertView setDelegate:self];
    [alertView show];

}

-(void) loadRegistrationView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.registrationController = (RegistrationViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"RegistrationViewController"];
    [self.navigationController pushViewController:self.registrationController animated:YES];
    
}

-(void) initializeModals
{
    self.userData.isRequestViewShown = NO;
    self.bidDetails = [[BidDetails alloc]init];
    
}

-(void) initializeObjects:(NSDictionary *) responseData
{
     responseData = [responseData valueForKey:@"data"];
    NSMutableArray *openRequests = [responseData valueForKey:@"openRequests"];
     NSMutableArray *acceptedRequests = [responseData valueForKey:@"acceptedRequests"];
     NSMutableArray *completedRequests = [responseData valueForKey:@"servicedRequests"];
    if(openRequests)
        [self.userData saveUserOpenRequestsData:openRequests];
     if(acceptedRequests)
        [self.userData saveUserAcceptedRequestsData:acceptedRequests];
     if(completedRequests)
        [self.userData saveUserCompletedRequestsData:completedRequests];
    
}

-(void) facebookLogin{
   
    self.fbLoginView = [[FacebookLogin alloc]init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void) makeImageRoundCornerAndMoveCenter
{
   
    //self.imgLogo.layer.masksToBounds = YES;
    //self.imgLogo.layer.cornerRadius = (self.imgLogo.frame.size.width)/2;
    //self.imgLogo.clipsToBounds = YES;
    [self.imgLogo setCenter:self.view.center];
}

-(void) animationWithDuration:(int)duration anddelay:(int)delay andMovementDistance:(int) movement
{
    dispatch_queue_t myQueue;
    myQueue = dispatch_queue_create("com.neighbour.MyCustomQueue", NULL);
    
        [UIView animateWithDuration:duration  delay:delay options:0 animations:^{
            CGSize size = CGSizeMake(self.imgLogo.frame.size.width , self.imgLogo.frame.size.height);
            CGPoint origin = CGPointMake(self.imgLogo.frame.origin.x, 150);
            CGRect logoRect = CGRectMake(origin.x, origin.y, size.width, size.height);
            self.imgLogo.frame = logoRect;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.6f animations:^{
                            self.loginDetailsContainer.alpha = 1.0f;
            } completion:nil];
        }];
}

@end
