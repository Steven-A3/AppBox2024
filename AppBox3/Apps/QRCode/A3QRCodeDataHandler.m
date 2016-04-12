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

@interface A3QRCodeDataHandler () < MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate,
UIActionSheetDelegate, EKEventEditViewDelegate>

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, weak) UIViewController *targetViewController;
@property (nonatomic, strong) MXLCalendar *parsedEventCalendar;

@end

@implementation A3QRCodeDataHandler

- (void)performActionWithData:(NSString *)data inViewController:(UIViewController *)viewController {
	// Detection Order
	// GEO:37.566535,126.97769
	// SMS:"SMS:01074727077:hello" , SMS:(number):(message)
	// MECARD: https://www.nttdocomo.co.jp/english/service/developer/make/content/barcode/function/application/addressbook/index.html
	// BEGIN:VCARD
	// Event, BEGIN:VCALENDAR
	// Phone Number, email address, url
	// Finally, TEXT
	// Encrypted Option, ENC:data (Try)

	if ([data hasPrefix:@"GEO:"] && [self handleGEOLocation:data inViewController:viewController]) {return;}
	if ([data hasPrefix:@"SMS:"] && [self handleSMS:data inViewController:viewController]) {return;}
	if ([data hasPrefix:@"MECARD:"] && [self handleMeCard:data inViewController:viewController]) {return;};
	if ([data hasPrefix:@"BEGIN:VCARD"] && [self handleVCard:data inViewController:viewController]) {return;};
	if ([data hasPrefix:@"BEGIN:VCALENDAR"] && [self handleVCalendar:data inViewController:viewController]) {return;};
	if ([self handleByDataDetector:data inViewController:viewController]) {return;};
	[self handleText:data inViewController:viewController];
}

- (BOOL)handleGEOLocation:(NSString *)data inViewController:(UIViewController *)viewController {
	NSArray *components = [[data substringFromIndex:4] componentsSeparatedByString:@","];
	if ([components count] != 2) return NO;
	A3QRCodeMapViewController *mapViewController = [A3QRCodeMapViewController new];
	mapViewController.centerLocation = CLLocationCoordinate2DMake([components[0] floatValue], [components[1] floatValue]);
	A3PlaceAnnotation *annotation = [A3PlaceAnnotation new];
	annotation.coordinate = mapViewController.centerLocation;
	annotation.title = [data substringFromIndex:4];
	mapViewController.annotation = annotation;
	[viewController.navigationController pushViewController:mapViewController animated:YES];
	return YES;
}

- (BOOL)handleSMS:(NSString *)data inViewController:(UIViewController *)viewController {
	NSArray *components = [data componentsSeparatedByString:@":"];
	if ([components count] != 3) return NO;

	[self presentMessageViewControllerOn:viewController receipents:@[components[1]] body:components[2]];
	return YES;
}

- (void)presentMessageViewControllerOn:(UIViewController *)controller receipents:(NSArray *)recipients body:(NSString *)body {
	MFMessageComposeViewController *messageViewController = [MFMessageComposeViewController new];
	messageViewController.messageComposeDelegate = self;
	messageViewController.recipients = recipients;
	messageViewController.body = body;
	[controller presentViewController:messageViewController animated:YES completion:nil];
}

- (BOOL)handleMeCard:(NSString *)data inViewController:(UIViewController *)viewController {
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	ABRecordRef newPerson = ABPersonCreate();

	NSScanner *scanner = [NSScanner scannerWithString:data];
	
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

	CFErrorRef error;
	ABAddressBookAddRecord(addressBook, newPerson, &error);
	ABAddressBookSave(addressBook, nil);
	
	ABPersonViewController *personViewController = [ABPersonViewController new];
	personViewController.displayedPerson = newPerson;
	[viewController.navigationController pushViewController:personViewController animated:YES];

	CFRelease(newPerson);
	CFRelease(addressBook);
	
	return YES;
}

