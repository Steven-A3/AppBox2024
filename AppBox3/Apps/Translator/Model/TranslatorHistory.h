//
//  TranslatorHistory.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TranslatorHistory : NSManagedObject

@property (nonatomic, retain) NSString * originalText;
@property (nonatomic, retain) NSString * translatedText;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * groupID;

@end
