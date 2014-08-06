//
//  WalletData.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

extern NSString *const W_DoNotShow_KEY;
extern NSString *const W_SYSTEM_KEY;
extern NSString *const W_NAME_KEY;
extern NSString *const W_ICON_KEY;
extern NSString *const W_ID_KEY;
extern NSString *const W_FIELDS_KEY;
extern NSString *const W_STYLE_KEY;
extern NSString *const W_TYPE_KEY;

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

@interface WalletData : NSObject

+ (NSArray *)typeList;
+ (NSDictionary *)styleList;
+ (NSArray *)categoryPresetData;

+ (float)getDurationOfMovie:(NSURL *)fileURL;
+ (NSDate *)getCreateDateOfMovie:(NSURL *)fileURL;
+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl;

+ (void)createDirectories;

+ (NSMutableArray *)localizedPresetCategories;

+ (NSArray *)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow;
+ (NSUInteger)visibleCategoryCount;
+ (NSDictionary *)firstEditableWalletCategory;

+ (NSArray *)categoriesExcludingSystemCategories;

+ (NSArray *)iconList;
+ (NSDictionary *)categoryItemWithID:(NSString *)categoryID;
+ (void)saveCategory:(NSDictionary *)category;

+ (NSDictionary *)fieldOfFieldItem:(WalletFieldItem *)fieldItem category:(NSDictionary *)category;
@end
