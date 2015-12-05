//
//  A3CurrencyPickerStyleViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyPickerStyleViewController.h"
#import "CurrencyFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3CurrencyDataManager.h"
#import "CurrencyRateItem.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults.h"
#import "A3NumberKeyboardViewController.h"
#import "A3YahooCurrency.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"
#import "A3CurrencyChartViewController.h"
#import "UIViewController+A3Addition.h"
#import "CurrencyHistory.h"
#import "CurrencyHistoryItem.h"
#import "A3CurrencyViewController.h"
#import "A3UserDefaults+A3Defaults.h"

NSString *const A3CurrencyPickerSelectedIndexColumnOne = @"A3CurrencyPickerSelectedIndexColumnOne";
NSString *const A3CurrencyPickerSelectedIndexColumnTwo = @"A3CurrencyPickerSelectedIndexColumnTwo";

@interface A3CurrencyPickerStyleViewController ()
<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, A3KeyboardDelegate,
		UIActivityItemSource,
		A3CurrencyChartViewDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *fromCurrencyCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *toCurrencyCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *toValueLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *fromValuesArray;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *toValuesArray;
@property (weak, nonatomic) IBOutlet UIView *chartBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *updateInfoLabel;
@property (strong, nonatomic) NSArray *favorites;
@property (strong, nonatomic) UITextField *hiddenTextField;
@property (strong, nonatomic) A3NumberKeyboardViewController *keyboardViewController;
@property (strong, nonatomic) NSString *oldValue;
@property (strong, nonatomic) NSNumberFormatter *decimalNumberFormatter;
@property (strong, nonatomic) NSNumberFormatter *fromNumberFormatter;
@property (strong, nonatomic) NSNumberFormatter *toNumberFormatter;
@property (strong, nonatomic) UIImageView *leftChartView, *rightChartView;
@property (weak, nonatomic) IBOutlet UILabel *tapToEnterGuideLabel;
@property (weak, nonatomic) IBOutlet UIView *fromCurrenciesContainerView;
@property (strong, nonatomic) UIView *bannerBorderView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;

@end

@implementation A3CurrencyPickerStyleViewController {
	BOOL _didPressNumberKey;
	BOOL _didPressClearKey;
}

#pragma mark - View Lifecycle Management

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setupPickerView];
	[self updateSampleLabelsForFrom:nil to:nil];
	[self setupHiddenTextField];

	[self setupFromValue];
	[self updateToValue];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		double delayInSeconds = 2.5;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self setupBannerViewForAdUnitID:AdMobAdUnitIDCurrency keywords:@[@"Finance", @"Money", @"Shopping", @"Travel"] gender:kGADGenderUnknown];
		});
	} else {
		_favorites = nil;
		[_pickerView reloadAllComponents];
		
		if ([self bannerView]) {
			[self adViewDidReceiveAd:[self bannerView]];
		}
	}
	[self setupPickerView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[_hiddenTextField resignFirstResponder];
}

#pragma mark - Update Contents

- (void)updateSampleLabelsForFrom:(A3YahooCurrency *)fromInfo to:(A3YahooCurrency *)toInfo {
	float rate = [toInfo.rateToUSD floatValue] / [fromInfo.rateToUSD floatValue];

	[self.fromNumberFormatter setCurrencyCode:fromInfo.currencyCode];
	[self.toNumberFormatter setCurrencyCode:toInfo.currencyCode];
	NSArray *fromNumbers = @[@5, @10, @100, @500];

	[_fromValuesArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
		label.text = [self.fromNumberFormatter stringFromNumber:fromNumbers[idx]];
	}];
	[_toValuesArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
		label.text = [self.toNumberFormatter stringFromNumber:@([fromNumbers[idx] doubleValue] * rate)];
	}];
}

- (void)setupFromValue {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	A3YahooCurrency *fromInfo = [self currencyInfoAtRow:fromRow];
	[self.fromNumberFormatter setCurrencyCode:fromInfo.currencyCode];
	
	_fromValueLabel.text = [self.fromNumberFormatter stringFromNumber:@1];
	self.hiddenTextField.text = @"1";
}

