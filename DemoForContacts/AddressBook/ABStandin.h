//
//  AddressBook.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol AddressBookChange <NSObject>
- (void)addressbookDidChange;
@end

@interface ABStandin : NSObject
+ (ABAddressBookRef) addressBook;
+ (ABAddressBookRef) currentAddressBook;
+ (BOOL) save: (NSError **) error;
+ (void) load;

+ (void)addObserverForAddressbookChange:(id)observer;
+ (void)removeObserverForAddressbookChange:(id)observer;
@end
