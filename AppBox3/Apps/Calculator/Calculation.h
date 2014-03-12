//
//  Calculation.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Calculation : NSManagedObject

@property (nonatomic, retain) NSString * expression;
@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSDate * date;

@end
