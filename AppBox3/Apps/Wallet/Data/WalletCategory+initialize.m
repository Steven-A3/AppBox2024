//
//  WalletCategory+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletCategory+initialize.h"
#import "WalletItem+initialize.h"
#import "WalletField.h"
#import "WalletData.h"
#import "NSString+conversion.h"

NSString *const A3WalletUUIDAllCategory = @"10F30F9F-FF9D-43D4-AC69-020F61E016E0";
NSString *const A3WalletUUIDFavoriteCategory = @"9DA24468-83C1-41E1-B355-4AB245C1FEB5";
NSString *const A3WalletUUIDPhotoCategory = @"D840A875-9C99-481E-A592-4059DEF7A248";
NSString *const A3WalletUUIDVideoCategory = @"7FE1693F-76DA-42FC-A0A7-1C2E7F6346D9";
NSString *const A3WalletUUIDMemoCategory = @"2BD209C3-9CB5-4229-AA68-0E08BCB6C6F2";

@implementation WalletCategory (initialize)

- (void)initValues {
	self.doNotShow = @NO;
	self.modificationDate = [NSDate date];
}

+ (void)resetWalletCategoriesInContext:(NSManagedObjectContext *)context {
    if ([WalletCategory MR_countOfEntitiesWithContext:context] > 0) {
		[WalletCategory MR_truncateAllInContext:context];
	}
    
    // unit type set : make and set to core data
    NSArray *categoryPresets = [WalletData categoryPresetData];
	NSUInteger categoryIdx = 1;

    // create all, favorite category
    WalletCategory *favoriteCategory = [WalletCategory MR_createInContext:context];
	[favoriteCategory initValues];
	favoriteCategory.name = @"Favorite";
    favoriteCategory.icon = @"star01";
	favoriteCategory.uniqueID = A3WalletUUIDFavoriteCategory;
	favoriteCategory.order = [NSString orderStringWithOrder:categoryIdx++ * 1000000];

    WalletCategory *allCategory = [WalletCategory MR_createInContext:context];
	[allCategory initValues];
	allCategory.name = @"All";
    allCategory.icon = @"wallet_folder";
	allCategory.uniqueID = A3WalletUUIDAllCategory;
	allCategory.order = [NSString orderStringWithOrder:categoryIdx++ * 1000000];

    for (NSDictionary *preset in categoryPresets) {
        WalletCategory *category = [WalletCategory MR_createInContext:context];
		[category initValues];

		category.uniqueID = preset[@"uniqueID"];
        category.name = preset[@"name"];
        category.icon = preset[@"icon"];
		category.order = [NSString orderStringWithOrder:categoryIdx++ * 1000000];

		NSArray *fieldPresets = preset[@"Fields"];
        NSUInteger fieldIdx = 1;
		for (NSDictionary *fieldPreset in fieldPresets) {
            WalletField *field = [WalletField MR_createInContext:context];
			field.uniqueID = fieldPreset[@"uniqueID"];
			field.name = fieldPreset[@"name"];
            field.category = category;
            field.type = fieldPreset[@"type"];
            field.style = fieldPreset[@"style"];
			field.order = [NSString orderStringWithOrder:fieldIdx++ * 1000000];
        }
    }

	[context MR_saveToPersistentStoreAndWait];
}

- (NSArray *)fieldsArray
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    return [self.fields sortedArrayUsingDescriptors:@[sortDescriptor]];
}

+ (NSArray *)iconList
{
    return @[@"wallet_account",
             @"wallet_accountbook",
             @"wallet_bank",
             @"wallet_call",
             @"wallet_calling",
             @"wallet_combination",
             @"wallet_credit",
             @"wallet_driver",
             @"wallet_email",
             @"wallet_family",
             @"wallet_folder",
             @"wallet_frequent",
             @"wallet_insurance",
             @"wallet_locked",
             @"wallet_membership",
             @"wallet_memo",
             @"wallet_note",
             @"wallet_openmail",
             @"wallet_paperplane",
             @"wallet_passport",
             @"wallet_personal",
             @"wallet_photo",
             @"wallet_photogallery",
             @"wallet_pil",
             @"wallet_prescription",
             @"wallet_software",
             @"wallet_vehicle",
             @"wallet_video",
             @"wallet_wallet"];
}

+ (WalletCategory *)allCategory
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", A3WalletUUIDAllCategory];
    NSArray *array = [WalletCategory MR_findAllWithPredicate:predicate];
    
    return [array count] ? array[0] : nil;
}

+ (WalletCategory *)favoriteCategory
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", A3WalletUUIDFavoriteCategory];
	NSArray *array = [WalletCategory MR_findAllWithPredicate:predicate];

	return [array count] ? array[0] : nil;
}

- (void)assignOrder {
	WalletCategory *category = [WalletCategory MR_findFirstOrderedByAttribute:@"order" ascending:NO];
	if (category) {
		NSInteger latestOrder = [category.order integerValue];
		self.order = [NSString orderStringWithOrder:latestOrder + 1000000];
	} else {
		self.order = [NSString orderStringWithOrder:1000000];
	}
}

+ (void)exportCategoryInfoAsPList {
	NSArray *categories = [WalletCategory MR_findAllSortedBy:@"name" ascending:YES];
	NSMutableArray *array = [NSMutableArray new];
	for (WalletCategory *category in categories) {
		NSMutableArray *fieldsArray = [NSMutableArray new];
		NSArray *fields = [WalletField MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"category.uniqueID == %@", category.uniqueID]];
		for (WalletField *field in fields) {
			NSDictionary *fieldDictionary = @{
					@"name" : field.name,
					@"style" : field.style,
					@"type" : field.type,
					@"uniqueID" : field.uniqueID,
			};
			[fieldsArray addObject:fieldDictionary];
		}
		NSDictionary *categoryDictionary = @{
				@"uniqueID" : category.uniqueID,
				@"name" : category.name,
				@"icon" : category.icon,
				@"Fields" : fieldsArray
		};
		[array addObject:categoryDictionary];
	}
	[array writeToFile:[@"wallet_preset.plist" pathInLibraryDirectory] atomically:YES];
}

@end
