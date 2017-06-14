//
//  A3CurrencyChartViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyChartViewController.h"
#import "A3CurrencyTVDataCell.h"
#import "A3CurrencyTableViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3NumberKeyboardViewController.h"
#import "A3CurrencySelectViewController.h"
#import "NSString+conversion.h"
#import "UIView+Screenshot.h"
#import "Reachability.h"
#import "UIViewController+A3Addition.h"
#import "A3CurrencyDataManager.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3CalculatorViewController.h"
#import "A3YahooCurrency.h"

@interface A3CurrencyChartViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
		A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate, A3ViewControllerProtocol,
        UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UIView *valueView;
@property (nonatomic, weak) IBOutlet UIView *line2;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, weak) IBOutlet UIWebView *chartWebView;
@property (nonatomic, weak) IBOutlet UIView *webViewCoverView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSTimer *activityIndicatorRemoveTimer;

@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, weak) UITextField *sourceTextField, *targetTextField;
@property (nonatomic, strong) UIWebView *landscapeChartWebView;
@property (nonatomic, strong) UIScrollView *landscapeView;
@property (nonatomic, strong) NSNumber *sourceValue;
@property (nonatomic, copy) NSString *previousValue;
@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, copy) NSString *sourceCurrencyCode, *targetCurrencyCode;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, strong) NSNumberFormatter *decimalNumberFormatter;

@end

@implementation A3CurrencyChartViewController {
	BOOL			_selectionInSource;
	BOOL			_isNumberKeyboardVisible;
	BOOL			_didPressClearKey;
	BOOL			_didPressNumberKey;
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

	[self makeFixedConstraint];

	self.automaticallyAdjustsScrollViewInsets = NO;
	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    self.tableView.rowHeight = IS_IPHONE35 ? 70.0 : 84.0;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
	self.tableView.separatorColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
	self.tableView.showsVerticalScrollIndicator = NO;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

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

	if (IS_IPAD && [[NSLocale preferredLanguages][0] hasPrefix:@"it"]) {
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), 1] forSegmentAtIndex:0];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:1];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 3] forSegmentAtIndex:2];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), 1] forSegmentAtIndex:3];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), 5] forSegmentAtIndex:4];
	} else
	if (IS_IPHONE35) {
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:2];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 5] forSegmentAtIndex:3];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    UITapGestureRecognizer *chartTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnWebView)];
    [_webViewCoverView addGestureRecognizer:chartTapRecognizer];
}

- (void)didTapOnWebView {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://tradingview.go2cloud.org/aff_c?offer_id=2&aff_id=4413"]];
}

- (void)applicationDidEnterBackground {
	[self dismissNumberKeyboard];
}

- (void)setOriginalSourceCode:(NSString *)originalSourceCode {
	_originalSourceCode = [originalSourceCode mutableCopy];
	_sourceCurrencyCode = originalSourceCode;
}

- (void)setOriginalTargetCode:(NSString *)originalTargetCode {
	_originalTargetCode = [originalTargetCode mutableCopy];
	_targetCurrencyCode = originalTargetCode;
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
    [self updateDisplay];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
	[self notifyDelegateValueChanged];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)notifyDelegateValueChanged {
	NSNumber *number = @([_sourceTextField.text floatValueEx]);
	if ([number isEqualToNumber:self.initialValue] && [_originalSourceCode isEqualToString:_sourceCurrencyCode]  && [_originalTargetCode isEqualToString:_targetCurrencyCode]) {
		// Nothing changed
		return;
	}
	if ([_delegate respondsToSelector:@selector(chartViewControllerValueChangedChartViewController:valueChanged:)]) {
		[_delegate chartViewControllerValueChangedChartViewController:self valueChanged:number];
	}
}

- (void)viewWillLayoutSubviews {
	[self makeConstraints];
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

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
	[self setupFont];
}

- (void)makeFixedConstraint {
	BOOL isIPHONE35 = IS_IPHONE35;

	UIView *superview = _tableView.superview;
	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(superview.top).with.offset(64);
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.height.equalTo(isIPHONE35 ? @140 : @168 );
	}];
	[_line1 makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.height.equalTo(@0.5);
	}];
	[_titleView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_line1.bottom);
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.height.equalTo(isIPHONE35 ? @22 : @30);
	}];
	[_valueView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_titleView.bottom);
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.height.equalTo(isIPHONE35 ? @22 : @30);
	}];
	[_line2 makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_valueView.bottom);
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.height.equalTo(@0.5);
	}];
	[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.height.equalTo(@28);
	}];
	[_chartWebView makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
	}];
}

