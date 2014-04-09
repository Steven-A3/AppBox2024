//
//  A3SalesCalcData.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcData.h"
#import "SalesCalcHistory.h"
#import "A3SalesCalcPreferences.h"

@implementation A3SalesCalcData

-(id)init{
    self = [super init];
    if (self) {
        self.price = @0;
        self.discount = @0;
        self.additionalOff = @0;
        self.tax = @0;
        self.notes = @"";
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _historyDate = [aDecoder decodeObjectForKey:@"historyDate"];
        _shownPriceType = [aDecoder decodeIntegerForKey:@"shownPriceType"];
        _price = [aDecoder decodeObjectForKey:@"price"];
        _priceType = [aDecoder decodeIntegerForKey:@"priceType"];
        _discount = [aDecoder decodeObjectForKey:@"discount"];
        _discountType = [aDecoder decodeIntegerForKey:@"_discountType"];
        _additionalOff = [aDecoder decodeObjectForKey:@"additionalOff"];
        _additionalOffType = [aDecoder decodeIntegerForKey:@"additionalOffType"];
        _tax = [aDecoder decodeObjectForKey:@"tax"];
        _taxType = [aDecoder decodeIntegerForKey:@"taxType"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_historyDate forKey:@"historyDate"];
    [aCoder encodeInteger:_shownPriceType forKey:@"shownPriceType"];
    [aCoder encodeObject:_price forKey:@"price"];
    [aCoder encodeInteger:_priceType forKey:@"priceType"];
    [aCoder encodeObject:_discount forKey:@"discount"];
    [aCoder encodeInteger:_discountType forKey:@"_discountType"];
    [aCoder encodeObject:_additionalOff forKey:@"additionalOff"];
    [aCoder encodeInteger:_additionalOffType forKey:@"additionalOffType"];
    [aCoder encodeObject:_tax forKey:@"tax"];
    [aCoder encodeInteger:_taxType forKey:@"taxType"];
    [aCoder encodeObject:_notes forKey:@"notes"];
}

-(BOOL)saveData {

    if (self.price == nil ||
        self.discount == nil ) {
        return NO;
    }
    
    if ([self.price isEqualToNumber:@0] ||
        [self.discount isEqualToNumber:@0]) {
        return NO;
    }
    
    
    SalesCalcHistory *entity = [SalesCalcHistory MR_createEntity];
    entity.historyDate = [NSDate date];
    entity.price = self.price;
    entity.priceType = @(self.priceType);
    entity.discount = self.discount;
    entity.discountType = @(self.discountType);
    entity.additionalOff = self.additionalOff;
    entity.additionalOffType = @(self.additionalOffType);
    entity.tax = self.tax;
    entity.taxType = @(self.taxType);
    entity.notes = self.notes;
    entity.shownPriceType = @(self.shownPriceType);

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

-(BOOL)saveDataForcingly {
    
    if ([self.price isEqualToNumber:@0] ||
        [self.discount isEqualToNumber:@0]) {
        return NO;
    }
    
    if (self.historyDate != nil) {
        NSArray *oldDate = [NSArray arrayWithObjects:self.historyDate, nil];
        NSArray *oldHistory = [SalesCalcHistory MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"historyDate IN %@", oldDate]];
        if (oldHistory.count!=0) {
            FNLOG(@"존재하는 히스토리입니다.");
            return NO;
        }
    }
    
    SalesCalcHistory *entity = [SalesCalcHistory MR_createEntity];
    entity.historyDate = [NSDate date];
    entity.price = self.price;
    entity.priceType = @(self.priceType);
    entity.discount = self.discount;
    entity.discountType = @(self.discountType);
    entity.additionalOff = self.additionalOff;
    entity.additionalOffType = @(self.additionalOffType);
    entity.tax = self.tax;
    entity.taxType = @(self.taxType);
    entity.notes = self.notes;
    entity.shownPriceType = @(self.shownPriceType);

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

+(A3SalesCalcData *)loadDataFromHistory:(SalesCalcHistory *)history
{
    A3SalesCalcData *data = [A3SalesCalcData new];
    data.historyDate = history.historyDate;
    data.price = history.price;
    data.priceType = history.priceType.integerValue;
    data.discount = history.discount;
    data.discountType = history.discountType.integerValue;
    data.additionalOff = history.additionalOff;
    data.additionalOffType = history.additionalOffType.integerValue;
    data.tax = history.tax;
    data.taxType = history.taxType.integerValue;
    data.notes = history.notes;
    data.shownPriceType = history.shownPriceType.unsignedIntegerValue;

    return data;
}

@end
