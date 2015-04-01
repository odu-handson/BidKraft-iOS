//
//  ProfileTableViewController.h
//  Qwyvr
//
//  Created by Bharath kongara on 10/17/14.
//  Copyright (c) 2014 Qwyvr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfilePictureDelegate<NSObject>

-(void) imageCpatured:(UIImage *) image;
@end

@interface ProfileTableViewController : UITableViewController
@property (nonatomic,weak) id<ProfilePictureDelegate> profilePictureDelegate;

@end