- (void)makeConstraints {
	if (!_constraints) {
		_constraints = [NSMutableArray new];
	} else {
		for (MASConstraint *constraint in _constraints) {
			[constraint uninstall];
		}
	}
	BOOL isIPHONE35 = IS_IPHONE35, isIPHONE = IS_IPHONE, isPORTRAIT = IS_PORTRAIT;
	[_line1 makeConstraints:^(MASConstraintMaker *make) {
		[_constraints addObject:make.top.equalTo(_tableView.bottom).with.offset(isIPHONE ? (isIPHONE35 ? 10 : 17) : (isPORTRAIT ? 50 : 33))];
	}];

	[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		[_constraints addObject:make.top.equalTo(_line2.bottom).with.offset(isIPHONE ? (isIPHONE35 ? 10 : 17) : (isPORTRAIT ? 50 : 40))];
		[_constraints addObject:make.width.equalTo(self.view.width).with.offset(-40)];
	}];
	[_chartWebView makeConstraints:^(MASConstraintMaker *make) {
        CGFloat verticalMargin = isIPHONE ? (isIPHONE35 ? 14 : 18) : (isPORTRAIT ? 20 : 35);
		[_constraints addObject:make.top.equalTo(_segmentedControl.bottom).with.offset(verticalMargin)];
		[_constraints addObject:make.width.equalTo(self.view.width).with.offset(-40)];
		[_constraints addObject:make.bottom.equalTo(self.view.bottom).with.offset(-verticalMargin)];
	}];
    [_webViewCoverView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_chartWebView);
    }];
}

- (void)setupFont {
	UIFont *font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[_titleLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.font = font;
	}];
	[_valueLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.font = font;
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)labelWithFrame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumScaleFactor = 0.5;
	return label;
}

- (void)updateDisplay {
	self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", @"%@ to %@"), _sourceCurrencyCode, _targetCurrencyCode];

	[self fillCurrencyTable];
	self.segmentedControl.selectedSegmentIndex = 0;
	[self reloadChartImage];
}

#pragma mark - CurrencyItem

- (float)conversionRate {
	A3YahooCurrency *source = [_currencyDataManager dataForCurrencyCode:_sourceCurrencyCode];
	A3YahooCurrency *target = [_currencyDataManager dataForCurrencyCode:_targetCurrencyCode];
	return [target.rateToUSD floatValue] / [source.rateToUSD floatValue];
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
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.rightMargin.offset(-15);
	[cell layoutIfNeeded];

	if (indexPath.row == 0) {
		cell.valueField.delegate = self;
		cell.valueField.textColor = self.tableView.tintColor;

//		cell.rateLabel.text = self.sourceItem.currencySymbol;
        cell.rateLabel.text =@"";
		cell.codeLabel.text = _sourceCurrencyCode;
		_sourceTextField = cell.valueField;

		NSNumberFormatter *nf = [self currencyFormatterWithCurrencyCode:_sourceCurrencyCode];
		cell.valueField.text = [nf stringFromNumber:_sourceValue];
	} else {
		cell.valueField.delegate = self;
		[cell.valueField setEnabled:NO];
		cell.valueField.text = self.targetValueString;
        cell.rateLabel.text = [NSString stringWithFormat:@"%@ = %@",
						NSLocalizedString(@"Rate", @"Rate"),
						[self.decimalNumberFormatter stringFromNumber:@(self.conversionRate)]];
		cell.codeLabel.text = _targetCurrencyCode;
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
	[nf setCurrencyCode:_targetCurrencyCode];
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
	[nf setCurrencyCode:_sourceCurrencyCode];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return [nf stringFromNumber:@(self.sourceValueConvertedFromTarget)];
}

- (NSNumberFormatter *)decimalNumberFormatter {
	if (!_decimalNumberFormatter) {
		_decimalNumberFormatter = [NSNumberFormatter new];
		_decimalNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		_decimalNumberFormatter.minimumFractionDigits = 4;
	}
	return _decimalNumberFormatter;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return;
	/*
	_selectionInSource = indexPath.row == 0;

	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
	//viewController.allowChooseFavorite = YES;
    viewController.allowChooseFavorite = NO;

	if (IS_IPHONE) {
		viewController.showCancelButton = YES;

		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencySelectViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self.A3RootViewController presentRightSideViewController:viewController];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	*/
}

- (void)currencySelectViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if (_selectionInSource) {
		self.sourceCurrencyCode = selectedItem;
	} else {
		self.targetCurrencyCode = selectedItem;
	}
	[self.tableView reloadData];
	[self updateDisplay];
}

