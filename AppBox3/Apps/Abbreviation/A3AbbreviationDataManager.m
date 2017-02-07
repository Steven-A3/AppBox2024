//
//  A3AbbreviationDataManager.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/31/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationDataManager.h"
#import "NSString+conversion.h"
#import "AbbreviationFavorite+CoreDataClass.h"
#import "NSManagedObject+extension.h"
#import "NSMutableArray+A3Sort.h"
#import "A3AbbreviationDrillDownTableViewController.h"

NSString *const A3AbbreviationKeyTag = @"tag";
NSString *const A3AbbreviationKeyTags = @"tags";

NSString *const A3AbbreviationKeyComponents = @"components";
NSString *const A3AbbreviationKeySectionTitle = @"sectionTitle";

NSString *const A3AbbreviationKeyAbbreviation = @"abbreviation";
NSString *const A3AbbreviationKeyLetter = @"letter";
NSString *const A3AbbreviationKeyMeaning = @"meaning";

@implementation A3AbbreviationDataManager

+ (A3AbbreviationDataManager *)instance {
	A3AbbreviationDataManager *dataManager = [A3AbbreviationDataManager new];
	[dataManager prepareData];

	return dataManager;
}

- (void)prepareData {
	self.dataArray = [self abbreviationsArrayFromDataFile];;
	[self buildHashTagSections];
	[self buildAlphabetSections];
	
	FNLOG(@"%@", _hashTagSections);
	FNLOG(@"%@", _alphabetSections);
}

- (NSArray *)abbreviationsArrayFromDataFile {
	NSString *dataFilePath = [@"Abbreviation.json" pathInCachesDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:dataFilePath]) {
		dataFilePath = [[NSBundle mainBundle] pathForResource:@"Abbreviation.json" ofType:nil];
		if (![fileManager fileExistsAtPath:dataFilePath]) {
			return nil;
		}
	}
	NSData *rawData = [NSData dataWithContentsOfFile:dataFilePath];
	if (!rawData) {
		return nil;
	}
	NSError *error;
	NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingAllowFragments error:&error];
	if (error) {
		FNLOG(@"%@", error.localizedDescription);
		return nil;
	}
	return dataArray;
}

- (void)buildHashTagSections {
	NSMutableArray *hashTagSections = [NSMutableArray new];
	NSArray *availableTags = @[@"Top24", @"Romance", @"Business"];
	for (NSString *tag in availableTags) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", A3AbbreviationKeyTags, tag];
		NSArray *components = [self.dataArray filteredArrayUsingPredicate:predicate];
		[hashTagSections addObject:@{A3AbbreviationKeyTag : tag, A3AbbreviationKeyComponents : components}];
	}
	_hashTagSections = hashTagSections;
}

- (void)buildAlphabetSections {
	NSMutableArray *alphabetSections = [NSMutableArray new];
	NSArray *alphabet = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
	for (NSString *letter in alphabet) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", A3AbbreviationKeyAbbreviation, letter];
		NSArray *components = [self.dataArray filteredArrayUsingPredicate:predicate];
		[alphabetSections addObject:@{A3AbbreviationKeyLetter : letter, A3AbbreviationKeyComponents:components}];
	}
	_alphabetSections = alphabetSections;
}

- (NSArray *)favoritesArray {
	NSArray *favoriteKeys = [AbbreviationFavorite MR_findAllSortedBy:@"order" ascending:YES];
	
	if ([favoriteKeys count] > 0) {
		NSMutableArray *favorites = [NSMutableArray new];
		for (AbbreviationFavorite *favorite in favoriteKeys) {
			@autoreleasepool {
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", A3AbbreviationKeyAbbreviation, favorite.uniqueID];
				NSArray *results = [self.dataArray filteredArrayUsingPredicate:predicate];
				[favorites addObjectsFromArray:results];
			}
		}
		FNLOG(@"%@", favorites);
		return favorites;
	}
	return nil;
}

