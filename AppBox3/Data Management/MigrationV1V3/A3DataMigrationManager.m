//
//  A3DataMigrationManager.m
//  AppBox3
//
//  Created by A3 on 5/26/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DataMigrationManager.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDate.h"
#import "A3DaysCounterDefine.h"
#import "LadyCalendarPeriod.h"
#import "LadyCalendarAccount.h"
#import "A3LadyCalendarModelManager.h"
#import "TranslatorGroup.h"
#import "TranslatorGroup+manage.h"
#import "TranslatorHistory.h"
#import "TranslatorHistory+manager.h"
#import "NSData-AES.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "WalletItem.h"
#import "WalletField+initialize.h"
#import "WalletFieldItem+initialize.h"
#import "WalletFieldItemImage.h"
#import "A3UserDefaults.h"
#import "WalletData.h"
#import "WalletItem+initialize.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent+management.h"
#import "A3AppDelegate.h"

NSString *const kKeyForDDayTitle 					= @"kKeyForDDayTitle";
NSString *const kKeyForDDayDate						= @"kKeyForDDayDate";
NSString *const kKeyForDDayEnds						= @"kKeyForDDayEnds";
NSString *const kKeyForDDayType						= @"kKeyForDDayType";
NSString *const kKeyForDDayRepeat					= @"kKeyForDDayRepeat";
NSString *const kKeyForDDayBadgeType				= @"kKeyForDDayBadgeType";						// For Badge
NSString *const kKeyForDDayBadgeTerm				= @"kKeyForDDayBadgeTerm";
NSString *const kKeyForDDayNotificationMinutes      = @"kKeyForDDayNotificationMinutesBefore";
// Integer,
// -2 : Custom
// -1 : Don't make a notification (or missing)
//  0 : Use "kKeyForDDayNotificationTime" to make notification
// >0 : Use "kKeyForDDayNotificationTime" to make notification and this value contains minutes from eventStart when eventDateType == 1
NSString *const kKeyForDDayNotificationTime			= @"kKeyForDDayNotificationTime";
NSString *const kKeyForDDayImageFilename			= @"kKeyForDDayImageFilename";
NSString *const kKeyForDDayMemo						= @"kKeyForDDayMemo";
NSString *const kKeyForDDayShowCountdown			= @"kKeyForDDayShowCountdown";

@interface A3DataMigrationManager ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation A3DataMigrationManager

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	self = [super init];
	if (self) {
		_context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		_context.persistentStoreCoordinator = persistentStoreCoordinator;
		_context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
		_context.undoManager = nil;
	}
	return self;
}

/*!
 * \param password, pass nil for default security code
 * \returns
 */
- (void)migrateV1DataWithPassword:(NSString *)password {
	[self migrateDaysCounterInContext:_context];
	[self migrateLadyCalendarInContext:_context];
	[self migrateTranslatorHistoryInContext:_context];
	[self migrateWalletDataInContext:_context withPassword:password];

	// Reload main context after V1 data migration.
	[[[A3AppDelegate instance] managedObjectContext] reset];

	if ([_delegate respondsToSelector:@selector(migrationManager:didFinishMigration:)]) {
		[_delegate migrationManager:self didFinishMigration:YES];
	}
}

- (NSString *)migrationDirectory {
	if (!_migrationDirectory) {
		_migrationDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
	}
	return _migrationDirectory;
}

- (NSString *)pathForFilename:(NSString *)filename {
	return [self.migrationDirectory stringByAppendingPathComponent:filename];
}

#pragma mark - Days Until

- (NSString *)daysUntilV1DataFilePath {
	return [self pathForFilename:@"DDayData.db"];
}

