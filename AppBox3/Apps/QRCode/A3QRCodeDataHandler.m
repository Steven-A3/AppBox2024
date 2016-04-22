//
//  A3QRCodeDataHandler.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "A3QRCodeDataHandler.h"
#import "A3QRCodeMapViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3QRCodeTextViewController.h"
#import "MXLCalendarManager.h"
#import "A3AppDelegate.h"
#import "A3QRCodeDetailViewController.h"
#import "QRCodeHistory.h"

typedef NS_ENUM(NSUInteger, A3QRCodeActionSheetType) {
	A3QRCodeActionSheetTypeAddEvent = 1,
	A3QRCodeActionSheetTypePhoneOrSMS,
	A3QRCodeActionSheetTypeMeCardAddContact,
	A3QRCodeActionSheetTypeVCardAddContact
};

@interface A3QRCodeDataHandler () < MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate,
UIActionSheetDelegate, EKEventEditViewDelegate, ABNewPersonViewControllerDelegate>

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, weak) UIViewController *targetViewController;
@property (nonatomic, strong) MXLCalendar *parsedEventCalendar;
@property (nonatomic, strong) QRCodeHistory *targetHistory;

@end

@implementation A3QRCodeDataHandler

- (void)performActionWithData:(QRCodeHistory *)history inViewController:(UIViewController *)viewController {
	// Detection Order
	// GEO:37.566535,126.97769
	// SMS:"SMS:01074727077:hello" , SMS:(number):(message)
	// MECARD: https://www.nttdocomo.co.jp/english/service/developer/make/content/barcode/function/application/addressbook/index.html
	// BEGIN:VCARD
	// Event, BEGIN:VCALENDAR
	// Phone Number, email address, url
	// Finally, TEXT
	// Encrypted Option, ENC:data (Try)

	NSString *scanData = history.scanData;
	if ([scanData hasPrefix:@"GEO:"] && [self handleGEOLocation:history inViewController:viewController]) {return;}
	if ([scanData hasPrefix:@"SMS:"] && [self handleSMS:history inViewController:viewController]) {return;}
	if ([scanData hasPrefix:@"MECARD:"] && [self handleMeCard:history inViewController:viewController]) {return;};
	if ([scanData hasPrefix:@"BEGIN:VCARD"] && [self handleVCard:history inViewController:viewController]) {return;};
	if ([scanData hasPrefix:@"BEGIN:VCALENDAR"] && [self handleVCalendar:history inViewController:viewController]) {return;};
	if ([scanData hasPrefix:@"MedID:"] && [self handleMedicalID:history inViewController:viewController]) {return;};
	if ([scanData hasPrefix:@"skype:"] && [self handleSkype:history]) {return;};
	if ([self handleByDataDetector:history inViewController:viewController]) {return;};
	[self handleText:history inViewController:viewController];
}

- (BOOL)handleSkype:(QRCodeHistory *)history {
	NSURL *skypeURL = [NSURL URLWithString:history.scanData];
	return [[UIApplication sharedApplication] openURL:skypeURL];
}

- (BOOL)handleGEOLocation:(QRCodeHistory *)history inViewController:(UIViewController *)viewController {
	NSArray *components = [[history.scanData substringFromIndex:4] componentsSeparatedByString:@","];
	if ([components count] != 2) return NO;
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:[components[0] floatValue] longitude:[components[1] floatValue]];
	CLGeocoder *geocoder = [CLGeocoder new];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
		A3QRCodeMapViewController *mapViewController = [A3QRCodeMapViewController new];
		mapViewController.centerLocation = CLLocationCoordinate2DMake([components[0] floatValue], [components[1] floatValue]);
		A3PlaceAnnotation *annotation = [A3PlaceAnnotation new];
		annotation.coordinate = mapViewController.centerLocation;
		
		CLPlacemark *placemark = [placemarks firstObject];
		if (placemark) {
			NSString *userFriendlyName = placemark.name ?: [history.scanData substringFromIndex:4];
			if (placemark.locality) {
				userFriendlyName = [userFriendlyName stringByAppendingString:@", "];
				userFriendlyName = [userFriendlyName stringByAppendingString:placemark.locality];
			}
			if (placemark.administrativeArea) {
				userFriendlyName = [userFriendlyName stringByAppendingString:@", "];
				userFriendlyName = [userFriendlyName stringByAppendingString:placemark.administrativeArea];
			}
			annotation.title = userFriendlyName;
		} else {
			annotation.title = [history.scanData substringFromIndex:4];
		}
		mapViewController.annotation = annotation;
		[viewController.navigationController pushViewController:mapViewController animated:YES];
	}];
	
	return YES;
}

