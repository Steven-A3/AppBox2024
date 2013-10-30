//
//  A3TableViewSections.h
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A3TableViewElement;
@protocol A3SelectTableViewControllerProtocol;

@interface A3TableViewSections : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIViewController <A3SelectTableViewControllerProtocol> *viewController;
@property (nonatomic, strong) NSArray *sectionsArray;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (A3TableViewElement *)elementForIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
