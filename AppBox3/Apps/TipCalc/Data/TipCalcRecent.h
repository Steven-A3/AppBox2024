//
//  TipCalcRecent.h
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TipCalcRecent : NSManagedObject

@property (nonatomic, retain) NSNumber * beforeSplit;
@property (nonatomic, retain) NSNumber * costs;
@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSString * historyID;
@property (nonatomic, retain) NSNumber * isMain;
@property (nonatomic, retain) NSNumber * isPercentTax;
@property (nonatomic, retain) NSNumber * isPercentTip;
@property (nonatomic, retain) NSNumber * knownValue;
@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSNumber * showRounding;
@property (nonatomic, retain) NSNumber * showSplit;
@property (nonatomic, retain) NSNumber * showTax;
@property (nonatomic, retain) NSNumber * split;
@property (nonatomic, retain) NSNumber * tax;
@property (nonatomic, retain) NSNumber * tip;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * valueType;

@end
