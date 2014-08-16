//
//  WalletData.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

extern NSString *const WalletFieldTypeText;
extern NSString *const WalletFieldTypeNumber;
extern NSString *const WalletFieldTypePhone;
extern NSString *const WalletFieldTypeURL;
extern NSString *const WalletFieldTypeEmail;
extern NSString *const WalletFieldTypeDate;
extern NSString *const WalletFieldTypeImage;
extern NSString *const WalletFieldTypeVideo;

extern NSString *const WalletFieldStyleNormal;
extern NSString *const WalletFieldStylePassword;
extern NSString *const WalletFieldStyleAccount;
extern NSString *const WalletFieldStyleHidden;

extern NSString *const WalletFieldNativeType;
extern NSString *const WalletFieldNativeTypeText;
extern NSString *const WalletFieldNativeTypeImage;
extern NSString *const WalletFieldNativeTypeVideo;
extern NSString *const WalletFieldTypeID;

extern NSString *const A3WalletUUIDAllCategory;
extern NSString *const A3WalletUUIDFavoriteCategory;
extern NSString *const A3WalletUUIDPhotoCategory;
extern NSString *const A3WalletUUIDVideoCategory;
extern NSString *const A3WalletUUIDMemoCategory;

@class WalletFieldItem;
@class WalletField;
@class WalletCategory;

@interface WalletData : NSObject

+ (NSArray *)typeList;
+ (NSDictionary *)styleList;
+ (NSArray *)categoryPresetData;

+ (float)getDurationOfMovie:(NSURL *)fileURL;
+ (NSDate *)getCreateDateOfMovie:(NSURL *)fileURL;
+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl;

+ (void)createDirectories;

+ (void)createLocalizedPresetCategoriesInContext:(NSManagedObjectContext *)context;

+ (void)createSystemCategoryInContext:(NSManagedObjectContext *)context;

+ (void)initializeWalletCategories;

+ (NSArray *)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)visibleCategoryCount;
+ (WalletCategory *)firstEditableWalletCategory;

+ (NSArray *)categoriesExcludingSystemCategories;

+ (NSArray *)iconList;
+ (WalletCategory *)categoryItemWithID:(NSString *)categoryID;

+ (WalletField *)fieldOfFieldItem:(WalletFieldItem *)fieldItem;
@end
