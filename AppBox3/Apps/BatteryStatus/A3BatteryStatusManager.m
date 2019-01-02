//
//  A3BatteryStatusManager.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatteryStatusManager.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"

NSString *const A3BatteryStatusThemeColorChanged = @"A3BatteryStatusThemeColorChanged";

@implementation A3BatteryStatusManager

#pragma mark -

+(void)setChosenThemeIndex:(NSInteger)chosenThemeIndex
{
    [[A3UserDefaults standardUserDefaults] setInteger:chosenThemeIndex forKey:A3BatteryChosenThemeIndex];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

+(void)setChosenTheme:(UIColor *)chosenTheme
{
    NSData* themeData = [NSKeyedArchiver archivedDataWithRootObject:chosenTheme];
    [[A3UserDefaults standardUserDefaults] setObject:themeData forKey:A3BatteryChosenTheme];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

+(void)setAdjustedIndex:(NSArray *)adjustedIndex
{
    [[A3UserDefaults standardUserDefaults] setObject:adjustedIndex forKey:A3BatteryAdjustedIndex];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

+(void)setShowIndex:(NSArray *)showIndex
{
    [[A3UserDefaults standardUserDefaults] setObject:showIndex forKey:A3BatteryShowIndex];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)chosenThemeIndex
{
    return [[A3UserDefaults standardUserDefaults] integerForKey:A3BatteryChosenThemeIndex];
}

+(UIColor *)chosenTheme {

    NSData * themeData = [[A3UserDefaults standardUserDefaults] objectForKey:A3BatteryChosenTheme];
    if (!themeData) {
        [self setChosenThemeIndex:3];
        return [UIColor colorWithRed:0.0/255.0 green:230.0/255.0 blue:76.0/255.0 alpha:1.0];
    }
    UIColor *themeColor = [NSKeyedUnarchiver unarchiveObjectWithData:themeData];
    return themeColor;
}

+(NSArray *)themeColorArray {
    return @[[UIColor colorWithRed:253.0 / 255.0 green:158.0 / 255.0 blue:26.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:250.0 / 255.0 green:207.0 / 255.0 blue:37.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:165.0 / 255.0 green:222.0 / 255.0 blue:55.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:76.0 / 255.0 green:217.0 / 255.0 blue:76.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:32.0 / 255.0 green:214.0 / 255.0 blue:120.0 / 255.0 alpha:1.0],

			[UIColor colorWithRed:64.0 / 255.0 green:224.0 / 255.0 blue:208.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:90.0 / 255.0 green:200.0 / 255.0 blue:250.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:63.0 / 255.0 green:156.0 / 255.0 blue:250.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:107.0 / 255.0 green:105.0 / 255.0 blue:223.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:204.0 / 255.0 green:115.0 / 255.0 blue:225.0 / 255.0 alpha:1.0],

			[UIColor colorWithRed:246.0 / 255.0 green:104.0 / 255.0 blue:202.0 / 255.0 alpha:1.0],
			[UIColor colorWithRed:198.0 / 255.0 green:156.0 / 255.0 blue:109.0 / 255.0 alpha:1.0]];
}

+(NSArray *)adjustedIndex {
    return [[A3UserDefaults standardUserDefaults] objectForKey:A3BatteryAdjustedIndex];
}

+(NSArray *)showIndex {
    return [[A3UserDefaults standardUserDefaults] objectForKey:A3BatteryShowIndex];
}

#pragma mark -

+(NSArray *)deviceInfoDataArray
{
    NSDictionary * currentDeviceInfo = [A3UIDevice deviceInformationDictionary];
    if (!currentDeviceInfo) {
        FNLOG(@"존재하는 currentDeviceInfo 정보가 없습니다.");
        return nil;
    }

	NSString *modelName = NSLocalizedString(currentDeviceInfo[@"Model"], nil);
    NSString *Chips = currentDeviceInfo[@"Chips"];
    NSString *CPU = currentDeviceInfo[@"CPU"];
    NSString *GPU = currentDeviceInfo[@"GPU"];
    NSString *Memory = currentDeviceInfo[@"Memory"];

	NSMutableArray *array = [NSMutableArray new];

    // Device.
    [array addObject:@{@"title" : NSLocalizedString(@"Device", @"Device"), @"value" : modelName}];
    // Version.
    [array addObject:@{@"title" : NSLocalizedString(@"Version", @"Version"), @"value" : [NSString stringWithFormat:@"%@ %@",
                                                          [[UIDevice currentDevice] systemName],
                                                          [[UIDevice currentDevice] systemVersion]]}];
    // Chips.
    if (Chips) {
        [array addObject:@{@"title" : NSLocalizedString(@"Chips", @"Chips"), @"value" : Chips}];
    }
    // CPU.
    if (CPU) {
        [array addObject:@{@"title" : NSLocalizedString(@"CPU", @"CPU"), @"value" : CPU}];
    }
    // GPU.
    if (GPU) {
        [array addObject:@{@"title" : NSLocalizedString(@"GPU", @"GPU"), @"value" : GPU}];
    }
    // Storage.
    NSString * storage = [A3UIDevice capacity];
    [array addObject:@{@"title" : NSLocalizedString(@"Storage", @"Storage"), @"value" : storage}];
    
    if ([storage isEqualToString:@"1TB"] && [[modelName substringToIndex:3] isEqualToString:@"iPad"]) {
        Memory = @"6 GB 1600MHz LPDDR4 DRAM";
    }
    // Memory.
    if (Memory) {
        [array addObject:@{@"title" : NSLocalizedString(@"Memory", @"Memory"), @"value" : Memory}];
    }
    return array;
}

+(NSArray *)remainTimeDataArray
{
    NSMutableArray *array = [NSMutableArray new];
   
	NSDictionary *remainingTimeInfo = [A3UIDevice remainingTimeDictionary];

    NSArray * columns = @[
			@"Talk Time on 2G",
			@"Talk Time on 3G",
			@"Internet on 3G",
			@"Internet on LTE",
			@"Internet on Wi-Fi",
			@"Internet on Cellular",
			@"Video playback",
			@"Audio playback",
			@"Standby",
			@"FaceTime",
			@"GPS",
			@"Charging time",
			@"2D Game",
			@"3D Game",
			@"YouTube"];

    for (NSString * aColumn in columns) {
        NSNumber * value = [remainingTimeInfo objectForKey:aColumn];
        if (value) {
            [array addObject:@{@"title" : aColumn, @"value" : value.stringValue}];
        }
    }
    
    return array;
}

+ (NSURL *)howToMaximizePowerUse
{
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *urlString;
    
    if ([[[UIDevice currentDevice] model] hasPrefix:@"iPod touch"]) {
        if ([languageCode hasPrefix:@"zh-Hans"] || [languageCode hasPrefix:@"zh-Hant"]) {
            urlString = @"https://www.apple.com/cn/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"fr"]) {
            urlString = @"https://www.apple.com/fr/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"de"]) {
            urlString = @"https://www.apple.com/de/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"it"]) {
            urlString = @"https://www.apple.com/it/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"ja"]) {
            urlString = @"https://www.apple.com/jp/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"ko"]) {
            urlString = @"https://www.apple.com/kr/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"pl"]) {
            urlString = @"https://www.apple.com/pl/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"es"]) {
            urlString = @"https://www.apple.com/es/batteries/iphone.html";
        } else {
            urlString = @"https://www.apple.com/batteries/maximizing-performance/";
        }
        
    } else if ([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]) {
        if ([languageCode hasPrefix:@"zh-Hans"] || [languageCode hasPrefix:@"zh-Hant"]) {
            urlString = @"https://www.apple.com/cn/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"fr"]) {
            urlString = @"https://www.apple.com/fr/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"de"]) {
            urlString = @"https://www.apple.com/de/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"it"]) {
            urlString = @"https://www.apple.com/it/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"ja"]) {
            urlString = @"https://www.apple.com/jp/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"ko"]) {
            urlString = @"https://www.apple.com/kr/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"pl"]) {
            urlString = @"https://www.apple.com/pl/batteries/iphone.html";
        } else if ([languageCode hasPrefix:@"es"]) {
            urlString = @"https://www.apple.com/es/batteries/ipods.html";
        } else {
            urlString = @"https://www.apple.com/batteries/maximizing-performance/";
        }
    } else if ([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]) {
        if ([languageCode hasPrefix:@"zh-Hans"] || [languageCode hasPrefix:@"zh-Hant"]) {
            urlString = @"https://www.apple.com/cn/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"fr"]) {
            urlString = @"https://www.apple.com/fr/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"de"]) {
            urlString = @"https://www.apple.com/de/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"it"]) {
            urlString = @"https://www.apple.com/it/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"ja"]) {
            urlString = @"https://www.apple.com/jp/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"ko"]) {
            urlString = @"https://www.apple.com/kr/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"pl"]) {
            urlString = @"https://www.apple.com/pl/batteries/ipad.html";
        } else if ([languageCode hasPrefix:@"es"]) {
            urlString = @"https://www.apple.com/es/batteries/ipad.html";
        } else {
            urlString = @"https://www.apple.com/batteries/maximizing-performance/";
        }
    } else {
        // simulator
        urlString = @"https://www.apple.com/batteries/maximizing-performance/";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

+ (NSURL *)moreInformationAboutBatteries
{
    NSString *languageCode = [NSLocale preferredLanguages][0];
    NSString *urlString;
    if ([languageCode hasPrefix:@"zh-Hans"] || [languageCode hasPrefix:@"zh-Hant"]) {
        urlString = @"https://www.apple.com/cn/batteries/";
    } else if ([languageCode hasPrefix:@"fr"]) {
        urlString = @"https://www.apple.com/fr/batteries/";
    } else if ([languageCode hasPrefix:@"de"]) {
        urlString = @"https://www.apple.com/de/batteries/";
    } else if ([languageCode hasPrefix:@"it"]) {
        urlString = @"https://www.apple.com/it/batteries/";
    } else if ([languageCode hasPrefix:@"ja"]) {
        urlString = @"https://www.apple.com/jp/batteries/";
    } else if ([languageCode hasPrefix:@"ko"]) {
        urlString = @"https://www.apple.com/kr/batteries/";
    } else if ([languageCode hasPrefix:@"pl"]) {
        urlString = @"https://www.apple.com/pl/batteries/";
    } else if ([languageCode hasPrefix:@"es"]) {
        urlString = @"https://www.apple.com/es/batteries/";
    } else {
        urlString = @"https://www.apple.com/batteries/";
    }

    return [NSURL URLWithString:urlString];
}

@end