- (BOOL)handleSMS:(QRCodeHistory *)history inViewController:(UIViewController *)viewController {
	NSArray *components = [history.scanData componentsSeparatedByString:@":"];
	if ([components count] != 3) return NO;

	[self presentMessageViewControllerOn:viewController receipents:@[components[1]] body:components[2]];
	return YES;
}

- (void)presentMessageViewControllerOn:(UIViewController *)controller receipents:(NSArray *)recipients body:(NSString *)body {
	if (![MFMessageComposeViewController canSendText]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
															message:NSLocalizedString(@"iMessage is not enabled.", @"iMessage is not enabled.")
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];
		[alertView show];

		if ([_delegate respondsToSelector:@selector(dataHandlerDidFailToPresentViewController)]) {
			[_delegate dataHandlerDidFailToPresentViewController];
		}
		return;
	}
	MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
	if (messageViewController) {
		messageViewController.messageComposeDelegate = self;
		messageViewController.recipients = recipients;
		messageViewController.body = body;
		[controller presentViewController:messageViewController animated:YES completion:nil];
	} else {
		NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", recipients[0]]];
		[[UIApplication sharedApplication] openURL:URL];
	}
}

- (BOOL)handleMeCard:(QRCodeHistory *)history inViewController:(UIViewController *)viewController {
	self.targetHistory = history;
	self.targetViewController = viewController;

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Preview", @"Preview"), NSLocalizedString(@"Add a contact", @"Add a contact"), nil];
	actionSheet.tag = A3QRCodeActionSheetTypeMeCardAddContact;
	[actionSheet showInView:viewController.view];
	
	return YES;
}

