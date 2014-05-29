//
//  AddressBook.m
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import "ABStandin.h"
#import "O_weak_list.h"

static ABAddressBookRef shared = NULL;
static __strong NSTimer *pTmr_refresh = nil;

@implementation ABStandin
// Return the current shared address book, 
// Creating if needed
+ (ABAddressBookRef) addressBook
{
    if (!shared) {
        shared = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(shared, &ExternalChangeCallback, NULL);
    }
    
    return shared;
}

#pragma mark - observer list

void ExternalChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    [pTmr_refresh invalidate];
    pTmr_refresh = nil;
    pTmr_refresh = [NSTimer scheduledTimerWithTimeInterval:3.f
                                                    target:[ABStandin class]
                                                  selector:@selector(handleAdressBookExternalCallbackBackground)
                                                  userInfo:nil
                                                   repeats:NO];
}

+ (void)handleAdressBookExternalCallbackBackground
{
    [pTmr_refresh invalidate];
    pTmr_refresh = nil;
    
    ABAddressBookRef addressbook = [ABStandin addressBook];
    if (ABAddressBookHasUnsavedChanges(addressbook)) {
        if (![ABStandin save:nil]) {
            ABAddressBookRevert(addressbook);
//            [ABStandin currentAddressBook];
        }
    }
    
    NSArray *pArr_obj = [[ABStandin addressbookChangeCallbackObservers] allObjs];
    for (id obj in pArr_obj) {
        if ([obj respondsToSelector:@selector(addressbookDidChange)]) {
            [obj performSelector:@selector(addressbookDidChange) withObject:nil];
        }
    }
}

+ (O_weak_list *)addressbookChangeCallbackObservers
{
    static __strong O_weak_list *pList = nil;
    if (!pList) {
        pList = [O_weak_list list];
    }
    return pList;
}

+ (void)addObserverForAddressbookChange:(id)observer
{
    O_weak_list *pList = [self addressbookChangeCallbackObservers];
    [pList addObj:observer];
}

+ (void)removeObserverForAddressbookChange:(id)observer
{
    O_weak_list *pList = [self addressbookChangeCallbackObservers];
    [pList removeObj:observer];
}

// Load the current address book
+ (ABAddressBookRef) currentAddressBook
{
    if (shared)
    {
        ABAddressBookUnregisterExternalChangeCallback(shared, &ExternalChangeCallback, NULL);
        CFRelease(shared);
        shared = nil;
    }
    
    return [self addressBook];
}

// Thanks Frederic Bronner
// Save the address book out
+ (BOOL) save: (NSError **) error
{
    CFErrorRef cfError;
    if (shared)
    {
        BOOL success = ABAddressBookSave(shared, &cfError);
        if (!success)
        {
            if (error)
                *error = (__bridge_transfer NSError *)cfError;
            return NO;
        }        
        return YES;
    }
    return NO;
}

+ (void) load
{
    [ABStandin addressBook];
}
@end
