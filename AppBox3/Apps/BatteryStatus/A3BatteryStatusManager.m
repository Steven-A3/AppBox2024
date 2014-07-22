//
//  A3BatteryStatusManager.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatteryStatusManager.h"
#import "A3UIDevice.h"

NSString *const A3BatteryStatusThemeColorChanged = @"A3BatteryStatusThemeColorChanged";

static NSString *const A3BatteryChosenThemeIndex = @"A3BatteryChosenThemeIndex";
static NSString *const A3BatteryChosenTheme = @"A3BatteryChosenTheme";
static NSString *const A3BatteryAdjustedIndex = @"A3BatteryAdjustedIndex";
static NSString *const A3BatteryShowIndex = @"A3BatteryShowIndex";

@implementation A3BatteryStatusManager

#pragma mark -

+(void)setChosenThemeIndex:(NSInteger)chosenThemeIndex
{
    [[NSUserDefaults standardUserDefaults] setInteger:chosenThemeIndex forKey:A3BatteryChosenThemeIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setChosenTheme:(UIColor *)chosenTheme
{
    NSData* themeData = [NSKeyedArchiver archivedDataWithRootObject:chosenTheme];
    [[NSUserDefaults standardUserDefaults] setObject:themeData forKey:A3BatteryChosenTheme];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setAdjustedIndex:(NSArray *)adjustedIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:adjustedIndex forKey:A3BatteryAdjustedIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setShowIndex:(NSArray *)showIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:showIndex forKey:A3BatteryShowIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)chosenThemeIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:A3BatteryChosenThemeIndex];
}

+(UIColor *)chosenTheme {

    NSData * themeData = [[NSUserDefaults standardUserDefaults] objectForKey:A3BatteryChosenTheme];
    if (!themeData) {
        [self setChosenThemeIndex:3];
        return [UIColor colorWithRed:0.0/255.0 green:230.0/255.0 blue:76.0/255.0 alpha:1.0];
    }
    UIColor *themeColor = [NSKeyedUnarchiver unarchiveObjectWithData:themeData];
    return themeColor;
}

+(NSArray *)themeColorArray {
    return [NSArray arrayWithObjects:
     [UIColor colorWithRed:253.0/255.0 green:158.0/255.0 blue:26.0/255.0 alpha:1.0],
     [UIColor colorWithRed:250.0/255.0 green:207.0/255.0 blue:37.0/255.0 alpha:1.0],
     [UIColor colorWithRed:165.0/255.0 green:222.0/255.0 blue:55.0/255.0 alpha:1.0],
     [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:76.0/255.0 alpha:1.0],
     [UIColor colorWithRed:32.0/255.0 green:214.0/255.0 blue:120.0/255.0 alpha:1.0],
     
     [UIColor colorWithRed:64.0/255.0 green:224.0/255.0 blue:208.0/255.0 alpha:1.0],
     [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1.0],
     [UIColor colorWithRed:63.0/255.0 green:156.0/255.0 blue:250.0/255.0 alpha:1.0],
     [UIColor colorWithRed:107.0/255.0 green:105.0/255.0 blue:223.0/255.0 alpha:1.0],
     [UIColor colorWithRed:204.0/255.0 green:115.0/255.0 blue:225.0/255.0 alpha:1.0],
     
     [UIColor colorWithRed:246.0/255.0 green:104.0/255.0 blue:202.0/255.0 alpha:1.0],
     [UIColor colorWithRed:198.0/255.0 green:156.0/255.0 blue:109.0/255.0 alpha:1.0],
     nil];
}

+(NSArray *)adjustedIndex {
    return [[NSUserDefaults standardUserDefaults] objectForKey:A3BatteryAdjustedIndex];
}

+(NSArray *)showIndex {
    return [[NSUserDefaults standardUserDefaults] objectForKey:A3BatteryShowIndex];
}

#pragma mark -

+(NSArray *)deviceInfoDataArray
{
    NSMutableArray *array = [NSMutableArray new];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"device_infomation" ofType:@"json"];
    NSAssert(path, @"BatteryStatusPropertyList 파일이 존재하지 않습니다.");
    
    NSString * modelName = [A3UIDevice platformString];
    NSError * error;
    NSData * jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary *deviceInformation = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary * devicesInfo = [deviceInformation objectForKey:@"devicesInfo"];
    if (!devicesInfo) {
        FNLOG(@"존재하는 device정보가 없습니다.");
        return nil;
    }
    
    NSDictionary * currentDeviceInfo = [devicesInfo objectForKey:modelName];
    if (!currentDeviceInfo) {
        FNLOG(@"존재하는 currentDeviceInfo 정보가 없습니다.");
        return nil;
    }
    

    NSString *Chips = [currentDeviceInfo objectForKey:@"Chips"];
    NSString *CPU = [currentDeviceInfo objectForKey:@"CPU"];
    NSString *GPU = [currentDeviceInfo objectForKey:@"GPU"];
    NSString *Memory = [currentDeviceInfo objectForKey:@"Memory"];

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
    // Memory.
    if (Memory) {
        [array addObject:@{@"title" : NSLocalizedString(@"Memory", @"Memory"), @"value" : Memory}];
    }
    // Storage.
    NSString * storage = [A3UIDevice capacity];
    [array addObject:@{@"title" : NSLocalizedString(@"Capacity", @"Capacity"), @"value" : storage}];
    
    return array;
}

