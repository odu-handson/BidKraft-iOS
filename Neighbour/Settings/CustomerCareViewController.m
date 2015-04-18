//
//  CustomerCareViewController.m
//  BidKraft
//
//  Created by Bharath Kongara on 4/10/15.
//  Copyright (c) 2015 ODU_HANDSON. All rights reserved.
//

#import "CustomerCareViewController.h"

@interface CustomerCareViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *topText;
@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UITextView *txtIssueDescription;

@end

@implementation CustomerCareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f]}];
    
    UIBarButtonItem *rightBarButton;
   
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitTapped:)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    //[self.navigationItem setRightBarButtonItem:anotherButton];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    self.txtSubject.delegate = self;
    self.txtIssueDescription.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

-(void) submitTapped:(UIButton *) button
{
    
}

@end
