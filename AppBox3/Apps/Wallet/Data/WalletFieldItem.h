//
//  WalletFieldItem.h
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WalletFieldItem : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * fieldID;
@property (nonatomic, retain) NSNumber * hasImage;
@property (nonatomic, retain) NSNumber * hasVideo;
@property (nonatomic, retain) NSData * imageMetaData;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSDate * videoCreationDate;
@property (nonatomic, retain) NSString * videoExtension;
@property (nonatomic, retain) NSString * walletItemID;

@end
