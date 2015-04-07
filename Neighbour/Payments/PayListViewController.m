//
//  PayListViewController.m
//  BidKraft
//
//  Created by Raghav Sai on 4/1/15.
//  Copyright (c) 2015 ODU_HANDSON. All rights reserved.
//

#import "PayListViewController.h"
#import "PaymentViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "HomeViewController.h"
#import <EventKit/EventKit.h>
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "User.h"


@interface PayListViewController ()<UIAlertViewDelegate,ServiceProtocol>

@property (weak, nonatomic) IBOutlet UIButton *btnPayVenmo;
@property (strong, nonatomic) NSString *payMemo;
@property (nonatomic,strong) HomeViewController *homeViewController;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) NSDictionary *confirmationDetails;
@property BOOL isvenmoPayment;


@end

@implementation PayListViewController


- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![Venmo isVenmoAppInstalled])
        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAPI];
    else
        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAppSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Venmo pay action
- (IBAction)payWithVenmo:(id)sender
{
    [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments,
                                                 VENPermissionAccessProfile]
                         withCompletionHandler:^(BOOL success, NSError *error) {
                             if (success)
                             {
                                 [self showPaymentAlert];
                             }
                             else {
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authorization failed"
                                                                                     message:error.localizedDescription
                                                                                    delegate:self
                                                                           cancelButtonTitle:nil
                                                                           otherButtonTitles:@"OK", nil];
                                 [alertView show];
  
                             }
                }];

}


- (void)venmoPay
{
    
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    self.isvenmoPayment = YES;
    NSMutableDictionary *parameters = [self preparePostData:self.bidId];
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kAcceptBidKey];
    [self.manager serviceCallWithURL:url andParameters:parameters];

//    [[Venmo sharedInstance] sendPaymentTo:@"7578147843"
//                                   amount:self.bidAmount.floatValue*100 // this is in cents!
//                                     note:self.payMemo
//                        completionHandler:^(VENTransaction *transaction, BOOL success, NSError *error) {
//                            if (success)
//                            {
//                                
//                                
//                                [self.navigationController popViewControllerAnimated:YES];
//                                
//                            }
//                            else {
//                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authorization failed"
//                                                                                    message:error.localizedDescription
//                                                                                   delegate:self
//                                                                          cancelButtonTitle:nil
//                                                                          otherButtonTitles:@"OK", nil];
//                                [alertView show];
//
//                                NSLog(@"Transaction failed with error: %@", [error localizedDescription]);
//                            }
//                        }];

    
    
    
}

-(void) prepareParametersForVenmo
{
    
}

- (void)showPaymentAlert
{
    UIAlertView *paymentAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Note"
                                                               message:@""
                                                              delegate:self
                                                     cancelButtonTitle:@"cancel"
                                                     otherButtonTitles:@"ok", nil];
    paymentAlertView.tag = 1;
    paymentAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [paymentAlertView show];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex>0)
    {
        UITextField *txtPayMemo = [alertView textFieldAtIndex:0];
        self.payMemo = txtPayMemo.text;
        //[self venmoPay];
        [self serviceCall];
    }
    
    if (buttonIndex == 0 && alertView.tag ==2)
    {
        [self parseAcceptedRequests];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        self.homeViewController = (HomeViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self.navigationController showViewController:self.homeViewController sender:self];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)serviceCall
{
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
     self.isvenmoPayment = NO;
    NSMutableDictionary *parameters = [self preparePostData:self.bidId];
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kAcceptBidKey];
    [self.manager serviceCallWithURL:url andParameters:parameters];
}

-(NSMutableDictionary *)preparePostData:(NSString *)bidId
{
    NSMutableDictionary *parameters = [[ NSMutableDictionary alloc] init];
    [parameters setObject:bidId forKey:@"bidId"];
    [parameters setObject:self.requestId forKey:@"requestId"];
    [parameters setObject:[self.userData userId] forKey:@"userId"];
    return parameters;
}


