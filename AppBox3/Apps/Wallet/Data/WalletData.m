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
    
    NSString *imagePath = [A3WalletImageDirectory pathInAppGroupContainer];
    if (![fileManager fileExistsAtPath:imagePath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            FNLOG(@"%@", error.localizedFailureReason);
        }
    }

	NSString *videoPath = [A3WalletVideoDirectory pathInAppGroupContainer];
    if (![fileManager fileExistsAtPath:videoPath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            FNLOG(@"%@", error.localizedFailureReason);
        }
    }

	NSString *imageThumbnailDirectory = [A3WalletImageThumbnailDirectory pathInCachesDirectory];
    if (![fileManager fileExistsAtPath:imageThumbnailDirectory]) {
        NSError *error;
        [fileManager createDirectoryAtPath:imageThumbnailDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            FNLOG(@"%@", error.localizedFailureReason);
        }
    }

	NSString *videoThumbnailDirectory = [A3WalletVideoThumbnailDirectory pathInCachesDirectory];
    if (![fileManager fileExistsAtPath:videoThumbnailDirectory]) {
        NSError *error;
        [fileManager createDirectoryAtPath:videoThumbnailDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            FNLOG(@"%@", error.localizedFailureReason);
        }
    }
    return;
}

+ (void)createLocalizedPresetCategories {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.newBackgroundContext;

    [context performBlock:^{
        // Fetch existing categories in one request
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WalletCategory_"];
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.propertiesToFetch = @[@"uniqueID"];
        NSError *fetchError = nil;
        NSArray *existingCategories = [context executeFetchRequest:fetchRequest error:&fetchError];
        
        if (fetchError) {
            NSLog(@"Error fetching existing categories: %@", fetchError);
            return;
        }

        // Create a set of unique IDs for existing categories
        NSSet *existingIDs = [NSSet setWithArray:[existingCategories valueForKey:@"uniqueID"]];
        
        // Retrieve preset categories
        NSArray *presetCategories = [self categoryPresetData];
        NSMutableArray *categories = [NSMutableArray new];

        [presetCategories enumerateObjectsUsingBlock:^(NSDictionary *category, NSUInteger idx, BOOL *stop) {
            NSString *uniqueID = category[PRESET_ID_KEY];
            
            // Skip if the category already exists
            if ([existingIDs containsObject:uniqueID]) {
                return;
            }
            
            // Create new category
            WalletCategory_ *newCategory = [[WalletCategory_ alloc] initWithContext:context];
            newCategory.uniqueID = uniqueID;
            newCategory.name = NSLocalizedStringFromTable(category[PRESET_NAME_KEY], @"WalletPreset", nil);
            newCategory.icon = category[PRESET_ICON_KEY];
            newCategory.isSystem = @NO;
            newCategory.doNotShow = @NO;
            [categories addObject:newCategory];

            // Create fields for the category
            [category[PRESET_FIELDS_KEY] enumerateObjectsUsingBlock:^(NSDictionary *field, NSUInteger idx, BOOL *stop) {
                WalletField_ *newField = [[WalletField_ alloc] initWithContext:context];
                newField.uniqueID = field[PRESET_ID_KEY];
                newField.categoryID = newCategory.uniqueID;
                newField.name = NSLocalizedStringFromTable(field[PRESET_NAME_KEY], @"WalletPreset", nil);
                newField.style = field[PRESET_STYLE_KEY];
                newField.type = field[PRESET_TYPE_KEY];
                [newField assignOrderAsLast];
            }];
        }];

        // Sort categories by name
        [categories sortUsingComparator:^NSComparisonResult(WalletCategory_ *obj1, WalletCategory_ *obj2) {
            return [obj1.name compare:obj2.name];
        }];

        // Assign order values
        NSInteger order = 1000000;
        for (WalletCategory_ *category in categories) {
            category.order = [NSString orderStringWithOrder:order];
            order += 1000000;
        }

        // Save the context
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"Error saving context: %@", saveError);
        }
    }];
}

+ (void)createSystemCategory {
    // Order would be [Recent, Favorite, All]
    // So, make it from the last
    [WalletData insertAllCategory];
    [WalletData insertFavoriteCategory];
    [WalletData insertRecentsCategory];
}

