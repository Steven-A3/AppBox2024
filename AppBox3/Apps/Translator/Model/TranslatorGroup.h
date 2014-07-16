//
//  TranslatorGroup.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TranslatorHistory;

@interface TranslatorGroup : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * sourceLanguage;
@property (nonatomic, retain) NSString * targetLanguage;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *texts;
@end

@interface TranslatorGroup (CoreDataGeneratedAccessors)

- (void)addTextsObject:(TranslatorHistory *)value;
- (void)removeTextsObject:(TranslatorHistory *)value;
- (void)addTexts:(NSSet *)values;
- (void)removeTexts:(NSSet *)values;

@end
