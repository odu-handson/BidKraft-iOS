
#import <UIKit/UIKit.h>
#import "VendorTableViewCell.h"

@protocol VendorBidsOwnedProtocol <NSObject>

-(void)getCellBidsOwnedData:(NSString *)requestDate withRequestDesc:(NSString *)requestDescription withRequestID:(NSInteger)requestID onCellData:(VendorTableViewCell *) cell;

@end

@interface VendorBidsOwnedTableViewController : UITableViewController

@property (nonatomic,strong) id<VendorBidsOwnedProtocol> vendorBidsOwnedNavControlDelegate;

@end
