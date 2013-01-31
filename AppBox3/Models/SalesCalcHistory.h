//
//  SalesCalcHistory.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SalesCalcHistory : NSManagedObject

@property (nonatomic, retain) NSString * additionaloff;
@property (nonatomic) NSTimeInterval createdDate;
@property (nonatomic, retain) NSString * discount;
@property (nonatomic) BOOL isAdvanced;
@property (nonatomic) BOOL isOriginalPrice;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * salePrice;
@property (nonatomic, retain) NSString * tax;
@property (nonatomic, retain) NSString * originalPrice;
@property (nonatomic, retain) NSString * amountSaved;

@end
