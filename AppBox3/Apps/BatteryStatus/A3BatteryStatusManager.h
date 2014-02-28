//
//  A3BatteryStatusManager.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const A3BatteryStatusThemeColorChanged;

@interface A3BatteryStatusManager : NSObject

//@property (nonatomic, strong) UIColor * chosenTheme;
//@property (nonatomic, strong) NSArray * adjustedIndex;
//@property (nonatomic, strong) NSArray * showIndex;
+(void)setChosenThemeIndex:(NSInteger)chosenThemeIndex;
+(void)setChosenTheme:(UIColor *)chosenTheme;
+(void)setAdjustedIndex:(NSArray *)adjustedIndex;
+(void)setShowIndex:(NSArray *)showIndex;
+(NSInteger)chosenThemeIndex;
+(UIColor *)chosenTheme;
+(NSArray *)themeColorArray;
+(NSArray *)adjustedIndex;
+(NSArray *)showIndex;

+(NSArray *)deviceInfoDataArray;
+(NSArray *)remainTimeDataArray;

+(NSURL *)howToMaximizePowerUse;
+(NSURL *)moreInformationAboutBatteries;

@end
