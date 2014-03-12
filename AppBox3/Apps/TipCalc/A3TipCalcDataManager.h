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

typedef enum{
    TipCalcRoundingTargetTip = 0,
    TipCalcRoundingTargetTotal,
    TipCalcRoundingTargetTotalPerPerson,
    TipCalcRoundingTargetTipPerPerson
} TipCalcRoundingTarget;

typedef NS_ENUM (NSInteger, TCTipSplitOption) {
	TCTipSplitOption_BeforeSplit = 0,
    TCTipSplitOption_PerPerson
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

#import "TipCalcRecently.h"
#import "TipCalcHistory.h"
#import <CoreLocation/CoreLocation.h>

@interface A3TipCalcDataManager : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager* _lm;
}


+ (A3TipCalcDataManager*)sharedInstance;
+ (void)terminate;

@property (nonatomic, weak) id<A3TipCalcDataManagerDelegate> delegate;

- (TipCalcRecently*)tipCalcData;
- (NSArray*)tipCalcHistory;

@property (nonatomic, strong) NSNumber * defaultTax;
- (void)getUSTaxRateByLocation;

- (NSString*)currencyStringFromNum:(double)aNum;
- (double)numFromCurrencyString:(NSString*)aCurreny;
- (NSString*)stringNumFromCurrencyString:(NSString*)aCurreny;


- (void)addHistory:(NSString*)aCaptionTip total:(NSString*)aCaptionTotal;
- (void)historyToRecently:(TipCalcHistory*)aHistory;

- (NSString *)currencyFormattedStringForCurrency:(NSString *)code value:(NSNumber *)value;
- (NSString*)currencySymbolFromCode:(NSString*)aCode;

- (double)costsAfterTax;
- (double)costsBeforeTax;
- (double)taxRst;
- (double)tipRst:(int)aBeforeSplitFlag;
- (double)totalRst:(int)aBeforeSplitFlag;

- (NSString*)sharedData;

#pragma mark - calculate
- (NSNumber *)numberByRoundingMethodForValue:(NSNumber *)aValue;

#pragma mark - Getter
- (BOOL)hasCalcData;

#pragma mark - Setting
@property (nonatomic, assign, getter = isTaxOptionOn) BOOL taxOption;
@property (nonatomic, assign, getter = isSplitOptionOn) BOOL splitOption;
@property (nonatomic, assign, getter = isRoundingOptionOn) BOOL RoundingOption;

#pragma mark Manipulate TipCalc Data
- (void)setTipCalcDataForMainTableView;
- (void)setTipCalcDataForHistoryData:(TipCalcHistory *)aHistory;

#pragma mark Split Option
- (void)setTipSplitOption:(TCTipSplitOption)option;
- (TCTipSplitOption)tipSplitOption;

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
- (NSNumber *)totalBeforeSplit;
- (NSNumber *)totalPerPerson;
- (NSNumber *)taxPercent;
- (NSNumber *)taxValue;
- (NSNumber *)taxValueWithSplit;
- (NSNumber *)tipValue;
- (NSNumber *)tipPercent;
- (NSNumber *)tipValueWithSplit;

#pragma mark - Rounding Method
- (void)setRoundingMethodValue:(TCRoundingMethodValue)value;
- (TCRoundingMethodValue)roundingMethodValue;
- (void)setRoundingMethodOption:(TCRoundingMethodOption)option;
- (TCRoundingMethodOption)roundingMethodOption;

@end


