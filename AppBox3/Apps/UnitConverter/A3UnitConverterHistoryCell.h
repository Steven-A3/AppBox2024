//
//  A3UnitConverterHistoryCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3UnitConverterHistoryCell : UITableViewCell

- (UILabel *)addUILabelWithColor:(UIColor *)color;
- (void)addConstraintLeft:(UILabel *)left right:(UILabel *)right centerY:(CGFloat)centerY;

@end
