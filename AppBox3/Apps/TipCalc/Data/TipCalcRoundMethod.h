//
//  TipCalcRoundMethod.h
//  AppBox3
//
//  Created by dotnetguy83 on 5/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TipCalcRecently;

@interface TipCalcRoundMethod : NSManagedObject

@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSNumber * valueType;
@property (nonatomic, retain) TipCalcRecently *rRecently;

@end
