//
//  WalletField.h
//  AppBox3
//
//  Created by A3 on 8/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WalletField : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * order;

@end
