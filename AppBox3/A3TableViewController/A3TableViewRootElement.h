//
//  A3TableViewRootElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"

@protocol A3SelectTableViewControllerProtocol;

@interface A3TableViewRootElement : A3TableViewElement

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
