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

NSString *const A3WalletUUIDAllCategory = @"10f30f9f-ff9d-43d4-ac69-020f61e016e0";
NSString *const A3WalletUUIDFavoriteCategory = @"9da24468-83c1-41e1-b355-4ab245c1feb5";
NSString *const A3WalletUUIDPhotoCategory = @"d840a875-9c99-481e-a592-4059def7a248";
NSString *const A3WalletUUIDVideoCategory = @"7fe1693f-76da-42fc-a0a7-1c2e7f6346d9";
NSString *const A3WalletUUIDMemoCategory = @"2bd209c3-9cb5-4229-aa68-0e08bcb6c6f2";

@implementation WalletCategory (initialize)

- (void)awakeFromInsert {
	[super awakeFromInsert];

	self.uniqueID = [[NSUUID UUID] UUIDString];
	self.doNotShow = @NO;
}

+ (void)resetWalletCategory
{
    if ([[WalletCategory MR_numberOfEntities] integerValue] > 0) {
		[WalletCategory MR_truncateAll];
	}
    
    // unit type set : make and set to core data
    NSArray *categoryPresets = [WalletData categoryPresetData];
	NSUInteger categoryIdx = 1;

    // create all, favorite category
    WalletCategory *favoriteCategory = [WalletCategory MR_createEntity];
    favoriteCategory.name = @"Favorite";
    favoriteCategory.icon = @"star01";
	favoriteCategory.modificationDate = [NSDate date];
	favoriteCategory.uniqueID = A3WalletUUIDFavoriteCategory;
	favoriteCategory.order = [NSString orderStringWithOrder:categoryIdx++ * 1000000];

    WalletCategory *allCategory = [WalletCategory MR_createEntity];
    allCategory.name = @"All";
    allCategory.icon = @"wallet_folder";
	allCategory.modificationDate = [NSDate date];
	allCategory.uniqueID = A3WalletUUIDAllCategory;
	allCategory.order = [NSString orderStringWithOrder:categoryIdx++ * 1000000];

    for (NSDictionary *preset in categoryPresets) {
        WalletCategory *category = [WalletCategory MR_createEntity];
		if ([preset[@"Name"] isEqualToString:@"Photos"]) {
			category.uniqueID = A3WalletUUIDPhotoCategory;
		} else if ([preset[@"Name"] isEqualToString:@"Video"]) {
			category.uniqueID = A3WalletUUIDVideoCategory;
		} else if ([preset[@"Name"] isEqualToString:@"Memo"]) {
			category.uniqueID = A3WalletUUIDMemoCategory;
		}

        category.name = preset[@"Name"];
        category.icon = preset[@"Icon"];
		category.modificationDate = [NSDate date];
		category.order = [NSString orderStringWithOrder:categoryIdx++ * 1000000];

		NSArray *fieldPresets = preset[@"Fields"];
        NSUInteger fieldIdx = 1;
		for (NSDictionary *fieldPreset in fieldPresets) {
            WalletField *field = [WalletField MR_createEntity];
			field.name = fieldPreset[@"Name"];
            field.category = category;
            field.type = fieldPreset[@"Type"];
            field.style = fieldPreset[@"Style"];
			field.order = [NSString orderStringWithOrder:fieldIdx++ * 1000000];
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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

@end
