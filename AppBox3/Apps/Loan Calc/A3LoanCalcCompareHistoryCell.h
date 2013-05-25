//
//  A3LoanCalcCompareHistoryCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcCompareHistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *leftAmount;
@property (nonatomic, weak) IBOutlet UILabel *leftCondition;
@property (nonatomic, weak) IBOutlet UILabel *leftMonthlyPayment;
@property (nonatomic, weak) IBOutlet UILabel *rightAmount;
@property (nonatomic, weak) IBOutlet UILabel *rightCondition;
@property (nonatomic, weak) IBOutlet UILabel *rightMonthlyPayment;

@end
