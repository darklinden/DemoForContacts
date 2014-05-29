//
//  ABSource.m
//  ContactsManager
//
//  Created by DarkLinden on O/17/2013.
//  Copyright (c) 2013 darklinden. All rights reserved.
//

#import "ABSource.h"
#import "ABStandin.h"

@implementation ABSource
@synthesize record;

// Thanks to Quentarez, Ciaran
- (id)initWithRecord:(ABRecordRef)aRecord
{
    if (self = [super init]) record = CFRetain(aRecord);
    return self;
}

- (void)dealloc
{
    if (record)
        CFRelease(record);
}

+ (id)sourceWithRecord:(ABRecordRef)record
{
    return [[ABSource alloc] initWithRecord:record];
}

+ (id)sourceWithRecordID:(ABRecordID)recordID
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    ABRecordRef sourcerec = ABAddressBookGetSourceWithRecordID(addressBook, recordID);
    if (!sourcerec) return nil; // Thanks, Frederic Bronner
    
    ABSource *source = [self sourceWithRecord:sourcerec];
    return source;
}

+ (NSArray *)allSources
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    NSArray *sources = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllSources(addressBook);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:sources.count];
    for (id source in sources)
        [array addObject:[ABSource sourceWithRecord:(__bridge ABRecordRef)source]];
    return array;
}

+ (ABSource *)defaultSource
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    ABRecordRef sourcerec = ABAddressBookCopyDefaultSource(addressBook);
    if (!sourcerec) return nil;
    
    ABSource *source = [self sourceWithRecord:sourcerec];
    return source;
}

+ (NSArray *)sourcesWithType:(ABSourceType)sourceType
{
    NSArray *sources = [self allSources];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:sources.count];
    for (ABSource *source in sources) {
        if (source.type == sourceType) {
            [array addObject:source];
        }
    }
    return array;
}

#pragma getter

- (NSString *)getRecordString:(ABPropertyID) anID
{
    return (__bridge_transfer NSString *) ABRecordCopyValue(record, anID);
}

- (NSString *)name
{
    return [self getRecordString:kABSourceNameProperty];
}

- (ABSourceType)type
{
    ABSourceType sourcetype = [(__bridge_transfer NSNumber *)ABRecordCopyValue(record, kABSourceTypeProperty) intValue];
    switch (sourcetype) {
        case kABSourceTypeLocal:
            NSLog(@"kABSourceTypeLocal");
            break;
        case kABSourceTypeExchange:
            NSLog(@"kABSourceTypeExchange");
            break;
        case kABSourceTypeExchangeGAL:
            NSLog(@"kABSourceTypeExchangeGAL");
            break;
        case kABSourceTypeMobileMe:
            NSLog(@"kABSourceTypeMobileMe");
            break;
        case kABSourceTypeLDAP:
            NSLog(@"kABSourceTypeLDAP");
            break;
        case kABSourceTypeCardDAV:
            NSLog(@"kABSourceTypeCardDAV");
            break;
        case kABSourceTypeCardDAVSearch:
            NSLog(@"kABSourceTypeCardDAVSearch");
            break;
        default:
            NSLog(@"Unknown");
            break;
    }
    return sourcetype;
}


@end