- (void)migrateDaysCounterInContext:(NSManagedObjectContext *)context {
	NSString *v1DataFilePath = [self daysUntilV1DataFilePath];
	NSArray *V1DataArray = [[NSArray alloc] initWithContentsOfFile:v1DataFilePath];
	if (![V1DataArray count]) {
		FNLOG(@"DaysUntil does not have V1 data.");
		return;
	}

	A3DaysCounterModelManager *modelManager = [A3DaysCounterModelManager new];
	[modelManager prepare];
	[context reset];

	DaysCounterCalendar *daysCounterCalendar = [DaysCounterCalendar MR_findFirstOrderedByAttribute:@"order" ascending:YES inContext:context];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	for (NSDictionary *v1Item in V1DataArray) {
		@autoreleasepool {
			DaysCounterEvent *newEvent = [DaysCounterEvent MR_createInContext:context];
			newEvent.uniqueID = [[NSUUID UUID] UUIDString];
			newEvent.calendar = daysCounterCalendar;
			newEvent.eventName = v1Item[kKeyForDDayTitle];
			newEvent.isAllDay = @([v1Item[kKeyForDDayType] integerValue] == 0);
			newEvent.durationOption = @(DurationOption_Day);

			newEvent.startDate = [DaysCounterDate MR_createInContext:context];
			newEvent.startDate.solarDate = v1Item[kKeyForDDayDate];
			newEvent.effectiveStartDate = newEvent.startDate.solarDate;

			NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:newEvent.startDate.solarDate];
			newEvent.startDate.year = @(components.year);
			newEvent.startDate.month = @(components.month);
			newEvent.startDate.day = @(components.day);
			newEvent.startDate.hour = @(components.hour);
			newEvent.startDate.minute = @(components.minute);
			NSDate *endDate = v1Item[kKeyForDDayEnds];
			if (endDate) {
				newEvent.endDate = [DaysCounterDate MR_createInContext:context];
				newEvent.endDate.solarDate = endDate;
			}
			newEvent.repeatType = @([self repeatTypeForV1RepeatType:v1Item[kKeyForDDayRepeat]]);
			NSString *filename = v1Item[kKeyForDDayImageFilename];
			NSString *filePath = [self pathForFilename:filename];
			if ([filename length] && [fileManager fileExistsAtPath:filePath] ) {
				newEvent.hasPhoto = @YES;
				NSString *photoPath = [newEvent photoPathInOriginalDirectory:YES];
				[fileManager removeItemAtPath:photoPath error:NULL];
				[fileManager moveItemAtPath:filePath toPath:photoPath error:NULL];
			}
			newEvent.notes = v1Item[kKeyForDDayMemo];

			[context MR_saveToPersistentStoreAndWait];
		}
	}
}

- (A3DaysCounterRepeatType)repeatTypeForV1RepeatType:(NSNumber *)v1RepeatType {
	switch([v1RepeatType integerValue]) {
		case 1:
			return RepeatType_EveryDay;
		case 2:
			return RepeatType_EveryWeek;
		case 3:
			return RepeatType_Every2Week;
		case 4:
			return RepeatType_EveryMonth;
		case 5:
			return RepeatType_EveryYear;
		default:
			return RepeatType_Never;
	}
}

#pragma mark - Lady Calendar

NSString *const kMyGirlsDayDataTypeHistory				= @"history";
NSString *const kMyGirlsDayHistoryTypeInput				= @"input";

- (NSString *)ladyCalendarDataFilePath {
	return [self pathForFilename:@"myGirlsDayData.db"];
}

- (void)migrateLadyCalendarInContext:(NSManagedObjectContext *)context {
	NSDictionary *dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:[self ladyCalendarDataFilePath]];
	NSArray *history = dataDictionary[kMyGirlsDayDataTypeHistory];
	if (![history count]) {
		return;
	}

	// Create Default account and get account
	A3LadyCalendarModelManager *dataManager = [A3LadyCalendarModelManager new];
	[dataManager prepareAccount];

	NSString *accountID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
	LadyCalendarAccount *account = [LadyCalendarAccount MR_findFirstByAttribute:@"uniqueID" withValue:accountID inContext:context];

	for (NSArray *item in history) {
		if ([item[0] isEqualToString:kMyGirlsDayHistoryTypeInput]) {
			@autoreleasepool {
				LadyCalendarPeriod *period = [LadyCalendarPeriod MR_createInContext:context];
				period.uniqueID = [[NSUUID UUID] UUIDString];
				period.account = account;
				period.startDate = item[1];
				period.endDate = item[2];
				period.cycleLength = @([item[3] integerValue]);
				[context MR_saveToPersistentStoreAndWait];
			}
		}
	}
}

#pragma mark - Translator

NSString *const kABP_TR_FAVORITES_ARRAY			= @"kABP_TR_FAVORITES_ARRAY";
NSString *const kSourceLanguageCode				= @"kSourceLanguageCode";
NSString *const kSourceText						= @"kSourceText";
NSString *const kTargetLanguageCode				= @"kTargetLanguageCode";
NSString *const kTargetText						= @"kTargetText";

