//
//  WalletData.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletData.h"
#import "WalletFieldItem+initialize.h"
#import "NSString+conversion.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import <AVFoundation/AVFoundation.h>

NSString *const W_DoNotShow_KEY				= @"doNotShow";
NSString *const W_SYSTEM_KEY				= @"SYSTEM";
NSString *const W_NAME_KEY					= @"name";
NSString *const W_ICON_KEY					= @"icon";
NSString *const W_ID_KEY					= @"uniqueID";
NSString *const W_FIELDS_KEY				= @"Fields";
NSString *const W_STYLE_KEY					= @"style";
NSString *const W_TYPE_KEY					= @"type";

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

+ (NSMutableArray *)localizedPresetCategories {
	NSMutableArray *presetCategories = [[self categoryPresetData] mutableCopy];
	NSMutableArray *newCategories = [NSMutableArray new];
	[presetCategories enumerateObjectsUsingBlock:^(NSDictionary *category, NSUInteger idx, BOOL *stop) {
		NSMutableDictionary *newCategory = [category mutableCopy];
		newCategory[W_NAME_KEY] = NSLocalizedStringFromTable(category[W_NAME_KEY], @"WalletPreset", nil);

		NSMutableArray *newFields = [NSMutableArray new];
		[category[W_FIELDS_KEY] enumerateObjectsUsingBlock:^(NSDictionary *field, NSUInteger idx, BOOL *stop) {
			NSMutableDictionary *newField = [field mutableCopy];
			newField[W_NAME_KEY] = NSLocalizedStringFromTable(field[W_NAME_KEY], @"WalletPreset", nil);
			[newFields addObject:newField];
		}];
		newCategory[W_FIELDS_KEY] = newFields;

		[newCategories addObject:newCategory];
	}];
	[newCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [NSLocalizedStringFromTable(obj1[W_NAME_KEY], @"WalletPreset", nil)
				compare:NSLocalizedStringFromTable(obj2[W_NAME_KEY], @"WalletPreset", nil)];
	}];
	return newCategories;
}

+ (NSArray *)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow {
	NSArray *object = [[NSUserDefaults standardUserDefaults] objectForKey:A3WalletUserDefaultsCategoryInfo];
	if (object) {
		if (hideDoNotShow) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != YES", W_DoNotShow_KEY];
			return [object filteredArrayUsingPredicate:predicate];
		}
		return object;
	}

	NSMutableArray *newCategories = [WalletData localizedPresetCategories];
	[newCategories insertObject:@{
			W_ID_KEY : A3WalletUUIDFavoriteCategory,
			W_NAME_KEY : NSLocalizedString(@"Favorites", nil),
			W_ICON_KEY : @"star01",
			W_SYSTEM_KEY : W_SYSTEM_KEY
	} atIndex:0];

	[newCategories insertObject:@{
			W_ID_KEY : A3WalletUUIDAllCategory,
			W_NAME_KEY : NSLocalizedString(@"Wallet_All_Category", @"All"),
			W_ICON_KEY : @"wallet_folder",
			W_SYSTEM_KEY : W_SYSTEM_KEY
	} atIndex:1];

	[WalletData saveWalletObject:newCategories forKey:A3WalletUserDefaultsCategoryInfo];
	return newCategories;
}

+ (NSUInteger)visibleCategoryCount {
	NSArray *walletCategories = [WalletData walletCategoriesFilterDoNotShow:YES];
	return [walletCategories count] - 2;
}

+ (NSDictionary *)firstEditableWalletCategory {
	NSArray *walletCategories = [WalletData walletCategoriesFilterDoNotShow:YES];
	NSUInteger idx = [walletCategories indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return obj[W_SYSTEM_KEY] == nil && obj[W_DoNotShow_KEY] == nil;
	}];
	return walletCategories[idx];
}

+ (NSArray *)categoriesExcludingSystemCategories {
	NSArray *allCategories = [WalletData walletCategoriesFilterDoNotShow:YES];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == NULL", W_SYSTEM_KEY];
	return [allCategories filteredArrayUsingPredicate:predicate];
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

+ (NSDictionary *)categoryItemWithID:(NSString *)categoryID {
	NSArray *allCategories = [WalletData walletCategoriesFilterDoNotShow:NO];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", W_ID_KEY, categoryID];
	NSArray *result = [allCategories filteredArrayUsingPredicate:predicate];
	if ([result count] >= 1) {
		return result[0];
	}
	return nil;
}

+ (void)saveCategory:(NSDictionary *)category {
	NSMutableArray *allCategories = [[WalletData walletCategoriesFilterDoNotShow:NO] mutableCopy];
	NSUInteger idx = [allCategories indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return [obj[W_ID_KEY] isEqualToString:category[W_ID_KEY]];
	}];
	if (idx != NSNotFound) {
		allCategories[idx] = category;
	} else {
		[allCategories addObject:category];
	}
	[WalletData saveWalletObject:allCategories forKey:A3WalletUserDefaultsCategoryInfo];
}

+ (void)saveWalletObject:(id)object forKey:(NSString *)key {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3WalletUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:object forKey:key];
		[store setObject:updateDate forKey:A3WalletUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

+ (NSDictionary *)fieldOfFieldItem:(WalletFieldItem *)fieldItem category:(NSDictionary *)category {
	NSArray *fields = category[W_FIELDS_KEY];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", W_ID_KEY, fieldItem.fieldID];
	NSArray *filtered = [fields filteredArrayUsingPredicate:predicate];
	if ([filtered count]) {
		return filtered[0];
	}
	return nil;
}

@end
