//
//  WalletData.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletData.h"
#import "WalletFieldItem+initialize.h"
#import "WalletItem+initialize.h"
#import "WalletCategory.h"
#import "WalletField.h"
#import "WalletItem.h"
#import <AVFoundation/AVFoundation.h>
#import "A3AppDelegate.h"
#import <AppBoxKit/AppBoxKit.h>

NSString *const PRESET_DoNotShow_KEY		= @"doNotShow";
NSString *const PRESET_SYSTEM_KEY			= @"SYSTEM";
NSString *const PRESET_NAME_KEY				= @"name";
NSString *const PRESET_ICON_KEY				= @"icon";
NSString *const PRESET_ID_KEY				= @"uniqueID";
NSString *const PRESET_FIELDS_KEY			= @"Fields";
NSString *const PRESET_STYLE_KEY			= @"style";
NSString *const PRESET_TYPE_KEY				= @"type";

NSString *const WalletFieldTypeText			= @"Text";
NSString *const WalletFieldTypeNumber		= @"Number";
NSString *const WalletFieldTypePhone		= @"Phone";
NSString *const WalletFieldTypeURL			= @"URL";
NSString *const WalletFieldTypeEmail		= @"Email";
NSString *const WalletFieldTypeDate			= @"Date";
NSString *const WalletFieldTypeImage		= @"Image";
NSString *const WalletFieldTypeVideo		= @"Video";

NSString *const WalletFieldStyleNormal		= @"Normal";
NSString *const WalletFieldStylePassword	= @"Password";
NSString *const WalletFieldStyleAccount		= @"Account";
NSString *const WalletFieldStyleHidden		= @"Hidden";

NSString *const WalletFieldNativeType 		= @"NativeType";
NSString *const WalletFieldNativeTypeText	= @"Text";
NSString *const WalletFieldNativeTypeImage	= @"Image";
NSString *const WalletFieldNativeTypeVideo	= @"Video";
NSString *const WalletFieldTypeID			= @"Name";

NSString *const A3WalletUUIDAllCategory = @"10F30F9F-FF9D-43D4-AC69-020F61E016E0";
NSString *const A3WalletUUIDFavoriteCategory = @"9DA24468-83C1-41E1-B355-4AB245C1FEB5";
NSString *const A3WalletUUIDRecentsCategory = @"2493316a-b6a4-4d71-8501-4587174e9342";
NSString *const A3WalletUUIDPhotoCategory = @"D840A875-9C99-481E-A592-4059DEF7A248";
NSString *const A3WalletUUIDVideoCategory = @"7FE1693F-76DA-42FC-A0A7-1C2E7F6346D9";
NSString *const A3WalletUUIDMemoCategory = @"2BD209C3-9CB5-4229-AA68-0E08BCB6C6F2";

@implementation WalletData

+ (NSArray *)typeList
{
    return @[@{WalletFieldTypeID : WalletFieldTypeText, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypeNumber, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypePhone, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypeURL, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypeEmail, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypeDate, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypeImage, WalletFieldNativeType : WalletFieldTypeImage},
             @{WalletFieldTypeID : WalletFieldTypeVideo, WalletFieldNativeType : WalletFieldTypeVideo}];
}

+ (NSDictionary *)styleList
{
    return @{
			WalletFieldNativeTypeText : @[
					WalletFieldStyleNormal,
					WalletFieldStylePassword,
					WalletFieldStyleAccount,
					WalletFieldStyleHidden
			],
			WalletFieldNativeTypeImage : @[],
			WalletFieldNativeTypeVideo : @[]};
}

+ (NSArray *)categoryPresetData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WalletCategoryPreset" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:filePath];
}

+ (float)getDurationOfMovie:(NSURL *)fileURL
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime duration = audioAsset.duration;
    float durationSeconds = CMTimeGetSeconds(duration);
    
    return durationSeconds;
}

+ (NSDate *)getCreateDateOfMovie:(NSURL *)fileURL
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSArray *metas = audioAsset.commonMetadata;
    
    for (AVMetadataItem *metaItem in metas) {
        if ([metaItem.commonKey isEqualToString:AVMetadataCommonKeyCreationDate]) {
            return metaItem.dateValue;
        }
    }
    return nil;
}