- (NSString *)translatorDataFilePath {
	return [self pathForFilename:@"translatorFavorites.db"];
}

- (void)migrateTranslatorHistoryInContext:(NSManagedObjectContext *)context {
	NSDictionary *dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:[self translatorDataFilePath]];
	NSArray *historyArray = dataDictionary[kABP_TR_FAVORITES_ARRAY];
	if (![historyArray count]) {
		return;
	}
	NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"sourceLanguage == $source AND targetLanguage == $target"];
	for (NSDictionary *item in historyArray) {
		@autoreleasepool {
			NSString *sourceLanguageCode = item[kSourceLanguageCode];
			NSString *targetLanguageCode = item[kTargetLanguageCode];
			NSPredicate *predicate = [predicateTemplate predicateWithSubstitutionVariables:@{@"source":sourceLanguageCode, @"target":targetLanguageCode}];
			TranslatorGroup *group = [TranslatorGroup MR_findFirstWithPredicate:predicate inContext:context];
			if (!group) {
				group = [TranslatorGroup MR_createInContext:context];
				[group setupOrder];
				group.sourceLanguage = sourceLanguageCode;
				group.targetLanguage = targetLanguageCode;
			}
			TranslatorHistory *history = [TranslatorHistory MR_createInContext:context];
			history.date = [NSDate date];
			history.group = group;
			history.originalText = item[kSourceText];
			history.translatedText = item[kTargetText];
			[history setAsFavoriteMember:YES];

			[context MR_saveToPersistentStoreAndWait];
		}

	}
}

#pragma mark - Wallet

- (NSString *)walletDataFilePath {
	return [self pathForFilename:@"wallet.db"];
}

NSString *const DEFAULT_SECURITY_KEY		= @"d54?qjS8QD[.,UasG2R7FhS8?uk-D9+L";
NSString *const KWalletDictionary			= @"KeyWalletDictionary";
NSString *const KWalletTypeInfoArray		= @"KeyWalletTypeInfoArray";
NSString *const KWalletTypeInfoDictionary	= @"KeyWalletTypeInfoDictionary";
NSString *const KWalletFieldInfoArray		= @"KeyWalletFieldInfoArray";
NSString *const KWalletFieldInfoDictionary	= @"KeyWalletFieldInfoDictionary";

NSString *const KWalletTypeName				= @"KeyWalletTypeName";
NSString *const KWalletTypeIconPath			= @"KeyWalletTypeIconPath";
NSString *const KWalletTypeID				= @"KeyWalletTypeID";

NSString *const KWalletItemInfoDictionary	= @"KeyWalletItemInfoDictionary";
NSString *const KWalletItemName				= @"KeyWalletItemName";
NSString *const KWalletItemIconPath			= @"KeyWalletItemIconPath";
NSString *const KWalletValueDictionary		= @"KeyWalletValueDictionary";
NSString *const KWalletValueLastUpdated		= @"KeyWalletValueLastUpdated";

NSString *const WalletFieldType				= @"WALLETFIELDTYPE";		//  Key, string
NSString *const WalletFieldName				= @"WALLETFIELDNAME";		//  Key, string
NSString *const WalletFieldStyle			= @"WALLETFIELDSTYLE";		//  Key, string
NSString *const WalletFieldID				= @"WALLETFIELDID";		//	Key, string
NSString *const WalletFieldIDForMemo		= @"MEMO";					//	Static Key, string

- (BOOL)walletDataFileExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self walletDataFilePath]];
}

- (NSDictionary *)walletDataWithPassword:(NSString *)password {
	NSData *walletData = [[NSData alloc] initWithContentsOfFile:[self walletDataFilePath]];
	if (!walletData) {
		return nil;
	}
	walletData = [walletData AESDecryptWithPassphrase:[password length] ? password : DEFAULT_SECURITY_KEY];
	if (!walletData) {
		FNLOG(@"Failed to decrypt data file.");
		return nil;
	}
	NSError *error;
	NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:walletData options:NSPropertyListImmutable format:NULL error:&error];
	if (error) {
		FNLOG(@"Failed to parse the property file.");
		FNLOG(@"%@\n%@", error.localizedDescription, error.localizedFailureReason);
		return nil;
	}
	return dictionary;
}

