//
//  AddressBook.m
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import "ABAuthorizeHelper.h"
#import "ABContact.h"

@interface ABAuthorizeHelper ()
@property (unsafe_unretained) ABAddressBookRef      addrbook;
@property (unsafe_unretained) ABAuthorizationStatus auth_status;

@end

@implementation ABAuthorizeHelper

+ (ABAuthorizationStatus)authorizeAdressBook:(ABAddressBookRef)addrbook
{
    ABAuthorizeHelper *pHelper = [[ABAuthorizeHelper alloc] init];
    pHelper.addrbook = addrbook;
    pHelper.auth_status = kABAuthorizationStatusNotDetermined;
    [pHelper startCheckAuth];
    
    CFRunLoopRun();
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    pHelper = Nil;
    
    return status;
}

- (void)startCheckAuth
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.f) {
        NSNumber *num_status = [NSNumber numberWithLong:kABAuthorizationStatusAuthorized];
        [self performSelector:@selector(endCheckAuth:)
                   withObject:num_status
                   afterDelay:0.1f];
        return;
    }
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusNotDetermined:
        {
            //No authorization status could be determined.
            ABAddressBookRef addrbook = self.addrbook;
            ABAddressBookRequestAccessWithCompletion(addrbook, ^(bool granted, CFErrorRef error) {
                if ([NSThread isMainThread]) {
                    [self performSelector:@selector(startCheckAuth)
                               withObject:nil
                               afterDelay:0.1f];
                }
                else {
                    [self performSelectorOnMainThread:@selector(startCheckAuth)
                                           withObject:nil
                                        waitUntilDone:NO];
                }
            });
        }
            break;
        case kABAuthorizationStatusRestricted:
        {
            //The app is not authorized to access address book data. The user cannot change this access, possibly due to restrictions such as parental controls.
            NSNumber *num_status = [NSNumber numberWithLong:status];
            
            if ([NSThread isMainThread]) {
                [self performSelector:@selector(endCheckAuth:)
                           withObject:num_status
                           afterDelay:0.1f];
            }
            else {
                [self performSelectorOnMainThread:@selector(endCheckAuth:)
                                       withObject:num_status
                                    waitUntilDone:NO];
            }
        }
            break;
        case kABAuthorizationStatusDenied:
        {
            //The user explicitly denied access to address book data for this app.
            NSNumber *num_status = [NSNumber numberWithLong:status];
            
            if ([NSThread isMainThread]) {
                [self performSelector:@selector(endCheckAuth:)
                           withObject:num_status
                           afterDelay:0.1f];
            }
            else {
                [self performSelectorOnMainThread:@selector(endCheckAuth:)
                                       withObject:num_status
                                    waitUntilDone:NO];
            }
        }
            break;
        case kABAuthorizationStatusAuthorized:
        {
            //The app is authorized to access address book data.
            NSNumber *num_status = [NSNumber numberWithLong:status];
            
            if ([NSThread isMainThread]) {
                [self performSelector:@selector(endCheckAuth:)
                           withObject:num_status
                           afterDelay:0.1f];
            }
            else {
                [self performSelectorOnMainThread:@selector(endCheckAuth:)
                                       withObject:num_status
                                    waitUntilDone:NO];
            }
        }
            break;
        default:
            break;
    }
}

- (void)endCheckAuth:(NSNumber *)num_status
{
    self.auth_status = num_status.longValue;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
