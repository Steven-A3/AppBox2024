//
//  TranslatorGroup.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
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
@property (nonatomic, retain) NSOrderedSet *texts;
@end

@interface TranslatorGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(TranslatorHistory *)value inTextsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTextsAtIndex:(NSUInteger)idx;
- (void)insertTexts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTextsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTextsAtIndex:(NSUInteger)idx withObject:(TranslatorHistory *)value;
- (void)replaceTextsAtIndexes:(NSIndexSet *)indexes withTexts:(NSArray *)values;
- (void)addTextsObject:(TranslatorHistory *)value;
- (void)removeTextsObject:(TranslatorHistory *)value;
- (void)addTexts:(NSOrderedSet *)values;
- (void)removeTexts:(NSOrderedSet *)values;
@end