- (void)willDismissSearchViewController {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (IS_IPHONE && IS_LANDSCAPE) return NO;

	self.previousValue = textField.text;

	[self presentNumberKeyboardForTextField:textField];

	textField.text = [self.decimalFormatter stringFromNumber:@0];
	_targetTextField.text = [self targetValueString];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_calculatorTargetTextField = textField;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	[self addNumberKeyboardNotificationObservers];
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
	[self removeNumberKeyboardNotificationObservers];

    FNLOG(@"%@, %@", textField.text, textField);
	if (![textField.text length]) {
		textField.text = self.previousValue;
	}
    
	float value = [textField.text floatValueEx];
	if (value < 1.0) {
		value = 1.0;
	}
    
	NSNumberFormatter *nf;
	if (textField == _sourceTextField) {
		_sourceValue = @(value);
		nf = [self currencyFormatterWithCurrencyCode:_sourceCurrencyCode];
	} else if (textField == _targetTextField) {
		nf = [self currencyFormatterWithCurrencyCode:_targetCurrencyCode];
	}
	textField.text = [nf stringFromNumber:@(value)];

	if (textField == _sourceTextField) {
		_targetTextField.text = self.targetValueString;
	} else {
		_sourceTextField.text = self.sourceValueString;
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

- (void)presentNumberKeyboardForTextField:(UITextField *) textField {
	if (_isNumberKeyboardVisible) {
		return;
	}

	_editingTextField = textField;
	self.numberKeyboardViewController = [self simpleNumberKeyboard];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	keyboardViewController.delegate = self;
	keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
	keyboardViewController.textInputTarget = textField;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
	UIView *keyboardView = keyboardViewController.view;
	[self.view addSubview:keyboardView];
	[self addChildViewController:keyboardViewController];
	
	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	[self textFieldDidBeginEditing:textField];
	
	keyboardView.frame = CGRectMake(0, bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
	
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	if (_didPressClearKey) {
		_sourceTextField.text = [self.decimalFormatter stringFromNumber:@0];
	} else if (!_didPressNumberKey) {
		_sourceTextField.text = _previousValue;
	}

	[self textFieldDidEndEditing:_editingTextField];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_editingTextField = nil;
		_isNumberKeyboardVisible = NO;
	}];
}

#pragma mark A3KeyboardViewControllerDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;

	if (keyInputDelegate == _sourceTextField) {
		_sourceTextField.text = [self.decimalFormatter stringFromNumber:@0];
		_targetTextField.text = self.targetValueString;
	} else {
		_targetTextField.text = [self.decimalFormatter stringFromNumber:@0];
		_sourceTextField.text = self.sourceValueString;
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
	_didPressClearKey = NO;
	_targetTextField.text = [self targetValueString];
}

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
	[self.editingObject resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	_calculatorTargetTextField.text = value;

	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

#pragma mark - UISegmentedControl event handler

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)control {
	[self reloadChartImage];
}

- (void)reloadChartImage {
    [_activityIndicatorRemoveTimer invalidate];
    _activityIndicatorRemoveTimer = nil;
    [_activityIndicatorView removeFromSuperview];
    _activityIndicatorView = nil;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_webViewCoverView addSubview:_activityIndicatorView];
    
    [_activityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_webViewCoverView);
    }];
    
    [_activityIndicatorView startAnimating];
    
    _activityIndicatorRemoveTimer =
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [_activityIndicatorView removeFromSuperview];
                                          _activityIndicatorView = nil;
                                      }];
   
    [self.chartWebView loadHTMLString:[self chartContentHTML] baseURL:nil];
}

