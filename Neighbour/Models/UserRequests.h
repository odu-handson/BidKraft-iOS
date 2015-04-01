//
//  UserRequests.h
//  Neighbour
//
//  Created by Bharath kongara on 9/15/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BidDetails.h"

@interface UserRequests : NSObject

@property (nonatomic,strong) NSDate *requestCreatedDate;
@property (nonatomic,strong) NSString *requestDescription;
@property (nonatomic,strong) NSDate *requestStartDate;
@property (nonatomic,strong) NSString *requestStatus;
@property (nonatomic,strong) NSMutableArray *bidsArray;
@property (nonatomic,strong) BidDetails *bidDetail;
@property (nonatomic,assign) NSInteger categoryId;
@property (nonatomic,assign) NSInteger requestId;
@property (nonatomic,assign) NSInteger lowestBid;
@property (nonatomic,assign) NSInteger totalBids;
@property (nonatomic,strong) NSString *requestStartFromTime;
@property (nonatomic,strong) NSString *categoryName;

@end
