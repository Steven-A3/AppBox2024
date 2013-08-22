//
//  A3CurrencyChartViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3CurrencyChartViewController.h"
#import "A3CurrencyTVDataCell.h"
#import "CurrencyItem.h"
#import "NSManagedObject+MagicalFinders.h"
#import "common.h"
#import "UIImageView+AFNetworking.h"
#import "A3CurrencyViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3NumberKeyboardViewController.h"
#import "A3CurrencySelectViewController.h"
#import "CurrencyItem+name.h"
#import "A3UIDevice.h"
#import "NSString+conversion.h"
#import "NSNumberExtensions.h"
#import "UIViewController+navigation.h"

@interface A3CurrencyChartViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CurrencySelectViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UIView *valueView;
@property (nonatomic, weak) IBOutlet UIView *line2;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIImageView *chartView;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, strong) CurrencyItem *sourceItem, *targetItem;
@property (nonatomic, weak) UITextField *sourceTextField, *targetTextField;
@property (nonatomic, strong) UIImageView *landscapeChartView;
@property (nonatomic, strong) UIScrollView *landscapeView;
@property (nonatomic, strong) NSNumber *sourceValue;

@end

@implementation A3CurrencyChartViewController {
	BOOL _selectionInSource;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	_sourceValue = _initialValue ? _initialValue : @(1.0);

	[self makeBackButtonEmptyArrow];

	self.automaticallyAdjustsScrollViewInsets = NO;
	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    self.tableView.rowHeight = [[UIScreen mainScreen] bounds].size.height == 480.0 ? 70.0 : 84.0;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

	[self setupConstraints];

	NSInteger idx = 0;
	_titleLabels = [[NSMutableArray alloc] initWithCapacity:5];
	_valueLabels = [[NSMutableArray alloc] initWithCapacity:5];
	for (;idx < 5; idx++) {
		UILabel *label = [self labelWithFrame:CGRectZero];
		[_titleLabels addObject:label];
		[_titleView addSubview:label];

		UILabel *valueLabel = [self labelWithFrame:CGRectZero];
		[_valueLabels addObject:valueLabel];
		[_valueView addSubview:valueLabel];
	}
	[self setupFont];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)viewWillLayoutSubviews {
	[self setupConstraints];
}


- (void)viewDidLayoutSubviews{
	CGFloat width = CGRectGetWidth(self.titleView.bounds)/5.0;
	NSInteger idx = 0;
	CGRect frame = self.titleView.bounds;
	frame.size.width = width;
	for (;idx < 5; idx++) {
		frame.origin.x = width * idx;

		UILabel *label = _titleLabels[idx];
		label.frame = frame;

		UILabel *valueLabel = _valueLabels[idx];
		valueLabel.frame = frame;
	}
}

