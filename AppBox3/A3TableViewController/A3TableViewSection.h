//
//  A3TableViewSection
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/22/13 3:37 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3TableViewSection : NSObject

@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, strong) NSMutableArray *elementsMatchingTableView;

- (NSInteger)numberOfRows;
- (void)toggleExpandableElementAtIndexPath:(NSIndexPath *)indexPath;

@end
