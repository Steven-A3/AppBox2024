//
//  A3JHTableViewSections.h
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A3JHTableViewElement;
@protocol A3JHSelectTableViewControllerProtocol;

@interface A3JHTableViewSections : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIViewController <A3JHSelectTableViewControllerProtocol> *viewController;
@property (nonatomic, strong) NSArray *sectionsArray;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (A3JHTableViewElement *)elementForIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
