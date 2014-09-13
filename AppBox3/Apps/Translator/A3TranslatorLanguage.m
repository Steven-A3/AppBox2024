//
//  A3TranslatorLanguage.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorLanguage.h"
#import "A3UIDevice.h"
#import "NSString+conversion.h"

static NSString *const kTranslatorAppleCode = @"AppleCode";
static NSString *const kTranslatorGoogleCode = @"GoogleCode";
static NSString *const kTranslatorLocalizedName = @"localizedName";

@implementation A3TranslatorLanguage

+ (NSArray *)findAllWithDetectLanguage:(BOOL)addDetectLanguage {
	NSArray *languageCodes = @[
			@{kTranslatorAppleCode:@"af"},		// Afrikaans, 2009-09-22
			@{kTranslatorAppleCode:@"ar"},		// Arabic
			@{kTranslatorAppleCode:@"be"},		// Belarusian, 2009-09-22
			@{kTranslatorAppleCode:@"bg"},		// Bulgarian
			@{kTranslatorAppleCode:@"ca"},		// Catalan,
			@{kTranslatorAppleCode:@"cs"},		// Czech
			@{kTranslatorAppleCode:@"cy"},		// Welsh, 2009-09-22
			@{kTranslatorAppleCode:@"da"},		// Danish
			@{kTranslatorAppleCode:@"de"},		// German,
			@{kTranslatorAppleCode:@"el"},		// Greek,
			@{kTranslatorAppleCode:@"en"},		// English,
			@{kTranslatorAppleCode:@"es"},		// Spanish,
			@{kTranslatorAppleCode:@"et"},		// Estonian,
			@{kTranslatorAppleCode:@"fa"},		// Persian,
			@{kTranslatorAppleCode:@"fi"},		// Finnish,
			@{kTranslatorAppleCode:@"fr"},		// French,
			@{kTranslatorAppleCode:@"ga"},		// Irish, 2009-09-22
			@{kTranslatorAppleCode:@"gl"},		// Galician,
			@{kTranslatorAppleCode:@"hi"},		// Hindi,
			@{kTranslatorAppleCode:@"hr"},		// Croatian
			@{kTranslatorAppleCode:@"ht"},		// Haitian, Haitian Creole, 2010-01-25
			@{kTranslatorAppleCode:@"hu"},		// Hungarian,
			@{kTranslatorAppleCode:@"id"},		// Indonesian,
			@{kTranslatorAppleCode:@"is"},		// Icelandic, 2009-09-22
			@{kTranslatorAppleCode:@"it"},		// Italian,
			@{kTranslatorAppleCode:@"he", kTranslatorGoogleCode:@"iw"},		// Hebrew, "iw" in Google
			@{kTranslatorAppleCode:@"ja"},		// Japanese,
			@{kTranslatorAppleCode:@"ko"},		// Korean,
			@{kTranslatorAppleCode:@"lt"},		// Lithuanian,
			@{kTranslatorAppleCode:@"lv"},		// Latvian,
			@{kTranslatorAppleCode:@"mk"},		// Macedonian, 2009-09-22
			@{kTranslatorAppleCode:@"ms"},		// Malay, 2009-09-22
			@{kTranslatorAppleCode:@"mt"},		// Maltese,
			@{kTranslatorAppleCode:@"no"},		// Norwegian,
			@{kTranslatorAppleCode:@"nl"},		// Dutch
			@{kTranslatorAppleCode:@"pl"},		// Polish,
			@{kTranslatorAppleCode:@"pt"},		// Portuguese,
			@{kTranslatorAppleCode:@"ro"},		// Romanian,
			@{kTranslatorAppleCode:@"ru"},		// Russian,
			@{kTranslatorAppleCode:@"sk"},		// Slovak,
			@{kTranslatorAppleCode:@"sl"},		// Slovenian,
			@{kTranslatorAppleCode:@"sq"},		// Albanian
			@{kTranslatorAppleCode:@"sr"},		// Serbian,
			@{kTranslatorAppleCode:@"sv"},		// Swedish,
			@{kTranslatorAppleCode:@"sw"},		// Swahili, 2009-09-22
			@{kTranslatorAppleCode:@"th"},		// Thai,
			@{kTranslatorAppleCode:@"fil", kTranslatorGoogleCode:@"tl"},		// Filipino, "tl" in Google
			@{kTranslatorAppleCode:@"tr"},		// Turkish,
			@{kTranslatorAppleCode:@"uk"},		// Ukrainian,
			@{kTranslatorAppleCode:@"vi"},		// Vietnamese,
			@{kTranslatorAppleCode:@"yi"},		// Yiddish, 2009-09-22
			@{kTranslatorAppleCode:@"zh-Hans", kTranslatorGoogleCode:@"zh-CN"},	// Chinese
			@{kTranslatorAppleCode:@"zh-Hant", kTranslatorGoogleCode:@"zh-TW"},	// zh-CN, zh-TW,
	];

	NSMutableArray *newArray = [NSMutableArray new];
	for (NSDictionary *item in languageCodes) {
		A3TranslatorLanguage *newItem = [A3TranslatorLanguage new];
		newItem.code = [item valueForKey:kTranslatorAppleCode];
		newItem.googleCode = [item valueForKey:kTranslatorGoogleCode];
		if (![newItem.googleCode length]) {
			newItem.googleCode = newItem.code;
		}
        newItem.name = [[self class] localizedNameForCode:newItem.code];
		[newArray addObject:newItem];
	}
    [newArray sortUsingComparator:^NSComparisonResult(A3TranslatorLanguage *obj1, A3TranslatorLanguage *obj2) {
		return [obj1.name compare:obj2.name];
	}];
	if (addDetectLanguage) {
		A3TranslatorLanguage *detectLanguage = [A3TranslatorLanguage new];
		detectLanguage.name = NSLocalizedString(@"Detect Language", @"Detect Language");
        detectLanguage.code = @"Detect";
		[newArray insertObject:detectLanguage atIndex:0];
	}
	return newArray;
}

