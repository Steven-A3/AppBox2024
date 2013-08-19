//
//  TranslatorHistory.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TranslatorHistory : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * originalLanguage;
@property (nonatomic, retain) NSString * originalText;
@property (nonatomic, retain) NSString * translatedLanguage;
@property (nonatomic, retain) NSString * translatedText;
@property (nonatomic, retain) NSString * languageGroup;

@end