- (void)setupConstraints {
	[self.view removeConstraints:[self.view constraints]];

	FNLOGRECT([[UIScreen mainScreen] bounds]);
	FNLOGRECT(self.view.frame);
	FNLOGRECT(self.view.bounds);
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

	NSNumber *tableViewHeight;
	NSNumber *titleViewHeight;
	NSNumber *space1;
	NSNumber *space2;
	NSNumber *space3;
	NSNumber *space4;
	NSNumber *chartHeight;
	NSNumber *chartWidth;
	NSNumber *segmentedControlWidth;

	if (IS_IPHONE) {
		if (screenBounds.size.height == 480.0) {
			tableViewHeight = @140.0;
			titleViewHeight = @22.0;
			space1 = @10.0;
			space2 = @10.0;
			space3 = @14.0;
			space4 = @14.0;
			chartHeight = @154.0;
			chartWidth = @263.0;
		} else {
			tableViewHeight = @168.0;
			titleViewHeight = @30.0;
			space1 = @17.0;
			space2 = @17.0;
			space3 = @18.0;
			space4 = @19.0;
			chartHeight = @175.0;
			chartWidth = @300.0;
		}
		segmentedControlWidth = @300.0;
	} else {
		tableViewHeight = @168.0;
		titleViewHeight = @30.0;

		if (IS_LANDSCAPE) {
			segmentedControlWidth = @555.0;
			chartWidth = @555.0;
			chartHeight = @312.0;
			space1 = @33.0;
			space2 = @33.0;
			space3 = @34.0;
			space4 = @34.0;
		} else {
			segmentedControlWidth = @605.0;
			chartWidth = @605.0;
			chartHeight = @340.0;
			space1 = @50.0;
			space2 = @50.0;
			space3 = @20.0;
			space4 = @242.0;
		}
	}

	[self constraintForHorizontalLayout:_tableView];
	[self constraintForHorizontalLayout:_line1];
	[self constraintForHorizontalLayout:_titleView];
	[self constraintForHorizontalLayout:_valueView];
	[self constraintForHorizontalLayout:_valueView];
	[self constraintForHorizontalLayout:_line2];
	[self constraintForHorizontalLayout:_segmentedControl width:segmentedControlWidth.cgFloatValue];
	[self constraintForHorizontalLayout:_chartView width:chartWidth.cgFloatValue];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[_tableView(tableViewHeight)]-space1-[_line1(1)][_titleView(titleViewHeight)][_valueView(titleViewHeight)][_line2(1)]-space2-[_segmentedControl(28)]-space3-[_chartView(chartHeight)]-space4-|"
																	  options:0
																	  metrics:NSDictionaryOfVariableBindings(tableViewHeight, titleViewHeight, space1, space2, space3, space4, chartHeight)
																		views:NSDictionaryOfVariableBindings(_tableView, _line1, _titleView, _valueView, _line2, _segmentedControl, _chartView)]];
}

- (void)constraintForHorizontalLayout:(UIView *)view {
	view.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
														  attribute:NSLayoutAttributeWidth
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeWidth
														 multiplier:1.0 constant:0.0]];
}

- (void)constraintForHorizontalLayout:(UIView *)view width:(CGFloat)width {
	view.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
														  attribute:NSLayoutAttributeWidth
														  relatedBy:NSLayoutRelationEqual
															 toItem:nil
														  attribute:NSLayoutAttributeNotAnAttribute
														 multiplier:0.0 constant:width]];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
	[self setupFont];
}

- (void)setupFont {
	[_titleLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	}];
	[_valueLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)labelWithFrame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumScaleFactor = 0.5;
	return label;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	FNLOG();

	[self updateDisplay];
}

- (void)updateDisplay {
	self.title = [NSString stringWithFormat:@"%@ to %@", self.sourceItem.currencyCode, self.targetItem.currencyCode];

	[self fillCurrencyTable];
	self.segmentedControl.selectedSegmentIndex = 0;
	[self.chartView setImageWithURL:IS_IPHONE ? self.urlForChartImage : self.urlForBigChartImage];
}

#pragma mark - CurrencyItem
- (CurrencyItem *)sourceItem {
	if (!_sourceItem) {
		NSArray *fetchedResult = [CurrencyItem MR_findByAttribute:A3KeyCurrencyCode withValue:_sourceCurrencyCode];
		NSAssert([fetchedResult count], @"%s, %s, CurrencyItem is empty or source currency code is not valid.", __FUNCTION__, __PRETTY_FUNCTION__);
		_sourceItem = fetchedResult[0];
	}
	return _sourceItem;
}

- (CurrencyItem *)targetItem {
	if (!_targetItem) {
		NSArray *fetchedResult = [CurrencyItem MR_findByAttribute:A3KeyCurrencyCode withValue:_targetCurrencyCode];
		NSAssert([fetchedResult count], @"%s, CurrencyItem is empty or target currency code is not valid.", __PRETTY_FUNCTION__);
        _targetItem = fetchedResult[0];
	}
	return _targetItem;
}

- (float)conversionRate {
	return self.targetItem.rateToUSD.floatValue / self.sourceItem.rateToUSD.floatValue;
}

