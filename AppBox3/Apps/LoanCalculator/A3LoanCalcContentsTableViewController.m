//
//  A3LoanCalcContentsTableViewController.m
//  AppBox3
//
//  Created by A3 on 5/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <tgmath.h>
#import "A3LoanCalcLoanGraphCell.h"
#import "LoanCalcData+Calculation.h"
#import "NSDateFormatter+A3Addition.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3LoanCalcLoanDetailViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "LoanCalcString.h"
#import "A3LoanCalcMonthlyDataViewController.h"
#import "A3NumberKeyboardViewController.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3LoanCalcContentsTableViewController () <A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate>
@end

@implementation A3LoanCalcContentsTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];

}

- (void)removeObserver {
	FNLOG();
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)dealloc
{
	[self removeObserver];
}

- (NSMutableArray *)extraPaymentItems
{
	if (!_extraPaymentItems) {
		_extraPaymentItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode extraPaymentTypes]];
	}

	return _extraPaymentItems;
}

- (void)infoButtonAction:(UIButton *)button
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName: IS_IPAD ? @"LoanCalculatorPadStoryBoard" : @"LoanCalculatorPhoneStoryBoard" bundle:nil];
	A3LoanCalcMonthlyDataViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"A3LoanCalcMonthlyDataViewController"];
	viewController.loanData = _loanData;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)totalButtonAction:(UIButton *)button
{
	if (!_totalMode) {
		_totalMode = YES;

		[self displayLoanGraph];
	}
}

- (void)monthlyButtonAction:(UIButton *)button
{
	if (_totalMode) {
		_totalMode = NO;

		[self displayLoanGraph];
	}
}

- (NSUInteger)indexOfCalcItem:(A3LoanCalcCalculationItem) calcItem
{
	for (NSNumber *itemNum in self.calcItems) {
		A3LoanCalcCalculationItem item = itemNum.integerValue;

		if (calcItem == item) {
			NSUInteger idx = [_calcItems indexOfObject:itemNum];
			return idx;
		}
	}

	return -1;
}

- (void)configureExtraPaymentYearlyCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [LoanCalcString titleOfExtraPayment:A3LC_ExtraPaymentYearly];
    NSString *currencyText;
    if (_loanData.extraPaymentYearly) {
        currencyText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentYearly];
    }
    else {
        currencyText = [self.loanFormatter stringFromNumber:@(0)];
    }
    NSString *dateText;
	NSDate *yearlyDate = _loanData.extraPaymentYearlyDate;
	if (!yearlyDate && [_loanData.extraPaymentYearly doubleValue] > 0) {
		yearlyDate = [NSDate date];
	}

    if (yearlyDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:yearlyDate];
        NSString *month = IS_IPHONE ? [[formatter shortMonthSymbols] objectAtIndex:dateComp.month - 1] : [[formatter monthSymbols] objectAtIndex:dateComp.month - 1];
        dateText = month;
    }
    else {
        dateText = NSLocalizedString(@"None", @"None");
    }

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
}

- (void)configureExtraPaymentOneTimeCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [LoanCalcString titleOfExtraPayment:A3LC_ExtraPaymentOnetime];
    NSString *currencyText = @"";
    if (_loanData.extraPaymentOneTime) {
        currencyText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentOneTime];
    }
    else {
        currencyText = [self.loanFormatter stringFromNumber:@(0)];
    }

    NSString *dateText;
	NSDate *oneTimeDate = _loanData.extraPaymentOneTimeDate;
	if (!oneTimeDate && [_loanData.extraPaymentOneTime doubleValue] > 0) {
		oneTimeDate = [NSDate date];
	}
    if (oneTimeDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:IS_IPHONE ? NSDateFormatterMediumStyle : NSDateFormatterLongStyle];
        NSString *format = [formatter formatStringByRemovingDayComponent:formatter.dateFormat];
		[formatter setDateFormat:format];
        dateText = [formatter stringFromDate:oneTimeDate];
    }
    else {
        dateText = NSLocalizedString(@"None", @"None");
    }

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
}

- (void)displayLoanGraph
{
    A3LoanCalcLoanGraphCell *graphCell = (A3LoanCalcLoanGraphCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([_loanData calculated]) {
        [self displayGraphCell:graphCell];
    }
    else {
        [self makeGraphCellClear:graphCell];
    }

    [graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] forState:UIControlStateNormal];
}