- (void)updateToValue {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];
	A3YahooCurrency *fromInfo = [self currencyInfoAtRow:fromRow];
	A3YahooCurrency *toInfo = [self currencyInfoAtRow:toRow];

	[self.fromNumberFormatter setCurrencyCode:fromInfo.currencyCode];
	[self.toNumberFormatter setCurrencyCode:toInfo.currencyCode];

	double rate = [toInfo.rateToUSD doubleValue] / [fromInfo.rateToUSD doubleValue];
	double from = [[self.fromNumberFormatter numberFromString:_fromValueLabel.text] doubleValue];
	double to = from * rate;
	_toValueLabel.text = [self.toNumberFormatter stringFromNumber:@(to)];
}

#pragma mark - Data Management

- (NSArray *)favorites {
	if (!_favorites) {
		_favorites = [CurrencyFavorite MR_findAllSortedBy:A3CommonPropertyOrder ascending:YES];
	}
	return _favorites;
}

#pragma mark - UIPickerViewDataSource, Delegate

- (void)setupPickerView {
	NSNumber *selectedRowColumnOne = [[A3UserDefaults standardUserDefaults] objectForKey:A3CurrencyPickerSelectedIndexColumnOne];
	NSNumber *selectedRowColumnTwo = [[A3UserDefaults standardUserDefaults] objectForKey:A3CurrencyPickerSelectedIndexColumnTwo];

	NSInteger rowC1 = selectedRowColumnOne ? MIN([selectedRowColumnOne integerValue], [self.favorites count] - 1) : 0;
	NSInteger rowC2 = selectedRowColumnTwo ? MIN([selectedRowColumnTwo integerValue], [self.favorites count] - 1) : 1;
	
	[_pickerView selectRow:rowC1 inComponent:0 animated:YES];
	[_pickerView selectRow:rowC2 inComponent:1 animated:YES];

	[self didSelectPickerRow];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.favorites count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 44;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	CurrencyFavorite *favorite = self.favorites[row];
	NSString *currencyCode = favorite.uniqueID;
	if (!view) {
		UIView *newView = [UIView new];
		if ([[A3UserDefaults standardUserDefaults] currencyShowNationalFlag]) {
			UIView *centerAlignView = [UIView new];
			UIImageView *imageView = [UIImageView new];
			
			imageView.tag = 100;
			[centerAlignView addSubview:imageView];
			
			UILabel *codeNameLabel  = [self currencyCodeLabel];
			[centerAlignView addSubview:codeNameLabel];
			
			[imageView makeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(centerAlignView.left);
				make.centerY.equalTo(centerAlignView.centerY);
				make.width.equalTo(@24);
				make.height.equalTo(@24);
			}];
			[codeNameLabel makeConstraints:^(MASConstraintMaker *make) {
				make.right.equalTo(centerAlignView.right);
				make.centerY.equalTo(centerAlignView.centerY);
			}];
			
			[newView addSubview:centerAlignView];
			
			[centerAlignView makeConstraints:^(MASConstraintMaker *make) {
				make.centerX.equalTo(newView.centerX);
				make.centerY.equalTo(newView.centerY);
				make.width.equalTo(@(24 + 10 + codeNameLabel.bounds.size.width));
				make.height.equalTo(@24);
			}];
			
		} else {
			UILabel *codeNameLabel = [self currencyCodeLabel];
			[newView addSubview:codeNameLabel];
			
			[codeNameLabel makeConstraints:^(MASConstraintMaker *make) {
				make.centerX.equalTo(newView.centerX);
				make.centerY.equalTo(newView.centerY);
			}];
		}

		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		newView.bounds = CGRectMake(0, 0, screenBounds.size.width / 2, 44);
		
		[self preparePickerRowView:newView forCurrencyCode:currencyCode];
		return newView;
	}

	[self preparePickerRowView:view forCurrencyCode:currencyCode];
	return view;
}