+ (void)insertAllCategory {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.newBackgroundContext;

    [context performBlockAndWait:^{
        @try {
            // Check if "All Category" already exists
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WalletCategory_"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", A3WalletUUIDAllCategory];
            fetchRequest.fetchLimit = 1; // Limit to one result for efficiency

            NSError *fetchError = nil;
            NSUInteger count = [context countForFetchRequest:fetchRequest error:&fetchError];
            
            if (fetchError) {
                NSLog(@"Error fetching WalletCategory_: %@", fetchError);
                return;
            }

            // If no existing category found, create a new one
            if (count == 0) {
                WalletCategory_ *allCategory = [[WalletCategory_ alloc] initWithContext:context];
                allCategory.uniqueID = A3WalletUUIDAllCategory;
                allCategory.name = NSLocalizedString(@"Wallet_All_Category", @"All");
                allCategory.icon = @"wallet_folder";
                allCategory.isSystem = @YES;
                allCategory.doNotShow = @NO;
                allCategory.order = [NSString orderStringWithOrder:9999999999999999];

                // Assign the order as the first
                [allCategory assignOrderAsFirst];

                // Save the context
                NSError *saveError = nil;
                if (![context save:&saveError]) {
                    FNLOG(@"Error saving context: %@", saveError);
                }
            }
        } @catch (NSException *exception) {
            FNLOG(@"Exception in insertAllCategory: %@", exception);
        }
    }];
}

+ (void)insertRecentsCategory {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.newBackgroundContext;

    [context performBlockAndWait:^{
        @try {
            // Check if "Recents Category" already exists
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WalletCategory_"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", A3WalletUUIDRecentsCategory];
            fetchRequest.fetchLimit = 1; // Limit fetch for efficiency

            NSError *fetchError = nil;
            NSUInteger count = [context countForFetchRequest:fetchRequest error:&fetchError];

            if (fetchError) {
                NSLog(@"Error fetching WalletCategory_ for Recents: %@", fetchError);
                return;
            }

            // If no existing category found, create a new one
            if (count == 0) {
                WalletCategory_ *recentsCategory = [[WalletCategory_ alloc] initWithContext:context];
                recentsCategory.uniqueID = A3WalletUUIDRecentsCategory;
                recentsCategory.name = NSLocalizedString(@"Recents", nil);
                recentsCategory.icon = @"history";
                recentsCategory.isSystem = @YES;
                recentsCategory.doNotShow = @NO;
                recentsCategory.order = [NSString orderStringWithOrder:9999999999999999];

                // Assign the order as the first
                [recentsCategory assignOrderAsFirst];

                // Save the context
                NSError *saveError = nil;
                if (![context save:&saveError]) {
                    NSLog(@"Error saving context for Recents Category: %@", saveError);
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception in insertRecentsCategory: %@", exception);
        }
    }];
}

+ (void)initializeWalletCategories {
    FNLOG(@"Wallet CATEGORY - Initializing wallet categories");
    
    CoreDataStack *stack = [CoreDataStack shared];
    [stack fetchCloudKitRecordWithRecordType:@"CD_WalletCategory_"
                                   fieldName:@"CD_uniqueID"
                                  fieldValue:A3WalletUUIDAllCategory
                                  completion:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (record == nil) {
            NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
            [WalletData createLocalizedPresetCategories];
            [WalletData createSystemCategory];
            [context saveIfNeeded];
        }
    }];
}

