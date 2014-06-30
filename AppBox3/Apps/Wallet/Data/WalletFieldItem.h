//
//  WalletFieldItem.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletField, WalletFieldItemImage, WalletFieldItemVideo, WalletItem;

@interface WalletFieldItem : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) WalletField *field;
@property (nonatomic, retain) WalletFieldItemImage *image;
@property (nonatomic, retain) WalletFieldItemVideo *video;
@property (nonatomic, retain) WalletItem *walletItem;

@end
