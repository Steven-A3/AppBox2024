//
//  A3JHTableViewRootElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewElement.h"

@protocol A3SelectTableViewControllerProtocol;

@interface A3JHTableViewRootElement : A3JHTableViewElement

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIViewController <A3SelectTableViewControllerProtocol> *viewController;
@property (nonatomic, strong) NSArray *sectionsArray;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (A3JHTableViewElement *)elementForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForElement:(A3JHTableViewElement *)element; // KJH
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
