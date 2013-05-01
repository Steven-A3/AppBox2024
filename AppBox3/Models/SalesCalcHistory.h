//
//  SalesCalcHistory.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SalesCalcHistory : NSManagedObject

@property (nonatomic, retain) NSString * additionalOff;
@property (nonatomic, retain) NSString * amountSaved;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * discount;
@property (nonatomic, retain) NSNumber * isAdvanced;
@property (nonatomic, retain) NSNumber * isKnownValueOriginalPrice;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * originalPrice;
@property (nonatomic, retain) NSString * salePrice;
@property (nonatomic, retain) NSString * tax;
@property (nonatomic, retain) NSNumber * editing;

@end