- (BOOL)handleVCard:(NSString *)data inViewController:(UIViewController *)viewController {
	CFDataRef vCardData = (__bridge CFDataRef)[data dataUsingEncoding:NSUTF8StringEncoding];
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

	ABRecordRef parsedPerson;
	ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(addressBook);
	CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
	for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++) {
		ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
		
		[self print:person];
		
		parsedPerson = person;
		
		//ABAddressBookAddRecord(book, person, NULL);
		CFRelease(person);
	}
	
	//CFRelease(vCardPeople);
	CFRelease(defaultSource);
	CFRelease(addressBook);

	ABPersonViewController *personViewController = [ABPersonViewController new];
	personViewController.displayedPerson = parsedPerson;
	[viewController.navigationController pushViewController:personViewController animated:YES];

	return YES;
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

- (BOOL)handleVCalendar:(NSString *)data inViewController:(UIViewController *)viewController {
	MXLCalendarManager *parser = [MXLCalendarManager new];
	[parser parseICSString:data withCompletionHandler:^(MXLCalendar *calendar, NSError *error) {
		if (error) {
			return;
		}
		
		_parsedEventCalendar = calendar;
		_targetViewController = viewController;
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Event"
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Add", nil];
		actionSheet.tag = 2000;
		[actionSheet showInView:viewController.view];
	}];
	return YES;
}

- (void)handleText:(NSString *)data inViewController:(UIViewController *)controller {
	A3QRCodeTextViewController *viewController = [A3QRCodeTextViewController new];
	viewController.text = data;
	[controller.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)handleByDataDetector:(NSString *)data inViewController:(UIViewController *)controller {
	NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
	NSTextCheckingResult *match = [dataDetector firstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
	if ((match.resultType == NSTextCheckingTypeLink) && [[match.URL.scheme lowercaseString] isEqualToString:@"mailto"]) {
		MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setToRecipients:@[match.URL.resourceSpecifier]];
		[controller presentViewController:mailComposeViewController animated:YES completion:nil];
		return YES;
	} else if (match.resultType == NSTextCheckingTypePhoneNumber) {
		self.phoneNumber = [match.phoneNumber copy];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:match.phoneNumber
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Call", @"SMS", nil];
		actionSheet.tag = 1000;
		[actionSheet showInView:controller.view];
		return YES;
	} else if (match.resultType == NSTextCheckingTypeLink) {
		if ([[UIApplication sharedApplication] canOpenURL:match.URL]) {
			[controller presentWebViewControllerWithURL:match.URL];
			return YES;
		}
	}
	return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 1000) {
		if (buttonIndex == actionSheet.cancelButtonIndex) return;
		
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Call"]) {
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.phoneNumber]];
			[[UIApplication sharedApplication] openURL:url];
		} else {
			[self presentMessageViewControllerOn:_targetViewController receipents:@[_phoneNumber] body:@""];
		}
	} else if (actionSheet.tag == 2000) {
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			_parsedEventCalendar = nil;
			return;
		}

		EKEventStore *eventStore = [EKEventStore new];

		void(^addEvent)(void) = ^() {
			MXLCalendarEvent *event = _parsedEventCalendar.events[0];

			EKEventEditViewController *eventViewController = [EKEventEditViewController new];
			eventViewController.eventStore = eventStore;
			
			EKEvent *newEvent = eventViewController.event;
			newEvent.title = event.eventDescription;
			newEvent.startDate = event.eventStartDate;
			newEvent.endDate = event.eventEndDate;
			newEvent.allDay = event.eventIsAllDay;
			
			eventViewController.editViewDelegate = self;
			[_targetViewController presentViewController:eventViewController animated:YES completion:nil];
		};
		
		EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
		if (status != EKAuthorizationStatusAuthorized) {
			[eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
			 {
				 if (granted)
				 {
					 dispatch_async(dispatch_get_main_queue(), ^{
						 addEvent();
					 });
				 }
			 }];
		} else {
			addEvent();
		}
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
