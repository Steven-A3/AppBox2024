//
//  A3LoanCalcHistoryCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoanCalcHistory;

@interface A3LoanCalcHistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *notes;
@property (nonatomic, weak) IBOutlet UILabel *condition;
@property (nonatomic, weak) IBOutlet UILabel *monthlyPayment;

- (void)setObject:(LoanCalcHistory *)object;

@end

