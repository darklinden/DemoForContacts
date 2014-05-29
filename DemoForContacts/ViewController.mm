//
//  ViewController.m
//  DemoForContacts
//
//  Created by DarkLinden on J/19/2013.
//  Copyright (c) 2013 darklinden. All rights reserved.
//

#import "ViewController.h"
//#import "O_address_book_mgr.h"
#import "ABContact.h"
#import "ABContactsHelper.h"
#import "ABStandin.h"
#import "FakePerson.h"
#import <AddressBook/AddressBook.h>
#include <time.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface DM_contact : NSObject
@property (nonatomic, strong) ABContact *contact;
@property (nonatomic, strong) NSString *string_sort;
@end

@implementation DM_contact
@end

@interface ViewController () <ABPersonViewControllerDelegate, UISearchBarDelegate, ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
    UILocalizedIndexedCollation *collation;
    __strong NSMutableArray *sectionsArray;
}

@end

@implementation ViewController

//- (BOOL) ask: (NSString *) aQuestion
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aQuestion message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
//    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alertView];
//    int response = [delegate show];
//    return response;
//}


#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	if (person)
	{
		ABContact *contact = [ABContact contactWithRecord:person];
		self.title = [NSString stringWithFormat:@"Added %@", contact.compositeName];
        
        NSError *error;
		BOOL success = [ABContactsHelper addContact:contact withError:&error];
        if (!success)
        {
            NSLog(@"Could not add contact. %@", error.localizedFailureReason);
            self.title = @"Error.";
		}
        
        [ABStandin save:nil];
	}
	else
		self.title = @"Cancelled";
    
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PEOPLE PICKER DELEGATE METHODS
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
	ABContact *contact = [ABContact contactWithRecord:person];
    
    NSString *query = [NSString stringWithFormat:@"Really delete %@?",  contact.compositeName];
//    if ([self ask:query])
//	{
//		self.title = [NSString stringWithFormat:@"Deleted %@", contact.compositeName];
//		[contact removeSelfFromAddressBook:nil];
//        [ABStandin save:nil];
//	}
    
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	// required method that is never called in the people-only-picking
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)personViewController: (ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    // Reveal the item that was selected
    if ([ABContact propertyIsMultiValue:property])
    {
        NSArray *array = [ABContact arrayForProperty:property inRecord:person];
        NSLog(@"%@", [array objectAtIndex:identifierForValue]);
    }
    else
    {
        id object = [ABContact objectForProperty:property inRecord:person];
        NSLog(@"%@", [object description]);
    }
    
    return NO;
}

- (void) add
{
	// create a new view controller
	ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
	
	// Create a new contact
	ABContact *contact = [ABContact contact];
	npvc.displayedPerson = contact.record;
	
	// Set delegate
	npvc.newPersonViewDelegate = self;
	
	[self.navigationController pushViewController:npvc animated:YES];
}

- (void) remove
{
	ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
	ppnc.peoplePickerDelegate = self;
	[self presentModalViewController:ppnc animated:YES];
}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// The number of sections is the same as the number of titles in the collation.
    return [[collation sectionTitles] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	// The number of time zones in the section is the count of the array associated with the section in the sections array.
	NSArray *timeZonesInSection = [sectionsArray objectAtIndex:section];
	
    return [timeZonesInSection count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	NSArray *contactsInSection = [sectionsArray objectAtIndex:indexPath.section];
	DM_contact *contact = [contactsInSection objectAtIndex:indexPath.row];
    
    cell.textLabel.text = contact.string_sort;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *timeZonesInSection = [sectionsArray objectAtIndex:section];
    if (timeZonesInSection.count) {
        return [[collation sectionTitles] objectAtIndex:section];
    }
    else {
        return nil;
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [collation sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [collation sectionForSectionIndexTitleAtIndex:index];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contactsInSection = [sectionsArray objectAtIndex:indexPath.section];
	ABContact *contact = [contactsInSection objectAtIndex:indexPath.row];
    
    ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
    pvc.displayedPerson = contact.record;
    pvc.personViewDelegate = self;
    pvc.allowsEditing = YES; // optional editing
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - search

// Via Jack Lucky. Handle the cancel button by resetting the search text
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    NSLog(@"Restoring contacts");
    //    matches = [ABContactsHelper contacts];
    //    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (void) loadView
{
    [super loadView];
    
    // Create a search bar
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
    searchBar.delegate = self;
	self.tableView.tableHeaderView = searchBar;
	
	// Create the search display controller
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add", @selector(add));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Remove", @selector(remove));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startCheckAuth];
}

//The app is not authorized to access address book data. The user cannot change this access, possibly due to restrictions such as parental controls.
#define AUTH_FAILED_USER_CAN_NOT_CHANGE @"AUTH_FAILED_USER_CAN_NOT_CHANGE"

//The user explicitly denied access to address book data for this app.
#define AUTH_FAILED_USER_DENIED         @"AUTH_FAILED_USER_DENIED"

- (void)startCheckAuth
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 6.f) {
        [self endCheckAuth:nil];
        return;
    }
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusNotDetermined:
        {
            //No authorization status could be determined.
            ABAddressBookRef addrbook = [ABStandin addressBook];
            ABAddressBookRequestAccessWithCompletion(addrbook, ^(bool granted, CFErrorRef error) {
                if ([NSThread isMainThread]) {
                    [self performSelector:@selector(startCheckAuth) withObject:nil afterDelay:0.f];
                }
                else {
                    [self performSelectorOnMainThread:@selector(startCheckAuth) withObject:nil waitUntilDone:NO];
                }
            });
        }
            break;
        case kABAuthorizationStatusRestricted:
        {
            //The app is not authorized to access address book data. The user cannot change this access, possibly due to restrictions such as parental controls.
            if ([NSThread isMainThread]) {
                [self performSelector:@selector(endCheckAuth:) withObject:AUTH_FAILED_USER_CAN_NOT_CHANGE afterDelay:0.f];
            }
            else {
                [self performSelectorOnMainThread:@selector(endCheckAuth:) withObject:AUTH_FAILED_USER_CAN_NOT_CHANGE waitUntilDone:NO];
            }
        }
            break;
        case kABAuthorizationStatusDenied:
        {
            //The user explicitly denied access to address book data for this app.
            if ([NSThread isMainThread]) {
                [self performSelector:@selector(endCheckAuth:) withObject:AUTH_FAILED_USER_DENIED afterDelay:0.f];
            }
            else {
                [self performSelectorOnMainThread:@selector(endCheckAuth:) withObject:AUTH_FAILED_USER_DENIED waitUntilDone:NO];
            }
        }
            break;
        case kABAuthorizationStatusAuthorized:
        {
            //The app is authorized to access address book data.
            if ([NSThread isMainThread]) {
                [self performSelector:@selector(endCheckAuth:) withObject:nil afterDelay:0.f];
            }
            else {
                [self performSelectorOnMainThread:@selector(endCheckAuth:) withObject:nil waitUntilDone:NO];
            }
        }
            break;
        default:
            break;
    }
}