- (UILabel *)currencyCodeLabel {
	UILabel *codeNameLabel = [UILabel new];
	codeNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	codeNameLabel.font = [UIFont systemFontOfSize:17];
	codeNameLabel.textColor = [UIColor blackColor];
	codeNameLabel.tag = 200;
	codeNameLabel.text = @"USD";
	[codeNameLabel sizeToFit];
	return codeNameLabel;
}

- (void)preparePickerRowView:(UIView *)view forCurrencyCode:(NSString *)currencyCode {
	if ([[A3UserDefaults standardUserDefaults] currencyShowNationalFlag]) {
		UIImageView *imageView = [view viewWithTag:100];
		CurrencyRateItem *currencyInfo = [[[A3AppDelegate instance] cacheStoreManager] currencyInfoWithCode:currencyCode];
		imageView.image = [UIImage imageNamed:currencyInfo.flagImageName];
	}

	UILabel *codeNameLabel = [view viewWithTag:200];
	codeNameLabel.text = currencyCode;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	FNLOG();
	[self didSelectPickerRow];
}

- (void)didSelectPickerRow {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];

	[[A3UserDefaults standardUserDefaults] setInteger:fromRow forKey:A3CurrencyPickerSelectedIndexColumnOne];
	[[A3UserDefaults standardUserDefaults] setInteger:toRow forKey:A3CurrencyPickerSelectedIndexColumnTwo];
	[[A3UserDefaults standardUserDefaults] synchronize];
	
	A3YahooCurrency *fromCurrencyInfo = [self currencyInfoAtRow:fromRow];
	NSString *displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCurrencyCode value:fromCurrencyInfo.currencyCode];
	_fromCurrencyCodeLabel.text = [NSString stringWithFormat:@"%@(%@)", displayName, fromCurrencyInfo.currencyCode];
	[self.fromNumberFormatter setCurrencyCode:fromCurrencyInfo.currencyCode];
	_fromValueLabel.text = [self.fromNumberFormatter stringFromNumber:@([_hiddenTextField.text doubleValue])];
	
	A3YahooCurrency *toCurrencyInfo = [self currencyInfoAtRow:toRow];
	float rate = [toCurrencyInfo.rateToUSD floatValue] / [fromCurrencyInfo.rateToUSD floatValue];
	NSString *toDisplayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCurrencyCode value:toCurrencyInfo.currencyCode];
	_toCurrencyCodeLabel.text = [NSString stringWithFormat:@"%@(%@), %@/%@=%.4g", toDisplayName, toCurrencyInfo.currencyCode, fromCurrencyInfo.currencyCode, toCurrencyInfo.currencyCode, rate];

	[self updateSampleLabelsForFrom:fromCurrencyInfo to:toCurrencyInfo];
	[self updateToValue];
	[self updateChartViewFrom:fromCurrencyInfo.currencyCode to:toCurrencyInfo.currencyCode];
}

- (A3YahooCurrency *)currencyInfoAtRow:(NSInteger)row {
	if (row >= [self.favorites count]) {
		return nil;
	}
	CurrencyFavorite *favorite = self.favorites[row];
	return [_currencyDataManager dataForCurrencyCode:favorite.uniqueID];
}

#pragma mark - Text Field

- (IBAction)didTapOnFromValueLabel:(UITapGestureRecognizer *)sender {
	[_tapToEnterGuideLabel setHidden:YES];
	[self.hiddenTextField becomeFirstResponder];
}

- (UITextField *)hiddenTextField {
	if (!_hiddenTextField) {
		_hiddenTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_hiddenTextField.delegate = self;
		_hiddenTextField.hidden = YES;
	}
	return _hiddenTextField;
}

