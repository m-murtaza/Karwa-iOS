//
//  ABManager.m
//  Kuber
//
//  Created by Asif Kamboh on 10/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "ABManager.h"
//#import <AddressBookUI/AddressBookUI.h>

@interface ABManager ()

//@property (nonatomic, assign) ABAddressBookRef addressBook;

@end


@implementation ABManager
- (void) fetchUserPhoneNumber
{
    
    //_addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    [self checkAddressBookAccess];
}

#pragma mark -
#pragma mark Address Book Access
// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess
{
    /*switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self fetchUserData];
            break;

            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        default:
            break;
    }*/
}


// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    /*ABManager * __weak weakSelf = self;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         
                                                         [weakSelf fetchUserData];
                                                     });
                                                 }
                                             });*/
}

-(void) fetchUserData
{
    /*NSArray *people = (NSArray *)CFBridgingRelease(ABAddressBookCopyPeopleWithName(self.addressBook, CFSTR("me")));
    // Display "Appleseed" information if found in the address book
    if ((people != nil) && [people count])
    {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
        //NSString* name = (__bridge NSString *)ABRecordCopyValue(person,
        //                                               kABPersonFirstNameProperty);

        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(person, kABPersonPhoneProperty));
        NSString* mobile=@"";
        NSString* mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                //[mobile release] ;
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                [self savePhoneInDefaults:mobile];
            }
        }
        //NSLog(@"name = %@ , Mobile = %@",name,mobile);
    }*/
}


-(void) savePhoneInDefaults:(NSString*)pNum
{
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pNum forKey:KSDetaultsPhoneNumber];
    [defaults synchronize];*/
}

+(NSString*) userPhoneNumber
{
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNumber = [defaults objectForKey:KSDetaultsPhoneNumber];
    return phoneNumber ? phoneNumber : @"";*/
    return @"";
}
@end
