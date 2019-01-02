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
#import "A3AbbreviationDrillDownViewController.h"
#import "UIColor+A3Addition.h"

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
	self.dataArray = [self abbreviationsArrayFromDataFile];
//	FNLOG(@"Total: %ld", (long)[_dataArray count]);
	
	[self buildHashTagSections];
	[self buildAlphabetSections];
	
	FNLOG(@"%@", _hashTagSections);
	FNLOG(@"%@", _alphabetSections);
}

- (NSArray *)abbreviationsArrayFromDataFile {
	NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"Abbreviation.json" ofType:nil];
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

- (NSArray *)headStartColors {
	if (!_headStartColors) {
		_headStartColors = @[
							 [UIColor colorFromHexString:@"F03E3E"],	// A
							 [UIColor colorFromHexString:@"D6336C"],	// B
							 [UIColor colorFromHexString:@"AE3EC9"],	// C
							 [UIColor colorFromHexString:@"7048E8"],	// D
							 [UIColor colorFromHexString:@"4263E8"],	// E
							 [UIColor colorFromHexString:@"1C7CD6"],	// F
							 [UIColor colorFromHexString:@"1098AD"],	// G
							 [UIColor colorFromHexString:@"0CA678"],	// H
							 [UIColor colorFromHexString:@"37B24D"],	// I
							 [UIColor colorFromHexString:@"74B816"],	// J
							 [UIColor colorFromHexString:@"F59F00"],	// K
							 [UIColor colorFromHexString:@"F76707"],	// L
							 [UIColor colorFromHexString:@"F03E3E"],	// M
							 [UIColor colorFromHexString:@"D6336C"],	// N
							 [UIColor colorFromHexString:@"AE3EC9"],	// O
							 [UIColor colorFromHexString:@"7048E8"],	// P
							 [UIColor colorFromHexString:@"4263E8"],	// Q
							 [UIColor colorFromHexString:@"1C7CD6"],	// R
							 [UIColor colorFromHexString:@"1098AD"],	// S
							 [UIColor colorFromHexString:@"0CA678"],	// T
							 [UIColor colorFromHexString:@"37B24D"],	// U
							 [UIColor colorFromHexString:@"74B816"],	// V
							 [UIColor colorFromHexString:@"F59F00"],	// W
							 [UIColor colorFromHexString:@"F76707"],	// X
							 [UIColor colorFromHexString:@"F03E3E"],	// Y
							 [UIColor colorFromHexString:@"D6336C"],	// Z
							 ];
	}
	return _headStartColors;
}

- (NSArray *)alphabetBGColors {
	if (!_alphabetBGColors) {
		_alphabetBGColors = @[
							  [UIColor colorFromHexString:@"F03E3E"],	// A
							  [UIColor colorFromHexString:@"D6336C"],	// B
							  [UIColor colorFromHexString:@"AE3EC9"],	// C
							  [UIColor colorFromHexString:@"7048E8"],	// D
							  [UIColor colorFromHexString:@"4263E8"],	// E
							  [UIColor colorFromHexString:@"1C7CD6"],	// F
							  [UIColor colorFromHexString:@"1098AD"],	// G
							  [UIColor colorFromHexString:@"0CA678"],	// H
							  [UIColor colorFromHexString:@"37B24D"],	// I
							  [UIColor colorFromHexString:@"74B816"],	// J
							  [UIColor colorFromHexString:@"F59F00"],	// K
							  [UIColor colorFromHexString:@"F76707"],	// L
							  [UIColor colorFromHexString:@"F03E3E"],	// M
							  [UIColor colorFromHexString:@"D6336C"],	// N
							  [UIColor colorFromHexString:@"AE3EC9"],	// O
							  [UIColor colorFromHexString:@"7048E8"],	// P
							  [UIColor colorFromHexString:@"4263E8"],	// Q
							  [UIColor colorFromHexString:@"1C7CD6"],	// R
							  [UIColor colorFromHexString:@"1098AD"],	// S
							  [UIColor colorFromHexString:@"0CA678"],	// T
							  [UIColor colorFromHexString:@"37B24D"],	// U
							  [UIColor colorFromHexString:@"74B816"],	// V
							  [UIColor colorFromHexString:@"F59F00"],	// W
							  [UIColor colorFromHexString:@"F76707"],	// X
							  [UIColor colorFromHexString:@"F03E3E"],	// Y
							  [UIColor colorFromHexString:@"D6336C"],	// Z
							  ];
	}
	return _alphabetBGColors;
}

- (NSArray *)bodyBGStartColors {
	if (!_bodyBGStartColors) {
		_bodyBGStartColors = @[
							   [UIColor colorFromHexString:@"C92A2A"],	// A
							   [UIColor colorFromHexString:@"A61E4D"],	// B
							   [UIColor colorFromHexString:@"862E9C"],	// C
							   [UIColor colorFromHexString:@"5F3DC4"],	// D
							   [UIColor colorFromHexString:@"364FC7"],	// E
							   [UIColor colorFromHexString:@"1862AB"],	// F
							   [UIColor colorFromHexString:@"0B7285"],	// G
							   [UIColor colorFromHexString:@"087F5B"],	// H
							   [UIColor colorFromHexString:@"2B8A3E"],	// I
							   [UIColor colorFromHexString:@"5C940D"],	// J
							   [UIColor colorFromHexString:@"E67700"],	// K
							   [UIColor colorFromHexString:@"D9480F"],	// L
							   [UIColor colorFromHexString:@"C92A2A"],	// M
							   [UIColor colorFromHexString:@"A61E4D"],	// N
							   [UIColor colorFromHexString:@"862E9C"],	// O
							   [UIColor colorFromHexString:@"5F3DC4"],	// P
							   [UIColor colorFromHexString:@"364FC7"],	// Q
							   [UIColor colorFromHexString:@"1862AB"],	// R
							   [UIColor colorFromHexString:@"0B7285"],	// S
							   [UIColor colorFromHexString:@"087F5B"],	// T
							   [UIColor colorFromHexString:@"2B8A3E"],	// U
							   [UIColor colorFromHexString:@"5C940D"],	// V
							   [UIColor colorFromHexString:@"E67700"],	// W
							   [UIColor colorFromHexString:@"D9480F"],	// X
							   [UIColor colorFromHexString:@"C92A2A"],	// Y
							   [UIColor colorFromHexString:@"A61E4D"],	// Z
							   ];
	}
	return _bodyBGStartColors;
}

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
	if ([filteredArray count] > 0) {
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
		return NSLocalizedString(@"Abbreviation reference on the AppBox Pro", nil);
	}
	return @"";
}

- (NSString *)placeholderForShare:(NSString *)titleString {
	return NSLocalizedString(@"Abbreviation reference on the AppBox Pro", nil);
}

#pragma mark - A3DrillDownDataSource
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