+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    NSArray *mediaTypes = [asset tracksWithMediaType:AVMediaTypeVideo];
    CMTimeRange range = [[mediaTypes lastObject] timeRange];
    NSError *error = NULL;
    CMTime time = CMTimeMake(((range.duration.value / range.duration.timescale) > 10) ? (10 * 65) : 1, 65);
    CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
    FNLOG(@"error==%@, Refimage==%@", error, refImg);
    
    UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
    
    return FrameImage;
}

+ (void)createDirectories {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imagePath = [A3WalletImageDirectory pathInLibraryDirectory];
	if (![fileManager fileExistsAtPath:imagePath])
		[fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:NULL];

	NSString *videoPath = [A3WalletVideoDirectory pathInLibraryDirectory];
	if (![fileManager fileExistsAtPath:videoPath])
		[fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:NULL];

	NSString *imageThumbnailDirectory = [A3WalletImageThumbnailDirectory pathInCachesDirectory];
	if (![fileManager fileExistsAtPath:imageThumbnailDirectory])
		[fileManager createDirectoryAtPath:imageThumbnailDirectory withIntermediateDirectories:YES attributes:nil error:NULL];

	NSString *videoThumbnailDirectory = [A3WalletVideoThumbnailDirectory pathInCachesDirectory];
	if (![fileManager fileExistsAtPath:videoThumbnailDirectory])
		[fileManager createDirectoryAtPath:videoThumbnailDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
}

+ (void)createLocalizedPresetCategories {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	NSArray *presetCategories = [self categoryPresetData];
	NSMutableArray *categories = [NSMutableArray new];
	[presetCategories enumerateObjectsUsingBlock:^(NSDictionary *category, NSUInteger idx, BOOL *stop) {
        WalletCategory *newCategory = [[WalletCategory alloc] initWithContext:context];
		newCategory.uniqueID = category[PRESET_ID_KEY];
		newCategory.name = NSLocalizedStringFromTable(category[PRESET_NAME_KEY], @"WalletPreset", nil);
		newCategory.icon = category[PRESET_ICON_KEY];
		newCategory.isSystem = @NO;
		newCategory.doNotShow = @NO;
		[categories addObject:newCategory];

		[category[PRESET_FIELDS_KEY] enumerateObjectsUsingBlock:^(NSDictionary *field, NSUInteger idx, BOOL *stop) {
            WalletField *newField = [[WalletField  alloc] initWithContext:context];
			newField.uniqueID = field[PRESET_ID_KEY];
			newField.categoryID = newCategory.uniqueID;
			newField.name = NSLocalizedStringFromTable(field[PRESET_NAME_KEY], @"WalletPreset", nil);
			newField.style = field[PRESET_STYLE_KEY];
			newField.type = field[PRESET_TYPE_KEY];
			[newField assignOrderAsLast];
		}];
	}];

	[categories sortUsingComparator:^NSComparisonResult(WalletCategory *obj1, WalletCategory *obj2) {
		return [obj1.name compare:obj2.name];
	}];
	NSInteger order = 1000000;
	for (WalletCategory *category in categories) {
		category.order = [NSString orderStringWithOrder:order];
		order += 1000000;
	}

	return;
}

+ (void)createSystemCategory {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    WalletCategory *allCategory = [[WalletCategory alloc] initWithContext:context];
	allCategory.uniqueID = A3WalletUUIDAllCategory;
	allCategory.name = NSLocalizedString(@"Wallet_All_Category", @"All");
	allCategory.icon = @"wallet_folder";
	allCategory.isSystem = @YES;
	allCategory.doNotShow = @NO;
	[allCategory assignOrderAsFirst];

    WalletCategory *favoriteCategory = [[WalletCategory alloc] initWithContext:context];
	favoriteCategory.uniqueID = A3WalletUUIDFavoriteCategory;
	favoriteCategory.name = NSLocalizedString(@"Favorites", nil);
	favoriteCategory.icon = @"star01";
	favoriteCategory.isSystem = @YES;
	favoriteCategory.doNotShow = @NO;
	[favoriteCategory assignOrderAsFirst];

    [WalletData createRecentsCategory];
}

+ (void)createRecentsCategory {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    WalletCategory *recentsCategory = [[WalletCategory alloc] initWithContext:context];
    recentsCategory.uniqueID = A3WalletUUIDRecentsCategory;
    recentsCategory.name = NSLocalizedString(@"Recents", nil);
    recentsCategory.icon = @"history";
    recentsCategory.isSystem = @YES;
    recentsCategory.doNotShow = @NO;
    [recentsCategory assignOrderAsFirst];
}

+ (void)initializeWalletCategories {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [WalletData createLocalizedPresetCategories];
    [WalletData createSystemCategory];
    [context saveContext];
}

+ (NSArray *)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	if (hideDoNotShow) {
		NSArray *categories = [WalletCategory findAllSortedBy:@"order" ascending:YES];
		BOOL dataUpdated = NO;
		for (NSInteger idx = 0; idx < MIN(IS_IPHONE ? 4 : 7, [categories count]); idx++) {
			WalletCategory *category = categories[idx];
			if (category.doNotShow.boolValue) {
				category.doNotShow = @NO;
				dataUpdated = YES;
			}
		}
		if (dataUpdated) {
            [context saveContext];
		}
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", @"doNotShow", @(hideDoNotShow)];
		return [WalletCategory findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
	} else {
		return [WalletCategory findAllSortedBy:@"order" ascending:YES];
	}
}

+ (NSUInteger)visibleCategoryCount {
	NSArray *walletCategories = [WalletData walletCategoriesFilterDoNotShow:YES];
	return [walletCategories count] - 2;
}

+ (WalletCategory *)firstEditableWalletCategory {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSystem == NO AND doNotShow = NO"];
    return [WalletCategory findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:YES];
}

+ (NSArray *)categoriesExcludingSystemCategories {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSystem == NO"];
	return [WalletCategory findAllSortedBy:A3CommonPropertyOrder ascending:YES withPredicate:predicate];
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

+ (WalletCategory *)categoryItemWithID:(NSString *)categoryID {
	return [WalletCategory findFirstByAttribute:@"uniqueID" withValue:categoryID];
}

+ (WalletField *)fieldOfFieldItem:(WalletFieldItem *)fieldItem {
	return [WalletField findFirstByAttribute:@"uniqueID" withValue:fieldItem.fieldID];
}

+ (NSString *)stringRepresentationOfContents {
    NSMutableString *contents = [[NSMutableString alloc] init];
    
    NSArray *categories = [WalletCategory findAllSortedBy:@"order" ascending:YES];
    [categories enumerateObjectsUsingBlock:^(WalletCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *fields = [WalletField findByAttribute:@"categoryID" withValue:category.uniqueID];
        if ([fields count]) {
            NSArray *items = [WalletItem findByAttribute:@"categoryID" withValue:category.uniqueID];
            // Add category name here
            [contents appendString:[NSString stringWithFormat:@"%@: %@\n", [NSLocalizedString(@"Category", nil) uppercaseString], category.name]];
            // Add field header here
            [contents appendString:[NSString stringWithFormat:@"%@\n", [NSLocalizedString(@"Columns Header", nil) uppercaseString]]];
            [fields enumerateObjectsUsingBlock:^(WalletField * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                [contents appendString:[NSString stringWithFormat:@"%@ (%@, %@), ",
                                        field.name,
                                        NSLocalizedString(field.type, nil),
                                        NSLocalizedString(field.style, nil)]];
            }];
            [contents deleteCharactersInRange:NSMakeRange(contents.length - 2, 2)];
            [contents appendString:@"\n"];
            [items enumerateObjectsUsingBlock:^(WalletItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *fieldItems = [item fieldItemsArraySortedByFieldOrder];
                // Add field items
                if ([fieldItems count]) {
                    [fieldItems enumerateObjectsUsingBlock:^(WalletFieldItem * _Nonnull fieldItem, NSUInteger idx, BOOL * _Nonnull stop) {
                        [contents appendString:fieldItem.value ? fieldItem.value : @""];
                        [contents appendString:@", "];
                    }];
                    [contents deleteCharactersInRange:NSMakeRange(contents.length - 2, 2)];
                    [contents appendString:@"\n"];
                }
            }];
            [contents appendString:@"\n\n"];
        }
    }];
    
    return contents;
}

+ (NSArray *)sortedArrayUsingCollation:(NSArray *)array {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
    
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    // Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
    for (index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }

    BOOL needAdjustment = LANGUAGE_KOREAN;
    // Segregate the time zones into the appropriate arrays.
    for (WalletItem *object in array) {
        if (!object.name) {
            object.name = @"";
        }
        
        // Ask the collation which section number the time zone belongs in, based on its locale name.
        NSInteger sectionNumber = [collation sectionForObject:object collationStringSelector:NSSelectorFromString(@"name")];
        
        // Language가 Korean인 경우, 영어에서 sectionNumber가 실제보다 1 크게 결과가 나오는 오류가 있어서 보정함
        if (needAdjustment && [object.name length]) {
            NSRange range = [[object.name substringToIndex:1] rangeOfString:[collation.sectionTitles[sectionNumber] substringToIndex:1] options:NSCaseInsensitiveSearch];
            if (range.location == NSNotFound) {
                sectionNumber = MAX(0, sectionNumber - 1);
            }
        }

        // Get the array for the section.
        NSMutableArray *sections = newSectionsArray[sectionNumber];
        
        //  Add the time zone to the section.
        [sections addObject:object];
    }
    NSMutableArray *result = [NSMutableArray new];
    for (index = 0; index < sectionTitlesCount; index++) {
        
        NSMutableArray *dataArrayForSection = newSectionsArray[index];
        
        if ([dataArrayForSection count]) {
            // If the table view or its contents were editable, you would make a mutable copy here.
            NSArray *sortedDataArrayForSection = [collation sortedArrayFromArray:dataArrayForSection collationStringSelector:NSSelectorFromString(@"name")];
            [result addObjectsFromArray:sortedDataArrayForSection];
        }
    }

    return result;
}

/*
 
 */
+ (NSString *)htmlRepresentationOfContents {
    NSMutableString *contents = [[NSMutableString alloc] init];
    [contents appendString:NSLocalizedStringFromTable(@"exportHeader", @"walletExport", nil)];
    
    NSArray *categories = [WalletCategory findAllSortedBy:@"order" ascending:YES];
    for (WalletCategory *category in categories) {
        if ([category.uniqueID isEqualToString:A3WalletUUIDAllCategory] || [category.uniqueID isEqualToString:A3WalletUUIDFavoriteCategory]) continue;
        
        FNLOG(@"%@", category.uniqueID);
        FNLOG(@"%@", category.name);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", category.uniqueID];
        NSArray *allRows = [WalletItem findAllSortedBy:@"name" ascending:YES withPredicate:predicate];
        
        if ([allRows count] == 0) continue;
        
        allRows = [WalletData sortedArrayUsingCollation:allRows];
        
        [contents appendString:[NSString stringWithFormat:@"<h2>%@ (%d)</h2>", category.name, [allRows count]]];

        [contents appendString:@"<table>"];
        
        NSArray *fields = [WalletField findByAttribute:@"categoryID" withValue:category.uniqueID];
        [contents appendString:@"<tr>"];
        [contents appendString:[NSString stringWithFormat:@"<th style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</th>", NSLocalizedString(@"Title", nil)]];
        for (WalletField *field in fields) {
            [contents appendString:[NSString stringWithFormat:@"<th style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</th>", field.name ?: @""]];
        }
        [contents appendString:[NSString stringWithFormat:@"<th style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</th>", NSLocalizedString(@"Memo", nil)]];
        [contents appendString:@"</tr>"];

        // Append table header row
        for (WalletItem *row in allRows) {
            [contents appendString:@"<tr>"];
            [contents appendString:[NSString stringWithFormat:@"<td style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</td>", row.name ?: @""]];
            for (WalletField *field in fields) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@ AND fieldID == %@", row.uniqueID, field.uniqueID];
                NSArray *fieldItems = [WalletFieldItem findAllWithPredicate:predicate];
                if ([fieldItems count]) {
                    WalletFieldItem *fieldItem = fieldItems[0];
                    [contents appendString:[NSString stringWithFormat:@"<td style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</td>", fieldItem.value ?: @""]];
                } else {
                    [contents appendString:@"<td style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\"></td>"];
                }
            }
            [contents appendString:[NSString stringWithFormat:@"<td style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</td>", row.note ?: @""]];
            [contents appendString:@"</tr>"];
        }

        [contents appendString:@"</table>"];
    }
    [contents appendString:NSLocalizedStringFromTable(@"exportTail", @"walletExport", nil)];
    
    return contents;
}

@end
