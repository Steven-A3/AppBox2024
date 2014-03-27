//
//  A3JHTableViewCell.h
//  AppBox3
//
//  Created by A3 on 11/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A3TableViewCell_TextView_Tag 1  // KJH

@interface A3JHTableViewCell : UITableViewCell
@property (assign) CGFloat leftSeparatorInset; // KJH, separatorInset 이 특수한 경우를 위하여 추가하였습니다.
@end