- (void)displayGraphCell:(A3LoanCalcLoanGraphCell *)graphCell
{
    graphCell.infoButton.hidden = NO;

    // red bar
    graphCell.redLineView.hidden = NO;

    // downLabel, info X위치 (아이폰/아이패드 모두 우측에서 50)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = 15.0 + graphCell.infoButton.bounds.size.width + 10.0;
        graphCell.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = graphCell.lowLabel.center;
        center.x = graphCell.bounds.size.width - fromRightDistance;
        graphCell.lowLabel.center = center;
        graphCell.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

        float fromRightDistance2 = 15.0;
        graphCell.infoButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center2 = graphCell.infoButton.center;
        center2.x = graphCell.bounds.size.width - fromRightDistance2;
        center2.y = (int)round(center.y);
        graphCell.infoButton.center = center2;
        graphCell.infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    });

    // 애니메이션 Start
    graphCell.upLabel.alpha = 0.0;
    graphCell.lowLabel.alpha = 0.0;

    float aniDuration = 0.3;
    [UIView beginAnimations:@"GraphUpdate" context:NULL];
    [UIView setAnimationDuration:aniDuration];

    float percentOfRedBar = 0;

    if (_totalMode) {
        float valueUp = [_loanData totalInterest].floatValue;
        float valueDown = [_loanData totalAmount].floatValue;
        percentOfRedBar = valueUp/valueDown;
    }
    else {
        float valueUp = [_loanData monthlyAverageInterest].floatValue;
        float valueDown = [_loanData repayment].floatValue;
        percentOfRedBar = valueUp/valueDown;
    }

    CGRect redRect = graphCell.redLineView.frame;
    redRect.size.width = self.view.bounds.size.width * percentOfRedBar;
    graphCell.redLineView.frame = redRect;

    // 애니메이션 End
    graphCell.upLabel.alpha = 1.0;
    graphCell.lowLabel.alpha = 1.0;

    [UIView commitAnimations];

    // text info
    NSString *interestText = _totalMode ? NSLocalizedString(@"Total Interest", nil) : NSLocalizedString(@"Avg.Interest", @"Avg.Interest");
    NSString *paymentText = _totalMode ? NSLocalizedString(@"Total Amount", @"Total Amount") : NSLocalizedString(@"Payment", @"Payment");
    
    NSNumber *interestNumber = _totalMode ? [_loanData totalInterest] : [_loanData monthlyAverageInterest];
    NSNumber *paymentNumber = _totalMode ? [_loanData totalAmount] : _loanData.repayment;
    NSString *interestValue = [self.loanFormatter stringFromNumber:interestNumber];
    NSString *paymentValue = [self.loanFormatter stringFromNumber:paymentNumber];

//    if (IS_IPHONE) {
//        if ([interestNumber doubleValue] > 0.0) {
//            interestValue = [interestValue stringByReplacingOccurrencesOfString:[self.loanFormatter currencySymbol] withString:@""];
//            interestValue = [interestValue stringByReplacingOccurrencesOfString:[self.loanFormatter currencyCode] withString:@""];
//        }
//        
//        if ([paymentNumber doubleValue] > 0.0) {
//            paymentValue = [paymentValue stringByReplacingOccurrencesOfString:[self.loanFormatter currencySymbol] withString:@""];
//            paymentValue = [paymentValue stringByReplacingOccurrencesOfString:[self.loanFormatter currencyCode] withString:@""];
//        }
//    }

    if (!_totalMode) {
        paymentValue = [NSString stringWithFormat:@"%@/%@", paymentValue, [LoanCalcString shortTitleOfFrequency:_loanData.frequencyIndex]];
    }

    NSDictionary *textAttributes1 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };

    NSDictionary *textAttributes2 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0],
                                      NSForegroundColorAttributeName:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                                      };

    NSDictionary *textAttributes3 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };

    NSDictionary *textAttributes4 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    NSDictionary *space1 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:25.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };

    NSDictionary *space2 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };

    NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:interestValue attributes:textAttributes1];
    NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:interestText attributes:textAttributes2];
    NSMutableAttributedString *upGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space1];
    [upAttrString appendAttributedString:upText1];
    [upAttrString appendAttributedString:upGap];
    [upAttrString appendAttributedString:upText2];
    graphCell.upLabel.attributedText = upAttrString;

    NSMutableAttributedString *downAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *downText1 = [[NSMutableAttributedString alloc] initWithString:paymentValue attributes:textAttributes3];
    NSMutableAttributedString *downText2 = [[NSMutableAttributedString alloc] initWithString:paymentText attributes:textAttributes4];
    NSMutableAttributedString *lowGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space2];
    [downAttrString appendAttributedString:downText1];
    [downAttrString appendAttributedString:lowGap];
    [downAttrString appendAttributedString:downText2];
    graphCell.lowLabel.attributedText = downAttrString;
}