- (BOOL)migrateWalletDataInContext:(NSManagedObjectContext *)context withPassword:(NSString *)password {
	[WalletData createDirectories];
	[WalletCategory resetWalletCategory];
	[context reset];

	if (![self walletDataFileExists]) {
		FNLOG(@"Wallet Data File does not exist. Nothing to migrate.");
		return YES;
	}
	NSDictionary *walletDictionary = [self walletDataWithPassword:password];
	if (!walletDictionary) {
		FNLOG(@"Failed to read wallet data file.");
		return NO;
	}

	NSMutableDictionary *categoryMap = [[self categoryMap] mutableCopy];
	NSMutableDictionary *allFieldMap = [[self fieldMap] mutableCopy];

	NSArray *V1CategoryInfoArray = walletDictionary[KWalletTypeInfoArray];

	NSFileManager *fileManager = [NSFileManager defaultManager];

	for (NSDictionary *V1Category in V1CategoryInfoArray) {
		@autoreleasepool {
			NSString *V1CategoryID = V1Category[KWalletTypeID];
			NSArray *V1FieldItemsArray = walletDictionary[V1CategoryID];
			if (!V1FieldItemsArray) continue;

			NSString *V3CategoryID = categoryMap[V1CategoryID];
			if (!V3CategoryID) {
				// TODO: CategoryID does not Exist? User made new category
				// 카테고리를 추가해야 한다.
			}
			WalletCategory *category = [WalletCategory MR_findFirstByAttribute:@"uniqueID" withValue:V3CategoryID inContext:context];
			category.name = V1Category[KWalletTypeName];
			NSArray *V1FieldInfoArray = V1Category[KWalletFieldInfoArray];

			NSMutableDictionary *fieldMap = [allFieldMap[V1CategoryID] mutableCopy];

			// Copy fields name from V1
			for (NSDictionary *V1FieldInfo in V1FieldInfoArray) {
				NSString *V3FieldID = fieldMap[V1FieldInfo[WalletFieldID]];
				WalletField *V3Field = [WalletField MR_findFirstByAttribute:@"uniqueID" withValue:V3FieldID inContext:context];
				V3Field.name = V1FieldInfo[WalletFieldName];
			}
			[context MR_saveToPersistentStoreAndWait];

			for (NSDictionary *valueInfo in V1FieldItemsArray) {
				@autoreleasepool {
					WalletItem *newItem = [WalletItem MR_createInContext:context];
					newItem.uniqueID = [[NSUUID UUID] UUIDString];
					[newItem assignOrder];
					newItem.category = category;
					newItem.name = valueInfo[KWalletItemName];
					NSDictionary *valueDictionary = valueInfo[KWalletValueDictionary];
					newItem.modificationDate = valueDictionary[KWalletValueLastUpdated];

					[context MR_saveToPersistentStoreAndWait];

					for (NSString *fieldID in valueDictionary.allKeys) {
						@autoreleasepool {
							if ([fieldID isEqualToString:KWalletValueLastUpdated]) continue;
							if ([fieldID isEqualToString:WalletFieldIDForMemo]) {
								newItem.note = valueDictionary[fieldID];
								continue;
							}

							NSUInteger fieldInfoIndex = [V1FieldInfoArray indexOfObjectPassingTest:^BOOL(NSDictionary *fieldInfo, NSUInteger idx, BOOL *stop) {
								return [fieldInfo[WalletFieldID] isEqualToString:fieldID];
							}];
							if (fieldInfoIndex != NSNotFound) {
								WalletFieldItem *V3FieldItem = [WalletFieldItem MR_createInContext:context];
								V3FieldItem.uniqueID = [[NSUUID UUID] UUIDString];
								[newItem addFieldItemsObject:V3FieldItem];

								NSString *V3FieldID = fieldMap[fieldID];
								if (!V3FieldID) {
									// TODO: fieldInfo does not exist.
									// Field 정보를 추가 해야 한다.

								} else {
									WalletField *V3Field = [WalletField MR_findFirstByAttribute:@"uniqueID" withValue:V3FieldID inContext:context];
									V3FieldItem.field = V3Field;
								}

								NSDictionary *V1FieldInfo = V1FieldInfoArray[fieldInfoIndex];
								if ([V1FieldInfo[WalletFieldType] isEqualToString:WalletFieldTypeImage]) {
									WalletFieldItemImage *itemImage = [WalletFieldItemImage MR_createInContext:context];
									itemImage.fieldItem = V3FieldItem;

									NSString *filePath = [V3FieldItem photoImagePathInOriginalDirectory:YES];
									[fileManager removeItemAtPath:filePath error:NULL];
									[fileManager moveItemAtPath:[self pathForFilename:valueDictionary[fieldID]] toPath:filePath error:NULL];

								} else if ([V1FieldInfo[WalletFieldType] isEqualToString:WalletFieldTypeDate]) {
									V3FieldItem.date = valueDictionary[fieldID];
								} else {
									V3FieldItem.value = valueDictionary[fieldID];
								}
								[context MR_saveToPersistentStoreAndWait];
							} else {
								FNLOG(@"fieldInfo not found. %@, %@", V1CategoryID, fieldID);
							}
						}
					}
				}
			}
		}
	}
	return YES;
}