+(NSArray *)remainTimeDataArray
{
    NSMutableArray *array = [NSMutableArray new];
   
    NSError * error;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"device_infomation" ofType:@"json"];
    NSAssert(path, @"BatteryStatusPropertyList 파일이 존재하지 않습니다.");

    NSString * modelName = [A3UIDevice platformString];
    NSData * jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary *deviceInformation = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary * remainingTimeInfo = [deviceInformation objectForKey:@"remainingTimeInfo"];
    remainingTimeInfo = [remainingTimeInfo objectForKey:modelName];
    if (!remainingTimeInfo) {
        FNLOG(@"존재하는 device정보가 없습니다.");
        return nil;
    }

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

+(NSURL *)howToMaximizePowerUse
{
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *urlString;
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
        if ([languageCode isEqualToString:@"zh-Hans"] || [languageCode isEqualToString:@"zh-Hant"]) {
            urlString = @"http://www.apple.com/cn/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"fr"]) {
            urlString = @"http://www.apple.com/fr/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"de"]) {
            urlString = @"http://www.apple.com/de/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"it"]) {
            urlString = @"http://www.apple.com/it/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"ja"]) {
            urlString = @"http://www.apple.com/jp/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"ko"]) {
            urlString = @"http://www.apple.com/kr/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"pl"]) {
            urlString = @"http://www.apple.com/pl/batteries/ipods.html";
        } else if ([languageCode isEqualToString:@"es"]) {
            urlString = @"http://www.apple.com/es/batteries/ipods.html";
        } else {
            urlString = @"http://www.apple.com/batteries/ipods.html";
        }
        
    } else if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
        if ([languageCode isEqualToString:@"zh-Hans"] || [languageCode isEqualToString:@"zh-Hant"]) {
            urlString = @"http://www.apple.com/cn/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"fr"]) {
            urlString = @"http://www.apple.com/fr/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"de"]) {
            urlString = @"http://www.apple.com/de/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"it"]) {
            urlString = @"http://www.apple.com/it/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"ja"]) {
            urlString = @"http://www.apple.com/jp/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"ko"]) {
            urlString = @"http://www.apple.com/kr/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"pl"]) {
            urlString = @"http://www.apple.com/pl/batteries/iphone.html";
        } else if ([languageCode isEqualToString:@"es"]) {
            urlString = @"http://www.apple.com/es/batteries/ipods.html";
        } else {
            urlString = @"http://www.apple.com/batteries/iphone.html";
        }
    } else if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        if ([languageCode isEqualToString:@"zh-Hans"] || [languageCode isEqualToString:@"zh-Hant"]) {
            urlString = @"http://www.apple.com/cn/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"fr"]) {
            urlString = @"http://www.apple.com/fr/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"de"]) {
            urlString = @"http://www.apple.com/de/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"it"]) {
            urlString = @"http://www.apple.com/it/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"ja"]) {
            urlString = @"http://www.apple.com/jp/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"ko"]) {
            urlString = @"http://www.apple.com/kr/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"pl"]) {
            urlString = @"http://www.apple.com/pl/batteries/ipad.html";
        } else if ([languageCode isEqualToString:@"es"]) {
            urlString = @"http://www.apple.com/es/batteries/ipad.html";
        } else {
            urlString = @"http://www.apple.com/batteries/ipad.html";
        }
    } else {
        // simulator
        urlString = @"http://www.apple.com/batteries/ipad.html";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

+(NSURL *)moreInformationAboutBatteries
{
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *urlString;
    if ([languageCode isEqualToString:@"zh-Hans"] || [languageCode isEqualToString:@"zh-Hant"]) {
        urlString = @"http://www.apple.com/cn/batteries/";
    } else if ([languageCode isEqualToString:@"fr"]) {
        urlString = @"http://www.apple.com/fr/batteries/";
    } else if ([languageCode isEqualToString:@"de"]) {
        urlString = @"http://www.apple.com/de/batteries/";
    } else if ([languageCode isEqualToString:@"it"]) {
        urlString = @"http://www.apple.com/it/batteries/";
    } else if ([languageCode isEqualToString:@"ja"]) {
        urlString = @"http://www.apple.com/jp/batteries/";
    } else if ([languageCode isEqualToString:@"ko"]) {
        urlString = @"http://www.apple.com/kr/batteries/";
    } else if ([languageCode isEqualToString:@"pl"]) {
        urlString = @"http://www.apple.com/pl/batteries/";
    } else if ([languageCode isEqualToString:@"es"]) {
        urlString = @"http://www.apple.com/es/batteries/";
    } else {
        urlString = @"http://www.apple.com/batteries/";
    }

    return [NSURL URLWithString:urlString];
}

@end
