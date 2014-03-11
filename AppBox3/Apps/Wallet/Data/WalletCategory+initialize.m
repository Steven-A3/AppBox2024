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
#import "NSMutableArray+A3Sort.h"
#import "NSManagedObject+Identify.h"

@implementation WalletCategory (initialize)

+ (void)resetWalletCategory
{
    if ([[WalletCategory MR_numberOfEntities] integerValue] > 0) {
		[WalletCategory MR_truncateAll];
	}
    
    // unit type set : make and set to coredata
    NSArray *categoryPresets = [WalletData categoryPresetData];
    
    NSMutableArray *tmp = [NSMutableArray new];
    
    // create all, favorite category
    WalletCategory *favCate = [WalletCategory MR_createEntity];
    favCate.name = @"Favorite";
    favCate.icon = @"star01";
    [tmp addObjectToSortedArray:favCate];
    
    WalletCategory *allCate = [WalletCategory MR_createEntity];
    allCate.name = @"All";
    allCate.icon = @"wallet_folder";
    [tmp addObjectToSortedArray:allCate];

    for (int i=0; i<categoryPresets.count; i++) {
        NSDictionary *preset = categoryPresets[i];
        
        WalletCategory *category = [WalletCategory MR_createEntity];
        category.name = preset[@"Name"];
        category.icon = preset[@"Icon"];
        [tmp addObjectToSortedArray:category];
        
        NSArray *fieldPresets = preset[@"Fields"];
        
        NSMutableArray *tmp2 = [NSMutableArray new];
        for (int j=0; j<fieldPresets.count; j++) {
            NSDictionary *fieldPreset = fieldPresets[j];
            
            WalletField *field = [WalletField MR_createEntity];
            field.name = fieldPreset[@"Name"];
            field.category = category;
            field.type = fieldPreset[@"Type"];
            field.style = fieldPreset[@"Style"];
            [tmp2 addObjectToSortedArray:field];
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    NSString *favKey = [favCate uriKey];
    [[NSUserDefaults standardUserDefaults] setObject:favKey forKey:kWalletFavCateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *allKey = [allCate uriKey];
    [[NSUserDefaults standardUserDefaults] setObject:allKey forKey:kWalletAllCateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name==%@", @"All"];
    NSArray *array = [WalletCategory MR_findAllWithPredicate:predicate];
    
    NSString *keyString = [[NSUserDefaults standardUserDefaults] stringForKey:kWalletAllCateKey];
    
    for (WalletCategory *cate in array) {
        if ([cate.uriKey isEqualToString:keyString]) {
            return cate;
        }
    }
    return nil;
}

+ (WalletCategory *)favCategory
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name==%@", @"Favorite"];
    NSArray *array = [WalletCategory MR_findAllWithPredicate:predicate];
    
    NSString *keyString = [[NSUserDefaults standardUserDefaults] stringForKey:kWalletFavCateKey];
    
    for (WalletCategory *cate in array) {
        if ([cate.uriKey isEqualToString:keyString]) {
            return cate;
        }
    }
    return nil;
}

- (void)deleteAndClearRelated
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"category==%@", self];
    NSArray *items1 = [WalletItem MR_findAllWithPredicate:predicate1];
    
    for (int i=0; i<items1.count; i++) {
        WalletItem *item = items1[i];
        [item deleteAndClearRelated];
    }
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"category==%@", self];
    NSArray *items2 = [WalletField MR_findAllWithPredicate:predicate2];
    
    for (int i=0; i<items2.count; i++) {
        WalletField *item = items2[i];
        [item MR_deleteEntity];
    }
    
    [self MR_deleteEntity];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
