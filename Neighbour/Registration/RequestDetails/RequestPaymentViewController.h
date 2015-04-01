//
//  RequestPaymentViewController.h
//  Neighbour
//
//  Created by Raghav Sai on 11/10/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@interface RequestPaymentViewController : UIViewController<PayPalPaymentDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@property (weak, nonatomic) IBOutlet UIButton *btnPayWithPayPal;
@property  (nonatomic,assign) NSInteger cellBidID;
@property  (nonatomic,assign) NSInteger requestID;
@property  (nonatomic,strong) NSString *bidAmount;

@end
