//
//  WalletFieldItem.h
//  AppBox3
//
//  Created by A3 on 4/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletField, WalletItem;

@interface WalletFieldItem : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * hasVideo;
@property (nonatomic, retain) WalletField *field;
@property (nonatomic, retain) WalletItem *walletItem;

@end