- (void)endCheckAuth:(NSString *)errMsg
{
    if (!errMsg) {
        [self loadData];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:errMsg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)getContactSource
{
    NSLog(@"%d %d %d", kABPersonSocialProfileProperty, kABGroupNameProperty, kABPersonFirstNameProperty);
    
    NSArray *contacts = [ABContactsHelper sources];
    for (id src in contacts) {
        
        ABSourceType type = [(__bridge_transfer id)ABRecordCopyValue((__bridge ABRecordRef)(src), kABSourceTypeProperty) intValue];
        switch (type) {
            case kABSourceTypeLocal:
            {
                NSLog(@"kABSourceTypeLocal");
            }
                break;
            case kABSourceTypeExchange:
            {
                NSLog(@"kABSourceTypeExchange");
            }
                break;
            case kABSourceTypeExchangeGAL:
            {
                NSLog(@"kABSourceTypeExchangeGAL");
            }
                break;
            case kABSourceTypeMobileMe:
            {
                NSLog(@"kABSourceTypeMobileMe");
            }
                break;
            case kABSourceTypeLDAP:
            {
                NSLog(@"kABSourceTypeLDAP");
            }
                break;
            case kABSourceTypeCardDAV:
            {
                NSLog(@"kABSourceTypeCardDAV");
            }
                break;
            case kABSourceTypeCardDAVSearch:
            {
                NSLog(@"kABSourceTypeCardDAVSearch");
            }
                break;
            default:
                break;
        }
        
        for (int i = 0; i < 13; i++) {
            NSLog(@"%d", i);
            if (i == 10) {
                NSData *data = (__bridge NSData *)(ABRecordCopyValue((__bridge ABRecordRef)(src), i));
                
                NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"1.plist"];
                
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                [data writeToFile:path atomically:YES];
                
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
                NSLog(@"%@", [NSString stringWithFormat:@"%@", dict]);
            }
            else {
                if (ABRecordCopyValue((__bridge ABRecordRef)(src), i)) {
                    NSLog(@"%@", ABRecordCopyValue((__bridge ABRecordRef)(src), i));
                }
            }
        }
    }
}

- (void)loadData
{
    
    clock_t start, end;
    double cpu_time_used;
    
    start = clock();
    
    collation = [UILocalizedIndexedCollation currentCollation];
    
    NSArray *pArr_contact = [ABContactsHelper contacts];
    
    NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
	
	// Segregate the time zones into the appropriate arrays.
	for (ABContact *contact in pArr_contact) {
        
        DM_contact *test_contact = [[DM_contact alloc] init];
        test_contact.contact = contact;
        test_contact.string_sort = contact.description;
		
		// Ask the collation which section number the time zone belongs in, based on its locale name.
		NSInteger sectionNumber = [collation sectionForObject:test_contact collationStringSelector:@selector(string_sort)];
		
		// Get the array for the section.
		NSMutableArray *sections = [newSectionsArray objectAtIndex:sectionNumber];
		
		//  Add the time zone to the section.
		[sections addObject:test_contact];
	}
	
	// Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {
		
		NSMutableArray *timeZonesArrayForSection = [newSectionsArray objectAtIndex:index];
		
		NSArray *sortedTimeZonesArrayForSection = [collation sortedArrayFromArray:timeZonesArrayForSection collationStringSelector:@selector(string_sort)];
		
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedTimeZonesArrayForSection];
	}
    
    sectionsArray = newSectionsArray;
    
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    
    [self.tableView reloadData];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%f", cpu_time_used] message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alert show];
}

@end
