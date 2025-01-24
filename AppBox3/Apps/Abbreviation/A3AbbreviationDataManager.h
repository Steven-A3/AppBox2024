//
//  A3AbbreviationDataManager.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/31/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3SharePopupViewController.h"
#import "A3DrillDownDataSourceProtocols.h"

@interface A3AbbreviationDataManager : NSObject <A3SharePopupViewDataSource, A3DrillDownDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray<NSDictionary *> *hashTagSections;
@property (nonatomic, strong) NSArray<NSDictionary *> *alphabetSections;
@property (nonatomic, strong) NSArray<NSDictionary *> *favoritesArray;
@property (nonatomic, strong) NSArray<UIColor *> *headStartColors;
@property (nonatomic, strong) NSArray<UIColor *> *alphabetBGColors;
@property (nonatomic, strong) NSArray<UIColor *> *bodyBGStartColors;
@property (nonatomic, strong) NSArray<UIColor *> *bodyBGEndColors;

+ (A3AbbreviationDataManager *)instance;
- (NSString *)stringForShare:(NSString *)titleString;
- (NSString *)subjectForActivityType:(NSString *)activityType;
- (NSString *)placeholderForShare:(NSString *)titleString;

@end

extern NSString *const A3AbbreviationKeyTag;
extern NSString *const A3AbbreviationKeyTags;

extern NSString *const A3AbbreviationKeyComponents;
extern NSString *const A3AbbreviationKeySectionTitle;

extern NSString *const A3AbbreviationKeyAbbreviation;
extern NSString *const A3AbbreviationKeyLetter;
extern NSString *const A3AbbreviationKeyMeaning;
