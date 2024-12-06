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
extern NSString *const A3WalletUUIDRecentsCategory;
extern NSString *const A3WalletUUIDPhotoCategory;
extern NSString *const A3WalletUUIDVideoCategory;
extern NSString *const A3WalletUUIDMemoCategory;

@class WalletFieldItem_;
@class WalletField_;
@class WalletCategory_;

@interface WalletData : NSObject

+ (NSArray *)typeList;
+ (NSDictionary *)styleList;
+ (NSArray *)categoryPresetData;
+ (float)getDurationOfMovie:(NSURL *)fileURL;
+ (NSDate *)getCreateDateOfMovie:(NSURL *)fileURL;
+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl;
+ (void)createDirectories;
+ (void)createLocalizedPresetCategories;
+ (void)createSystemCategory;
+ (void)insertRecentsCategory;
+ (void)initializeWalletCategories;
+ (NSArray *_Nonnull)walletCategoriesFilterDoNotShow:(BOOL)hideDoNotShow;
+ (NSUInteger)visibleCategoryCount;
+ (WalletCategory_ *_Nonnull)firstEditableWalletCategory;
+ (NSArray *_Nonnull)categoriesExcludingSystemCategories;
+ (NSArray *_Nonnull)iconList;
+ (WalletCategory_ *_Nonnull)categoryItemWithID:(NSString *_Nullable)categoryID;
+ (WalletField_ *_Nonnull)fieldOfFieldItem:(WalletFieldItem_ *_Nonnull)fieldItem;
+ (NSString *_Nonnull)stringRepresentationOfContents;
+ (NSString *_Nonnull)htmlRepresentationOfContents;

@end
