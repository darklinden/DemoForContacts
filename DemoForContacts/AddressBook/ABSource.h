//
//  ABSource.h
//  ContactsManager
//
//  Created by DarkLinden on O/17/2013.
//  Copyright (c) 2013 darklinden. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ABSource : NSObject
{
	ABRecordRef record;
}

/*
 enum {
 kABSourceTypeLocal       = 0x0,
 kABSourceTypeExchange    = 0x1,
 kABSourceTypeExchangeGAL = kABSourceTypeExchange | kABSourceTypeSearchableMask,
 kABSourceTypeMobileMe    = 0x2,
 kABSourceTypeLDAP        = 0x3 | kABSourceTypeSearchableMask,
 kABSourceTypeCardDAV     = 0x4,
 kABSourceTypeCardDAVSearch = kABSourceTypeCardDAV | kABSourceTypeSearchableMask,
 };
 typedef int ABSourceType;
 */

+ (id)sourceWithRecord:(ABRecordRef)record;
+ (id)sourceWithRecordID:(ABRecordID)recordID;

+ (NSArray *)allSources;
+ (ABSource *)defaultSource;
+ (NSArray *)sourcesWithType:(ABSourceType)sourceType;

@property (nonatomic, readonly) ABRecordRef     record;
@property (nonatomic, readonly) ABRecordID      recordID;
@property (nonatomic, readonly) ABRecordType    recordType;
@property (nonatomic, readonly) NSString        *name;
@property (nonatomic, readonly) ABSourceType    type;



@end
