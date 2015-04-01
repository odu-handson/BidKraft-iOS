//
//  UserProfile.m
//  Neighbour
//
//  Created by Bharath kongara on 10/20/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "UserProfile.h"
#import "SystemLevelConstants.h"
@interface UserProfile()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation UserProfile

+ (UserProfile *)sharedData
{
    static UserProfile *sharedData;
    @synchronized(self)
    {
        if (!sharedData)
            sharedData = [[UserProfile alloc] init];
        return sharedData;
    }
}

- (NSUserDefaults *)defaults
{
    if(!_defaults)
        _defaults = [NSUserDefaults standardUserDefaults];
    
    return _defaults;
}


- (void)saveFirstName:(NSString *)firstName
{
    [self.defaults setObject:firstName  forKey:kNeighbor_firstName];
    self.firstName = firstName;
}

- (NSString *)firstName
{
    if(!_firstName)
    {
        NSString *fname = [self.defaults stringForKey:kNeighbor_firstName];
        _firstName = fname;
    }
    
    return _firstName;
}

- (void)saveMiddleName:(NSString *)middleName
{
    [self.defaults setObject:middleName  forKey:kNeighbor_middleName];
    self.middleName = middleName;
}

- (NSString *)middleName
{
    if(!_middleName)
    {
        NSString *mname = [self.defaults stringForKey:kNeighbor_middleName];
        _middleName = mname;
    }
    
    return _middleName;
}

- (void)saveLastName:(NSString *)lastName
{
    [self.defaults setObject:lastName  forKey:kNeighbor_lastName];
    self.lastName = lastName;
}

- (NSString *)lastName
{
    if(!_lastName)
    {
        NSString *lname = [self.defaults stringForKey:kNeighbor_lastName];
        _lastName = lname;
    }
    
    return _lastName;
}

- (void)saveEmail:(NSString *)email
{
    [self.defaults setObject:email  forKey:kNeighbor_email];
    self.email = email;
}

- (NSString *)email
{
    if(!_email)
    {
        NSString *email = [self.defaults stringForKey:kNeighbor_email];
        _email = email;
    }
    
    return _email;
}

- (void)saveAddress:(NSString *)address
{
    [self.defaults setObject:address  forKey:kNeighbor_address];
    self.address = address;
}

- (NSString *)address
{
    if(!_address)
    {
        NSString *address = [self.defaults stringForKey:kNeighbor_address];
        _address = address;
    }
    
    return _address;
}
- (void)saveProfilePicture:(UIImage *) profilePicture;
{
    NSData* imageData = UIImagePNGRepresentation(profilePicture);
    NSString* encodedImageData = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self.defaults setObject:encodedImageData forKey:kNeighbor_profilePicture];
    self.profilePicture = profilePicture;
}

-(UIImage *)profilePicture
{
    if(!_profilePicture)
    {
        NSString *encodedImageData = [self.defaults objectForKey:kNeighbor_profilePicture];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:encodedImageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage* image = [UIImage imageWithData:data];
        _profilePicture = image;
    }
    
    return _profilePicture;
    
}

- (void)saveUserId:(NSString *)userId
{
    [self.defaults setObject:userId forKey:kNeighbor_userid];
}

- (NSString *)userId
{
    if(!_userId)
    {
        NSString *uid = [self.defaults stringForKey:kNeighbor_userid];
        if(uid)
            _userId = uid;
    }
    
    return _userId;
}

//Saving the phone number for the first time
- (void)savePhoneNumber:(NSString *)phoneNumber
{
    [self.defaults setObject:phoneNumber forKey:kNeighbor_phone_number];
    self.phoneNumber = phoneNumber;
}

- (NSString *)phoneNumber
{
    if(!_phoneNumber)
    {
        NSString *phone = [self.defaults stringForKey:kNeighbor_phone_number];
        if(phone)
            _phoneNumber = phone;
    }
    
    return _phoneNumber;
}


@end
