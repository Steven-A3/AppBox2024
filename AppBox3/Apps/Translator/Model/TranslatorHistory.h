//
//  TranslatorHistory.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TranslatorFavorite, TranslatorGroup;

@interface TranslatorHistory : NSManagedObject

@property (nonatomic, retain) NSString * originalText;
@property (nonatomic, retain) NSString * translatedText;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) TranslatorFavorite *favorite;
@property (nonatomic, retain) TranslatorGroup *group;

@end
