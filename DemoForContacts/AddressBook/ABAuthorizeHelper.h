//
//  AddressBook.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ABAuthorizeHelper : NSObject

+ (ABAuthorizationStatus)authorizeAdressBook:(ABAddressBookRef)addrbook;

@end
