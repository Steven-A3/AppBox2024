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
#import "WalletCategory.h"
#import "NSManagedObject+extension.h"
#import "WalletField.h"
#import "NSMutableArray+A3Sort.h"
#import <AVFoundation/AVFoundation.h>

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

+ (void)createLocalizedPresetCategoriesInContext:(NSManagedObjectContext *)context {
	NSArray *presetCategories = [self categoryPresetData];
	NSMutableArray *categories = [NSMutableArray new];
	[presetCategories enumerateObjectsUsingBlock:^(NSDictionary *category, NSUInteger idx, BOOL *stop) {
		WalletCategory *newCategory = [WalletCategory MR_createEntityInContext:context];
		newCategory.uniqueID = category[PRESET_ID_KEY];
		newCategory.name = NSLocalizedStringFromTable(category[PRESET_NAME_KEY], @"WalletPreset", nil);
		newCategory.icon = category[PRESET_ICON_KEY];
		newCategory.isSystem = @NO;
		newCategory.doNotShow = @NO;
		[categories addObject:newCategory];

		[category[PRESET_FIELDS_KEY] enumerateObjectsUsingBlock:^(NSDictionary *field, NSUInteger idx, BOOL *stop) {
			WalletField *newField = [WalletField MR_createEntityInContext:context];
			newField.uniqueID = field[PRESET_ID_KEY];
			newField.categoryID = newCategory.uniqueID;
			newField.name = NSLocalizedStringFromTable(field[PRESET_NAME_KEY], @"WalletPreset", nil);
			newField.style = field[PRESET_STYLE_KEY];
			newField.type = field[PRESET_TYPE_KEY];
			[newField assignOrderAsLastInContext:context];
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

+ (void)createSystemCategoryInContext:(NSManagedObjectContext *)context {
	WalletCategory *allCategory = [WalletCategory MR_createEntityInContext:context];
	allCategory.uniqueID = A3WalletUUIDAllCategory;
	allCategory.name = NSLocalizedString(@"Wallet_All_Category", @"All");
	allCategory.icon = @"wallet_folder";
	allCategory.isSystem = @YES;
	allCategory.doNotShow = @NO;
	[allCategory assignOrderAsFirstInContext:context];

	WalletCategory *favoriteCategory = [WalletCategory MR_createEntityInContext:context];
	favoriteCategory.uniqueID = A3WalletUUIDFavoriteCategory;
	favoriteCategory.name = NSLocalizedString(@"Favorites", nil);
	favoriteCategory.icon = @"star01";
	favoriteCategory.isSystem = @YES;
	favoriteCategory.doNotShow = @NO;
	[favoriteCategory assignOrderAsFirstInContext:context];
}

+ (void)initializeWalletCategories {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_defaultContext];
	[WalletData createLocalizedPresetCategoriesInContext:savingContext];
	[WalletData createSystemCategoryInContext:savingContext];
	[savingContext MR_saveToPersistentStoreAndWait];
}

+ (NSArray *)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow inContext:(NSManagedObjectContext *)context {
	NSManagedObjectContext *workingContext = context ? context : [NSManagedObjectContext MR_defaultContext];
	if (hideDoNotShow) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", @"doNotShow", @(hideDoNotShow)];
		return [WalletCategory MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate inContext:workingContext];
	} else {
		return [WalletCategory MR_findAllSortedBy:@"order" ascending:YES inContext:workingContext];
	}
}

+ (NSUInteger)visibleCategoryCount {
	NSArray *walletCategories = [WalletData walletCategoriesFilterDoNotShow:YES inContext:nil ];
	return [walletCategories count] - 2;
}

+ (WalletCategory *)firstEditableWalletCategory {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSystem == NO AND doNotShow = NO"];
    return [WalletCategory MR_findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:YES];
}

+ (NSArray *)categoriesExcludingSystemCategories {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSystem == NO"];
	return [WalletCategory MR_findAllSortedBy:A3CommonPropertyOrder ascending:YES withPredicate:predicate];
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

+ (WalletCategory *)categoryItemWithID:(NSString *)categoryID inContext:(NSManagedObjectContext *)context {
	if (!context) {
		context = [NSManagedObjectContext MR_defaultContext];
	}
	return [WalletCategory MR_findFirstByAttribute:@"uniqueID" withValue:categoryID inContext:context];
}

+ (WalletField *)fieldOfFieldItem:(WalletFieldItem *)fieldItem {
	return [WalletField MR_findFirstByAttribute:@"uniqueID" withValue:fieldItem.fieldID];
}

@end
