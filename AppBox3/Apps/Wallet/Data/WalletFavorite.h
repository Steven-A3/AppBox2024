//
//  WalletFavorite.h
//  AppBox3
//
//  Created by A3 on 5/31/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletItem;

@interface WalletFavorite : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) WalletItem *item;

@end
