//
//  A3AppDataUtility.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 4/12/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3AppDataUtility : NSObject
<NSURLConnectionDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)init;
- (void)initializeMenu;

- (void)initCurrencyData;

- (void)makeCurrencyDataFile;


@end
