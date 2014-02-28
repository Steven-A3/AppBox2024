//
//  TranslatorFavorite.h
//  AppBox3
//
//  Created by A3 on 2/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TranslatorHistory;

@interface TranslatorFavorite : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) TranslatorHistory *text;

@end
