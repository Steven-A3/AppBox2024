//
//  A3TableViewCell.h
//  AppBox3
//
//  Created by A3 on 11/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3TableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *customTopSeparator;
@property (nonatomic, strong) UIView *customSeparator;
@property (assign) CGFloat leftSeparatorInset; // KJH, separatorInset 이 특수한 경우를 위하여 추가하였습니다.

- (void)showTopSeparator;

- (void)setBottomSeparatorForBottomRow;

- (void)setBottomSeparatorForMiddleRow;

- (void)setBottomSeparatorForExpandableBottom;
@end