- (void)setupHiddenTextField {
	[self.view addSubview:self.hiddenTextField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	
	self.keyboardViewController = [self simpleNumberKeyboard];
	self.keyboardViewController.delegate = self;
	textField.inputView = self.keyboardViewController.view;
	if ([textField respondsToSelector:@selector(inputAssistantItem)]) {
		textField.inputAssistantItem.leadingBarButtonGroups = @[];
		textField.inputAssistantItem.trailingBarButtonGroups = @[];
	}

	self.keyboardViewController.textInputTarget = textField;

	_oldValue = _hiddenTextField.text;

	NSInteger fromRow = [_pickerView selectedRowInComponent:0];

	A3YahooCurrency *fromCurrencyRateItem = [self currencyInfoAtRow:fromRow];
	[self.fromNumberFormatter setCurrencyCode:fromCurrencyRateItem.currencyCode];
	textField.text = @"";
	_fromValueLabel.text = [self.fromNumberFormatter stringFromNumber:@0];

	[self updateToValue];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string length]) {
		_didPressNumberKey = YES;
		_didPressClearKey = NO;
	}
	NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	FNLOG(@"Text Field.text = %@", newText);
	
	[self setFromValueLabelText:newText];
	return YES;
}

- (void)setFromValueLabelText:(NSString *)text {
	NSNumber *inputValue = [self.decimalNumberFormatter numberFromString:text];
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	A3YahooCurrency *currencyInfo = [self currencyInfoAtRow:fromRow];
	[self.fromNumberFormatter setCurrencyCode:currencyInfo.currencyCode];
	_fromValueLabel.text = [self.fromNumberFormatter stringFromNumber:inputValue];
	[self updateToValue];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (_didPressClearKey) {
		_hiddenTextField.text = @"1";
		[self setFromValueLabelText:@"1"];
		[self addHistoryWithValue:_oldValue];
		return;
	}
	if (!_didPressNumberKey) {
		_hiddenTextField.text = _oldValue;
		[self setFromValueLabelText:_oldValue];
	} else {
		[self addHistoryWithValue:_oldValue];
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self.hiddenTextField resignFirstResponder];
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_fromValueLabel.text = [self.fromNumberFormatter stringFromNumber:@0];
	_hiddenTextField.text = @"";
	[self updateToValue];
	_didPressClearKey = YES;
}

#pragma mark - Refresh Button Action

- (IBAction)refreshButtonAction:(UIButton *)sender {
	[self.currencyDataManager updateCurrencyRatesOnSuccess:^{
		[self didSelectPickerRow];
	} failure:^{

	}];
}

#pragma mark - Swap Button Action

- (IBAction)swapButtonAction:(UIButton *)sender {
	NSInteger row0 = [_pickerView selectedRowInComponent:0];
	NSInteger row1 = [_pickerView selectedRowInComponent:1];

	[_pickerView selectRow:row1 inComponent:0 animated:YES];
	[_pickerView selectRow:row0 inComponent:1 animated:YES];

	[self setFromValueLabelText:_hiddenTextField.text];
	[self didSelectPickerRow];
}

#pragma mark - Number Formatters

