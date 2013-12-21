//
//  A3CacheStoreManager.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3CacheStoreManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

- (void)save;
- (float)rateForCurrencyCode:(NSString *)currency;

@end
