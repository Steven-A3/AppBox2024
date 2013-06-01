//
//  A3LoanCalcQuickDialogViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog.h>
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3FrequencyKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3QuickDialogContainerController.h"
#import "LoanCalcHistory+calculation.h"
#import "A3LoanCalcPieChartViewController.h"
#import "A3LoanCalcChartViewController_iPhone.h"
#import "A3LoanCalcPreferences.h"
#import "A3HistoryViewController.h"

@interface A3LoanCalcQuickDialogViewController : A3QuickDialogContainerController <QuickDialogEntryElementDelegate, QuickDialogStyleProvider, A3KeyboardDelegate, A3FrequencyKeyboardDelegate, A3DateKeyboardDelegate, UITextFieldDelegate, A3QuickDialogCellStyleDelegate, A3HistoryViewControllerDelegate>

@property (nonatomic, strong)	A3LoanCalcPreferences *preferences;

@property (nonatomic, strong) 	UIViewController *tableHeaderViewController;

@property (nonatomic, strong)	A3LoanCalcPieChartController *chartController;

@property (nonatomic, strong)	LoanCalcHistory *editingObject;

- (UIView *)tableHeaderView;

- (void)reloadContents;
- (QElement *)calculationForElement;

- (void)reloadGraphView;

- (NSString *)valueForCalculationForField;

- (void)onSelectCalculationFor;
@end
