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
    destination.rRoundMethod.tip = source.rRoundMethod.tip;
    destination.rRoundMethod.tipPerPerson = source.rRoundMethod.tipPerPerson;
    destination.rRoundMethod.total = source.rRoundMethod.total;
    destination.rRoundMethod.totalPerPerson = source.rRoundMethod.totalPerPerson;
    destination.rRoundMethod.optionType = source.rRoundMethod.optionType;
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
            temp = round([aValue doubleValue]);
            
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

// elf 수정중 - round method 적용하기
- (double)costsAfterTax
{
    double dRst = 0.0;
    
    double dCosts = [self.tipCalcData.costs doubleValue];
    
    if([self.tipCalcData.knownValue intValue] == 0 || ![self isTaxOptionOn]) // 세후금액
        dRst = dCosts;
    else
        dRst = [self costsBeforeTax] + [self taxRst];
    
    return dRst;
}

- (double)costsBeforeTax    // //세전금액 역산-_-
{
    double dRst = 0.0;
    
    if([self.tipCalcData.knownValue intValue] == 1) // 세전금액입력일경우 그냥 리턴
        return [self.tipCalcData.costs doubleValue];
    
    double dCosts = [self.tipCalcData.costs doubleValue];
    double dTaxPer = [self.tipCalcData.tax doubleValue];
    
    dRst = dCosts / ((100+dTaxPer) * 0.01);
    
    return dRst;
}

// elf 수정중 - round method 적용하기
- (double)taxRst
{
    double dRst = 0.0;
    
    double dCosts = [self.tipCalcData.costs doubleValue];
    double dTaxPer = [self.tipCalcData.tax doubleValue];
    
    if(![self.tipCalcData.isPercentTax boolValue])
        return dTaxPer;
    
    if([self.tipCalcData.knownValue intValue] == 0) // 세후금액일때세금
        dRst = dCosts - [self costsBeforeTax];
    else    // 세전금액일때세금
        dRst = dCosts * (dTaxPer * 0.01);
    
    return dRst;
}

- (double)tipRst:(int)aBeforeSplitFlag
{
    double dRst = 0.0;
    
    double dCosts = [self.tipCalcData.costs doubleValue];
    double dTipPer = [self.tipCalcData.tip doubleValue];
    double dSplit = [self.tipCalcData.split doubleValue];
    
    if(![self.tipCalcData.isPercentTip boolValue])
    {
        dRst = dTipPer;
    }
    else
    {
        if([self.tipCalcData.knownValue intValue] == 0) // 세후가격
        {
            double dCostsBeforeTax = [self costsBeforeTax];
            
            dRst = dCostsBeforeTax * (dTipPer * 0.01);
        }
        else
        {// 세전가격
            dRst = dCosts * (dTipPer * 0.01);
        }
        
        if ([self roundingMethodValue] == TCRoundingMethodValue_Tip) {
            dRst = [self roundingValue:dRst rdMethod:[self.tipCalcData.rRoundMethod.tip intValue]];
        }
    }

    if(aBeforeSplitFlag == 1)
    {
        dRst = dRst / dSplit;
        
        if ([self roundingMethodValue] == TCRoundingMethodValue_Tip) {
            dRst = [self roundingValue:dRst rdMethod:[self.tipCalcData.rRoundMethod.tipPerPerson intValue]];
        }
    }
    
    return dRst;
}

- (double)totalRst:(int)aBeforeSplitFlag
{
    double dRst = 0.0;
    
    double dCosts = [self.tipCalcData.costs doubleValue];
    double dSplit = [self.tipCalcData.split doubleValue];
    
    if([self.tipCalcData.knownValue intValue] == 0) // 세후가격
        dRst = dCosts + [self tipRst:0];
    else    // 세전가격
        dRst = dCosts + [self taxRst] + [self tipRst:0];
    
    if ([self roundingMethodValue] == TCRoundingMethodValue_Total) {
        dRst = [self roundingValue:dRst rdMethod:[self.tipCalcData.rRoundMethod.total intValue]];
    }
    
    if (aBeforeSplitFlag == 1) {
        dRst = dRst / dSplit;

        if ([self roundingMethodValue] == TCRoundingMethodValue_TotalPerPerson) {
            dRst = [self roundingValue:dRst rdMethod:[self.tipCalcData.rRoundMethod.totalPerPerson intValue]];
        }
    }
    
    return dRst;
}

