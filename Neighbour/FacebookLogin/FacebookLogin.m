//
//  FacebookLogin.m
//  Neighbour
//
//  Created by bkongara on 9/8/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "FacebookLogin.h"

@interface FacebookLogin()
@property (strong,nonatomic) FBLoginView *fbLoginView;



@end
@implementation FacebookLogin
BOOL isUserLoggedIn;
-(id)init{
    
    self = [super init];
    if(self)
    {
        
        self.fbLoginView = [[FBLoginView alloc] init];
        [self openFBSession];
        [self requestPermissions];
        [self closeFBSessionIfExists];
        self.fbLoginView.delegate = self;
    }
    return self;
}

-(void) closeFBSessionIfExists
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    NSLog(@"User Logged in ");
    isUserLoggedIn = YES;
    
}

-(void) openFBSession
{
    FBSession *session = [[FBSession alloc] init];
    [FBSession setActiveSession:session];
}


-(void) requestPermissions
{
    NSArray *permissionsNeeded = @[@"public_profile", @"user_birthday",@"email"];
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
                                  
            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  
            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
            for (NSString *permission in permissionsNeeded)
            {
                if (![currentPermissions objectForKey:permission])
                {
                    [requestPermissions addObject:permission];
                }
            }
                                  
            if ([requestPermissions count] > 0)
            {
                                      
                [FBSession.activeSession
                  requestNewReadPermissions:requestPermissions
                completionHandler:^(FBSession *session, NSError *error)
                {
                  if (!error)
                  {
                    NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                           }
                 }];
            }
        }
    }];

}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    NSLog(@"%@", user);
    
    
}


@end
