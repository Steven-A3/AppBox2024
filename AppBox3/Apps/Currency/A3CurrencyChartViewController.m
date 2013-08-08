//
//  A3CurrencyChartViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyChartViewController.h"
#import "A3CurrencyTVDataCell.h"
#import "CurrencyItem.h"
#import "NSManagedObject+MagicalFinders.h"
#import "common.h"
#import "UIImageView+AFNetworking.h"
#import "A3CurrencyViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3CurrencySelectViewController.h"
#import "CurrencyItem+name.h"

@interface A3CurrencyChartViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CurrencySelectViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UIView *valueView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIImageView *chartView;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, strong) CurrencyItem *sourceItem, *targetItem;
@property (nonatomic, weak) UITextField *sourceTextField, *targetTextField;

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

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];

	self.automaticallyAdjustsScrollViewInsets = NO;
	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    self.tableView.rowHeight = 84.0;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

	CGFloat width = CGRectGetWidth(self.titleView.bounds)/5.0;
	NSInteger idx = 0;
	CGRect frame = self.titleView.bounds;
	frame.size.width = width;
	_titleLabels = [[NSMutableArray alloc] initWithCapacity:5];
	_valueLabels = [[NSMutableArray alloc] initWithCapacity:5];
	for (;idx < 5; idx++) {
		frame.origin.x = width * idx;

		UILabel *label = [self labelWithFrame:frame];
		[_titleLabels addObject:label];
		[_titleView addSubview:label];

		UILabel *valueLabel = [self labelWithFrame:frame];
		[_valueLabels addObject:valueLabel];
		[_valueView addSubview:valueLabel];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)doneButtonPressed {
	[self.navigationController popViewControllerAnimated:YES];
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
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
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
	[self.chartView setImageWithURL:self.urlForChartImage];
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
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	if (indexPath.row == 0) {
		cell.valueField.text = @"1";
		cell.valueField.delegate = self;
		cell.valueField.textColor = self.tableView.tintColor;

		[nf setCurrencyCode:self.sourceItem.currencyCode];
		cell.rateLabel.text = [nf currencySymbol];
		cell.codeLabel.text = self.sourceItem.currencyCode;
		_sourceTextField = cell.valueField;
	} else {
		cell.valueField.text = self.targetValueString;
		cell.rateLabel.text = [NSString stringWithFormat:@"%@, Rate = %@", _targetItem.currencySymbol, [nf stringFromNumber:@(self.conversionRate)]];
		cell.codeLabel.text = _targetItem.currencyCode;
		_targetTextField = cell.valueField;
	}
	return cell;
}

- (float)targetValue {
	float sourceValue = _sourceTextField ? _sourceTextField.text.floatValue : 1.0;
	return sourceValue * self.conversionRate;
}

- (NSString *)targetValueString {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:self.targetItem.currencyCode];
	[nf setCurrencySymbol:@""];
	return [nf stringFromNumber:@(self.targetValue)];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	_selectionInSource = indexPath.row == 0;
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
	viewController.allowChooseFavorite = YES;
	[self.navigationController pushViewController:viewController animated:YES];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _sourceTextField) {
		A3NumberKeyboardViewController *keyboardVC = [self simpleNumberKeyboard];
		self.numberKeyboardViewController = keyboardVC;
		keyboardVC.keyInputDelegate = textField;
		keyboardVC.delegate = self;
		textField.inputView = [keyboardVC view];
		return YES;
	}
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.numberKeyboardViewController = nil;
}

- (void)textFieldDidChange:(id)textFieldDidChange {
	_targetTextField.text = self.targetValueString;
}

#pragma mark A3KeyboardViewControllerDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	if (keyInputDelegate == _sourceTextField) {
		_sourceTextField.text = @"";
		_targetTextField.text = self.targetValueString;
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	if (keyInputDelegate == _sourceTextField) {
		[_sourceTextField resignFirstResponder];
	}
}

#pragma makr - UISegmentedControl event handler

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)control {
	[self.chartView setImageWithURL:self.urlForChartImage];
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

@end
