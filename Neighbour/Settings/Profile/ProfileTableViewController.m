//
//  ProfileTableViewController.m
//  Qwyvr
//
//  Created by Bharath kongara on 10/17/14.
//  Copyright (c) 2014 Qwyvr. All rights reserved.
//

#import "ProfileTableViewController.h"

#import "UserProfile.h"
#import "ProfileTableViewCell.h"
#import "User.h"
#import "ProfileAddressView.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import <MapKit/MapKit.h>


@interface ProfileTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UITextViewDelegate,ServiceProtocol>

@property (nonatomic, strong) UIBarButtonItem *menuItem;
@property (nonatomic, strong) UserProfile *userProfileData;
@property (nonatomic, strong) User *userData;
@property (nonatomic, strong) UILabel *lblProfileField;
@property (nonatomic, strong) UITextView *txtProfileFieldValues;
@property (nonatomic,assign) BOOL isPhotoPickerOptionsShown;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSMutableArray *profileFieldNamesArray;
@property (nonatomic,strong) UIImageView *temptumb;
@property (nonatomic,strong) UIImageView *fullview;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) NSMutableArray *textFields;
@property (nonatomic,strong) UITextView *address;
@property (nonatomic,strong) NSString *lattitude;
@property (nonatomic,strong) NSString *longitude;




@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UIView *headerView;


@end

@implementation ProfileTableViewController


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


- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self prepareNavigationBar];
    [self prepareLabels];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.imgProfile.layer.cornerRadius = (self.imgProfile.frame.size.width)/2;
    self.imgProfile.clipsToBounds = YES;
    [self prepareTableView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareTableView
{
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self prepareTableViewHeader];
}

- (void)prepareTableViewHeader
{
    self.tableView.tableHeaderView = self.headerView;
    
//    if(self.userData.profilePicture)
//        [self.imgProfile setImage:self.userData.profilePicture];
}

-(void) prepareLabels
{
    self.profileFieldNamesArray = [[NSMutableArray alloc] init];
    self.textFields = [[NSMutableArray alloc] init];
    [self.profileFieldNamesArray addObject:@"FirstName"];
    [self.profileFieldNamesArray addObject:@"LastName"];
    [self.profileFieldNamesArray addObject:@"Mobile Number"];
    [self.profileFieldNamesArray addObject:@"Email"];
    [self.profileFieldNamesArray addObject:@"Address"];
    
}

- (void)prepareLabeleName
{
    self.lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
    self.lblProfileField.text = [self.userProfileData.firstName stringByAppendingString:[NSString stringWithFormat:@" %@",self.userProfileData.lastName]];
    self.lblProfileField.font = [UIFont fontWithName:@"Avenir Next Medium" size:14];
    self.lblProfileField.backgroundColor = [UIColor clearColor];
    self.lblProfileField.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    [self.lblProfileField sizeToFit];
    self.lblProfileField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}


- (IBAction)showProfilePicture:(UIGestureRecognizer *)gestureRecognizer
{
    self.temptumb=(UIImageView *)gestureRecognizer.view;
    //fullview is gloabal, So we can acess any time to remove it
    self.fullview=[[UIImageView alloc]init];
    [self.fullview setContentMode:UIViewContentModeScaleAspectFit];
    [self.fullview setBackgroundColor:[UIColor blackColor]];
    self.fullview.image = [(UIImageView *)gestureRecognizer.view image];
    CGRect viewBounds = gestureRecognizer.view.bounds;
    viewBounds.origin.y = viewBounds.origin.y - 100;
    CGRect point=[self.view convertRect:viewBounds fromView:gestureRecognizer.view];
    [self.fullview setFrame:point];
    
    [self.view addSubview:self.fullview];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.fullview setFrame:CGRectMake(0,
                                                       0,
                                                       self.view.bounds.size.width,
                                                       self.view.bounds.size.height)];
                     }];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullimagetapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.fullview addGestureRecognizer:singleTap];
    [self.fullview setUserInteractionEnabled:YES];
}