+ (void)insertFavoriteCategory {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.newBackgroundContext;

    [context performBlockAndWait:^{
        @try {
            // Check if "Favorite Category" already exists
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WalletCategory_"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", A3WalletUUIDFavoriteCategory];
            fetchRequest.fetchLimit = 1; // Fetch only one result for efficiency

            NSError *fetchError = nil;
            NSUInteger count = [context countForFetchRequest:fetchRequest error:&fetchError];

            if (fetchError) {
                NSLog(@"Error fetching WalletCategory_ for Favorites: %@", fetchError);
                return;
            }

            // If no existing category found, create a new one
            if (count == 0) {
                WalletCategory_ *favoriteCategory = [[WalletCategory_ alloc] initWithContext:context];
                favoriteCategory.uniqueID = A3WalletUUIDFavoriteCategory;
                favoriteCategory.name = NSLocalizedString(@"Favorites", nil);
                favoriteCategory.icon = @"star01";
                favoriteCategory.isSystem = @YES;
                favoriteCategory.doNotShow = @NO;
                favoriteCategory.order = [NSString orderStringWithOrder:9999999999999999];

                // Assign the order as the first
                [favoriteCategory assignOrderAsFirst];

                // Save the context
                NSError *saveError = nil;
                if (![context save:&saveError]) {
                    NSLog(@"Error saving context for Favorite Category: %@", saveError);
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception in insertFavoriteCategory: %@", exception);
        }
    }];
}

+ (NSArray *)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
	if (hideDoNotShow) {
		NSArray *categories = [WalletCategory_ findAllSortedBy:@"order" ascending:YES];
		BOOL dataUpdated = NO;
		for (NSInteger idx = 0; idx < MIN(IS_IPHONE ? 4 : 7, [categories count]); idx++) {
			WalletCategory_ *category = categories[idx];
			if (category.doNotShow.boolValue) {
				category.doNotShow = @NO;
				dataUpdated = YES;
			}
		}
		if (dataUpdated) {
            [context saveIfNeeded];
		}
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", @"doNotShow", @(hideDoNotShow)];
		return [WalletCategory_ findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
	} else {
		return [WalletCategory_ findAllSortedBy:@"order" ascending:YES];
	}
}

+ (NSUInteger)visibleCategoryCount {
	NSArray *walletCategories = [WalletData walletCategoriesFilterDoNotShow:YES];
	return [walletCategories count] - 2;
}

+ (WalletCategory_ *)firstEditableWalletCategory {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSystem == NO AND doNotShow = NO"];
    return [WalletCategory_ findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:YES];
}

+ (NSArray *)categoriesExcludingSystemCategories {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSystem == NO"];
	return [WalletCategory_ findAllSortedBy:A3CommonPropertyOrder ascending:YES withPredicate:predicate];
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

+ (WalletCategory_ *)categoryItemWithID:(NSString *)categoryID {
	return [WalletCategory_ findFirstByAttribute:@"uniqueID" withValue:categoryID];
}

+ (WalletField_ *)fieldOfFieldItem:(WalletFieldItem_ *)fieldItem {
	return [WalletField_ findFirstByAttribute:@"uniqueID" withValue:fieldItem.fieldID];
}

+ (NSString *)stringRepresentationOfContents {
    NSMutableString *contents = [[NSMutableString alloc] init];
    
    NSArray *categories = [WalletCategory_ findAllSortedBy:@"order" ascending:YES];
    [categories enumerateObjectsUsingBlock:^(WalletCategory_ * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *fields = [WalletField_ findByAttribute:@"categoryID" withValue:category.uniqueID];
        if ([fields count]) {
            NSArray *items = [WalletItem_ findByAttribute:@"categoryID" withValue:category.uniqueID];
            // Add category name here
            [contents appendString:[NSString stringWithFormat:@"%@: %@\n", [NSLocalizedString(@"Category", nil) uppercaseString], category.name]];
            // Add field header here
            [contents appendString:[NSString stringWithFormat:@"%@\n", [NSLocalizedString(@"Columns Header", nil) uppercaseString]]];
            [fields enumerateObjectsUsingBlock:^(WalletField_ * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                [contents appendString:[NSString stringWithFormat:@"%@ (%@, %@), ",
                                        field.name,
                                        NSLocalizedString(field.type, nil),
                                        NSLocalizedString(field.style, nil)]];
            }];
            [contents deleteCharactersInRange:NSMakeRange(contents.length - 2, 2)];
            [contents appendString:@"\n"];
            [items enumerateObjectsUsingBlock:^(WalletItem_ * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *fieldItems = [item fieldItemsArraySortedByFieldOrder];
                // Add field items
                if ([fieldItems count]) {
                    [fieldItems enumerateObjectsUsingBlock:^(WalletFieldItem_ * _Nonnull fieldItem, NSUInteger idx, BOOL * _Nonnull stop) {
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
    for (WalletItem_ *object in array) {
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
    
    NSArray *categories = [WalletCategory_ findAllSortedBy:@"order" ascending:YES];
    for (WalletCategory_ *category in categories) {
        if ([category.uniqueID isEqualToString:A3WalletUUIDAllCategory] || [category.uniqueID isEqualToString:A3WalletUUIDFavoriteCategory]) continue;
        
        FNLOG(@"%@", category.uniqueID);
        FNLOG(@"%@", category.name);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", category.uniqueID];
        NSArray *allRows = [WalletItem_ findAllSortedBy:@"name" ascending:YES withPredicate:predicate];
        
        if ([allRows count] == 0) continue;
        
        allRows = [WalletData sortedArrayUsingCollation:allRows];
        
        [contents appendString:[NSString stringWithFormat:@"<h2>%@ (%lu)</h2>", category.name, (unsigned long)[allRows count]]];

        [contents appendString:@"<table>"];
        
        NSArray *fields = [WalletField_ findByAttribute:@"categoryID" withValue:category.uniqueID];
        [contents appendString:@"<tr>"];
        [contents appendString:[NSString stringWithFormat:@"<th style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</th>", NSLocalizedString(@"Title", nil)]];
        for (WalletField_ *field in fields) {
            [contents appendString:[NSString stringWithFormat:@"<th style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</th>", field.name ?: @""]];
        }
        [contents appendString:[NSString stringWithFormat:@"<th style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</th>", NSLocalizedString(@"Memo", nil)]];
        [contents appendString:@"</tr>"];

        // Append table header row
        for (WalletItem_ *row in allRows) {
            [contents appendString:@"<tr>"];
            [contents appendString:[NSString stringWithFormat:@"<td style=\"border: 1px solid #dddddd;text-align: left;padding: 8px;\">%@</td>", row.name ?: @""]];
            for (WalletField_ *field in fields) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@ AND fieldID == %@", row.uniqueID, field.uniqueID];
                NSArray *fieldItems = [WalletFieldItem_ findAllWithPredicate:predicate];
                if ([fieldItems count]) {
                    WalletFieldItem_ *fieldItem = fieldItems[0];
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
