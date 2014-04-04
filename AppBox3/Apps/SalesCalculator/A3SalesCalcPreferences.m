//
//  A3SalesCalcPreferences.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcPreferences.h"
#import "A3SalesCalcData.h"

@implementation A3SalesCalcPreferences

-(id)init
{
    self = [super init];
    if (self) {
        self.calcData = [A3SalesCalcData new];
    }
    return self;
}

-(void)setOldCalcData:(A3SalesCalcData *)oldCalcData
{
    _oldCalcData = [A3SalesCalcData new];
    _oldCalcData.price = [oldCalcData.price copy];
    _oldCalcData.discount = [oldCalcData.discount copy];
    _oldCalcData.additionalOff = [oldCalcData.additionalOff copy];
    _oldCalcData.tax = [oldCalcData.tax copy];
    _oldCalcData.notes = [oldCalcData.notes copy];
    _oldCalcData.shownPriceType = oldCalcData.shownPriceType;
}

-(BOOL)didSaveBefore
{
    if (self.oldCalcData==nil) {
        return NO;
    }
    
    if (![self.calcData.tax isKindOfClass:[NSNumber class]] ||
        ![self.calcData.additionalOff isKindOfClass:[NSNumber class]] ||
        ![self.calcData.price isKindOfClass:[NSNumber class]] ||
        ![self.calcData.discount isKindOfClass:[NSNumber class]]
        ) {
        FNLOG(@"Nil data detected.");
    }
    
    if (self.oldCalcData.price && [self.calcData.price isEqualToNumber:self.oldCalcData.price] &&
		self.oldCalcData.discount && [self.calcData.discount isEqualToNumber:self.oldCalcData.discount] &&
		self.oldCalcData.additionalOff && [self.calcData.additionalOff isEqualToNumber:self.oldCalcData.additionalOff] &&
        self.oldCalcData.tax && [self.calcData.tax isEqualToNumber:self.oldCalcData.tax] &&
		self.oldCalcData.notes && [self.calcData.notes isEqualToString:self.oldCalcData.notes] &&
        self.calcData.shownPriceType == self.oldCalcData.shownPriceType)
        return YES;
    
    return NO;
}
@end