- (NSNumberFormatter *)decimalNumberFormatter {
	if (!_decimalNumberFormatter) {
		_decimalNumberFormatter = [NSNumberFormatter new];
		[_decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	}
	return _decimalNumberFormatter;
}

- (NSNumberFormatter *)fromNumberFormatter {
	if (!_fromNumberFormatter) {
		_fromNumberFormatter = [NSNumberFormatter new];
		[_fromNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return _fromNumberFormatter;
}

- (NSNumberFormatter *)toNumberFormatter {
	if (!_toNumberFormatter) {
		_toNumberFormatter = [NSNumberFormatter new];
		[_toNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return _toNumberFormatter;
}

#pragma mark - Chart View

- (void)updateChartViewFrom:(NSString *)from to:(NSString *)to {
	if (_chartBackgroundView.bounds.size.height < 30.0) {
		[_leftChartView removeFromSuperview];
		_leftChartView = nil;
		[_rightChartView removeFromSuperview];
		_rightChartView = nil;
		return;
	}

	if ([[A3AppDelegate instance].reachability isReachable]) {
		UIView *superview = self.chartBackgroundView;

		[self.chartBackgroundView addSubview:self.leftChartView];
		[self.leftChartView remakeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(superview.top).with.offset(15);
			make.left.equalTo(superview.left).with.offset(10);
			make.height.equalTo(superview.height).with.priorityLow();
			make.right.equalTo(superview.centerX).with.offset(-10);
		}];

		[self.chartBackgroundView addSubview:self.rightChartView];
		[self.rightChartView remakeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(superview.top).with.offset(15);
			make.left.equalTo(superview.centerX).with.offset(10);
			make.right.equalTo(superview.right).with.offset(-10);
			make.height.equalTo(superview.height).with.priorityLow();
		}];

		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[self chartURLWithOption:@"1d" from:from to:to]];
		__weak A3CurrencyPickerStyleViewController *weakself = self;
		[self.leftChartView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
			[weakself.leftChartView setImage:image];
			FNLOG(@"Left Chart Image Downloaded Successfully");
		} failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
			FNLOG(@"%@", response);
		}];
		NSURLRequest *urlRequestRight = [NSURLRequest requestWithURL:[self chartURLWithOption:@"1m" from:from to:to]];
		[self.rightChartView setImageWithURLRequest:urlRequestRight placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
			[weakself.rightChartView setImage:image];
			FNLOG(@"Right Chart Image Downloaded Successfully");
		} failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
			FNLOG(@"%@", response);
		}];
	}
}

/**
 *  Yahoo Finance API
 *  Build URL preparing to call Yahoo Finance API
 *
 *  @param option @"1d", @"5d", @"1m", @"5m", @"1y"
 *  @param from   Currency Code for from value
 *  @param to     Currency Code for to value
 *
 *  @return NSURL object made for Yahoo Finance API, Currency Chart
 */
- (NSURL *)chartURLWithOption:(NSString *)option from:(NSString *)from to:(NSString *)to {
	NSString *string = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@%@=x&t=%@&z=%@&region=%@&lang=%@",
						from, to,
						option,
						IS_IPHONE ? @"s" : @"m",
						[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode],
						[[NSLocale preferredLanguages] objectAtIndex:0] ];
	return [NSURL URLWithString:string];
}

- (UIImageView *)leftChartView {
	if (!_leftChartView) {
		_leftChartView = [UIImageView new];
		_leftChartView.contentMode = UIViewContentModeScaleAspectFit;
		[_leftChartView setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
		UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer new];
		[tapGestureRecognizer addTarget:self action:@selector(didTapOnChart)];
		[_leftChartView addGestureRecognizer:tapGestureRecognizer];
		_leftChartView.userInteractionEnabled = YES;
	}
	return _leftChartView;
}

- (UIImageView *)rightChartView {
	if (!_rightChartView) {
		_rightChartView = [UIImageView new];
		_rightChartView.contentMode = UIViewContentModeScaleAspectFit;
		[_rightChartView setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
		UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer new];
		[tapGestureRecognizer addTarget:self action:@selector(didTapOnChart)];
		[_rightChartView addGestureRecognizer:tapGestureRecognizer];
		_rightChartView.userInteractionEnabled = YES;
	}
	return _rightChartView;
}

- (void)didTapOnChart {
	A3CurrencyChartViewController *viewController = [[A3CurrencyChartViewController alloc] initWithNibName:@"A3CurrencyChartViewController" bundle:nil];
	viewController.delegate = self;
	viewController.currencyDataManager = _currencyDataManager;
	viewController.initialValue = @([self.hiddenTextField.text doubleValue]);

	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];

	A3YahooCurrency *fromCurrencyInfo = [self currencyInfoAtRow:fromRow];
	A3YahooCurrency *toCurrencyInfo = [self currencyInfoAtRow:toRow];

	viewController.originalSourceCode = fromCurrencyInfo.currencyCode;
	viewController.originalTargetCode = toCurrencyInfo.currencyCode;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)chartViewControllerValueChangedChartViewController:(A3CurrencyChartViewController *)chartViewController valueChanged:(NSNumber *)newValue {

}

