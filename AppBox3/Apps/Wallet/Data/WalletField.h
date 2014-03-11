//
//  WalletField.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletCategory, WalletFieldItem;

@interface WalletField : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) WalletCategory *category;
@property (nonatomic, retain) WalletFieldItem *fieldItem;

@end
