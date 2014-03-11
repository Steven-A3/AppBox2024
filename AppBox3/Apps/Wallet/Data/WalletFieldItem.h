//
//  WalletFieldItem.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletField, WalletItem;

@interface WalletFieldItem : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) WalletField *field;
@property (nonatomic, retain) WalletItem *walletItem;

@end