#pragma mark - UITableViewDataSourceDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3CurrencyTVDataCell *cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyDataCellID forIndexPath:indexPath];
	if (!cell) {
		cell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyDataCellID];
	}
	if (indexPath.row == 0) {
		cell.valueField.delegate = self;
		cell.valueField.textColor = self.tableView.tintColor;

		cell.rateLabel.text = @"";
		cell.codeLabel.text = self.sourceItem.currencyCode;
		_sourceTextField = cell.valueField;

		NSNumberFormatter *nf = [self currencyFormatterWithCurrencyCode:self.sourceItem.currencyCode];
		cell.valueField.text = [nf stringFromNumber:_sourceValue];
	} else {
		cell.valueField.delegate = self;
		cell.valueField.text = self.targetValueString;
		cell.rateLabel.text = [NSString stringWithFormat:@"%@, Rate = %0.4f", _targetItem.currencySymbol, self.conversionRate];
		cell.codeLabel.text = _targetItem.currencyCode;
		_targetTextField = cell.valueField;
	}
	return cell;
}

- (float)targetValue {
	_sourceValue = @(_sourceTextField ? [_sourceTextField.text floatValueEx] : 1.0);
	return _sourceValue.floatValue * self.conversionRate;
}

- (NSString *)targetValueString {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:self.targetItem.currencyCode];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return [nf stringFromNumber:@(self.targetValue)];
}

- (float)sourceValueConvertedFromTarget {
	return [_targetTextField.text floatValueEx] / self.conversionRate;
}

- (NSString *)sourceValueString {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:self.sourceItem.currencyCode];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return [nf stringFromNumber:@(self.sourceValueConvertedFromTarget)];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_selectionInSource = indexPath.row == 0;
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
	viewController.allowChooseFavorite = YES;
	[self presentSubViewController:viewController];
}

- (void)currencySelected:(NSString *)selectedCurrencyCode {
	if (_selectionInSource) {
		self.sourceCurrencyCode = selectedCurrencyCode;
		_sourceItem = nil;
	} else {
		self.targetCurrencyCode = selectedCurrencyCode;
		_targetItem = nil;
	}
	[self.tableView reloadData];
	[self updateDisplay];
}

- (void)willDismissCurrencySelectView {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	A3NumberKeyboardViewController *keyboardVC = [self simpleNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.keyInputDelegate = textField;
	keyboardVC.delegate = self;
	textField.inputView = [keyboardVC view];
	textField.text = @"";
	if (textField == _sourceTextField) {
		_targetTextField.text = [self targetValueString];
	} else {
		_sourceTextField.text = [self sourceValueString];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (NSNumberFormatter *)currencyFormatterWithCurrencyCode:(NSString *)code {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:code];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return nf;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	self.numberKeyboardViewController = nil;

    FNLOG(@"%@, %@", textField.text, textField);
    if (![textField.text length])
        return;
    
	float value = [textField.text floatValue];
	if (value < 1.0) {
		value = 1.0;
	}
    
	NSNumberFormatter *nf;
	if (textField == _sourceTextField) {
		_sourceValue = @(value);
		nf = [self currencyFormatterWithCurrencyCode:_sourceItem.currencyCode];
        if (value > 0.0) {
            [self notifyDelegateValueChangedWithValue:_sourceValue];
        }
	} else if (textField == _targetTextField) {
		nf = [self currencyFormatterWithCurrencyCode:_targetItem.currencyCode];
        if (value > 0.0) {
            [self notifyDelegateValueChangedWithValue:@(self.sourceValueConvertedFromTarget)];
        }
	}
	textField.text = [nf stringFromNumber:@(value)];
}

- (void)notifyDelegateValueChangedWithValue:(NSNumber *)newNumber {
	if ([_delegate respondsToSelector:@selector(chartViewControllerValueChanged:)]) {
		if (![_initialValue isEqualToNumber:newNumber]) {
			[_delegate chartViewControllerValueChanged:newNumber];
			_initialValue = newNumber;		// Update _initialValue too.
		}
	}
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = notification.object;
	if (textField == _sourceTextField) {
		_targetTextField.text = self.targetValueString;
	} else {
		_sourceTextField.text = self.sourceValueString;
	}
}

#pragma mark A3KeyboardViewControllerDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	if (keyInputDelegate == _sourceTextField) {
		_sourceTextField.text = @"";
		_targetTextField.text = self.targetValueString;
	} else {
		_targetTextField.text = @"";
		_sourceTextField.text = self.sourceValueString;
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[keyInputDelegate resignFirstResponder];
}

#pragma makr - UISegmentedControl event handler

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)control {
	[self.chartView setImageWithURL:IS_IPHONE ? self.urlForChartImage : self.urlForBigChartImage];
}

