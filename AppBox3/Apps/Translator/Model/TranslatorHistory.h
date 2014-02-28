//
//  TranslatorHistory.h
//  AppBox3
//
//  Created by A3 on 2/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TranslatorFavorite, TranslatorGroup;

@interface TranslatorHistory : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * originalText;
@property (nonatomic, retain) NSString * translatedText;
@property (nonatomic, retain) TranslatorFavorite *favorite;
@property (nonatomic, retain) TranslatorGroup *group;

@end