+ (NSString *)localizedNameForCode:(NSString *)code {
    if ([code isEqualToString:@"Detect"]) return NSLocalizedString(@"Detect Language", @"Detect Language");
	if ([code isEqualToString:@"zh-Hans"]) return NSLocalizedString(@"Simplified Chinese", @"Simplified Chinese");
	if ([code isEqualToString:@"zh-Hant"]) return NSLocalizedString(@"Traditional Chinese", @"Traditional Chinese");
	NSString *result = [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:code];
	if (result == nil) {
		result = @"";
	}
	return result;
}

+ (NSArray *)filteredArrayWithArray:(NSArray *)array searchString:(NSString *)searchString includeDetectLanguage:(BOOL)includeDetectLanguage {
	NSString *trimmed = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSPredicate *predicate;
	if (LANGUAGE_KOREAN) {
		NSString *format;
		if (includeDetectLanguage) {
			format = @"name contains[cd] %@ OR name.componentsSeparatedByKorean contains %@";
            predicate = [NSPredicate predicateWithFormat:format, trimmed, trimmed];
		} else {
			format = @"(name contains[cd] %@ OR name.componentsSeparatedByKorean contains %@) AND code.length >= 1 AND code != %@";
            predicate = [NSPredicate predicateWithFormat:format, trimmed, trimmed, @"Detect"];
		}
	} else {
        NSString *format;
		if (includeDetectLanguage) {
			format = @"name contains[cd] %@";
            predicate = [NSPredicate predicateWithFormat:format, searchString];
		} else {
			format = @"name contains[cd] %@ AND code.length >= 1 AND code != %@";
            predicate = [NSPredicate predicateWithFormat:format, searchString, @"Detect"];
		}
	}
	return [array filteredArrayUsingPredicate:predicate];
}

+ (A3TranslatorLanguage *)findLanguageInArray:(NSArray *)array searchString:(NSString *)searchString {
	NSString *trimmed = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	NSPredicate *predicate;
	if (LANGUAGE_KOREAN) {
		predicate = [NSPredicate predicateWithFormat:@"name.componentsSeparatedByKorean contains %@", trimmed];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"name like[cd] %@", trimmed];
	}
	NSArray *result = [array filteredArrayUsingPredicate:predicate];
	if ([result count] == 1) {
		return result[0];
	} else {
		return nil;
	}
}

+ (NSString *)googleCodeFromAppleCode:(NSString *)appleCode {
	NSString *googleCode = appleCode;
	if ([appleCode isEqualToString:@"zh-Hans"]) {
		googleCode = @"zh-CN";
	} else if ([appleCode isEqualToString:@"zh-Hant"]) {
		googleCode = @"zh-TW";
	} else if ([appleCode isEqualToString:@"fil"]) {
		googleCode = @"tl";
	} else if ([appleCode isEqualToString:@"he"]) {
		googleCode = @"iw";
	}
	return googleCode;
}

+ (NSString *)appleCodeFromGoogleCode:(NSString *)googleCode {
	NSString *appleCode = googleCode;
	if ([appleCode isEqualToString:@"zh-CN"]) {
		appleCode = @"zh-Hans";
	} else if ([appleCode isEqualToString:@"zh-TW"]) {
		appleCode = @"zh-Hant";
	} else if ([appleCode isEqualToString:@"tl"]) {
		appleCode = @"fil";
	} else if ([appleCode isEqualToString:@"iw"]) {
		appleCode = @"he";
	}
	return appleCode;
}

@end
