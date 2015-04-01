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


@interface CreateRequestViewController ()<UIAlertViewDelegate,AMTagListDelegate,ServiceProtocol,UITextViewDelegate>


@property (weak, nonatomic) IBOutlet  IQDropDownTextField *btnRequestedDate;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *btnBiddingEnds;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentNavigationItem;
@property (weak, nonatomic) IBOutlet UIButton *btnAddTag;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;

@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic, strong) AMTagView *selection;

@end

@implementation CreateRequestViewController

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
    
    [parameters setObject:@"" forKey:@"categoryId"];
     //[parameters setObject: forKey:@"requesterUserId"];
     [parameters setObject:@"" forKey:@"categoryId"];
     [parameters setObject:@"" forKey:@"description"];
    [parameters setObject:@"" forKey:@"requestStartDate"];
    [parameters setObject:@"" forKey:@"requestStartDate"];
    [parameters setObject:@"" forKey:@"requestStartDate"];
    [parameters setObject:@"" forKey:@"requestStartDate"];
    
    return parameters;

}


#pragma UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    return YES;
}
- (void) textViewDidBeginEditing:(UITextView *) textView {
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
}


#pragma AMTagListDelegate delegate

- (BOOL)tagList:(AMTagListView *)tagListView shouldAddTagWithText:(NSString *)text resultingContentSize:(CGSize)size
{
    // Don't add a 'bad' tag
    return ![text isEqualToString:@"bad"];
}




@end
