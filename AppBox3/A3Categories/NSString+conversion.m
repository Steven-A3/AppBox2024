//
//  NSString+conversion.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/1/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSString+conversion.h"
#import "common.h"
#import "A3AppDelegate.h"

@implementation NSString (conversion)

- (NSString *)stringGroupByFirstInitial {
	NSString *temp = [self uppercaseString];

	if (!temp.length || temp.length == 1)
		return temp;
	return [temp substringToIndex:1];
}

- (NSNumber *)numberFromCurrencyFormattedStringWithCurrencyCode:(NSString *)currencyCode {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSString *myCurrencyCode = currencyCode;
	if (myCurrencyCode == nil) {
		if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"MT"]) {
			[numberFormatter setCurrencyCode:@"EUR"];
			[numberFormatter setCurrencySymbol:@"€"];
		} else {
			[numberFormatter setCurrencyCode:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]];
		}
	}
	[numberFormatter setCurrencyCode:myCurrencyCode];
	return [numberFormatter numberFromString:self];
}

- (float)floatValueEx {
	NSError *error;
	NSString *pattern = @"([\\d\\s’',\\.]+)";
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

	NSNumberFormatter *decimalStyleFormatter = [[NSNumberFormatter alloc] init];
	[decimalStyleFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	NSString *numberString;
	NSRange range;

//#ifdef DEBUG
//	NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
//	for (NSTextCheckingResult *result in matches) {
//		FNLOG(@"%@", [self substringWithRange:result.range]);
//	}
//#endif

	float result = 0.0;

	range = [regex rangeOfFirstMatchInString:self options:NSMatchingReportProgress range:NSMakeRange(0, [self length])];
	if (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0) )) {
		numberString = [self substringWithRange:range];
		result = [[decimalStyleFormatter numberFromString:numberString] floatValue];
	}
	return result;
}

- (NSString *)stringByDecimalConversion {
	NSString *resultString;
	float value = [self floatValueEx];
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setUsesGroupingSeparator:NO];
	resultString = value == 0.0 ? @"" : [numberFormatter stringFromNumber:[NSNumber numberWithFloat:value]];

	return resultString;
}

+ (NSString *)combineString:(NSString *)string1 withString:(NSString *)string2 {
	NSString *result = string1 != nil ? string1 : @"";
	if (string2 != nil) {
		result = [NSString stringWithFormat:@"%@ %@", result, string2];
	}
	result = [result stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	return result;
}

+ (NSString *)orderStringWithOrder:(NSInteger)order {
	return [NSString stringWithFormat:@"%016ld", (long)order];
}

- (NSMutableString *)extendedSearchPatternForKoreanString {
	static NSArray *chosungArray = nil;

    // 초성테이블이 만들어져 있지 않다면 만들어준다.
    // (배열로 유니코드값 집어넣어도 되지만 직관적으로 하기위해서 NSObject로 넣어준다.)
    // 초성 (19개)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chosungArray = @[
						@"ㄱ", @"ㄲ",
						@"ㄴ",
						@"ㄷ", @"ㄸ",
						@"ㄹ",
						@"ㅁ",
						@"ㅂ", @"ㅃ",
						@"ㅅ", @"ㅆ",
						@"ㅇ",
						@"ㅈ",
						@"ㅉ",
						@"ㅊ",
						@"ㅋ",
						@"ㅌ",
						@"ㅍ",
						@"ㅎ"];
    });

	// 정규 표현식
	NSMutableString *extendedSearchPattern = [[NSMutableString alloc] init];

	// 입력된 문자열을 한자한자 분석한다.
	for (int i = 0; i < [self length]; i++) {
		unichar convertedCharacter = [self characterAtIndex:i];

		// 자음인가? (Hangul Compatibility Jamo ㄱ-3131, ㅎ-314E)
		if (convertedCharacter >= [@"ㄱ" characterAtIndex:0] && convertedCharacter <= [@"ㅎ" characterAtIndex:0]) {


			// 일단 문자열에서 한글자만 때온다.
			NSString *charterString = [self substringWithRange:NSMakeRange(i, 1)];

			// 초성 테이블에서 몇번째 인덱스에 있는지 찾는다.
			int soundInitIndex = 0;
			for (NSString *soundInitCharterString in chosungArray) {
				if ([soundInitCharterString isEqualToString:charterString]) {
					break;
				}
				soundInitIndex++;
			}

			// Hangul Compatibility Jamo에서 Hangul Syllables로 유니코드 값을 바꿔 정규 표현식을 만든다.(입력된 자음 + 'ㅏ' 부터 입력된자음 + 'ㅣ' + 'ㅎ'까지 범위를 잡는다.)
			[extendedSearchPattern appendString:[NSString stringWithFormat:@"[\\u%x-\\u%x]",
																		   [@"가" characterAtIndex:0] + soundInitIndex * (21 * 28),
																		   [@"가" characterAtIndex:0] + (soundInitIndex + 1) * (21 * 28) - 1]];

		} else if (convertedCharacter >= [@"가" characterAtIndex:0] && convertedCharacter <= [@"힣" characterAtIndex:0]) {	// 자음+모음(또는 자음+모음+자음)인가?

			convertedCharacter -= [@"가" characterAtIndex:0];

			if (convertedCharacter % 28 == 0) {	// 자음+모음

				[extendedSearchPattern appendString:[NSString stringWithFormat:@"[\\u%x-\\u%x]",
																			   convertedCharacter + [@"가" characterAtIndex:0],
																			   convertedCharacter + [@"가" characterAtIndex:0] + 28 - 1]];

			} else {							// 자음+모음+자음

				[extendedSearchPattern appendString:[NSString stringWithFormat:@"\\u%x",
																			   convertedCharacter + [@"가" characterAtIndex:0]]];
			}

		} else {
			[extendedSearchPattern appendString:[self substringWithRange:NSMakeRange(i, 1)]];
		}
	}

	FNLOG(@"%@", extendedSearchPattern);

	return extendedSearchPattern;

}

- (NSString *)componentsSeparatedByKorean {
	NSArray *chosung = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
	NSMutableString *result = [NSMutableString new];
	for (int i=0;i<[self length];i++) {
		NSInteger code = [self characterAtIndex:i];
		if (code >= 44032 && code <= 55203) {
			NSInteger uniCode = code - 44032;
			NSInteger chosungIndex = uniCode / 21 / 28;
			[result appendString:[chosung objectAtIndex:chosungIndex]];
		} else {
			[result appendString:[self substringWithRange:NSMakeRange(i, 1)]];
		}
	}
	return result;
}

- (NSString *)pathInDocumentDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
}

- (NSString *)pathInLibraryDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
}

- (NSString *)pathInCachesDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
}

- (NSString *)pathInTemporaryDirectory {
	return [NSTemporaryDirectory() stringByAppendingPathComponent:self];
}

- (NSString *)stringByTrimmingSpaceCharacters {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)pathInCachesDataDirectory {
	return [[@"data" pathInCachesDirectory] stringByAppendingPathComponent:self];
}

@end
