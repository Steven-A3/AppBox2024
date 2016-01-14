//
//  A3LoanCalcComparisonHistoryCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcComparisonHistoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dateLb;
@property (strong, nonatomic) IBOutlet UILabel *infoA_Lb;
@property (strong, nonatomic) IBOutlet UILabel *infoB_Lb;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *markLbs;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;

@end
