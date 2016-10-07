//
//  A3LoanCalcContentsTableViewController.h
//  AppBox3
//
//  Created by A3 on 5/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcMode.h"
#import "A3SearchViewController.h"

@class LoanCalcData;
@class A3LoanCalcLoanGraphCell;

@interface A3LoanCalcContentsTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) LoanCalcData *loanData;
@property (nonatomic, assign, getter=isTotalMode) BOOL totalMode;
@property (nonatomic, strong) NSIndexPath *currentIndexPath, *scrollToIndexPath;
@property (nonatomic, strong) NSMutableArray *extraPaymentItems;
@property (nonatomic, strong) UITextField *calculatorTargetTextField;
@property (nonatomic, strong) NSMutableArray *calcItems;
@property (nonatomic, assign) NSInteger dataSectionStartIndex;

- (void)infoButtonAction:(UIButton *)button;
- (void)totalButtonAction:(UIButton *)button;
- (void)monthlyButtonAction:(UIButton *)button;
- (NSUInteger)indexOfCalcItem:(A3LoanCalcCalculationItem)calcItem;
- (void)configureExtraPaymentYearlyCell:(UITableViewCell *)cell;
- (void)configureExtraPaymentOneTimeCell:(UITableViewCell *)cell;
- (void)displayLoanGraph;
- (void)displayGraphCell:(A3LoanCalcLoanGraphCell *)graphCell;
- (void)makeGraphCellClear:(A3LoanCalcLoanGraphCell *)graphCell;
- (NSString *)defaultCurrencyCode;

- (void)currencySelectButtonAction:(NSNotification *)notification;

- (void)changeDefaultCurrencyCode:(NSString *)currencyCode;

- (void)calculatorButtonAction;

- (void)calculatorDidDismissWithValue:(NSString *)value;
@end
