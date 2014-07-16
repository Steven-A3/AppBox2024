//
//  A3TipCalcDataManager.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3TipCalcDataManagerDelegate <NSObject>
- (void)dataManager:(id)manager taxValueUpdated:(NSNumber *)taxRate;
@end

typedef enum{
    TipCalcRoundingFlagExact = 0,   // 출력시에만 내림
    TipCalcRoundingFlagUp,          // 올림
    TipCalcRoundingFlagDown,        // 내림
    TipCalcRoundingFlagOff          // 반올림
}TipCalcRoundingFlag;

typedef NS_ENUM (NSInteger, TipSplitOption) {
	TipSplitOption_BeforeSplit = 0,
    TipSplitOption_PerPerson
};

typedef NS_ENUM (NSInteger, TCKnownValue) {
	TCKnownValue_Subtotal = 0,
    TCKnownValue_CostsBeforeTax
};

typedef NS_ENUM (NSInteger, TCRoundingMethodValue) {
	TCRoundingMethodValue_Tip = 0,
    TCRoundingMethodValue_Total,
    TCRoundingMethodValue_TotalPerPerson,
    TCRoundingMethodValue_TipPerPerson
};

typedef NS_ENUM (NSInteger, TCRoundingMethodOption) {
	TCRoundingMethodOption_Exact = 0,
    TCRoundingMethodOption_Up,
    TCRoundingMethodOption_Down,
    TCRoundingMethodOption_Off
};

#import "TipCalcRecent.h"
#import "TipCalcHistory.h"
#import <CoreLocation/CoreLocation.h>

extern NSString *const A3TipCalcCurrencyCode;

@interface A3TipCalcDataManager : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
}

@property (nonatomic, weak) id<A3TipCalcDataManagerDelegate> delegate;

- (TipCalcRecent *)tipCalcData;
- (NSArray*)tipCalcHistory;

@property (nonatomic, strong) NSNumber * defaultTax;
- (void)getUSTaxRateByLocation;

- (NSString *)currencyCode;

- (NSString*)currencyStringFromDouble:(double)value;


- (void)addHistory:(NSString*)aCaptionTip total:(NSString*)aCaptionTotal;
- (void)historyToRecently:(TipCalcHistory*)aHistory;

- (NSString*)sharedDataIsMail:(BOOL)isMail;

#pragma mark - calculate
- (NSNumber *)numberByRoundingMethodForValue:(NSNumber *)aValue;

#pragma mark - Getter
- (BOOL)hasCalcData;

#pragma mark - Setting
@property (nonatomic, assign, getter = isTaxOptionOn) BOOL taxOption;
@property (nonatomic, assign, getter = isSplitOptionOn) BOOL splitOption;
@property (nonatomic, assign, getter = isRoundingOptionOn) BOOL RoundingOption;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

#pragma mark Manipulate TipCalc Data
- (void)setTipCalcDataForMainTableView;
- (void)setTipCalcDataForHistoryData:(TipCalcHistory *)aHistory;

#pragma mark Split Option
- (void)setTipSplitOption:(TipSplitOption)option;
- (TipSplitOption)tipSplitOption;

#pragma mark KnownValue
- (void)setKnownValue:(TCKnownValue)value;
- (TCKnownValue)knownValue;

#pragma mark Set Tip Calc Data
- (void)setTipCalcDataCost:(NSNumber *)cost;
- (void)setTipCalcDataTax:(NSNumber *)tax isPercentType:(BOOL)isPercent;
- (void)setTipCalcDataTip:(NSNumber *)tax isPercentType:(BOOL)isPercent;
- (void)setTipCalcDataSplit:(NSNumber *)split;
#pragma mark Save Data
- (void)saveTipCalcData;
- (void)saveToHistory;


#pragma mark - Result Calculation
- (NSNumber *)costBeforeTax;
- (NSNumber *)costBeforeTaxWithSplit;
- (NSNumber *)subtotal;
- (NSNumber *)subtotalWithSplit;
- (NSNumber *)totalBeforeSplitWithTax;
- (NSNumber *)totalPerPersonWithTax;
- (NSNumber *)taxPercent;
- (NSNumber *)taxValue;
- (NSNumber *)taxValueWithSplit;
- (NSNumber *)tipValueWithRounding:(BOOL)rounding;
- (NSNumber *)tipValueWithSplitWithRounding:(BOOL)rounding;
- (NSNumber *)tipPercent;

#pragma mark - Rounding Method
- (void)setRoundingMethodValue:(TCRoundingMethodValue)value;
- (TCRoundingMethodValue)roundingMethodValue;
- (void)setRoundingMethodOption:(TCRoundingMethodOption)option;
- (TCRoundingMethodOption)roundingMethodOption;

@end


