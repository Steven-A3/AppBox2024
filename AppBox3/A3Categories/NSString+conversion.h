//
//  NSString+conversion.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/1/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (conversion)

+ (NSString *)combineString:(NSString *)string1 withString:(NSString *)string2;
+ (NSString *)orderStringWithOrder:(NSInteger)order;
- (NSMutableString *)extendedSearchPatternForKoreanString;
- (NSString *)componentsSeparatedByKorean;

- (NSString *)pathInDocumentDirectory;

- (NSString *)pathInLibraryDirectory;
- (NSString *)pathInCachesDirectory;
- (NSString *)pathInTemporaryDirectory;

- (NSString *)stringByTrimmingSpaceCharacters;

- (NSString *)pathInCachesDataDirectory;

- (NSString *)stringGroupByFirstInitial;
- (float)floatValueEx;
- (NSString *)stringByDecimalConversion;

@end
