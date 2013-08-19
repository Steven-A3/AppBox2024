//
//  TranslatorHistory+addition.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "TranslatorHistory+addition.h"
#import "A3TranslatorLanguage.h"

@implementation TranslatorHistory (addition)

//- (void)awakeFromFetch {
//	[super awakeFromFetch];
//
//	[self setLanguageGroup:[NSString stringWithFormat:@"%@ to %@", [A3TranslatorLanguage localizedNameForCode:self.originalLanguage], [A3TranslatorLanguage localizedNameForCode:self.translatedLanguage]]];
//}
- (NSString *)languageGroup {
	return [NSString stringWithFormat:@"%@ to %@", [A3TranslatorLanguage localizedNameForCode:self.originalLanguage], [A3TranslatorLanguage localizedNameForCode:self.translatedLanguage]];
}

@end
