//
//  A3TranslatorLanguage.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3TranslatorLanguage : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *googleCode;

+ (NSArray *)findAllWithDetectLanguage:(BOOL)addDetectLanguage;

+ (NSArray *)filteredArrayWithArray:(NSArray *)array searchString:(NSString *)searchString includeDetectLanguage:(BOOL)includeDetectLanguage;

+ (A3TranslatorLanguage *)findLanguageInArray:(NSArray *)array searchString:(NSString *)searchString;

+ (NSString *)googleCodeFromAppleCode:(NSString *)appleCode;

+ (NSString *)appleCodeFromGoogleCode:(NSString *)googleCode;

+ (NSString *)localizedNameForCode:(NSString *)code;

@end
