//
//  A3SpeechTest.m
//  AppBox3
//
//  Created by A3 on 3/2/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>

@interface A3SpeechTest : XCTestCase

@end

@implementation A3SpeechTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testScreen {
	UIScreen *mainScreen = [UIScreen mainScreen];
//	FNLOGRECT(mainScreen.nativeBounds);
//	FNLOGRECT(mainScreen.bounds);
//	FNLOG(@"%f", mainScreen.scale);
//	FNLOG(@"%f", mainScreen.nativeScale);
	
	UIDevice *device = [UIDevice currentDevice];
//	FNLOG(@"%@", device.systemName);
//	FNLOG(@"%@", device.model);
}

- (void)testAVSpeech
{
	NSMutableSet *appleSpeechSet = [NSMutableSet new];
	NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
	voices = [voices sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [[obj1 valueForKeyPath:@"language"] compare:[obj2 valueForKeyPath:@"language"]];
	}];
	NSLocale *locale = [NSLocale currentLocale];
	NSMutableString *log = [NSMutableString new];
	
	[log appendString:@"\n"];
	for (AVSpeechSynthesisVoice *voice in voices) {
		[log appendFormat:@"%@: ", voice.language];
		[log appendFormat:@"%@\n", [locale displayNameForKey:NSLocaleLanguageCode value:[voice.language substringToIndex:2]]];
		[appleSpeechSet addObject:[voice.language substringToIndex:2]];
	}

	NSArray *googleTranslation = @[								  @"af",		// Afrikaans, 2009-09-22
																  @"ar",		// Arabic
																  @"be",		// Belarusian, 2009-09-22
																  @"bg",		// Bulgarian
																  @"ca",		// Catalan,
																  @"cs",		// Czech
																  @"cy",		// Welsh, 2009-09-22
																  @"da",		// Danish
																  @"de",		// German,
																  @"el",		// Greek,
																  @"en",		// English,
																  @"es",		// Spanish,
																  @"et",		// Estonian,
																  @"fa",		// Persian,
																  @"fi",		// Finnish,
																  @"fr",		// French,
																  @"ga",		// Irish, 2009-09-22
																  @"gl",		// Galician,
																  @"hi",		// Hindi,
																  @"hr",		// Croatian
																  @"ht",		// Haitian, Haitian Creole, 2010-01-25
																  @"hu",		// Hungarian,
																  @"id",		// Indonesian,
																  @"is",		// Icelandic, 2009-09-22
																  @"it",		// Italian,
																  @"he",		// Hebrew, "iw" in Google
																  @"ja",		// Japanese,
																  @"ko",		// Korean,
																  @"lt",		// Lithuanian,
																  @"lv",		// Latvian,
																  @"mk",		// Macedonian, 2009-09-22
																  @"ms",		// Malay, 2009-09-22
																  @"mt",		// Maltese,
																  @"no",		// Norwegian,
																  @"nl",		// Dutch
																  @"pl",		// Polish,
																  @"pt",		// Portuguese,
																  @"ro",		// Romanian,
																  @"ru",		// Russian,
																  @"sk",		// Slovak,
																  @"sl",		// Slovenian,
																  @"sq",		// Albanian
																  @"sr",		// Serbian,
																  @"sv",		// Swedish,
																  @"sw",		// Swahili, 2009-09-22
																  @"th",		// Thai, 
																  @"fil",		// Filipino, "tl" in Google
																  @"tr",		// Turkish, 
																  @"uk",		// Ukrainian, 
																  @"vi",		// Vietnamese, 
																  @"yi",		// Yiddish, 2009-09-22
																  @"zh-Hans",	// Chinese
																  @"zh-Hant",	// zh-CN, zh-TW,
																  ];
	[log appendString:@"\n"];
	NSSet *googleVoice = [NSSet setWithArray:@[@"be", @"bg", @"et", @"tl", @"ga", @"gl", @"iw", @"ga", @"lt", @"ms", @"mt", @"fa", @"sl", @"th", @"uk", @"yi"]];
	NSMutableSet *googleSpeechSet = [NSMutableSet new];
	for (NSString *code in googleTranslation) {
		if (![googleVoice member:code]) {
			[log appendFormat:@"%@: %@\n", code, [locale displayNameForKey:NSLocaleLanguageCode value:code]];
			[googleSpeechSet addObject:code];
		}
	}
	NSLog(@"%@", log);

	[googleSpeechSet minusSet:appleSpeechSet];
	
	NSLog(@"%@", googleSpeechSet);
}

@end
