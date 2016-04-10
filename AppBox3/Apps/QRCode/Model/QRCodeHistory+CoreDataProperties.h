//
//  QRCodeHistory+CoreDataProperties.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "QRCodeHistory.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeHistory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *created;
@property (nullable, nonatomic, retain) NSString *dimension;
@property (nullable, nonatomic, retain) NSString *scanData;
@property (nullable, nonatomic, retain) NSData *searchData;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *uniqueID;

@end

NS_ASSUME_NONNULL_END
