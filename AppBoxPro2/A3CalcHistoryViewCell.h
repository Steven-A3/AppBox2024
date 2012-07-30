//
//  A3CalcHistoryViewCell.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/28/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CalcExpressionView.h"

@interface A3CalcHistoryContentsView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet A3CalcExpressionView *expressionView;

@end

@interface A3CalcHistoryViewCell : UITableViewCell

@property (strong, nonatomic) A3CalcHistoryContentsView *contentsView1, *contentsView2;

@end