- (NSDictionary *)fieldMap {
	return @{
			@"T163" : @{                                                	// Bank Account
					@"F622" : @"408B2E88-130F-49AB-9F79-794CF0869898",    	// Account Number
					@"F130" : @"314C11BF-FA08-4A3F-883C-9ECBBA3B7F21",    	// Routing Number
					@"F340" : @"05D7BDB3-6C8A-40D3-B462-B2B1740C42E3",    	// Screen Name
					@"F638" : @"3953D729-165E-4210-9207-E7263BBA3D91",    	// Password for screen name
					@"F748" : @"CDBAB9CF-394D-44AC-A0B0-6DDF39B85447",    	// Photo
					@"F636" : @"DA56EA9D-9DC8-43CD-AA3A-F46A02B7F397",    	// PIN
					@"F76" : @"0D1F5721-C13A-42E6-950A-DF921F78FB50",    	// Branch
					@"F795" : @"A61DE35E-DFBA-4CC0-B1B4-C8216AE1E739",    	// Phone
			},
			@"T635" : @{                                                	// Calling Cards
					@"F636" : @"7A6E260F-1C17-48DC-9710-E22D980FC43B",    	// Access Number
					@"F232" : @"33C0B1ED-64FD-47A2-AED3-16298623DAE3",    	// PIN
					@"F707" : @"A4F60D4F-1784-422F-B429-890E5E56BB0E",    	// Photo
			},
			@"T301" : @{                                                	// Combinations
					@"F389" : @"91D8A8E1-6AEB-4401-B805-87559BE3353D",    	// Code
			},
			@"T174" : @{                                                	// Credit Cards
					@"F669" : @"AC698B66-3E14-4231-AE6E-AA01CDB4F9F1",    	// Card Number
					@"F528" : @"4822DED1-3A69-4D86-AA9A-5A85159D52BC",    	// Holder Name
					@"F352" : @"605BDAE6-677B-4307-8BF9-CAAD67303E6B",    	// Expiration
					@"F369" : @"6017A87F-86AC-4537-B147-6618D3DA9C88",    	// Password
					@"F724" : @"EF0CD2CE-9896-416C-BC4B-F2CFE39EC02F",    	// Photo
					@"F614" : @"DC7A50A8-43A7-4843-AAA3-051FDB7C6CE8",    	// Billing Zip Code
					@"F175" : @"234C6127-4BB9-43B0-B1D1-B5F9D01FA9A5",    	// PIN
					@"F964" : @"2C5E538E-BA78-4868-A2D4-D75896489E69",    	// Bank
					@"F420" : @"AF84B291-1348-4347-8F10-ADFC3D4A9CC2",    	// Support Phone
			},
			@"T82" : @{                                                    	// Driver License
					@"F277" : @"9E1A5B0E-AE8C-416C-A401-C30BDA486263",    	// License Number
					@"F943" : @"67BEF47C-237E-4DED-9496-762218B996D7",    	// State
					@"F13" : @"DE7DB902-02C0-4859-81DF-677F15576A6B",    	// Expires
					@"F960" : @"3615ACF3-F118-41D2-BC0A-CF65DB03FD9B",    	// Class
					@"F679" : @"026BF5FD-B60F-4DB3-A7A7-38D7549C36EB",    	// Issued
					@"F793" : @"2519144E-4A09-4921-AC30-36683FE7222F",    	// Photo
			},
			@"T43" : @{                                                    	// Email
					@"F905" : @"711F5334-109A-4959-836A-247B04428BBB",    	// Provider
					@"F10"	: @"5E19C012-125A-4AE0-8750-72D45FD13E26",		// Username
					@"F273" : @"11707027-0E20-4AE3-9A67-B929B2601136",		// Password
					@"F957" : @"AB4BD62B-AA07-47B2-B314-0E948E14044B",		// POP3 Host
					@"F851" : @"6C0F5534-5B38-46D5-82AE-D52D4309B958",		// Port
					@"F640" : @"9AF025D6-13C8-44CB-9FFE-911E7913322A",		// SMTP Host
			},
			@"T304" : @{													// Family
					@"F622" : @"7A4895A5-3404-43C5-BD3A-681BDAC1D63F",		// Name
					@"F499" : @"46AFECAE-B345-47BA-B22A-7236438118CE",		// Birthday
					@"F25"  : @"0852C643-F9F2-44ED-9453-676DB7149D6D",		// Mobile Phone
					@"F849" : @"D091CDEA-0032-4718-A357-6B1E2F220664",		// Dress Size
					@"F480" : @"50F8E9ED-43BD-4E6E-8E85-4FB9BFCDFE27",		// Shoe Size
			},
			@"T303" : @{													// Frequent Flyer
					@"F549" : @"61261AD0-56DC-4D73-960D-54CC8611E37F",		// Airline
					@"F812" : @"9F84DB93-07C0-4534-9C62-BDDC45CC3804",		// Number
					@"F968" : @"30C42B91-4DB7-4A52-9B07-285AE87FD9F9",		// Photo
			},
			@"T354" : @{													// Insurance
					@"F22" 	: @"62775023-7A4B-43B0-AB63-064744A85197",		// Name
					@"F57"  : @"35B4691E-49D3-4417-94E8-A6741CECB8C6",		// Type
					@"F548" : @"B92F9FFE-04B2-4DAF-A31E-BC46887A79DC",		// Policy Number
					@"F460" : @"1D3AEDB0-5652-4AE6-B224-0DD87E010A36",		// Expiration
					@"F144" : @"C78C7C9C-7BBC-47D0-BB8C-05627F8ABEF6",		// Phone
					@"F21"  : @"979530E4-5B8A-46E0-935E-16B6F260FDA3",		// URL
			},
			@"T143" : @{													// Memberships
					@"F178" : @"235152AF-0CB6-4489-BDA6-CCC6009D7648",		// Name
					@"F634" : @"ADD3D80C-AE2F-4A96-BB28-4329CCA59A33",		// Account Number
					@"F616" : @"D350A936-820C-4CC8-8D85-99560687FF31",		// Expiration
					@"F617" : @"46DD7D02-11E4-460D-AD03-4E33F317354B",		// URL
					@"F528" : @"05F7130A-59E5-4348-99FF-A72DAB6AB83B",		// Web Account
					@"F633" : @"BB8F93B5-5A58-4F3A-85C8-12418D7CC4C8",		// Password
					@"F124" : @"3E8409A9-2FFA-4D1C-83AD-43880D77D581",		// PIN
			},
			@"T592" : @{													// Passport
					@"F83"  : @"5FCAF1BC-15C6-4D86-B6F8-1F3B40087BAF",		// Name
					@"F962" : @"4F3AE65C-D449-4B41-81B5-5CAE872E6EB3",		// Number
					@"F751" : @"7429FDA0-5CCD-4CE3-980D-0ED8413D31F3",		// Expiration
					@"F154" : @"ED3D4592-A2B1-4400-A6F2-D439E3FD3D28",		// Issued
					@"F915" : @"B65CE4AC-6B49-4F2E-81A3-2D5246191F24",		// Photo
			},
			@"T285" : @{													// Personal Info
					@"F812" : @"CFEE0B9E-9FCC-4E7B-B91C-5F7E574147DE",		// Name
					@"F461" : @"F6C45392-1A8F-448A-A431-8A8749CFAA06",		// SSN
					@"F829" : @"88443AD9-C3BB-442C-A203-94F97511BB4C",		// Date
			},
			@"T817" : @{													// Photos
					@"F554" : @"822EFC58-01E0-4B8B-BE1D-3FB5E6E27E86",		// Photo
			},
			@"T835" : @{													// Prescriptions
					@"F240" : @"8F567D64-99E4-4D96-9AC5-5BE87CC9AC8D",		// Rx Number
					@"F608" : @"A3428351-B210-4332-99AC-9F1B1F21E5AB",		// Name
					@"F450" : @"CA778D77-CCB0-430E-942A-4F5E455186D1",		// Doctor
					@"F292" : @"5391E23E-D0D4-40B3-BEB4-9761F7149AC2",		// Doctor Phone
					@"F625" : @"3574CF44-E027-4A87-AA6B-8ACEC31DFBA9",		// Pharmacy
					@"F309" : @"F55343A1-19D1-4AAE-86A4-E1A0066AB83C",		// Pharmacy Phone
			},
			@"T289" : @{
					@"F659" : @"1C9BDD31-95CA-402C-A7FC-5654AD2A2BA6",		// Plate
					@"F378" : @"F792FA0D-7F07-4A55-A1E3-2533ED30C471",		// Maker
					@"F27"  : @"27830F1D-6C57-46B7-BCE7-27C055ED1ED5",		// Model
					@"F290" : @"DC853A24-C979-464D-A159-1F7335780392",		// VIN
					@"F570" : @"6FA68677-58DB-405E-A009-95B0E3E422C0",		// Service Phone
			},
			@"T673" : @{													// Account (Web Account)
					@"F306" : @"25264B49-91E8-47C1-94CC-A42C86D9F217",		// ID
					@"F148" : @"5240FD26-87DE-4C13-A584-A13AA0E14744",		// Password
					@"F604" : @"F7CE4D4A-A5DE-43C4-982F-931AD1234929",		// Email address
					@"F375" : @"6AC8138D-84A8-46A6-897C-DE4F5EBC9AA2",		// URL
			},
	};
}

