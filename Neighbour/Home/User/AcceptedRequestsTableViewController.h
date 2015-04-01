//
//  AcceptedRequestsTableView.h
//  Neighbour
//
//  Created by Raghav Sai on 11/29/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface AcceptedRequestsTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) HomeViewController *homeViewController;
@property (nonatomic , weak) UIView *userHeaderView;

@end
