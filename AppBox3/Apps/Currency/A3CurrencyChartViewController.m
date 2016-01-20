//
//  A3CurrencyChartViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyChartViewController.h"
#import "A3CurrencyTVDataCell.h"
#import "UIImageView+AFNetworking.h"
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
		A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate, A3ViewControllerProtocol>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UIView *valueView;
@property (nonatomic, weak) IBOutlet UIView *line2;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIImageView *chartView;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, weak) UITextField *sourceTextField, *targetTextField;
@property (nonatomic, strong) UIImageView *landscapeChartView;
@property (nonatomic, strong) UIScrollView *landscapeView;
@property (nonatomic, strong) NSNumber *sourceValue;
@property (nonatomic, copy) NSString *previousValue;
@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, copy) NSString *sourceCurrencyCode, *targetCurrencyCode;

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

	if (IS_IPAD && [[NSLocale preferredLanguages][0] isEqualToString:@"it"]) {
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), 1] forSegmentAtIndex:0];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), 5] forSegmentAtIndex:1];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:2];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 5] forSegmentAtIndex:3];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), 1] forSegmentAtIndex:4];
	} else
	if (IS_IPHONE35) {
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:2];
		[_segmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 5] forSegmentAtIndex:3];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:nil];
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
	[_chartView makeConstraints:^(MASConstraintMaker *make) {
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
	CGSize chartSize = [self chartSize];
	[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		[_constraints addObject:make.top.equalTo(_line2.bottom).with.offset(isIPHONE ? (isIPHONE35 ? 10 : 17) : (isPORTRAIT ? 50 : 40))];
		[_constraints addObject:make.width.equalTo(@(chartSize.width))];
	}];
	[_chartView makeConstraints:^(MASConstraintMaker *make) {
		[_constraints addObject:make.top.equalTo(_segmentedControl.bottom).with.offset(isIPHONE ? (isIPHONE35 ? 14 : 18) : (isPORTRAIT ? 20 : 35))];
		[_constraints addObject:make.width.equalTo(@(chartSize.width))];
		[_constraints addObject:make.height.equalTo(@(chartSize.height))];
	}];
}

- (CGSize)chartSize {
	CGSize size;
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	if (IS_IPHONE) {
		size.width = screenBounds.size.height == 480 ? 263 : 300;
		size.height = screenBounds.size.height == 480 ? 154 : 175;
	} else {
		size.width = IS_PORTRAIT ?  605 : 555 ;
		size.height = IS_PORTRAIT ? 268 : 246 ;
	}
	return size;
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	FNLOG();

	[self updateDisplay];
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
//		cell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@, Rate = %0.4f", @"%@, Rate = %0.4f"), self.targetItem.currencySymbol, self.conversionRate];
        cell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rate = %0.4f", @"Rate = %0.4f"), self.conversionRate];
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

	A3NumberKeyboardViewController *keyboardVC = [self simpleNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	keyboardVC.keyboardType = A3NumberKeyboardTypeCurrency;
	textField.inputView = [keyboardVC view];
	if ([textField respondsToSelector:@selector(inputAssistantItem)]) {
		textField.inputAssistantItem.leadingBarButtonGroups = @[];
		textField.inputAssistantItem.trailingBarButtonGroups = @[];
	}
	textField.text = @"";
	return YES;
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
	self.numberKeyboardViewController = nil;

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

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
	[self.firstResponder resignFirstResponder];
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
	NSURLRequest *request = [NSURLRequest requestWithURL:self.urlForChartImage];
	[self.chartView setImageWithURLRequest:request
						  placeholderImage:nil
								   success:nil
								   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									   [self.chartView setImage:[self chartNotAvailableImage]];
								   } ];
}

- (UIImage *)chartNotAvailableImage {
	CGSize chartSize = [self chartSize];
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

#pragma mark - UIImageView Yahoo Chart
/**
 *  Yahoo Finance API
 *  Build URL preparing to call Yahoo Finance API
 *
 *  @return NSURL object made for Yahoo Finance API, Currency Chart
 */
- (NSURL *)urlForChartImage {
	NSArray *types = @[@"1d", @"5d", @"1m", @"5m", @"1y"];
	NSString *string = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@%@=x&t=%@&z=%@&region=%@&lang=%@",
												  _sourceCurrencyCode, _targetCurrencyCode,
												  types[(NSUInteger) self.segmentedControl.selectedSegmentIndex],
												  IS_IPHONE || (IS_IPHONE && !IS_LANDSCAPE)  ? @"m" : @"l",
												  [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode],
												  [[NSLocale preferredLanguages] objectAtIndex:0] ];

	FNLOG(@"%@", string);

	return [NSURL URLWithString:string];
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

- (UIImageView *)landscapeChartView {
	if (!_landscapeChartView) {
		_landscapeChartView = [[UIImageView alloc] init];
		[_landscapeChartView setImageWithURL:self.urlForChartImage];
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

- (void)reachabilityChanged {
	if ([[A3AppDelegate instance].reachability isReachable]) {
		[self reloadChartImage];
	}
}

#pragma mark - A3ViewControllerProtocol

- (BOOL)shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
	return NO;
}

@end