- (NSDictionary *)categoryMap {
	return @{
			@"T163" : @"D047C2C5-BB0A-46A4-8E78-9092A9DB0CBA",	// Bank Account
			@"T635" : @"6BFC8AB4-14B9-4C77-B59C-347B21400F45",	// Calling Cards
			@"T301" : @"BE821EC2-66D8-4808-B201-9BF20957660B",	// Combinations
			@"T174" : @"78CECFF4-7CA2-438C-AC5F-0DA59342F208",	// Credit Cards
			@"T82"  : @"C026CCC0-0F0D-45BD-9B74-0C179F07237C",	// Driver License
			@"T43"	: @"4F453D57-D4DF-46DC-9F7B-F0D37DC7E85A",	// Email
			@"T304" : @"67B8AFE1-D0DF-40E3-AF0F-098648060BEE",	// Family
			@"T303" : @"3198D305-C8FC-4632-989E-AC9FCCBD131B",	// Frequent Flier
			@"T354" : @"A91B3772-1C89-4C5A-AFEB-3C2594055D6D",	// Insurance
			@"T143" : @"F099C6B6-6BEE-4C17-813C-3D6553A88AC1",	// Memberships
			@"T960" : @"2BD209C3-9CB5-4229-AA68-0E08BCB6C6F2",	// Memos
			@"T592" : @"6B3C9EDA-A2A2-4850-9C63-7E09605811A8",	// Passport
			@"T285" : @"0409554E-123E-4C5D-BD8A-B3C42913CA61",	// Personal Info
			@"T817" : @"D840A875-9C99-481E-A592-4059DEF7A248",	// Photos
			@"T835" : @"7EACBD3B-DC63-40E5-A4D8-3AB57E2F11D0",	// Prescriptions
			@"T289" : @"85C87304-9D41-4BAD-BA60-9F15C7917288",	// Vehicles
			@"T673" : @"EB2FCD1A-E111-42FB-95CB-FBDE5D6A6986",	// Account (Web Account)
	};
}

- (void)askWalletPassword {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Encryption Key for Wallet" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
	alertView.delegate = self;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		NSString *password = [[alertView textFieldAtIndex:0] text];
		if ([self walletDataWithPassword:password]) {
			[self migrateV1DataWithPassword:password];
		} else {
			[self askWalletPassword];
		}
	}
}

@end