- (NSString*)sharedData
{
    NSMutableString* mstrOutput = [[NSMutableString alloc] init];
    
    if (![self isTaxOptionOn])
        [mstrOutput appendFormat:@"Costs : %@", [self currencyStringFromDouble:[self costsAfterTax]]];
    else if([self.tipCalcData.knownValue intValue] == 0) // 세후가격
        [mstrOutput appendFormat:@"Costs After Tax : %@", [self currencyStringFromDouble:[self costsAfterTax]]];
    else
        [mstrOutput appendFormat:@"Costs Before Tax : %@", [self currencyStringFromDouble:[self costsBeforeTax]]];
    
    [mstrOutput appendFormat:@"\r\n"];
    
    if ([self isTaxOptionOn])
        [mstrOutput appendFormat:@"Tax : %@", [self currencyStringFromDouble:[self taxRst]]];
    
    [mstrOutput appendFormat:@"\r\n"];
    
    [mstrOutput appendFormat:@"Tip : %@", [self currencyStringFromDouble:[self tipRst:0]]];
    
    [mstrOutput appendFormat:@"\r\n"];
    
    if([self.tipCalcData.beforeSplit intValue] == 0)
        [mstrOutput appendFormat:@"Total : %@", [self currencyStringFromDouble:[self totalRst:0]]];
    else
    {
        [mstrOutput appendFormat:@"Split : %@\r\n", self.tipCalcData.split];
        [mstrOutput appendFormat:@"Per Person : %@", [self currencyStringFromDouble:[self totalRst:1]]];
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
- (void)setTipSplitOption:(TCTipSplitOption)option {
    self.tipCalcData.beforeSplit = @(option);
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (TCTipSplitOption)tipSplitOption {
    return [self.tipCalcData.beforeSplit integerValue] == TCTipSplitOption_BeforeSplit ? TCTipSplitOption_BeforeSplit : TCTipSplitOption_PerPerson;
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
    history.labelTip = [self currencyStringFromDouble:[self.tipValue doubleValue]];
    history.labelTotal = [self currencyStringFromDouble:[self.totalBeforeSplit doubleValue]];
    
    history.dateTime = [NSDate date];
    history.rRecently = self.tipCalcData;
    self.tipCalcData.isMain = @(NO);

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    TipCalcRecently* recently = [TipCalcRecently MR_createEntity];
    recently.isMain = @(YES);
    recently.split = @1;
    recently.knownValue = @(TCKnownValue_CostsBeforeTax);
    recently.tip = @20;
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

- (NSNumber *)totalBeforeSplit {
    double totalBeforeSplit = [[self costBeforeTax] doubleValue] + [[self tipValue] doubleValue];
    
    if (self.roundingMethodValue == TCRoundingMethodValue_Total) {
        totalBeforeSplit = [[self numberByRoundingMethodForValue:@(totalBeforeSplit)] doubleValue];
    }
    
    return @(totalBeforeSplit);
}

- (NSNumber *)totalPerPerson {
    double totalBeforeSplit = [[self costBeforeTax] doubleValue] + [[self tipValue] doubleValue];

    if ([[self.tipCalcData split] isEqualToNumber:@0]) {
        if (self.roundingMethodValue == TCRoundingMethodValue_TotalPerPerson) {
            totalBeforeSplit = [[self numberByRoundingMethodForValue:@(totalBeforeSplit)] doubleValue];
        }
        return @(totalBeforeSplit);
    }
    
    double perPerson = totalBeforeSplit / [self.tipCalcData.split doubleValue];
    if (self.roundingMethodValue == TCRoundingMethodValue_TotalPerPerson) {
        perPerson = [[self numberByRoundingMethodForValue:@(perPerson)] doubleValue];
    }
    return @(perPerson);
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

- (NSNumber *)tipValue {
    
    NSNumber *tipValue = self.tipCalcData.tip;
    
    // valueType
    if (![self.tipCalcData.isPercentTip boolValue]) {
        if (self.roundingMethodValue == TCRoundingMethodValue_Tip && [self isRoundingOptionOn] && [self tipSplitOption] == TCTipSplitOption_BeforeSplit) {
            tipValue = [self numberByRoundingMethodForValue:tipValue];
        }
        return tipValue;
    }
    
    // percentType
    double resultTipValue = [[self costBeforeTax] doubleValue] * [tipValue doubleValue] / 100.0;
    if (self.roundingMethodValue == TCRoundingMethodValue_Tip && [self isRoundingOptionOn] && [self tipSplitOption] == TCTipSplitOption_BeforeSplit) {
        resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
    }
    return @(resultTipValue);
}

- (NSNumber *)tipPercent {
    return @(0);
}

- (NSNumber *)tipValueWithSplit {
    double tipValueWithSplit = 0.0;
    
    if ([self.tipCalcData.split isEqualToNumber:@0]) {
        tipValueWithSplit = [[self tipValue] doubleValue];
        
        if (self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson && [self tipSplitOption] == TCTipSplitOption_PerPerson && [self isRoundingOptionOn]) {
            tipValueWithSplit = [[self numberByRoundingMethodForValue:@(tipValueWithSplit)] doubleValue];
        }
        return @(tipValueWithSplit);
    }
    
    
    tipValueWithSplit = [[self tipValue] doubleValue] / [self.tipCalcData.split doubleValue];
    
    if (self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson && [self tipSplitOption] == TCTipSplitOption_PerPerson && [self isRoundingOptionOn]) {
        tipValueWithSplit = [[self numberByRoundingMethodForValue:@(tipValueWithSplit)] doubleValue];
    }
    
    return @(tipValueWithSplit);
}


#pragma mark - CLLocationManager stuff

//bool kIsFirstTipCalcGeocodeTemp = YES; // temp
- (void)getUSTaxRateByLocation
{
    if(_locationManager == nil)
        return;
    
	if (!self.delegate) return;
    
	_locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (!_locationManager) return;
	
	@autoreleasepool {
		[manager stopUpdatingLocation];
		
		CLGeocoder* geocoder = [[CLGeocoder alloc] init];
		
		[geocoder reverseGeocodeLocation: _locationManager.location completionHandler:
		 ^(NSArray *placemarks, NSError *error) {
			 
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
				 NSString *knownTaxString = self.knownUSTaxes[placemark.administrativeArea];
				 if ([knownTaxString length]) {
					 knownTax = @([knownTaxString doubleValue]);
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
}

- (NSDictionary *)knownUSTaxes {
	return @{
             @"AL" : @"4",
             @"AK" : @"0",
             @"AZ" : @"6.60",
             @"AR" : @"6",
             @"CA" : @"7.50",
             @"CO" : @"2.90",
             @"CT" : @"6.35",
             @"DE" : @"0",
             @"DC" : @"10",
             @"FL" : @"9",
             @"GA" : @"4",
             @"GU" : @"4",
             @"HI" : @"4",
             @"ID" : @"6",
             @"IL" : @"8.25",
             @"IN" : @"9",
             @"IA" : @"6",
             @"KS" : @"6.30",
             @"KY" : @"6",
             @"LA" : @"4",
             @"ME" : @"7",
             @"MD" : @"6",
             @"MA" : @"7",
             @"MI" : @"6",
             @"MN" : @"10.78",
             @"MS" : @"7",
             @"MO" : @"4.23",
             @"MT" : @"0",
             @"NE" : @"9.50",
             @"NV" : @"6.85",
             @"NH" : @"9",
             @"WY" : @"7",
             @"NJ" : @"5.13",
             @"NM" : @"8.50",
             @"NY" : @"8.50",
             @"NC" : @"5",
             @"ND" : @"5.75",
             @"OH" : @"4.50",
             @"OK" : @"0",
             @"OR" : @"6",
             @"PA" : @"5.50",
             @"PR" : @"8",
             @"RI" : @"10.50",
             @"SC" : @"4",
             @"SD" : @"7",
             @"TN" : @"6.25",
             @"TX" : @"4.70",
             @"UT" : @"9",
             @"VT" : @"5.30",
             @"VA" : @"10",
             @"WA" : @"6",
             @"WV" : @"5",
             @"WI" : @"4",
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