#pragma ServiceProtocol methods

- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSString *status =[responsedata objectForKey:@"status"];
    
    if( [status isEqualToString:@"success"])
    {
        
        NSDictionary *responsedata = [response objectForKey:@"data"];
        NSMutableArray *openRequests =  [responsedata objectForKey:@"openRequests"];
        NSMutableArray *acceptedRequests =  [responsedata objectForKey:@"acceptedRequests"];
        
        if(openRequests)
            [self.userData saveUserOpenRequestsData:openRequests];
        if(acceptedRequests)
            [self.userData saveUserAcceptedRequestsData:acceptedRequests];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation!"
                                                            message:@"Bid accepted"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag =2;
        alertView.delegate = self;
        [alertView show];
    }
    
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
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

#pragma Calender Events and Remainders and methods

-(void)addEventToCalender:(NSString *)eventDescription withEventDate:(NSDate *)eventDate
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = eventDescription;
        event.startDate = eventDate;
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
    }];
    
}

-(void)addRemainder:(NSString *)remainderDescription withRemainderDate:(NSDate *)remainderDate
{
    EKEventStore *remainderEvent = [[EKEventStore alloc] init];
    [remainderEvent requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if (!granted)
            return;
        if(remainderEvent!=nil)
        {
            EKReminder *reminder = [EKReminder
                                    reminderWithEventStore:remainderEvent];
            reminder.title = remainderDescription;
            reminder.calendar = [remainderEvent defaultCalendarForNewReminders];
            NSDate *remainderStartDate = remainderDate;
            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:remainderStartDate];
            [reminder addAlarm:alarm];
            NSError *errorRemainder = nil;
            [remainderEvent saveReminder:reminder commit:YES error:&errorRemainder];
            if (errorRemainder)
                NSLog(@"error = %@", errorRemainder);
        }
        
    }];
    
}

-(void)parseAcceptedRequests
{
    int indexValue=-1;
    NSDate *requestStartDate;
    NSString *requestDescription;
    for (UserRequests *parse in self.userData.userAcceptedRequests)
    {
        if(parse.bidDetail.bidId == [self.bidId integerValue])
        {
            indexValue++;
            NSLog(@"%ld",(long)parse.bidDetail.bidId);
            requestStartDate = parse.requestStartDate;
            requestDescription = parse.requestDescription;
            break;
        }
    }
    
    
    
    
//    UserRequests *getData = [self.userData.userAcceptedRequests objectAtIndex:indexValue];
//    NSLog(@"%@",getData.requestStartDate);
//    NSLog(@"%@",getData.requestStartFromTime);
//    NSLog(@"%@",getData.requestDescription);
    
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, dd MMM yyyy H:m:s z"];
    
    NSDate *newDate = [[NSDate alloc] init];
    newDate = [df dateFromString:(NSString *)requestStartDate];

    
   // NSDate *eventDate=[self parseDate:getData.requestStartDate withStartTime:getData.requestStartFromTime];
    
    [self addEventToCalender:requestDescription withEventDate:newDate];
    [self addRemainder:requestDescription withRemainderDate:newDate];
    
}

-(NSDate *)parseDate:(NSDate *)startDate withStartTime:(NSString *)startTime
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, dd MMM yyyy H:m:s z"];
    
    NSDate *newDate = [[NSDate alloc] init];
    newDate = [df dateFromString:(NSString *)startDate];
    
    NSString *newStartTime = [df stringFromDate:startDate];
//    NSDateFormatter *requiredFormat = [[NSDateFormatter alloc]init];
//    [requiredFormat setDateFormat:@"yyyy-MM-dd"];
//    NSString * requiredStringFormat = [ requiredFormat stringFromDate:newDate];
//    NSLog(@"%@",requiredStringFormat);
//    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"EST"];
    [formatter setTimeZone:gmt];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSDate *date = [formatter dateFromString:newStartTime];
    return date;
}


@end
