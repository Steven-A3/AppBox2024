//
//  A3SalesCalcHistoryTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3CalcExpressionView;

@interface A3SalesCalcHistoryTableViewCell : UITableViewCell

@property (nonatomic, strong)	UILabel *dateLabel, *salePriceLabel, *notesLabel;
@property (nonatomic, strong)	A3CalcExpressionView *expressionView;

@end
