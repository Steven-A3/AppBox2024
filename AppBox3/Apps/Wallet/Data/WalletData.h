//
//  WalletData.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletData : NSObject

#define WalletFieldStyleNormal		@"Normal"
#define WalletFieldStylePassword	@"Password"
#define WalletFieldStyleAccount		@"Account"
#define WalletFieldStyleHidden		@"Hidden"

#define WalletFieldTypeText			@"Text"					//  Value
#define WalletFieldTypeNumber		@"Number"
#define WalletFieldTypePhone		@"Phone"
#define WalletFieldTypeURL			@"URL"
#define WalletFieldTypeEmail		@"Email"
#define WalletFieldTypeDate			@"Date"
#define WalletFieldTypeImage		@"Image"
#define WalletFieldTypeVideo		@"Video"

#define WalletCategoryTypePhoto		@"Photos"
#define WalletCategoryTypeVideo		@"Video"

#define kWalletImageFilePrefix		@"ABP_WALLET_PHOTO_IMAGE"

+ (NSArray *)typeList;
+ (NSDictionary *)styleList;
+ (NSArray *)categoryPresetData;

+ (NSString *)thumbImgPathOfImgPath:(NSString *)imagePath;
+ (NSString *)thumbImgPathOfVideoPath:(NSString *)videoPath;
+ (void)deleteFileAtPath:(NSString *)filePath;

+ (float)getDurationOfMovie:(NSString *)filePath;
+ (NSDate *)getCreateDateOfMovie:(NSString *)filePath;
+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl;

@end
