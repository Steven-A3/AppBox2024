//
//  A3JHTableViewExpandableHeaderCell.h
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3TableViewExpandableHeaderCellProtocol <NSObject>
- (void)expandButtonPressed:(UIButton *)expandButton;
@end

@interface A3JHTableViewExpandableHeaderCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *expandButton;
@property (nonatomic, weak) id<A3TableViewExpandableHeaderCellProtocol> delegate;

@end