- (void)resetIntermediateState {
	[_hiddenTextField resignFirstResponder];
}

#pragma mark - Ad Received

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	if (IS_IPHONE) {
		if (!_bannerBorderView) {
			_bannerBorderView = [UIView new];
			_bannerBorderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
			_bannerBorderView.layer.borderWidth = 0.5;
			[self.view addSubview:_bannerBorderView];
			
			UIView *superview = self.view;
			[_bannerBorderView remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(superview.left).with.offset(-0.5);
				make.right.equalTo(superview.right).with.offset(0.5);
				make.top.equalTo(_fromCurrenciesContainerView.top);
				make.height.equalTo(@51);
			}];
		}
		[self.view addSubview:bannerView];
		
		[bannerView remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_bannerBorderView).insets(UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5));
		}];
	} else {
		[self.view addSubview:bannerView];

		UIView *superview = self.view;
		[bannerView remakeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(superview.centerX);
			make.centerY.equalTo(superview.bottom).multipliedBy(0.6);
		}];
	}
}

#pragma mark - History

- (void)addHistoryWithValue:(NSString *)value {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];
	
	A3YahooCurrency *fromCurrencyInfo = [self currencyInfoAtRow:fromRow];
	A3YahooCurrency *toCurrencyInfo = [self currencyInfoAtRow:toRow];

	CurrencyHistory *history = [CurrencyHistory MR_createEntity];
	history.uniqueID = [[NSUUID UUID] UUIDString];
	NSDate *keyDate = [NSDate date];
	history.updateDate = keyDate;
	history.currencyCode = fromCurrencyInfo.currencyCode;
	history.rate = fromCurrencyInfo.rateToUSD;
	history.value = @([value doubleValue]);

	CurrencyHistoryItem *item = [CurrencyHistoryItem MR_createEntity];
	item.uniqueID = [[NSUUID UUID] UUIDString];
	item.updateDate = keyDate;
	item.historyID = history.uniqueID;
	item.currencyCode = toCurrencyInfo.currencyCode;
	item.rate = toCurrencyInfo.rateToUSD;
	item.order = [NSString stringWithFormat:@"%010ld", 1l];

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

	[_mainViewController enableControls:YES];
}

#pragma mark - Share

- (void)shareButtonAction:(id)sender {
	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender completionHandler:^(NSString *activityType, BOOL completed) {
		[_mainViewController enableControls:YES];
	}];
	_sharePopoverController.delegate = self;
	[_mainViewController enableControls:NO];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return NSLocalizedString(@"Share Currency Converter Data", @"Share Currency Converter Data");
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a conversion with you.", nil)
									   contents:[self stringForShare]
										   tail:NSLocalizedString(@"You can convert more in the AppBox Pro.", nil)];
	}
	else {
		return [[self stringForShare] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
	}
}

- (NSString *)stringForShare {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];

	A3YahooCurrency *fromCurrencyInfo = [self currencyInfoAtRow:fromRow];
	A3YahooCurrency *toCurrencyInfo = [self currencyInfoAtRow:toRow];

	double rate = [toCurrencyInfo.rateToUSD doubleValue] / [fromCurrencyInfo.rateToUSD doubleValue];
	double inputValue = [_hiddenTextField.text doubleValue];
	return [NSString stringWithFormat:@"%@ %@ = %@ %@<br/>",
									  fromCurrencyInfo.currencyCode,
									  [_currencyDataManager stringFromNumber:@(inputValue) withCurrencyCode:fromCurrencyInfo.currencyCode isShare:YES],
									  toCurrencyInfo.currencyCode,
									  [_currencyDataManager stringFromNumber:@(inputValue * rate) withCurrencyCode:toCurrencyInfo.currencyCode isShare:YES]];
}

@end
