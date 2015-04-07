//
//  OffersTableViewCell.h
//  Neighbour
//
//  Created by bkongara on 9/11/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UserProfileProtocol <NSObject>

-(void)getProfileView:(NSDictionary *) profileResponse;

@end

@protocol PaymentProtocol <NSObject>

- (void)getPaymentDetails:(NSMutableDictionary *)paymentDetails;

@end

@interface OffersTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (nonatomic,assign) NSInteger bidId;
@property (nonatomic,assign) NSString *bidAmount;
@property (nonatomic,assign) NSString *bidOffererId;
@property (nonatomic,strong) id<UserProfileProtocol> userProfileViewDelegate;
@property (nonatomic,strong) id<PaymentProtocol> paymentDetailsDelegate;


- (void)prepareCellForVendorTabelView:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath withBids:(NSMutableArray *)listOfBids;
- (void)prepareCellForTabelView:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath withBids:(NSMutableArray *) listOfBids;


@end


