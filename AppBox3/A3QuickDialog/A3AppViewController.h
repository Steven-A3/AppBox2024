//
//  A3AppViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 9:06 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3AppViewController : UIViewController

- (UIFont *)fontForCellLabel;
- (UIFont *)fontForEntryCellLabel;
- (UIFont *)fontForEntryCellTextField;
- (UIColor *)tableViewBackgroundColor;
- (UIColor *)cellBackgroundColor;
- (UIColor *)colorForCellLabelNormal;
- (UIColor *)colorForCellLabelSelected;
- (UIColor *)colorForCellButton;
- (UIColor *)colorForEntryCellTextField;
- (CGFloat)heightForElement:(QElement *)element;

@end