- (UIImage *)chartNotAvailableImage {
    CGSize chartSize = _webViewCoverView.frame.size;
	UILabel *label = [UILabel new];
	label.frame = CGRectMake(0,0,chartSize.width, chartSize.height);
	label.numberOfLines = 2;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	label.textColor = [UIColor colorWithRed:172.0 / 255.0 green:172.0 / 255.0 blue:172.0 / 255.0 alpha:1.0];
	label.text = NSLocalizedString(@"Internet connection is not available.", @"Internet connection is not available.");
	label.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	label.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
	label.opaque = NO;
	return [label imageByRenderingView];
}

#pragma mark - currency table handler

- (void)fillCurrencyTable {
	float rate = self.conversionRate;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:_sourceCurrencyCode];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSArray *titles = @[@5, @10, @25, @50, @100];
	NSInteger index = 0;
	for (UILabel *titleLabel in _titleLabels) {
		titleLabel.text = [nf stringFromNumber:titles[index]];
		index++;
	}
	[nf setCurrencyCode:_targetCurrencyCode];
	index = 0;
	for (UILabel *valueLabel in _valueLabels) {
		valueLabel.text = [nf stringFromNumber:@([titles[index] floatValue] * rate)];
		index++;
	}
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	if (IS_IPHONE) {
		if ([[Reachability reachabilityWithHostname:@"finance.yahoo.com"] isReachable]) {
			return UIInterfaceOrientationMaskAllButUpsideDown;
		} else {
			return UIInterfaceOrientationMaskPortrait;
		}
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (UIWebView *)landscapeChartWebView {
	if (!_landscapeChartWebView) {
		_landscapeChartWebView = [[UIWebView alloc] init];
        [_landscapeChartWebView loadHTMLString:[self chartContentHTML] baseURL:nil];
	}
	return _landscapeChartWebView;
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
			CGRect frame = [A3UIDevice screenBoundsAdjustedWithOrientation];
			CGFloat width = frame.size.width;
			frame.size.width = frame.size.height;
			frame.size.height = width;

			self.landscapeView.frame = frame;
			_landscapeView.contentSize = frame.size;
			frame = CGRectInset(frame, 20.0, 20.0);
			self.landscapeChartWebView.frame = frame;
			[_landscapeView addSubview:_landscapeChartWebView];
			[self.view addSubview:self.landscapeView];
		}
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[_landscapeChartWebView removeFromSuperview];
		[_landscapeView removeFromSuperview];
		_landscapeChartWebView = nil;
		_landscapeView = nil;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;
		
		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

- (void)reachabilityChanged {
	if ([[A3AppDelegate instance].reachability isReachable]) {
		[self reloadChartImage];
	}
}

- (NSString *)chartContentHTML {
    FNLOG(@"%@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]);
    FNLOG(@"%@", [NSLocale preferredLanguages][0]);
    
    NSString *counryCode = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
    NSArray *supportedCountries = @[@"uk", @"in", @"es", @"fr", @"it", @"pl", @"br", @"ru", @"tr", @"kr"];
    NSString *locale = @"en";
    if ([supportedCountries containsObject:counryCode]) {
        locale = counryCode;
    } else {
        NSString *languageCode = [NSLocale preferredLanguages][0];
        NSArray *supportedLanguages = @[@"ja", @"es", @"ko", @"fr", @"it", @"pl", @"ru", @"tr"];
        if ([supportedLanguages containsObject:languageCode]) {
            locale = languageCode;
        }
    }
    
    NSArray *periodsArray = @[@"1d", @"1m", @"3m", @"1y", @"5y"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"chartWidget" withExtension:@"html"];
    NSString *templateString = [NSString stringWithContentsOfURL:url usedEncoding:NULL error:nil];
    CGSize chartSize = _webViewCoverView.frame.size;

    FNLOGRECT(_webViewCoverView.frame);
    NSString *width = [NSString stringWithFormat:@"%0.0f", chartSize.width];
    NSString *height = [NSString stringWithFormat:@"%0.0f", chartSize.height];
    NSString *title = [NSString stringWithFormat:@"%@%@", _originalSourceCode, _originalTargetCode];
    NSString *currencyPair = [NSString stringWithFormat:@"%@%@", _originalSourceCode, _originalTargetCode];
    NSString *periods = periodsArray[_segmentedControl.selectedSegmentIndex];
    return [NSString stringWithFormat:templateString, width, height, title, currencyPair, periods, width, height, locale];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    FNLOG();
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    FNLOG();
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    FNLOG();
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    FNLOG();
}

@end
