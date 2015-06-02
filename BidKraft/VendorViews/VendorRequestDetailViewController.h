//
//  VendorRequestDetailViewController.h
//  Neighbour
//
//  Created by Bharath kongara on 10/6/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorRequestDetailViewController : UIViewController

@property (nonatomic,assign) NSInteger requestId;
@property (nonatomic,strong) NSString *requestDate;
@property (nonatomic,strong) NSMutableArray *bidsPlaced;
@property (nonatomic,strong) NSString *requestDescription;

@end
