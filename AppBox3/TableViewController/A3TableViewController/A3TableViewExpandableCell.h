//
//  A3TableViewExpandableCell.h
//  AppBox3
//
//  Created by A3 on 11/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewCell.h"

@protocol A3TableViewExpandableCellDelegate <NSObject>
- (void)expandButtonPressed:(UIButton *)expandButton;
@end

@interface A3TableViewExpandableCell : A3TableViewCell

@property (nonatomic, weak) id<A3TableViewExpandableCellDelegate> delegate;
@property (nonatomic, strong) UIButton *expandButton;

@end
