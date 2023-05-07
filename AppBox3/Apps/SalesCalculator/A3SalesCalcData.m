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
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"

static NSString *const A3SalesCalcDataKeyHistoryDate = @"updateDate";
static NSString *const A3SalesCalcDataKeyShownPriceType = @"shownPriceType";
static NSString *const A3SalesCalcDataKeyPrice = @"price";
static NSString *const A3SalesCalcDataKeyPriceType = @"priceType";
static NSString *const A3SalesCalcDataKeyDiscount = @"discount";
static NSString *const A3SalesCalcDataKeyDiscountType = @"discountType";
static NSString *const A3SalesCalcDataKeyAdditionalOff = @"additionalOff";
static NSString *const A3SalesCalcDataKeyAdditionalOffType = @"additionalOffType";
static NSString *const A3SalesCalcDataKeyTax = @"tax";
static NSString *const A3SalesCalcDataKeyTaxType = @"taxType";
static NSString *const A3SalesCalcDataKeyNotes = @"notes";
static NSString *const A3SalesCalcDataKeyCurrencyCode = @"currencyCode";

@implementation A3SalesCalcData

- (id)init{
    self = [super init];
    if (self) {
        self.price = @0;
        self.discount = @0;
        self.discountType = A3TableViewValueTypePercent;
        self.additionalOff = @0;
        self.additionalOffType = A3TableViewValueTypePercent;
        self.tax = @0;
        self.taxType = A3TableViewValueTypePercent;
        self.notes = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _historyDate = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyHistoryDate];
        _shownPriceType = (A3SalesCalcShowPriceType) [aDecoder decodeIntegerForKey:A3SalesCalcDataKeyShownPriceType];
        _price = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyPrice];
        _priceType = (A3TableElementValueType) [aDecoder decodeIntegerForKey:A3SalesCalcDataKeyPriceType];
        _discount = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyDiscount];
        _discountType = (A3TableElementValueType) [aDecoder decodeIntegerForKey:A3SalesCalcDataKeyDiscountType];
        _additionalOff = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyAdditionalOff];
        _additionalOffType = (A3TableElementValueType) [aDecoder decodeIntegerForKey:A3SalesCalcDataKeyAdditionalOffType];
        _tax = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyTax];
        _taxType = (A3TableElementValueType) [aDecoder decodeIntegerForKey:A3SalesCalcDataKeyTaxType];
        _notes = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyNotes];
        _currencyCode = [aDecoder decodeObjectForKey:A3SalesCalcDataKeyCurrencyCode];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_historyDate forKey:A3SalesCalcDataKeyHistoryDate];
    [aCoder encodeInteger:_shownPriceType forKey:A3SalesCalcDataKeyShownPriceType];
    [aCoder encodeObject:_price forKey:A3SalesCalcDataKeyPrice];
    [aCoder encodeInteger:_priceType forKey:A3SalesCalcDataKeyPriceType];
    [aCoder encodeObject:_discount forKey:A3SalesCalcDataKeyDiscount];
    [aCoder encodeInteger:_discountType forKey:A3SalesCalcDataKeyDiscountType];
    [aCoder encodeObject:_additionalOff forKey:A3SalesCalcDataKeyAdditionalOff];
    [aCoder encodeInteger:_additionalOffType forKey:A3SalesCalcDataKeyAdditionalOffType];
    [aCoder encodeObject:_tax forKey:A3SalesCalcDataKeyTax];
    [aCoder encodeInteger:_taxType forKey:A3SalesCalcDataKeyTaxType];
    [aCoder encodeObject:_notes forKey:A3SalesCalcDataKeyNotes];
    [aCoder encodeObject:_currencyCode forKey:A3SalesCalcDataKeyCurrencyCode];
}

- (BOOL)saveDataToHistoryWithCurrencyCode:(NSString *)currencyCode {

    if (self.price == nil ||
        self.discount == nil ) {
        return NO;
    }
    
    if ([self.price isEqualToNumber:@0] ||
        [self.discount isEqualToNumber:@0]) {
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
			@"price == %@ AND \
			priceType == %@ AND \
			discount == %@ AND \
			discountType == %@ AND \
			additionalOff == %@ AND \
            additionalOffType == %@ AND \
			tax == %@ AND \
    		taxType == %@ AND \
			notes == %@ AND \
			shownPriceType == %@ AND \
			currencyCode == %@",
			self.price, @(self.priceType), self.discount, @(self.discountType), self.additionalOff, @(self.additionalOffType),
			self.tax, @(self.taxType), self.notes, @(self.shownPriceType), self.currencyCode];

	SalesCalcHistory *sameData = [SalesCalcHistory findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    if (sameData) {
        return NO;
    } else {
        SalesCalcHistory *entity = [[SalesCalcHistory alloc] initWithContext:context];
        entity.uniqueID = [[NSUUID UUID] UUIDString];
        entity.updateDate = [NSDate date];
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
        entity.currencyCode = currencyCode;
    }

    [context saveContext];
    
    return YES;
}

+ (A3SalesCalcData *)loadDataFromHistory:(SalesCalcHistory *)history
{
    A3SalesCalcData *data = [A3SalesCalcData new];
    data.historyDate = history.updateDate;
    data.price = history.price;
    data.priceType = (A3TableElementValueType) history.priceType.integerValue;
    data.discount = history.discount;
    data.discountType = (A3TableElementValueType) history.discountType.integerValue;
    data.additionalOff = history.additionalOff;
    data.additionalOffType = (A3TableElementValueType) history.additionalOffType.integerValue;
    data.tax = history.tax;
    data.taxType = (A3TableElementValueType) history.taxType.integerValue;
    data.notes = history.notes;
    data.shownPriceType = (A3SalesCalcShowPriceType) history.shownPriceType.unsignedIntegerValue;
    data.currencyCode = history.currencyCode;

    return data;
}

@end