- (void)fullimagetapped:(UIGestureRecognizer *)gestureRecognizer {
    
    CGRect point=[self.view convertRect:self.temptumb.bounds fromView:self.temptumb];
    
    gestureRecognizer.view.backgroundColor=[UIColor clearColor];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [(UIImageView *)gestureRecognizer.view setFrame:point];
                     }];
    [self performSelector:@selector(animationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
    
}

//Remove view after animation of remove
-(void)animationDone:(UIView  *)view
{
    //view.backgroundColor=[UIColor clearColor];
    [self.fullview removeFromSuperview];
    self.fullview=nil;
}

- (IBAction)showOptionsToSelectsProfilePhoto:(id)sender {
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Choose From photos", @"Take Picture", nil];
    [actionSheet showInView:self.view];
    
    
}



#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    
    if([buttonTitle isEqualToString:@"Take Picture"])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else if( [buttonTitle isEqualToString:@"Choose From photos"])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 3)
        return 60;
    else if(indexPath.row == 4)
        return 50;
    else
        return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    ProfileAddressView *addressCell;
    ProfileTableViewCell *cell;
    
    if(indexPath.row == 4)
    {
        cellIdentifier = @"AddressTableCell";
        addressCell = (ProfileAddressView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        addressCell.txtAddressView.layer.borderWidth = 0.3f;
        addressCell.txtAddressView.layer.borderColor = [UIColor grayColor].CGColor;
        addressCell.txtAddressView.layer.cornerRadius = 2.3f;
        
        if([self.userData homeAddress])
            
           addressCell.txtAddressView.text = [self.userProfileData address];
        else
           addressCell.txtAddressView.text = @"Address";
        self.address = addressCell.txtAddressView;
        addressCell.txtAddressView.delegate = self;
        return addressCell;
    }
    
    else if(indexPath.row ==5)
    {
        
        UITableViewCell *cell =(ProfileTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"UpdateButton"];
        return cell;
        
    }
    
    else
    {
        cellIdentifier = @"ProfileTableViewCell";
        cell =(ProfileTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = (ProfileTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lblProfileProperty.text = [self.profileFieldNamesArray objectAtIndex:indexPath.row];
        
        [self.textFields addObject:cell.txtProfilePropertyValue];
        
        if(indexPath.row == 0)
        {
            if([self.userProfileData firstName])
                cell.txtProfilePropertyValue.text =[self.userProfileData firstName];
            else
            cell.txtProfilePropertyValue.placeholder =[self.profileFieldNamesArray objectAtIndex:indexPath.row];
            
        }
        else if(indexPath.row == 1)
        {
            if([self.userProfileData firstName])
                
               cell.txtProfilePropertyValue.text =[self.userProfileData lastName];
            else
             cell.txtProfilePropertyValue.placeholder =[self.profileFieldNamesArray objectAtIndex:indexPath.row];

        }
        else if(indexPath.row == 2)
        {
            if([self.userProfileData email])
            {
               cell.txtProfilePropertyValue.text =[self.userProfileData email];
            }
            else
                cell.txtProfilePropertyValue.placeholder = @"Enter Email";
            
        }
        
        cell.txtProfilePropertyValue.delegate = self;
        
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Medium" size:17];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self.imgProfile setImage:chosenImage];
    [[self profilePictureDelegate] imageCpatured:chosenImage];
    [self.userProfileData saveProfilePicture:chosenImage];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark UITextField Delegate 

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
    return YES;

}


#pragma mark IBAction Actions
- (IBAction)updateBtnTapped:(id)sender {
    [self convertAddressToLatLong];
    
    
}
-(NSMutableDictionary *) prepareParametersForProfile
{
    
    UITextField *textField;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"87" forKey:@"userId"];
    textField = [self.textFields objectAtIndex:0];
    [parameters setValue:textField.text forKey:@"firstName"];
    textField = [self.textFields objectAtIndex:1];
    [parameters setValue:textField.text forKey:@"lastName"];
    textField = [self.textFields objectAtIndex:2];
    [parameters setValue:textField.text forKey:@"cellPhone"];
    textField = [self.textFields objectAtIndex:3];
    [parameters setValue:textField.text forKey:@"emailId"];
    
    NSMutableDictionary *homeAddress = [[NSMutableDictionary alloc] init];
    [homeAddress setValue:[self.userData userAddressId]   forKey:@"userAddressId"];
    [homeAddress setValue:self.lattitude forKey:@"latitude"];
     [homeAddress setValue:self.longitude forKey:@"longitude"];
     [homeAddress setValue:self.address.text forKey:@"address"];
    
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    [addressDictionary setValue:homeAddress forKey:@"homeAddress"];
    
     [parameters setValue:addressDictionary forKey:@"addresses"];
    return parameters;
    
}

-(void) convertAddressToLatLong
{
    CLGeocoder  *geocoder = [[CLGeocoder alloc] init];
    //NSMutableDictionary *parametersList =[[NSMutableDictionary alloc]init];
    [geocoder geocodeAddressString:self.address.text
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     for (CLPlacemark* aPlacemark in placemarks)
                     {
                         NSString *url;
                         CLLocation *location = [aPlacemark location];
                         CLLocationCoordinate2D coordinate = location.coordinate;
                         self.lattitude = [[NSString alloc ]initWithFormat:@"%f",coordinate.latitude];
                         self.longitude = [[NSString alloc ]initWithFormat:@"%f",coordinate.longitude];
                         self.manager = [ServiceManager defaultManager];
                         self.manager.serviceDelegate = self;
                         NSMutableDictionary *parameters = [self prepareParametersForProfile];
                         url = [ServiceURLProvider getURLForServiceWithKey:kUpdateProfile];
                         [self.manager serviceCallWithURL:url andParameters:parameters];

                         
                     }
                 }];
}

#pragma mark - ServiceProtocol Methods


- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSLog(@"data%@",responsedata);
    NSString *status = [response valueForKey:@"status"];
    if([status isEqualToString:@"success"])
    {
        NSString *updated = [response valueForKey:@"message"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@" Updated!"
                                                            message:updated.description
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        
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