- (void)makeGraphCellClear:(A3LoanCalcLoanGraphCell *)graphCell
{
    graphCell.redLineView.hidden = YES;
    graphCell.infoButton.hidden = YES;

    // downLabel X위치 (우측에서 15)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = 15.0;
        graphCell.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = graphCell.lowLabel.center;
        center.x = graphCell.bounds.size.width - fromRightDistance;
        graphCell.lowLabel.center = center;
        graphCell.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    });

    NSString *interestText = _totalMode ? NSLocalizedString(@"Total Interest", @"Interest") : (IS_IPAD ? NSLocalizedString(@"Average Interest", @"Average Interest") : NSLocalizedString(@"Avg.Interest", @"Avg.Interest"));
    NSString *paymentText = _totalMode ? NSLocalizedString(@"Total Amount", @"Total Amount") : NSLocalizedString(@"Payment", @"Payment");

    NSDictionary *textAttributes1 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };

    NSDictionary *textAttributes2 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0],
                                      NSForegroundColorAttributeName:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                                      };

    NSDictionary *textAttributes3 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };

    NSDictionary *textAttributes4 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    NSDictionary *space1 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:25.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };

    NSDictionary *space2 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };

    NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)] attributes:textAttributes1];
    NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:interestText attributes:textAttributes2];
    NSMutableAttributedString *upGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space1];
    [upAttrString appendAttributedString:upText1];
    [upAttrString appendAttributedString:upGap];
    [upAttrString appendAttributedString:upText2];
    graphCell.upLabel.attributedText = upAttrString;

    NSMutableAttributedString *downAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *downText1 = [[NSMutableAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)] attributes:textAttributes3];
    NSMutableAttributedString *downText2 = [[NSMutableAttributedString alloc] initWithString:paymentText attributes:textAttributes4];
    NSMutableAttributedString *lowGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space2];
    [downAttrString appendAttributedString:downText1];
    [downAttrString appendAttributedString:lowGap];
    [downAttrString appendAttributedString:downText2];
    graphCell.lowLabel.attributedText = downAttrString;
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
	FNLOG(@"%ld, %ld", (long)_currentIndexPath.section, (long)_dataSectionStartIndex);
	if (_currentIndexPath.section + _dataSectionStartIndex == 2) {
		// calculation item
		NSNumber *calcItemNum = _calcItems[_currentIndexPath.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;

		switch (calcItem) {
			case A3LC_CalculationItemDownPayment:
				_loanData.downPayment = @0;
				break;
			case A3LC_CalculationItemInterestRate:
				_loanData.showsInterestInYearly = @YES;
				_loanData.annualInterestRate = @0;
				break;
			case A3LC_CalculationItemPrincipal:
				_loanData.principal = @0;
				break;
			case A3LC_CalculationItemRepayment:
				_loanData.repayment = @0;
				break;
			case A3LC_CalculationItemTerm:
				_loanData.showsTermInMonths = @NO;
				_loanData.monthOfTerms = @0;
				break;
			default:
				break;
		}
	}
	else if (_currentIndexPath.section + _dataSectionStartIndex == 3) {
		// extra payment
		NSNumber *exPayItemNum = _extraPaymentItems[_currentIndexPath.row];
		A3LoanCalcExtraPaymentType exPayType = exPayItemNum.integerValue;

		if (exPayType == A3LC_ExtraPaymentMonthly) {
			_loanData.extraPaymentMonthly = @0;
		}
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {

	[self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}

#pragma mark --- Response to Calculator Button and result

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsCustomCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

#pragma mark - Number Keyboard Currency Select Button Notification

- (void)currencySelectButtonAction:(NSNotification *)notification {
	A3CurrencySelectViewController *viewController = [self presentCurrencySelectViewControllerWithCurrencyCode:notification.object];
	viewController.delegate = self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)currencyCode {
	[self changeDefaultCurrencyCode:currencyCode];

	[self.tableView reloadData];
}

- (void)changeDefaultCurrencyCode:(NSString *)currencyCode {
	if ([currencyCode length]) {
		[[A3SyncManager sharedSyncManager] setObject:currencyCode forKey:A3LoanCalcUserDefaultsCustomCurrencyCode state:A3KeyValueDBStateModified];

		[self.loanFormatter setCurrencyCode:currencyCode];
	}
}

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetTextField = (UITextField *) self.firstResponder;
	[self.firstResponder resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

#pragma mark --- Calculator View Delegate

- (UITextField *)previousTextField:(UITextField *) current
{
	// Virtual method, real implementation is in sub classes
	return nil;
}

- (UITextField *)nextTextField:(UITextField *) current
{
	// Virtual method, real implementation is in sub classes
	return nil;
}

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists{
	if ([self previousTextField:(UITextField *) self.firstResponder]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL)isNextEntryExists{
	if ([self nextTextField:(UITextField *) self.firstResponder]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)prevButtonPressed{
	if (self.firstResponder) {
		UITextField *prevTxtField = [self previousTextField:(UITextField *) self.firstResponder];
		if (prevTxtField) {
			[prevTxtField becomeFirstResponder];
		}
	}
}

- (void)nextButtonPressed{
	if (self.firstResponder) {
		UITextField *nextTxtField = [self nextTextField:(UITextField *) self.firstResponder];
		if (nextTxtField) {
			[nextTxtField becomeFirstResponder];
		}
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	// Virtual method, real implementation is in sub classes
}

@end
