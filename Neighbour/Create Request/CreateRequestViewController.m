//
//  CreateRequestViewController.m
//  Neighbour
//
//  Created by Bharath Kongara on 3/22/15.
//  Copyright (c) 2015 ODU_HANDSON. All rights reserved.
//

#import "CreateRequestViewController.h"
#import "IQDropDownTextField.h"
#import "HomeViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "User.h"
#import "NSDate+Utilities.h"

@interface CreateRequestViewController ()<UIAlertViewDelegate,AMTagListDelegate,ServiceProtocol,UITextViewDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet  IQDropDownTextField *btnRequestedDate;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *btnBiddingEnds;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentNavigationItem;
@property (weak, nonatomic) IBOutlet UIButton *btnAddTag;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *txtRequestEndTime;
@property (weak, nonatomic) IBOutlet UITextField *txtJobTitle;

@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic, strong) AMTagView *selection;
@property (nonatomic,strong) User *userData;
@property (nonatomic,strong) NSDictionary *responsedata;



@end

@implementation CreateRequestViewController


- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Create Request";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f]}];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitTapped)];
    
    [self.navigationItem setRightBarButtonItem:anotherButton];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];

    [self configureDropDown];
    [self designTags];
    [self designUI];
    self.txtDescription.delegate = self;
   
    // Do any additional setup after loading the view.
}
-(void) viewWillAppear:(BOOL)animated
{
    if([self.categoryType isEqualToString:@"Baby Sitting"])
    {
        NSArray *tags =@[@"Child Care",@"baby"];
        [self.tagListView addTags:tags andRearrange:YES];
    }
    else if([self.categoryType isEqualToString:@"Pet Care"])
    {
        NSArray *tags =@[@"Pet Care",@"pet"];
        [self.tagListView addTags:tags andRearrange:YES];
        
    }
    else if([self.categoryType isEqualToString:@"Tutoring"])
    {
        NSArray *tags =@[@"Tutoring",@"classes"];
        [self.tagListView addTags:tags andRearrange:YES];
        
    }
    else if([self.categoryType isEqualToString:@"Books Selling"])
    {
        NSArray *tags =@[@"Books",@"college"];
        [self.tagListView addTags:tags andRearrange:YES];
    }
}

#pragma design UI Elements

- (void)designUI
{
    self.btnAddTag.layer.cornerRadius = self.btnAddTag.frame.size.width/2.0;
}
- (void)designTags
{
    [[AMTagView appearance] setTagLength:05];
    [[AMTagView appearance] setTextPadding:5];
    [[AMTagView appearance] setTextFont:[UIFont fontWithName:@"Futura" size:14]];
    [[AMTagView appearance] setTagColor:[UIColor colorWithRed:241/255.0f green:196/255.0f blue:15/255.0f alpha:1.0f]];
    
    [[AMTagView appearance] setAccessoryImage:[UIImage imageNamed:@"close"]];
    self.tagListView.tagListDelegate = self;
    
    __weak CreateRequestViewController* weakSelf = self;
    [self.tagListView setTapHandler:^(AMTagView *view) {
        weakSelf.selection = view;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete"
                                                        message:[NSString stringWithFormat:@"Delete %@?", [view tagText]]
                                                       delegate:weakSelf
                                              cancelButtonTitle:@"Nope"
                                              otherButtonTitles:@"Sure!", nil];
        alert.tag = 2;
        [alert show];
    }];
    
}

-(void) configureDropDown
{
    self.btnRequestedDate.dropDownMode = IQDropDownModeDatePicker;
    self.btnBiddingEnds.dropDownMode = IQDropDownModeDatePicker;
    [self.btnBiddingEnds setBorderStyle:UITextBorderStyleNone];
    [self.btnRequestedDate setBorderStyle:UITextBorderStyleNone];
    [self.btnRequestedDate setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.btnBiddingEnds setDatePickerMode:UIDatePickerModeDateAndTime];
    
    self.txtRequestEndTime.dropDownMode = IQDropDownModeDatePicker;
    [self.txtRequestEndTime setDatePickerMode:UIDatePickerModeDateAndTime];
    
    self.txtRequestEndTime.delegate = self;
    self.btnRequestedDate.delegate  = self;
    self.btnBiddingEnds.delegate = self;
    
}

-(void) submitTapped
{
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSMutableDictionary *parameters = [self prepareParmeters];
    [self.manager serviceCallWithURL:@"http://rikers.cs.odu.edu:8080/bidding/request/create" andParameters:parameters];
    
}

