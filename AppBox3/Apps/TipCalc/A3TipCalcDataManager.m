//
//  A3TipCalcDataManager.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

NSString *const A3TipCalcCurrencyCode = @"A3TipCalcCurrencyCode";

#import "A3TipCalcDataManager.h"
#import "TipCalcRoundMethod.h"

@implementation A3TipCalcDataManager
{
    TipCalcRecently* _tipCalcData;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [self tipCalcData];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (TipCalcRecently *)tipCalcData
{
    if (!_tipCalcData) {
        [self setTipCalcDataForMainTableView];
        return _tipCalcData;
    }
    
    return _tipCalcData;
}

- (NSArray*)tipCalcHistory
{
    NSArray* arrRecent = [TipCalcHistory MR_findAllSortedBy:@"dateTime" ascending:NO];
    
    return arrRecent;
}


#pragma mark - 

- (NSString*)currencyStringFromDouble:(double)value
{
	return [self.currencyFormatter stringFromNumber:@(value)];
}

- (void)deepCopyRecently:(TipCalcRecently *)source dest:(TipCalcRecently*)destination
{
    destination.beforeSplit = source.beforeSplit;
    destination.costs = source.costs;
    destination.currencyCode = source.currencyCode;
    destination.isPercentTax = source.isPercentTax;
    destination.isPercentTip = source.isPercentTip;
    destination.knownValue = source.knownValue;
    destination.showRounding = source.showRounding;
    destination.showSplit = source.showSplit;
    destination.showTax = source.showTax;
    destination.split = source.split;
    destination.tax = source.tax;
    destination.tip = source.tip;
    destination.rRoundMethod.optionType = source.rRoundMethod.optionType;
    destination.rRoundMethod.valueType = source.rRoundMethod.valueType;
}

- (void)addHistory:(NSString*)aCaptionTip total:(NSString*)aCaptionTotal
{
    TipCalcHistory* history = [TipCalcHistory MR_createEntity];
    history.dateTime = [NSDate date];
    history.labelTip = aCaptionTip;
    history.labelTotal = aCaptionTotal;
    history.rRecently = [TipCalcRecently MR_createEntity];

	[self deepCopyRecently:self.tipCalcData dest:history.rRecently];
}

- (void)historyToRecently:(TipCalcHistory*)aHistory
{
	[self deepCopyRecently:aHistory.rRecently dest:self.tipCalcData];
}


#pragma mark - calculate

- (NSNumber *)numberByRoundingMethodForValue:(NSNumber *)aValue {
    NSNumber *result;
    
    double temp;
    switch (self.roundingMethodOption) {
        case TCRoundingMethodOption_Exact:
            result = aValue;
            break;
        case TCRoundingMethodOption_Up:
            temp = ceil([aValue doubleValue]);
            result = @(temp);
            break;
        case TCRoundingMethodOption_Down:
            temp = [aValue doubleValue];
            temp = floor(temp);
            result = @(temp);
            break;
        case TCRoundingMethodOption_Off:
            temp = round([aValue doubleValue] * 100.0) / 100.0;
            temp = round(temp);
            result = @(temp);
            break;
            
        default:
            break;
    }
    
    return result;
}

- (double)roundingValue:(double)aSrc rdMethod:(TipCalcRoundingFlag)aMethod
{
    switch (aMethod) {
        case TipCalcRoundingFlagUp:
            aSrc = ceil(aSrc * 100.0)/100.0;
            break;
        case TipCalcRoundingFlagDown:
            aSrc = floor(aSrc * 100.0)/100.0;
            break;
        case TipCalcRoundingFlagOff:
            aSrc = round(aSrc * 100.0)/100.0;
        default:
            break;
    }
    
    return aSrc;
}

- (NSString*)sharedDataIsMail:(BOOL)isMail
{
    NSMutableString* mstrOutput = [[NSMutableString alloc] init];
    
    if (isMail) {
		[mstrOutput appendString:NSLocalizedString(@"Calculation", @"Calculation")];
		[mstrOutput appendString:@"<br>"];
    }

	[mstrOutput appendString:NSLocalizedString(@"Total", nil)];
	[mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self totalBeforeSplitWithTax] doubleValue]] ];
	[mstrOutput appendString:NSLocalizedString(@"Tip", nil)];
	[mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self tipValueWithRounding:self.roundingMethodValue == TCRoundingMethodValue_Tip ? YES : NO] doubleValue]]];
    if ([self isSplitOptionOn] && [self.tipCalcData.split integerValue] > 1) {
		[mstrOutput appendString:NSLocalizedString(@"Total Per Person", @"Total Per Person")];
		[mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self totalPerPersonWithTax] doubleValue]]];
		[mstrOutput appendString:NSLocalizedString(@"Tip Per Person", @"Tip Per Person")];
		[mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self tipValueWithSplitWithRounding:self.roundingMethodValue == TCRoundingMethodValue_Tip ? YES : NO] doubleValue]]];
    }
    
    if (!isMail) {
        return mstrOutput;
    }

	[mstrOutput appendString:@"<br>"];
	[mstrOutput appendString:NSLocalizedString(@"Input", @"Input")];
	[mstrOutput appendString:@"<br>"];

    if (![self isTaxOptionOn]) {
		[mstrOutput appendString:NSLocalizedString(@"Costs", @"Costs")];
        [mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[self.tipCalcData.costs doubleValue]]];
    }
    else {
        if([self.tipCalcData.knownValue intValue] == TCKnownValue_Subtotal) {
			[mstrOutput appendString:NSLocalizedString(@"Costs After Tax", @"Costs After Tax")];
            [mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[self.tipCalcData.costs doubleValue]]];
        }
        else {
			[mstrOutput appendString:NSLocalizedString(@"Costs Before Tax", @"Costs Before Tax")];
            [mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[self.tipCalcData.costs doubleValue]]];
        }
    }
    
    if ([self isTaxOptionOn]) {
        if ([self.tipCalcData.isPercentTax boolValue]) {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            formatter.numberStyle = NSNumberFormatterPercentStyle;
            formatter.maximumFractionDigits = 3;
			[mstrOutput appendString:NSLocalizedString(@"Tax", @"Tax")];
            [mstrOutput appendFormat:@" : %@<br>", [formatter stringFromNumber:@([self.tipCalcData.tax doubleValue] / 100.0)]];
        }
        else {
			[mstrOutput appendString:NSLocalizedString(@"Tax", @"Tax")];
            [mstrOutput appendFormat:@" : %@<br>", [self.currencyFormatter stringFromNumber:self.tipCalcData.tax]];
        }
    }
    
    if ([self.tipCalcData.isPercentTip boolValue]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterPercentStyle;
        formatter.maximumFractionDigits = 3;
		[mstrOutput appendString:NSLocalizedString(@"Tip", @"Tip")];
        [mstrOutput appendFormat:@" : %@<br>", [formatter stringFromNumber:@([self.tipCalcData.tip doubleValue] / 100.0)]];
    }
    else {
		[mstrOutput appendString:NSLocalizedString(@"Tip", @"Tip")];
        [mstrOutput appendFormat:@" : %@<br>", [self.currencyFormatter stringFromNumber:self.tipCalcData.tip]];
    }
    
    if ([self isSplitOptionOn] && [self.tipCalcData.split integerValue] > 1) {
		[mstrOutput appendString:NSLocalizedString(@"Split", @"Split")];
        [mstrOutput appendFormat:@" : %@<br>", self.tipCalcData.split];
    }
    
    return mstrOutput;
}