/*
 /// Hash tag sections
 (
	{
 components =         (
 {
 abbreviation = B4N;
 meaning = "Bye For Now ";
 tags = Top24;
 },
 .... 생략
 );
 tag = Top24;
	},
	{
 components =         (
 {
 abbreviation = ALIWanIsU;
 meaning = "All I Want Is You";
 tags = Romance;
 },
 .... 생략
 );
 tag = Romance;
	},
	{
 components =         (
 {
 abbreviation = ADN;
 meaning = "Any Day Now";
 tags = Business;
 },
 );
 tag = Business;
	}
 )
 
 /// Alphabet List
 (
	{
 components =         (
 {
 abbreviation = ADN;
 meaning = "Any Day Now";
 tags = Business;
 },
 );
 letter = A;
	},
	{
 components =         (
 {
 abbreviation = B2B;
 meaning = "Business To Business";
 tags = Business;
 },
 );
 letter = B;
	},
	... Z까지 있음
 )
 */

- (NSArray *)hashTagSections {
	if (!_hashTagSections) {
		[self prepareData];
	}
	return _hashTagSections;
}

- (NSArray *)alphabetSections {
	if (!_alphabetSections) {
		[self prepareData];
	}
	return _alphabetSections;
}

/*
	{
 component =         (
 abbreviation = B2B;
 meaning = "Business To Business";
 tags = Business;
 },
 );
 order = (double value);	새 항목 추가시 마지막 값 + 1.0
 다른 항목 사이로 배치를 할 경우에는 위/아래 항목 순서값 / 2
	},
 */

#pragma mark - A3SharePopupViewControllerDelegate

- (BOOL)isMemberOfFavorites:(NSString *)titleString {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", titleString];
	NSArray *result = [AbbreviationFavorite MR_findAllWithPredicate:predicate];
	return [result count] > 0;
}

- (void)addToFavorites:(NSString *)titleString {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	AbbreviationFavorite *favorite = [AbbreviationFavorite MR_createEntityInContext:savingContext];
	favorite.uniqueID = titleString;
	[favorite assignOrderAsLastInContext:savingContext];
	[savingContext MR_saveToPersistentStoreAndWait];
}

- (void)removeFromFavorites:(NSString *)titleString {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", titleString];
	NSArray *result = [AbbreviationFavorite MR_findAllWithPredicate:predicate inContext:savingContext];
	if ([result count]) {
		for (AbbreviationFavorite *favorite in result) {
			[favorite MR_deleteEntityInContext:savingContext];
		}
		[savingContext MR_saveToPersistentStoreAndWait];
	}
}

- (NSString *)stringForShare:(NSString *)titleString {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", A3AbbreviationKeyAbbreviation, titleString];

	NSArray *filteredArray = [self.dataArray filteredArrayUsingPredicate:predicate];
	if ([filteredArray count] > 1) {
		NSDictionary *content = filteredArray[0];
		return [NSString stringWithFormat:@"%@ %@ %@",
										  content[A3AbbreviationKeyAbbreviation],
						NSLocalizedString(@"means", @"means"),
										  content[A3AbbreviationKeyMeaning]];;
	}
	return @"";
}

- (NSString *)subjectForActivityType:(NSString *)activityType {
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Abbreviation reference using AppBox Pro", nil);
	}
	return @"";
}

- (NSString *)placeholderForShare:(NSString *)titleString {
	return NSLocalizedString(@"Abbreviation Reference on the AppBox Pro", nil);
}

#pragma mark - A3AbbreviationDrillDownDataSource
// Favorites can delete or reorder the items

- (void)deleteItemForContent:(NSDictionary *)content {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	NSArray *results = [AbbreviationFavorite MR_findByAttribute:@"uniqueID" withValue:content[A3AbbreviationKeyAbbreviation]];
	if ([results count] > 0) {
		for (AbbreviationFavorite *favorite in results) {
			[favorite MR_deleteEntityInContext:savingContext];
		}
		[savingContext MR_saveToPersistentStoreAndWait];
	}
}

- (void)moveItemForContent:(id)content fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	NSMutableArray *favoriteKeys = [[AbbreviationFavorite MR_findAllSortedBy:@"order" ascending:YES inContext:savingContext] mutableCopy];
	FNLOG(@"%@", favoriteKeys);
	[favoriteKeys moveItemInSortedArrayFromIndex:fromIndex toIndex:toIndex];
	FNLOG(@"%@", favoriteKeys);
	[savingContext MR_saveToPersistentStoreAndWait];
}

@end
