//
//  A3TableViewCell.h
//  AppBox3
//
//  Created by A3 on 11/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A3TableViewCell_TextView_Tag 1  // KJH

@interface A3TableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *customTopSeparator;
@property (nonatomic, strong) UIView *customSeparator;

- (void)resetCellLayout;
- (void)showTopSeparator;
- (void)setBottomSeparatorForBottomRow;
- (void)setBottomSeparatorForMiddleRow;
- (void)setBottomSeparatorForExpandableBottom;

@end
