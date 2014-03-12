//
//  TipCalcRoundMethod.h
//  AppBox3
//
//  Created by A3 on 3/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TipCalcRecently;

@interface TipCalcRoundMethod : NSManagedObject

@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSNumber * tip;
@property (nonatomic, retain) NSNumber * tipPerPerson;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * totalPerPerson;
@property (nonatomic, retain) NSNumber * valueType;
@property (nonatomic, retain) TipCalcRecently *rRecently;

@end
