//
//  TipCalcRoundMethod.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TipCalcRecent;

@interface TipCalcRoundMethod : NSManagedObject

@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSNumber * valueType;
@property (nonatomic, retain) TipCalcRecent *recent;

@end