-(NSMutableDictionary *) prepareParmeters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:self.categoryId forKey:@"categoryId"];
    [parameters setObject:self.userData.userId forKey:@"requesterUserId"];
    [parameters setObject:self.txtDescription.text forKey:@"description"];
    [parameters setObject:[self makeRequiredDateFormat:self.btnRequestedDate.text] forKey:@"requestStartDate"];
    [parameters setObject:[self makeRequiredDateFormat:self.txtRequestEndTime.text] forKey:@"requestEndDate"];
    [parameters setObject:[self makeRequiredDateFormat:self.btnBiddingEnds.text] forKey:@"bidEndDateTime"];
    [parameters setObject:self.txtJobTitle.text forKey:@"jobTitle"];
    
    NSMutableArray *tagList = [self.tagListView tags];
    NSMutableArray *tagslist = [[NSMutableArray alloc] init];
    
    for(int i=0;i<tagList.count;i++)
    {
        [tagslist addObject:[(AMTagView *)tagList[i] tagText]];
    }
    [parameters setObject:tagslist forKey:@"tags"];
    //[self.tagListView tags]
    return parameters;
}

-(NSString *) makeRequiredDateFormat:(NSString *)oldDateFormat
{
    
    
    
    NSDateFormatter *datesFormatter = [[NSDateFormatter alloc] init];
    
    //[datesFormatter setDateFormat:@"MMM dd, yyyy, HH:mm:ss z"];
    [datesFormatter setDateStyle:NSDateFormatterMediumStyle];
    [datesFormatter setTimeStyle:NSDateFormatterLongStyle];
    [datesFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EDT"]];
    
    NSDate *formattedDateString = [datesFormatter dateFromString:oldDateFormat];
    NSLog(@"formattedDateString: %@", formattedDateString);
//    NSString *stringAfterTrimmed = oldDateFormat;
//    NSDate *newDate = [[NSDate alloc] init];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM/dd/yyy"];
   // newDate = [dateFormatter dateFromString:stringAfterTrimmed];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, dd MMM yyyy HH:m:ss z"];
    NSString  *requiredDateString = [df stringFromDate:formattedDateString];
    return requiredDateString;
}

#pragma UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(textField.tag == 1)
    {
        
        NSDateFormatter *datesFormatter = [[NSDateFormatter alloc] init];
        //[datesFormatter setDateFormat:@"MMM dd, yyyy, HH:mm:ss z"];
        [datesFormatter setDateStyle:NSDateFormatterMediumStyle];
        [datesFormatter setTimeStyle:NSDateFormatterLongStyle];
        [datesFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EDT"]];
        
        NSDate * currentDate = [NSDate date];
        
        NSDate *formattedDateString = [datesFormatter dateFromString:textField.text];
        NSComparisonResult result = [currentDate compare:formattedDateString];
        
        
        
        
    }
    
    
}


#pragma UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (void) textViewDidBeginEditing:(UITextView *) textView
{
    [textView setText:@""];
}

#pragma Add Tags
- (IBAction)addTags:(id)sender
{
    UIAlertView *addTagAlert = [[UIAlertView alloc]initWithTitle:@"Tags" message:@"Create your own tag" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    addTagAlert.tag = 1;
    addTagAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addTagAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",(long)buttonIndex);
    if(alertView.tag == 1 && buttonIndex > 0)
    {
        NSString *tagText = [[alertView textFieldAtIndex:0] text];
        [self.tagListView addTag:tagText];
    }
    else if (alertView.tag == 2 && buttonIndex > 0)
    {
        [self.tagListView removeTag:self.selection];
    }
    else if(alertView.tag == 3)
    {
        NSMutableDictionary *userData = [self.responsedata valueForKey:@"data"];
        NSMutableArray *requestsArray = [userData valueForKey:@"requests"];
        [self.userData saveUserOpenRequestsData:requestsArray];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma AMTagListDelegate delegate

- (BOOL)tagList:(AMTagListView *)tagListView shouldAddTagWithText:(NSString *)text resultingContentSize:(CGSize)size
{
    // Don't add a 'bad' tag
    return ![text isEqualToString:@"bad"];
}

#pragma mark - ServiceProtocol Methods


- (void)serviceCallCompletedWithResponseObject:(id)response
{
    self.responsedata = (NSDictionary *)response;
    NSString *status = [response valueForKey:@"status"];
    
    if( [status isEqualToString:@"success"])
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation!"
                                                            message:@"Request Posted"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag =3;
        [alertView setDelegate:self];
        [alertView show];
        
    }
    
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}




@end
