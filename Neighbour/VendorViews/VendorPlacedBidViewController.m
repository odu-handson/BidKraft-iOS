//
//  VendorPlacedBidViewController.m
//  Neighbour
//
//  Created by Bharath kongara on 10/6/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "VendorPlacedBidViewController.h"

@interface VendorPlacedBidViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnCancelBid;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnShareInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestDate;

@property (weak, nonatomic) IBOutlet UILabel *bidDescription;
@end

@implementation VendorPlacedBidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Bid Details";
    self.btnRequestInfo.layer.cornerRadius = 5;
    self.btnShareInfo.layer.cornerRadius = 5;
    self.lblRequestDate.text = self.requestDate;
    self.bidDescription.text = self.requestDescription;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)shareInfoTapped:(id)sender {


}


- (IBAction)requestInfoTapped:(id)sender {



}


@end
