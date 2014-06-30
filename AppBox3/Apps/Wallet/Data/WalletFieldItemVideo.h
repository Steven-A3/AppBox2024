//
//  WalletFieldItemVideo.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletFieldItem;

@interface WalletFieldItemVideo : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * extension;
@property (nonatomic, retain) WalletFieldItem *fieldItem;

@end