#pragma mark - Getter
- (BOOL)hasCalcData {
    if ([self.tipCalcData.costs compare:@0] == NSOrderedDescending &&
        [self.tipCalcData.tip compare:@0] == NSOrderedDescending) {
        return YES;
    }

    return NO;
}

#pragma mark - Setting

- (void)setTaxOption:(BOOL)taxOption {
	self.tipCalcData.showTax = @(taxOption);
	self.tipCalcData.knownValue = taxOption ? [self.tipCalcData knownValue] : @(0);
}

-(BOOL)isTaxOptionOn {
    return [self.tipCalcData.showTax boolValue];
}

-(void)setSplitOption:(BOOL)splitOption {
	self.tipCalcData.showSplit = @(splitOption);
	self.tipCalcData.beforeSplit = splitOption ? [self.tipCalcData beforeSplit] : @(0);
}

-(BOOL)isSplitOptionOn {
    return [self.tipCalcData.showSplit boolValue];
}

-(void)setRoundingOption:(BOOL)RoundingOption {
	self.tipCalcData.showRounding = @(RoundingOption);
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (BOOL)isRoundingOptionOn {
    return [self.tipCalcData.showRounding boolValue];
}

#pragma mark Manipulate TipCalc Data

- (void)setTipCalcDataForMainTableView {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isMain == %@",[NSNumber numberWithBool:YES]];
    NSArray* arrRecent = [TipCalcRecently MR_findAllWithPredicate:predicate];
    
    if(arrRecent.count > 0) {
        _tipCalcData = arrRecent[0];
        _tipCalcData.currencyCode = self.currencyCode;
    }
    else {
        TipCalcRecently* recently = [TipCalcRecently MR_createEntity];
        recently.knownValue = @(TCKnownValue_CostsBeforeTax);
        recently.isMain = [NSNumber numberWithBool:YES];
        recently.tip = @20;
        //recently.tax = _defaultTax;
        recently.isPercentTip = @(YES);
        recently.split = @1;
		recently.currencyCode = self.currencyCode;
        recently.showTax = @(YES);
        recently.showSplit = @(YES);
        recently.showRounding = @(YES);
        recently.rRoundMethod = [TipCalcRoundMethod MR_createEntity];
        recently.rRoundMethod.optionType = @(TCRoundingMethodOption_Exact);
        
        _tipCalcData = recently;
    }
}

- (void)setTipCalcDataForHistoryData:(TipCalcHistory *)aHistory {
    _tipCalcData = aHistory.rRecently;
}

#pragma mark Split Option
- (void)setTipSplitOption:(TipSplitOption)option {
    self.tipCalcData.beforeSplit = @(option);
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (TipSplitOption)tipSplitOption {
    return [self.tipCalcData.beforeSplit integerValue] == TipSplitOption_BeforeSplit ? TipSplitOption_BeforeSplit : TipSplitOption_PerPerson;
}

#pragma mark KnownValue
- (void)setKnownValue:(TCKnownValue)value {
    self.tipCalcData.knownValue = value == TCKnownValue_Subtotal ? @(TCKnownValue_Subtotal) : @(TCKnownValue_CostsBeforeTax);
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (TCKnownValue)knownValue {
    return self.tipCalcData.knownValue.integerValue == TCKnownValue_Subtotal ? TCKnownValue_Subtotal : TCKnownValue_CostsBeforeTax;
}

#pragma mark Set Tip Calc Data
- (void)setTipCalcDataCost:(NSNumber *)cost {
    self.tipCalcData.costs = cost;
}

- (void)setTipCalcDataTax:(NSNumber *)tax isPercentType:(BOOL)isPercent {
    self.tipCalcData.tax = tax;
    self.tipCalcData.isPercentTax = @(isPercent);
}

- (void)setTipCalcDataTip:(NSNumber *)tip isPercentType:(BOOL)isPercent {
    self.tipCalcData.tip = tip;
    self.tipCalcData.isPercentTip = @(isPercent);
}

- (void)setTipCalcDataSplit:(NSNumber *)split {
    if (!split || [split isEqualToNumber:@0]) {
        split = @1;
    }
    
    self.tipCalcData.split = split;
}

#pragma mark Save Data

- (void)saveTipCalcData {
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)saveToHistory {
    TipCalcHistory* history = [TipCalcHistory MR_createEntity];
    history.labelTip = [self currencyStringFromDouble:[[self tipValueWithSplitWithRounding:YES] doubleValue]];
    history.labelTotal = [self currencyStringFromDouble:[[self totalBeforeSplitWithTax] doubleValue]];
    
    history.dateTime = [NSDate date];
    history.rRecently = self.tipCalcData;
    self.tipCalcData.isMain = @(NO);

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    TipCalcRecently* recently = [TipCalcRecently MR_createEntity];
    recently.isMain = @(YES);
    recently.split = @1;
    recently.knownValue = @(TCKnownValue_CostsBeforeTax);
    recently.tip = @20;
    recently.tax = _defaultTax;
    recently.isPercentTip = @(YES);
    recently.showTax = @(YES);
    recently.showSplit = @(YES);
    recently.showRounding = @(YES);
    recently.rRoundMethod = [TipCalcRoundMethod MR_createEntity];
    recently.currencyCode = self.currencyCode;
    _tipCalcData = recently;
}

#pragma mark Rounding Method

- (void)setRoundingMethodValue:(TCRoundingMethodValue)value {
    self.tipCalcData.rRoundMethod.valueType =  @(value);
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (TCRoundingMethodValue)roundingMethodValue {
    return (TCRoundingMethodValue) [self.tipCalcData.rRoundMethod.valueType integerValue];
}

- (void)setRoundingMethodOption:(TCRoundingMethodOption)option {
    self.tipCalcData.rRoundMethod.optionType = @(option);
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (TCRoundingMethodOption)roundingMethodOption {
    return (TCRoundingMethodOption) [self.tipCalcData.rRoundMethod.optionType integerValue];
}

#pragma mark - Result Calculation

- (NSNumber *)costBeforeTax {

    if ([self knownValue] == TCKnownValue_CostsBeforeTax) {
        return self.tipCalcData.costs;
    }

    double costBeforeTax = 0.0;
    costBeforeTax = ([self.tipCalcData.costs doubleValue] * 100.0) / (100.0 + [[self taxPercent] doubleValue]);
    
    return @(costBeforeTax);
}

- (NSNumber *)costBeforeTaxWithSplit {
    double result = 0.0;
    if ([self.tipCalcData.split isEqualToNumber:@0]) {
        return [self costBeforeTax];
    }
    
    result = [[self costBeforeTax] doubleValue] / [self.tipCalcData.split doubleValue];
    return @(result);
}

- (NSNumber *)subtotal {
    double subtotal = 0.0;

    if ([self knownValue] == TCKnownValue_Subtotal) {
        if (self.roundingMethodValue == TCRoundingMethodValue_Total) {
            subtotal = [[self numberByRoundingMethodForValue:self.tipCalcData.costs] doubleValue];
        }
        else {
            subtotal = [self.tipCalcData.costs doubleValue];
        }
        return @(subtotal);
    }
    

    subtotal = [self.tipCalcData.costs doubleValue] + [[self taxValue] doubleValue];
    if (self.roundingMethodValue == TCRoundingMethodValue_Total) {
        subtotal = [[self numberByRoundingMethodForValue:@(subtotal)] doubleValue];
    }
    return @(subtotal);
}

- (NSNumber *)subtotalWithSplit {
    double result = 0.0;
    if ([self.tipCalcData.split isEqualToNumber:@0]) {
        return [self subtotal];
    }
    
    result = [[self subtotal] doubleValue] / [self.tipCalcData.split doubleValue];
    return @(result);
}

- (NSNumber *)totalBeforeSplitWithTax {
    double totalBeforeSplit;
    
    if ([self knownValue] == TCKnownValue_Subtotal) {
        totalBeforeSplit = [self.tipCalcData.costs doubleValue] + [[self tipValueWithRounding:self.roundingMethodValue == TCRoundingMethodValue_Tip ? YES : NO] doubleValue];
    }
    else {
        totalBeforeSplit = [[self costBeforeTax] doubleValue] + [[self taxValue] doubleValue] + [[self tipValueWithRounding:self.roundingMethodValue == TCRoundingMethodValue_Tip ? YES : NO] doubleValue];
    }
    
    
    if (self.roundingMethodValue == TCRoundingMethodValue_Total) {
        totalBeforeSplit = [[self numberByRoundingMethodForValue:@(totalBeforeSplit)] doubleValue];
    }
    
    return @(totalBeforeSplit);
}

- (NSNumber *)totalPerPersonWithTax {
    double totalWithSplit = [[self costBeforeTaxWithSplit] doubleValue] + [[self taxValueWithSplit] doubleValue] + [[self tipValueWithSplitWithRounding:self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson ? YES : NO ] doubleValue];

    if (self.roundingMethodValue == TCRoundingMethodValue_TotalPerPerson) {
        totalWithSplit = [[self numberByRoundingMethodForValue:@(totalWithSplit)] doubleValue];
    }
    return @(totalWithSplit);
}

- (NSNumber *)taxPercent {
    if (![self isTaxOptionOn]) {
        return @0;
    }
    if ([self.tipCalcData.isPercentTax boolValue]) {
        return [self.tipCalcData tax];
    }
    
    // Tax가 값인 경우, 퍼센트를 구하여 반환.
    double resultTaxPercent = 0.0;
    if ([self knownValue] == TCKnownValue_Subtotal) {
        double costBeforeTax = [self.tipCalcData.costs doubleValue] - [self.tipCalcData.tax doubleValue];
        resultTaxPercent = [self.tipCalcData.tax doubleValue] / (costBeforeTax / 100.0);
    }
    else if ([self knownValue] == TCKnownValue_CostsBeforeTax) {
        resultTaxPercent = [self.tipCalcData.tax doubleValue] / [self.tipCalcData.costs doubleValue] / 100.0;
    }
    
    return @(resultTaxPercent);
}

- (NSNumber *)taxValue {
    if (![self.tipCalcData.isPercentTax boolValue]) {
        return [self.tipCalcData tax];
    }
    if (![self isTaxOptionOn]) {
        return @0;
    }
    
    // Tax가 퍼센트인 경우, 값을 구하여 반환.
    double resultTaxValue = 0.0;
    if ([self knownValue] == TCKnownValue_Subtotal) {
        double costBeforeTax = ([self.tipCalcData.costs doubleValue] * 100.0) / (100.0 + [self.tipCalcData.tax doubleValue]);
        resultTaxValue = [self.tipCalcData.costs doubleValue] - costBeforeTax;
    }
    else if ([self knownValue] == TCKnownValue_CostsBeforeTax) {
        resultTaxValue = [self.tipCalcData.costs doubleValue] * [self.tipCalcData.tax doubleValue] / 100.0;
    }
    
    return @(resultTaxValue);
}

- (NSNumber *)taxValueWithSplit {
    if (![self isTaxOptionOn]) {
        return @0;
    }
    if ([self.tipCalcData.split isEqualToNumber:@0]) {
        return [self taxValue];
    }
    
    double result = 0.0;
    result = [[self taxValue] doubleValue] / [self.tipCalcData.split doubleValue];
    return @(result);
}

- (NSNumber *)tipValueWithRounding:(BOOL)rounding {
    
    NSNumber *tipValue = self.tipCalcData.tip;
    
    // valueType
    if (![self.tipCalcData.isPercentTip boolValue]) {
        if ([self tipSplitOption] == TipSplitOption_BeforeSplit) {
            if (self.roundingMethodValue == TCRoundingMethodValue_Tip && [self isRoundingOptionOn] && rounding) {
                tipValue = [self numberByRoundingMethodForValue:tipValue];
            }
        }
        else {
            if (self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson && [self isRoundingOptionOn] && rounding) {
                tipValue = [self numberByRoundingMethodForValue:tipValue];
            }
        }

        return tipValue;
    }
    
    // percentType
    double resultTipValue = [[self costBeforeTax] doubleValue] * [tipValue doubleValue] / 100.0;
    if ([self tipSplitOption] == TipSplitOption_BeforeSplit) {
        if (self.roundingMethodValue == TCRoundingMethodValue_Tip && [self isRoundingOptionOn] && rounding) {
            resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
        }
    }
    else {
        if (self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson && [self isRoundingOptionOn] && rounding) {
            resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
        }
    }

    return @(resultTipValue);
}

- (NSNumber *)tipPercent {
    return @(0);
}

- (NSNumber *)tipValueWithSplitWithRounding:(BOOL)rounding {
    NSNumber *tipValue = self.tipCalcData.tip;
    
    // valueType
    if (![self.tipCalcData.isPercentTip boolValue]) {
        tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
        
        if ([self tipSplitOption] == TipSplitOption_BeforeSplit) {
            if (rounding) {
                if (self.roundingMethodValue == TCRoundingMethodValue_Tip && [self isRoundingOptionOn]) {
                    tipValue = [self numberByRoundingMethodForValue:tipValue];
                }
            }
        }
        else {
            if (rounding) {
                if (self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson && [self isRoundingOptionOn]) {
                    tipValue = [self numberByRoundingMethodForValue:tipValue];
                }
            }
        }
        
        return tipValue;
    }
    
    // percentType
    double resultTipValue = [[self costBeforeTax] doubleValue] * [tipValue doubleValue] / 100.0;
    resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
    
    if ([self tipSplitOption] == TipSplitOption_BeforeSplit) {
        if (rounding) {
            if (self.roundingMethodValue == TCRoundingMethodValue_Tip && [self isRoundingOptionOn]) {
                resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
            }
        }
    }
    else {
        if (rounding) {
            if (self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson && [self isRoundingOptionOn]) {
                resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
            }
        }
    }
    
    return @(resultTipValue);
}


#pragma mark - CLLocationManager stuff

//bool kIsFirstTipCalcGeocodeTemp = YES; // temp
- (void)getUSTaxRateByLocation
{
    if(_locationManager == nil)
        return;
    
	if (!self.delegate)
        return;
    
	_locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (!_locationManager)
        return;

	[manager stopUpdatingLocation];

	CLGeocoder* geocoder = [[CLGeocoder alloc] init];

	[geocoder reverseGeocodeLocation: _locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {        
        NSLog(@"ori------");
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSLog(@"%@", placemark.ISOcountryCode);// 1
        NSLog(@"%@", placemark.country);
        NSLog(@"%@", placemark.postalCode);
        NSLog(@"%@", placemark.administrativeArea);//4
        NSLog(@"%@", placemark.subAdministrativeArea);
        NSLog(@"%@", placemark.locality);
        NSLog(@"%@", placemark.subLocality);
        NSLog(@"%@", placemark.thoroughfare);
        NSLog(@"%@", placemark.subThoroughfare);
        NSLog(@"--------");
        
        NSNumber *knownTax = nil;
        if ([placemark.ISOcountryCode isEqualToString:@"US"] &&
            [placemark.administrativeArea length]) {
            NSNumber *knownTaxFromTable = self.knownUSTaxes[placemark.administrativeArea];
            if (knownTaxFromTable) {
                knownTax = knownTaxFromTable;
            }
        }
        else {
            knownTax = @10;  // 기타 지역 기본 Tax 10%. - KJH
        }
        
        if (knownTax) {
            _defaultTax = knownTax;  // US 지역 기본 Tax 지정. - KJH
            [self setTipCalcDataTax:_defaultTax isPercentType:YES];
            
            id <A3TipCalcDataManagerDelegate> o = self.delegate;
            if ([o respondsToSelector:@selector(dataManager:taxValueUpdated:)]) {
                [o dataManager:self taxValueUpdated:knownTax];
            }
        }
        
        _locationManager.delegate = nil;
        _locationManager = nil;
    }];
}


// 미국 판매세 세율은 일반 상품에 적용되는 세율과 식당에 적용되는 세율이 다른 경우가 있습니다.
// Sales Calc는 일반 상품에 적용되는 세금을 이용합니다.
// Tip Calc는 식당에 적용되는 세율을 적용합니다.
// 최종 업데이트는 5월 23일 Wikipedia 정보 기준입니다.
- (NSDictionary *)knownUSTaxes {
	return @{
			@"AL" : @4,		// Alabama
			@"AK" : @0,		// Alaska
			@"AZ" : @5.6,		// Arizona
			@"AR" : @6.5,		// Arkansas
			@"CA" : @7.5,		// California
			@"CO" : @2.9,		// Colorado
			@"CT" : @6.35,		// Connecticut
			@"DE" : @0,		// Delaware
			@"DC" : @10,		// District of Columbia, 10%
			@"FL" : @9,		// Florida, 9%
			@"GA" : @4,		// Georgia
			@"GU" : @4,		// Guam
			@"HI" : @4,		// Hawaii
			@"ID" : @6,		// Idaho
			@"IL" : @8.25,		// Illinois, 8.25%
			@"IN" : @9,		// Indiana, 9%
			@"IA" : @6,		// Iowa
			@"KS" : @6.15,		// Kansas
			@"KY" : @6,		// Kentucky
			@"LA" : @4,		// Louisiana
			@"ME" : @7,		// Maine, 7%
			@"MD" : @6,		// Maryland
			@"MA" : @7,		// Massachusetts, 7%
			@"MI" : @6,		// Michigan
			@"MN" : @10.775,	// Minnesota, 10.775%
			@"MS" : @7,		// Mississippi
			@"MO" : @4.225,	// Missouri
			@"MT" : @0,		// Montana
			@"NE" : @9.5,		// Nebraska, 9.5%
			@"NV" : @6.85,		// Nevada
			@"NH" : @0,		// New Hampshire, 9%
			@"NJ" : @7,		// New Jersey
			@"NM" : @5.125,	// New Mexico
			@"NY" : @4,		// New York
			@"NC" : @8.5,		// North Carolina, 8.5
			@"ND" : @5,		// North Dakota
			@"OH" : @5.75,		// Ohio
			@"OK" : @8.517,	// Oklahoma
			@"OR" : @0,		// Oregon
			@"PA" : @6,		// Pennsylvania
			@"PR" : @7,		// Puerto Rico
			@"RI" : @7,		// Rhode Island, 8%
			@"SC" : @6,		// South Carolina, 10.5%
			@"SD" : @4,		// South Dakota
			@"TN" : @7,		// Tennessee
			@"TX" : @6.25,		// Texas
			@"UT" : @4.7,		// Utah
			@"VT" : @6,		// Vermont, 9%
			@"VA" : @4.3,		// Virginia, 5.3%
			@"WA" : @6.5,		// Washington, 10%
			@"WV" : @6,		// West Virginia
			@"WI" : @5,		// Wisconsin
			@"WY" : @4,		// Wyoming
	};
}

- (NSString *)currencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3TipCalcCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

- (NSNumberFormatter *)currencyFormatter {
	if (!_currencyFormatter) {
		_currencyFormatter = [NSNumberFormatter new];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[_currencyFormatter setCurrencyCode:self.currencyCode];
	}

	return _currencyFormatter;
}

@end
