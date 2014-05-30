//
//  WalletData.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

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

extern NSString *const WalletCategoryTypePhoto;
extern NSString *const WalletCategoryTypeVideo;

@interface WalletData : NSObject

+ (NSArray *)typeList;
+ (NSDictionary *)styleList;
+ (NSArray *)categoryPresetData;

+ (float)getDurationOfMovie:(NSString *)filePath;
+ (NSDate *)getCreateDateOfMovie:(NSString *)filePath;
+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl;

@end