- (void)processMeCardIsAdd:(BOOL)isAdd {
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	ABRecordRef newPerson = ABPersonCreate();
	
	NSScanner *scanner = [NSScanner scannerWithString:self.targetHistory.scanData];
	
	NSString *readString;
	if ([scanner scanUpToString:@"N:" intoString:nil]) {
		if ([scanner scanString:@"N:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFStringRef)readString, nil);
		}
	}
	
	readString = nil;
	scanner.scanLocation = 0;
	if ([scanner scanUpToString:@"SOUND:" intoString:nil]) {
		if ([scanner scanString:@"SOUND:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABRecordSetValue(newPerson, kABPersonFirstNamePhoneticProperty, (__bridge CFStringRef)readString, nil);
		}
	}
	
	scanner.scanLocation = 0;
	readString = nil;
	if ([scanner scanUpToString:@"TEL:" intoString:nil]) {
		if ([scanner scanString:@"TEL:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABMutableMultiValueRef phoneNumber = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			ABMultiValueAddValueAndLabel(phoneNumber, (__bridge CFStringRef)readString, kABPersonPhoneMobileLabel, NULL);
			ABRecordSetValue(newPerson, kABPersonPhoneProperty, phoneNumber, nil);
			CFRelease(phoneNumber);
		}
	}
	
	scanner.scanLocation = 0;
	readString = nil;
	if ([scanner scanUpToString:@"EMAIL:" intoString:nil]) {
		if ([scanner scanString:@"EMAIL:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			ABMultiValueAddValueAndLabel(email, (__bridge CFStringRef)readString, kABWorkLabel, NULL);
			ABRecordSetValue(newPerson, kABPersonEmailProperty, email, nil);
			CFRelease(email);
		}
	}
	
	scanner.scanLocation = 0;
	readString = nil;
	if ([scanner scanUpToString:@"NOTE:" intoString:nil]) {
		if ([scanner scanString:@"NOTE:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABRecordSetValue(newPerson, kABPersonNoteProperty, (__bridge CFStringRef)readString, nil);
		}
	}
	
	scanner.scanLocation = 0;
	if ([scanner scanUpToString:@"NICKNAME:" intoString:nil]) {
		if ([scanner scanString:@"NICKNAME:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABRecordSetValue(newPerson, kABPersonNicknameProperty, (__bridge CFStringRef)readString, nil);
		}
	}
	
	scanner.scanLocation = 0;
	if ([scanner scanUpToString:@"URL:" intoString:nil]) {
		if ([scanner scanString:@"URL:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			ABMutableMultiValueRef url = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			ABMultiValueAddValueAndLabel(url, (__bridge CFStringRef)readString, kABPersonHomePageLabel, NULL);
			ABRecordSetValue(newPerson, kABPersonURLProperty, url, nil);
			CFRelease(url);
		}
	}
	
	scanner.scanLocation = 0;
	if ([scanner scanUpToString:@"ADR:" intoString:nil]) {
		if ([scanner scanString:@"ADR:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			
			//// adding address details
			// create address object
			ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
			// create a new dictionary
			NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
			// set the address line to new dictionary object
			[addressDictionary setObject:readString forKey:(NSString *) kABPersonAddressStreetKey];
			//			// set the city to new dictionary object
			//			[addressDictionary setObject:@"Bengaluru" forKey:(NSString *)kABPersonAddressCityKey];
			//			// set the state to new dictionary object
			//			[addressDictionary setObject:@"Karnataka" forKey:(NSString *)kABPersonAddressStateKey];
			//			// set the zip/pin to new dictionary object
			//			[addressDictionary setObject:@"560068 " forKey:(NSString *)kABPersonAddressZIPKey];
			// retain the dictionary
			CFTypeRef ctr = CFBridgingRetain(addressDictionary);
			// copy all key-values from ctr to Address object
			ABMultiValueAddValueAndLabel(multiAddress,ctr, kABWorkLabel, NULL);
			// add address object to person
			ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress, nil);
			// release address object
			CFRelease(multiAddress);
		}
	}
	
	scanner.scanLocation = 0;
	if ([scanner scanUpToString:@"BDAY:" intoString:nil]) {
		if ([scanner scanString:@"BDAY:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			[dateFormatter setDateFormat:@"yyyyMMdd"];
			NSDate *date = [dateFormatter dateFromString:readString];
			
			if (date) {
				NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
				FNLOG(@"%ld, %ld", (long)components.day, (long)components.hour);
				components.hour = 12;
				date = [[[A3AppDelegate instance] calendar] dateFromComponents:components];
				
				ABRecordSetValue(newPerson, kABPersonBirthdayProperty, (__bridge CFDateRef)date, nil);
			}
		}
	}
	
//	CFErrorRef error;
//	ABAddressBookAddRecord(addressBook, newPerson, &error);
//	ABAddressBookSave(addressBook, nil);

	[self.targetViewController.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	if (isAdd) {
		ABNewPersonViewController *newPersonViewController = [ABNewPersonViewController new];
		newPersonViewController.addressBook = addressBook;
		newPersonViewController.displayedPerson = newPerson;
		newPersonViewController.newPersonViewDelegate = self;
		[self.targetViewController.navigationController pushViewController:newPersonViewController animated:YES];
	} else {
		ABPersonViewController *personViewController = [ABPersonViewController new];
		personViewController.addressBook = addressBook;
		personViewController.displayedPerson = newPerson;
		[self.targetViewController.navigationController setNavigationBarHidden:NO];
		[self.targetViewController.navigationController pushViewController:personViewController animated:YES];
	}
	
	CFRelease(newPerson);
	CFRelease(addressBook);
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
	[newPersonView.navigationController popViewControllerAnimated:YES];
}

- (BOOL)handleVCard:(QRCodeHistory *)history inViewController:(UIViewController *)viewController {
	_targetHistory = history;
	_targetViewController = viewController;

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Preview", @"Preview"), NSLocalizedString(@"Add a contact", @"Add a contact"), nil];
	actionSheet.tag = A3QRCodeActionSheetTypeVCardAddContact;
	[actionSheet showInView:viewController.view];

	return YES;
}

- (void)processVCardIsAdd:(BOOL)isAdd {
	CFDataRef vCardData = (__bridge CFDataRef)[_targetHistory.scanData dataUsingEncoding:NSUTF8StringEncoding];

	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

	ABRecordRef parsedPerson = nil;
	ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(addressBook);
	CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
	if (CFArrayGetCount(vCardPeople)) {
		parsedPerson = CFArrayGetValueAtIndex(vCardPeople, 0);
	}

	if (isAdd) {
		ABNewPersonViewController *personViewController = [ABNewPersonViewController new];
		personViewController.addressBook = addressBook;
		personViewController.displayedPerson = parsedPerson;
		personViewController.newPersonViewDelegate = self;
		[_targetViewController.navigationController setNavigationBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
		[_targetViewController.navigationController pushViewController:personViewController animated:YES];
	} else {
		ABPersonViewController *personViewController = [ABPersonViewController new];
		personViewController.addressBook = addressBook;
		personViewController.displayedPerson = parsedPerson;
		[_targetViewController.navigationController setNavigationBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
		[_targetViewController.navigationController pushViewController:personViewController animated:YES];
	}
	CFRelease(vCardPeople);
	CFRelease(defaultSource);
	CFRelease(addressBook);
}

-(void)print:(ABRecordRef)record {
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonMiddleNameProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonPrefixProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonSuffixProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonNicknameProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonFirstNamePhoneticProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonLastNamePhoneticProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonMiddleNamePhoneticProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonOrganizationProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonJobTitleProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonDepartmentProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonNoteProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonKindProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonBirthdayProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonCreationDateProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonModificationDateProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonEmailProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonAddressProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonDateProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonPhoneProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonInstantMessageProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonURLProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonRelatedNamesProperty));
	NSLog(@"kABPersonFirstNameProperty: %@", (__bridge NSString *)ABRecordCopyValue(record, kABPersonSocialProfileProperty));
}

- (BOOL)handleVCalendar:(QRCodeHistory *)history inViewController:(UIViewController *)viewController {
	MXLCalendarManager *parser = [MXLCalendarManager new];
	[parser parseICSString:history.scanData withCompletionHandler:^(MXLCalendar *calendar, NSError *error) {
		if (error) {
			return;
		}
		
		_parsedEventCalendar = calendar;
		_targetViewController = viewController;
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"Preview", @"Preview"), NSLocalizedString(@"Add to Calendar", @"Add to Calendar"), nil];
		actionSheet.tag = A3QRCodeActionSheetTypeAddEvent;
		[actionSheet showInView:viewController.view];
	}];
	return YES;
}

- (void)handleText:(QRCodeHistory *)history inViewController:(UIViewController *)controller {
	A3QRCodeTextViewController *viewController = [A3QRCodeTextViewController new];
	viewController.text = history.scanData;
	[controller.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)handleMedicalID:(QRCodeHistory *)history inViewController:(UIViewController *)controller {
	NSMutableArray<NSArray *> *sections = [NSMutableArray new];
	NSScanner *scanner = [NSScanner scannerWithString:history.scanData];
	
	NSMutableArray *rows = [NSMutableArray new];
	NSString *readString;
	if ([scanner scanUpToString:@"NAME:" intoString:nil]) {
		if ([scanner scanString:@"NAME:" intoString:nil]) {
			[scanner scanUpToString:@";" intoString:&readString];
			NSArray *components = [readString componentsSeparatedByString:@","];
			if ([components count] > 0) {
				[rows addObject:@{NSLocalizedString(@"First Name", @"First Name") :[components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] }];
			}
			if ([components count] > 1) {
				[rows addObject:@{NSLocalizedString(@"Last Name", @"Last Name") :[components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] }];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"BD:" intoString:nil]) {
			if ([scanner scanString:@"BD:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Birthday", @"Birthday") : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"GEN:" intoString:nil]) {
			if ([scanner scanString:@"GEN:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Gender", @"Gender") : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"ADR:" intoString:nil]) {
			if ([scanner scanString:@"ADR:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Address", @"Address") : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"KIN:" intoString:nil]) {
			if ([scanner scanString:@"KIN:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Nearest Kin", @"Nearest Kin") : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"KIN.TEL:" intoString:nil]) {
			if ([scanner scanString:@"KIN.TEL:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Kin Phone", @"Kin Phone") : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"BLD:" intoString:nil]) {
			if ([scanner scanString:@"BLD:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Blood Type", @"Blood Type") : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"ALLERG:" intoString:nil]) {
			if ([scanner scanString:@"ALLERG:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{@"Allergy" : readString} ];
			}
		}
		
		scanner.scanLocation = 0;
		readString = nil;
		if ([scanner scanUpToString:@"MORE:" intoString:nil]) {
			if ([scanner scanString:@"MORE:" intoString:nil]) {
				[scanner scanUpToString:@";"	 intoString:&readString];
				
				[rows addObject:@{NSLocalizedString(@"Additional Info", @"Additional Info") : readString} ];
			}
		}
	}
	[sections addObject:rows];
	
	A3QRCodeDetailViewController *viewController = [A3QRCodeDetailViewController new];
	viewController.historyData = history;
	viewController.sections = sections;
	[controller.navigationController pushViewController:viewController animated:YES];
	return YES;
}

- (BOOL)handleByDataDetector:(QRCodeHistory *)history inViewController:(UIViewController *)controller {
	NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
	NSTextCheckingResult *match = [dataDetector firstMatchInString:history.scanData options:0 range:NSMakeRange(0, [history.scanData length])];
	if ((match.resultType == NSTextCheckingTypeLink) && [[match.URL.scheme lowercaseString] isEqualToString:@"mailto"]) {
		MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setToRecipients:@[match.URL.resourceSpecifier]];
		[controller presentViewController:mailComposeViewController animated:YES completion:nil];
		return YES;
	} else if (match.resultType == NSTextCheckingTypePhoneNumber) {
		self.phoneNumber = [match.phoneNumber copy];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"Call", @"Call"), NSLocalizedString(@"SMS", @"SMS"), nil];
		actionSheet.tag = A3QRCodeActionSheetTypePhoneOrSMS;
		[actionSheet showInView:controller.view];
		return YES;
	} else if (match.resultType == NSTextCheckingTypeLink) {
		if ([[UIApplication sharedApplication] canOpenURL:match.URL]) {
			[controller.navigationController setNavigationBarHidden:NO];
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
			[controller presentWebViewControllerWithURL:match.URL];
			return YES;
		}
	}
	return NO;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == A3QRCodeActionSheetTypePhoneOrSMS) {
		if (buttonIndex == actionSheet.cancelButtonIndex) return;
		
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Call", @"Call")]) {
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.phoneNumber]];
			[[UIApplication sharedApplication] openURL:url];
		} else {
			[self presentMessageViewControllerOn:_targetViewController receipents:@[_phoneNumber] body:@""];
		}
	} else if (actionSheet.tag == A3QRCodeActionSheetTypeAddEvent) {
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			_parsedEventCalendar = nil;
			return;
		}

		BOOL isAdd = [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Add to Calendar", @"Add to Calendar")];

		void(^addEvent)(void) = ^() {
			EKEventStore *eventStore = [EKEventStore new];
			MXLCalendarEvent *event = _parsedEventCalendar.events[0];

			EKEventEditViewController *eventViewController = [EKEventEditViewController new];
			eventViewController.eventStore = eventStore;
			
			EKEvent *newEvent = eventViewController.event;
			newEvent.title = event.eventDescription;
			newEvent.startDate = event.eventStartDate;
			newEvent.endDate = event.eventEndDate;
			newEvent.allDay = event.eventIsAllDay;
			
			eventViewController.editViewDelegate = self;
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
			[_targetViewController presentViewController:eventViewController animated:YES completion:nil];
		};

		void(^previewEvent)(void) = ^() {
			EKEventStore *eventStore = [EKEventStore new];
			MXLCalendarEvent *event = _parsedEventCalendar.events[0];
			EKEvent *ekEvent = [EKEvent eventWithEventStore:eventStore];
			ekEvent.title = event.eventDescription;
			ekEvent.startDate = event.eventStartDate;
			ekEvent.endDate = event.eventEndDate;
			ekEvent.allDay = event.eventIsAllDay;

			EKEventViewController *eventViewController = [EKEventViewController new];
			eventViewController.event = ekEvent;
			[_targetViewController.navigationController setNavigationBarHidden:NO];
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
			[_targetViewController.navigationController pushViewController:eventViewController animated:YES];
		};

		EKEventStore *eventStore = [EKEventStore new];
		EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
		if (status != EKAuthorizationStatusAuthorized) {
			[eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
			 {
				 if (granted)
				 {
					 dispatch_async(dispatch_get_main_queue(), ^{
						 if (isAdd) {
							 addEvent();
						 } else {
							 previewEvent();
						 }
					 });
				 }
			 }];
		} else {
			if (isAdd) {
				addEvent();
			} else {
				previewEvent();
			}
		}
	} else if (actionSheet.tag == A3QRCodeActionSheetTypeMeCardAddContact) {
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			_targetHistory = nil;
			_targetViewController = nil;
			return;
		}
		BOOL isAdd = [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Add a contact", @"Add a contact")];
		[self processMeCardIsAdd:isAdd];
	} else if (actionSheet.tag == A3QRCodeActionSheetTypeVCardAddContact) {
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			_targetHistory = nil;
			_targetViewController = nil;
			return;
		}
		BOOL isAdd = [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Add a contact", @"Add a contact")];
		[self processVCardIsAdd:isAdd];
	}
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma  mark - EKEventViewControllerDelegate

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	[controller dismissViewControllerAnimated:YES completion:nil];

	NSError *error = nil;
	EKEvent *thisEvent = controller.event;

	switch (action) {
		case EKEventEditViewActionCanceled:
			// Edit action canceled, do nothing.
			break;

		case EKEventEditViewActionSaved: {
			// When user hit "Done" button, save the newly created event to the event store
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			break;
		}

		case EKEventEditViewActionDeleted:
			// When deleting an event, remove the event from the event store
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			break;

		default:
			break;
	}
}

@end
