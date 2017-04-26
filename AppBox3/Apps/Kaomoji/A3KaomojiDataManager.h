//
//  A3KaomojiDataManager.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/4/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3SharePopupViewController.h"
#import "A3DrillDownDataSourceProtocols.h"

extern NSString *const A3KaomojiKeyCategory;
extern NSString *const A3KaomojiKeyContents;

@interface A3KaomojiDataManager : NSObject <A3SharePopupViewDataSource, A3DrillDownDataSource>

@property (nonatomic, strong) NSArray *contentsArray;
@property (nonatomic, strong) NSArray *categoryColors;
@property (nonatomic, strong) NSArray *titleColors;
@property (nonatomic, strong) NSArray<NSDictionary *> *favoritesArray;

+ (A3KaomojiDataManager *)instance;
- (NSString *)stringForShare:(NSString *)titleString;
- (NSString *)subjectForActivityType:(NSString *)activityType;
- (NSString *)placeholderForShare:(NSString *)titleString;

@end
