//
//  TipCalcHistory.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TipCalcRecently;

@interface TipCalcHistory : NSManagedObject

@property (nonatomic, retain) NSString * labelTip;
@property (nonatomic, retain) NSString * labelTotal;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) TipCalcRecently *rRecently;

@end