#pragma mark - currency table handler

- (void)fillCurrencyTable {
	float rate = self.conversionRate;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:self.sourceItem.currencyCode];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSArray *titles = @[@5, @10, @25, @50, @100];
	NSInteger index = 0;
	for (UILabel *titleLabel in _titleLabels) {
		titleLabel.text = [nf stringFromNumber:titles[index]];
		index++;
	}
	[nf setCurrencyCode:_targetItem.currencyCode];
	index = 0;
	for (UILabel *valueLabel in _valueLabels) {
		valueLabel.text = [nf stringFromNumber:@([titles[index] floatValue] * rate)];
		index++;
	}
}

#pragma makr - UIImageView Yahoo Chart

- (NSURL *)urlForChartImage {
	NSArray *types = @[@"1d", @"5d", @"1m", @"5m", @"1y"];
	NSString *string = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@%@=x&t=%@&z=m&region=%@&lang=%@",
			self.sourceItem.currencyCode, self.targetItem.currencyCode,
			types[(NSUInteger) self.segmentedControl.selectedSegmentIndex],
			[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode],
			[[NSLocale preferredLanguages] objectAtIndex:0] ];

	FNLOG(@"%@", string);

	return [NSURL URLWithString:string];
}

- (NSURL *)urlForBigChartImage {
	NSArray *types = @[@"1d", @"5d", @"1m", @"5m", @"1y"];
	NSString *string = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@%@=x&t=%@&z=l&region=%@&lang=%@",
												  self.sourceItem.currencyCode, self.targetItem.currencyCode,
												  types[(NSUInteger) self.segmentedControl.selectedSegmentIndex],
												  [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode],
												  [[NSLocale preferredLanguages] objectAtIndex:0] ];

	FNLOG(@"%@", string);

	return [NSURL URLWithString:string];
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIImageView *)landscapeChartView {
	if (!_landscapeChartView) {
		_landscapeChartView = [[UIImageView alloc] init];
		[_landscapeChartView setImageWithURL:self.urlForBigChartImage];
	}
	return _landscapeChartView;
}

- (UIScrollView *)landscapeView {
	if (!_landscapeView) {
		_landscapeView = [[UIScrollView alloc] initWithFrame:CGRectZero];
		_landscapeView.backgroundColor = [UIColor whiteColor];
	}
	return _landscapeView;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPAD) {
		return;
	}

	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		if (!_landscapeView) {
			[[UIApplication sharedApplication] setStatusBarHidden:YES];
			[self.navigationController setNavigationBarHidden:YES animated:YES];
			CGRect frame = [[UIScreen mainScreen] bounds];
			CGFloat width = frame.size.width;
			frame.size.width = frame.size.height;
			frame.size.height = width;

			self.landscapeView.frame = frame;
			_landscapeView.contentSize = frame.size;
			frame = CGRectInset(frame, 20.0, 20.0);
			self.landscapeChartView.frame = frame;
			[_landscapeView addSubview:_landscapeChartView];
			[self.view addSubview:self.landscapeView];
		}
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[_landscapeChartView removeFromSuperview];
		[_landscapeView removeFromSuperview];
		_landscapeChartView = nil;
		_landscapeView = nil;
	}
}

@end
