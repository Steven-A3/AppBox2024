//
//  A3TipCalcDataManager.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcDataManager.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3AppDelegate.h"

NSString * const A3TipCalcRecentCurrentDataID = @"CurrentTipCalcRectnID";

@implementation A3TipCalcDataManager
{
    TipCalcRecent * _tipCalcData;
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

- (TipCalcRecent *)tipCalcData
{
    if (!_tipCalcData) {
        [self setTipCalcDataForMainTableView];
        return _tipCalcData;
    }
    
    return _tipCalcData;
}

- (NSArray*)tipCalcHistory
{
    NSArray* arrRecent = [TipCalcHistory findAllSortedBy:@"updateDate" ascending:NO];
    
    return arrRecent;
}


#pragma mark - 

- (NSString*)currencyStringFromDouble:(double)value
{
	return [self.currencyFormatter stringFromNumber:@(value)];
}

- (void)deepCopyRecently:(TipCalcRecent *)source dest:(TipCalcRecent *)destination
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
    destination.optionType = source.optionType;
    destination.valueType = source.valueType;
}

- (void)historyToRecently:(TipCalcHistory*)aHistory
{
    TipCalcRecent *history = [TipCalcRecent findFirstByAttribute:@"historyID" withValue:aHistory.uniqueID];
    FNLOG(@"%@, %@", aHistory, history);

    [[A3SyncManager sharedSyncManager] setObject:[history currencyCode] forKey:A3TipCalcUserDefaultsCurrencyCode state:A3DataObjectStateModified];

    self.currencyFormatter = nil;

    TipCalcRecent *currentData = self.tipCalcData;
    [self deepCopyRecently:history dest:currentData];
    
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];

	_tipCalcData = [TipCalcRecent findFirstByAttribute:@"uniqueID" withValue:A3TipCalcRecentCurrentDataID];
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
	[mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self tipValueWithRounding] doubleValue]]];
    if ([self isSplitOptionOn] && [self.tipCalcData.split integerValue] > 1) {
		[mstrOutput appendString:NSLocalizedString(@"Total Per Person", @"Total Per Person")];
		[mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self totalPerPersonWithTax] doubleValue]]];
		[mstrOutput appendString:NSLocalizedString(@"Tip Per Person", @"Tip Per Person")];
        [mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[[self tipValueWithSplitWithRounding:YES] doubleValue]]];
    }
    
    if (!isMail) {
        return mstrOutput;
    }

	[mstrOutput appendString:@"<br>"];
	[mstrOutput appendString:NSLocalizedString(@"Input", @"Input")];
	[mstrOutput appendString:@"<br>"];

    if (![self isTaxOptionOn]) {
		[mstrOutput appendString:NSLocalizedString(@"Amount", @"Amount")];
        [mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[self.tipCalcData.costs doubleValue]]];
    }
    else {
        if([self.tipCalcData.knownValue intValue] == TCKnownValue_CostAfterTax) {
			[mstrOutput appendString:NSLocalizedString(@"Amount After Tax", @"Amount After Tax")];
            [mstrOutput appendFormat:@" : %@<br>", [self currencyStringFromDouble:[self.tipCalcData.costs doubleValue]]];
        }
        else {
			[mstrOutput appendString:NSLocalizedString(@"Amount Before Tax", @"Amount Before Tax")];
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
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (BOOL)isRoundingOptionSwitchOn {
    return [self.tipCalcData.showRounding boolValue];
}

#pragma mark Manipulate TipCalc Data

- (void)setTipCalcDataForMainTableView {
    _tipCalcData = [TipCalcRecent findFirstByAttribute:@"uniqueID" withValue:A3TipCalcRecentCurrentDataID];
    if(_tipCalcData) {
        _tipCalcData.currencyCode = self.currencyCode;
    }
    else {
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        TipCalcRecent * recently = [[TipCalcRecent alloc] initWithContext:context];
		recently.uniqueID = A3TipCalcRecentCurrentDataID;
		recently.updateDate = [NSDate date];
		[self resetRecentValues:recently];
        _tipCalcData = recently;

        [context saveContext];
    }
}

- (void)resetRecentValues:(TipCalcRecent *)recently {
	recently.knownValue = @(TCKnownValue_CostsBeforeTax);
	recently.isMain = [NSNumber numberWithBool:YES];
	recently.costs = @0;
	recently.tip = @20;
	recently.tax = _defaultTax;
	recently.isPercentTip = @(YES);
	recently.split = @1;
	recently.currencyCode = self.currencyCode;
	recently.showTax = @YES;
	recently.showSplit = @YES;
	recently.showRounding = @YES;
	recently.optionType = @(TCRoundingMethodOption_Exact);
}

- (void)setTipCalcDataForHistoryData:(TipCalcHistory *)aHistory {
    _tipCalcData = [TipCalcRecent findFirstByAttribute:@"historyID" withValue:aHistory.uniqueID];
    self.currencyFormatter.currencyCode = _tipCalcData.currencyCode;
}

#pragma mark Split Option
- (void)setTipSplitOption:(TipSplitOption)option {
    self.tipCalcData.beforeSplit = @(option);
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (TipSplitOption)tipSplitOption {
    return [self.tipCalcData.beforeSplit integerValue] == TipSplitOption_BeforeSplit ? TipSplitOption_BeforeSplit : TipSplitOption_PerPerson;
}

#pragma mark KnownValue
- (void)setKnownValue:(TCKnownValue)value {
    self.tipCalcData.knownValue = value == TCKnownValue_CostAfterTax ? @(TCKnownValue_CostAfterTax) : @(TCKnownValue_CostsBeforeTax);
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (TCKnownValue)knownValue {
    return self.tipCalcData.knownValue.integerValue == TCKnownValue_CostAfterTax ? TCKnownValue_CostAfterTax : TCKnownValue_CostsBeforeTax;
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

- (void)saveCoreData {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    if ([context hasChanges]) {
        NSError *saveError = nil;
        [context save:&saveError];
        if (saveError) {
            FNLOG(@"%@", saveError);
        }
    }
}

- (BOOL)sameDataExist {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isMain == NO AND knownValue == %@ AND costs == %@ AND tip == %@ AND tax == %@ AND isPercentTip == %@ AND split == %@ AND currencyCode == %@",
					_tipCalcData.knownValue, _tipCalcData.costs, _tipCalcData.tip, _tipCalcData.tax, _tipCalcData.isPercentTip, _tipCalcData.split, _tipCalcData.currencyCode ];
	return [TipCalcRecent countOfEntitiesWithPredicate:predicate] > 0;
}

- (void)saveToHistory {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	TipCalcRecent *recently;
	if (![_tipCalcData.costs isEqualToNumber:@0] && ![self sameDataExist]) {
        TipCalcHistory* history = [[TipCalcHistory alloc] initWithContext:context];
		history.uniqueID = [[NSUUID UUID] UUIDString];
		history.updateDate = [NSDate date];
		history.labelTip = [self currencyStringFromDouble:[[self tipValueWithSplitWithRounding:YES] doubleValue]];
		history.labelTotal = [self currencyStringFromDouble:[[self totalBeforeSplitWithTax] doubleValue]];
		
		TipCalcRecent *historyData = (TipCalcRecent *) [_tipCalcData cloneInContext:context ];
		historyData.uniqueID = [[NSUUID UUID] UUIDString];
		historyData.historyID = history.uniqueID;
		historyData.isMain = @NO;
        recently = _tipCalcData;
	} else {
		recently = _tipCalcData;
	}

	recently.updateDate = [NSDate date];
	recently.knownValue = @(TCKnownValue_CostsBeforeTax);
	recently.isMain = [NSNumber numberWithBool:YES];
	recently.costs = @0;
	recently.tip = @20;
	recently.tax = _defaultTax;
	recently.isPercentTip = @(YES);
	recently.split = @1;
	recently.currencyCode = self.currencyCode;

    [context saveContext];

	_tipCalcData = [TipCalcRecent findFirstByAttribute:@"uniqueID" withValue:A3TipCalcRecentCurrentDataID];
}

#pragma mark Rounding Method

- (void)setRoundingMethodValue:(TCRoundingMethodValue)value {
    self.tipCalcData.valueType =  @(value);
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (TCRoundingMethodValue)roundingMethodValue {
    return (TCRoundingMethodValue) [self.tipCalcData.valueType integerValue];
}

- (void)setRoundingMethodOption:(TCRoundingMethodOption)option {
    self.tipCalcData.optionType = @(option);
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (TCRoundingMethodOption)roundingMethodOption {
    return (TCRoundingMethodOption) [self.tipCalcData.optionType integerValue];
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
    if ([self knownValue] == TCKnownValue_CostAfterTax) {
        return self.tipCalcData.costs;
    }
    
    double subtotal = 0.0;
    subtotal = [self.tipCalcData.costs doubleValue] + [[self taxValue] doubleValue];
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
    
    if ([self knownValue] == TCKnownValue_CostAfterTax) {
        totalBeforeSplit = [self.tipCalcData.costs doubleValue] + [[self tipValueWithRounding] doubleValue];
    }
    else {
        totalBeforeSplit = [[self costBeforeTax] doubleValue] + [[self taxValue] doubleValue] + [[self tipValueWithRounding] doubleValue];
    }
    
    
    switch (self.roundingMethodValue) {
        case TCRoundingMethodValue_Total:
            totalBeforeSplit = [[self numberByRoundingMethodForValue:@(totalBeforeSplit)] doubleValue];
            break;
            
        case TCRoundingMethodValue_TotalPerPerson:
            totalBeforeSplit = totalBeforeSplit / [self.tipCalcData.split doubleValue];
            totalBeforeSplit = [[self numberByRoundingMethodForValue:@(totalBeforeSplit)] doubleValue];
            totalBeforeSplit = totalBeforeSplit * [self.tipCalcData.split doubleValue];
            break;
            
        default:
            break;
    }

    return @(totalBeforeSplit);
}

- (NSNumber *)totalPerPersonWithTax {
    if (self.roundingMethodValue == TCRoundingMethodValue_Total) {
        double totalWithSplit = [[self numberByRoundingMethodForValue:[self totalBeforeSplitWithTax]] doubleValue] / [self.tipCalcData.split doubleValue];
        return @(totalWithSplit);
    }
    
    
    double totalWithSplit = [[self costBeforeTaxWithSplit] doubleValue] +
                            [[self taxValueWithSplit] doubleValue] +
                            [[self tipValueWithSplitWithRounding:(self.roundingMethodValue == TCRoundingMethodValue_Tip || self.roundingMethodValue == TCRoundingMethodValue_TipPerPerson) ? YES : NO ] doubleValue];

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
    if ([self knownValue] == TCKnownValue_CostAfterTax) {
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
    if ([self knownValue] == TCKnownValue_CostAfterTax) {
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

- (NSNumber *)tipValueWithRounding {
    
    NSNumber *tipValue = self.tipCalcData.tip;
    
    // valueType
    if (![self.tipCalcData.isPercentTip boolValue]) {
        if ([self isRoundingOptionSwitchOn]) {
            switch (self.roundingMethodValue) {
                case TCRoundingMethodValue_Tip:
                    tipValue = [self numberByRoundingMethodForValue:tipValue];
                    break;
                    
                case TCRoundingMethodValue_TipPerPerson:
                    tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
                    tipValue = [self numberByRoundingMethodForValue:tipValue];
                    tipValue = @([tipValue doubleValue] * [self.tipCalcData.split doubleValue]);
                    break;
                    
                case TCRoundingMethodValue_Total:
                {
                    double totalBeforeRounding = [self.subtotal doubleValue] + [tipValue doubleValue];
                    double totalAfterRounding = [[self numberByRoundingMethodForValue:@([self.subtotal doubleValue] + [tipValue doubleValue])] doubleValue];
                    tipValue = @([tipValue doubleValue] + (totalAfterRounding - totalBeforeRounding));
                }
                    break;
                    
                case TCRoundingMethodValue_TotalPerPerson:
                {
                    tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
                    double totalBeforeRounding = [self.subtotalWithSplit doubleValue] + [tipValue doubleValue];
                    double totalAfterRounding = [[self numberByRoundingMethodForValue:@([self.subtotalWithSplit doubleValue] + [tipValue doubleValue])] doubleValue];
                    tipValue = @([tipValue doubleValue] + (totalAfterRounding - totalBeforeRounding));
                    tipValue = @([tipValue doubleValue] * [self.tipCalcData.split doubleValue]);
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        return tipValue;
    }
    
    // percentType
    double resultTipValue = [[self costBeforeTax] doubleValue] * [tipValue doubleValue] / 100.0;
    if ([self isRoundingOptionSwitchOn]) {
        switch (self.roundingMethodValue) {
            case TCRoundingMethodValue_Tip:
                resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
                break;
                
            case TCRoundingMethodValue_TipPerPerson:
                resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
                resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
                resultTipValue = resultTipValue * [self.tipCalcData.split doubleValue];
                break;
                
            case TCRoundingMethodValue_Total:
            {
                double totalBeforeRounding = [self.subtotal doubleValue] + resultTipValue;
                double totalAfterRounding = [[self numberByRoundingMethodForValue:@([self.subtotal doubleValue] + resultTipValue)] doubleValue];
                resultTipValue += totalAfterRounding - totalBeforeRounding;
            }
                break;
                
            case TCRoundingMethodValue_TotalPerPerson:
            {
                resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
                double totalBeforeRounding = [self.subtotalWithSplit doubleValue] + resultTipValue;
                double totalAfterRounding = [[self numberByRoundingMethodForValue:@([self.subtotalWithSplit doubleValue] + resultTipValue)] doubleValue];
                resultTipValue += totalAfterRounding - totalBeforeRounding;
                resultTipValue = resultTipValue * [self.tipCalcData.split doubleValue];
            }
                break;
                
            default:
                break;
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
        tipValue = @([tipValue doubleValue]);

        if (rounding && [self isRoundingOptionSwitchOn]) {
            switch (self.roundingMethodValue) {
                case TCRoundingMethodValue_TipPerPerson:
                    tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
                    tipValue = [self numberByRoundingMethodForValue:tipValue];
                    break;
                    
                case TCRoundingMethodValue_Tip:
                    tipValue = [self numberByRoundingMethodForValue:tipValue];
                    tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
                    break;
                    
                case TCRoundingMethodValue_Total:
                case TCRoundingMethodValue_TotalPerPerson:
                {
                    tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
                    double totalBeforeRounding = [self.subtotalWithSplit doubleValue] + [tipValue doubleValue];
                    double totalAfterRounding = [self.totalPerPersonWithTax doubleValue];
                    tipValue = @([tipValue doubleValue] + (totalAfterRounding - totalBeforeRounding));
                }
                    break;
                    
                default:
                    break;
            }
        }
        else {
            tipValue = @([tipValue doubleValue] / [self.tipCalcData.split doubleValue]);
        }
        
        return tipValue;
    }
    
    
    
    // percentType
    double resultTipValue = [[self costBeforeTax] doubleValue] * [tipValue doubleValue] / 100.0;
    
    if (rounding && [self isRoundingOptionSwitchOn]) {
        switch (self.roundingMethodValue) {
            case TCRoundingMethodValue_TipPerPerson:
                resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
                resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
                break;
                
            case TCRoundingMethodValue_Tip:
                resultTipValue = [[self numberByRoundingMethodForValue:@(resultTipValue)] doubleValue];
                resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
                break;
                
            case TCRoundingMethodValue_Total:
            case TCRoundingMethodValue_TotalPerPerson:
            {
                resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
                double totalBeforeRounding = [self.subtotalWithSplit doubleValue] + resultTipValue;
                double totalAfterRounding = [self.totalPerPersonWithTax doubleValue];
                resultTipValue += totalAfterRounding - totalBeforeRounding;
            }
                break;
                
            default:
                resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
                break;
        }
    }
    else {
        resultTipValue = resultTipValue / [self.tipCalcData.split doubleValue];
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
        FNLOG(@"ori------");
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        FNLOG(@"%@", placemark.ISOcountryCode);// 1
        FNLOG(@"%@", placemark.country);
        FNLOG(@"%@", placemark.postalCode);
        FNLOG(@"%@", placemark.administrativeArea);//4
        FNLOG(@"%@", placemark.subAdministrativeArea);
        FNLOG(@"%@", placemark.locality);
        FNLOG(@"%@", placemark.subLocality);
        FNLOG(@"%@", placemark.thoroughfare);
        FNLOG(@"%@", placemark.subThoroughfare);
        FNLOG(@"--------");
        
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
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3TipCalcUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [A3UIDevice systemCurrencyCode];
	}
	return currencyCode;
}

- (A3NumberFormatter *)currencyFormatter {
	if (!_currencyFormatter) {
		_currencyFormatter = [A3NumberFormatter new];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[_currencyFormatter setCurrencyCode:self.currencyCode];
	}

	return _currencyFormatter;
}

@end
