//
//  A3CurrencyPickerStyleViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/9/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyPickerStyleViewController.h"
#import "A3CurrencyTVDataCell.h"
#import "A3CurrencyTableViewController.h"
#import "A3CurrencyDataManager.h"
#import "A3YahooCurrency.h"
#import "NSString+conversion.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3NumberKeyboardViewController.h"
#import "A3UserDefaults.h"
#import "A3UserDefaults+A3Defaults.h"
#import "A3AppDelegate.h"
#import "CurrencyRateItem.h"
#import "CurrencyFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "A3CurrencyViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3CalculatorViewController.h"

NSString *const A3CurrencyPickerSelectedIndexColumnOne = @"A3CurrencyPickerSelectedIndexColumnOne";
NSString *const A3CurrencyPickerSelectedIndexColumnTwo = @"A3CurrencyPickerSelectedIndexColumnTwo";

@interface A3CurrencyPickerStyleViewController ()
		<UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate,
		UITextFieldDelegate, UIPopoverControllerDelegate, A3CalculatorViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UIView *lineAboveAdBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *adBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adBackgroundViewHeightConstraint;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sampleTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sampleValueLabels;
@property (weak, nonatomic) IBOutlet UISegmentedControl *termSelectSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartImageViewWidthConstraint;
@property (nonatomic, weak) UITextField *sourceTextField, *targetTextField;
@property (nonatomic, copy) NSString *sourceCurrencyCode, *targetCurrencyCode;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, strong) NSNumber *sourceValue;
@property (nonatomic, copy) NSString *previousValue;
@property (strong, nonatomic) NSArray *favorites;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewAboveAdBGHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineTopSampleLabelsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineBottomSampleLabelsHeightConstraint;

@end

@implementation A3CurrencyPickerStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	_sourceValue = @1;
	
	[self setupPickerView];
    [self setupTableView];
	[self setupSampleLabelsFont];
	[self setupSegmentedControlTitles];
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
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	self.tableView.contentInset = UIEdgeInsetsZero;
	[self makeLinesSinglePixel];
}

#pragma mark - TableView

- (void)setupTableView {
	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.tableView.separatorColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    self.tableView.showsVerticalScrollIndicator = NO;
}

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

		CurrencyRateItem *currencyInfo = [[[A3AppDelegate instance] cacheStoreManager] currencyInfoWithCode:_sourceCurrencyCode];
		cell.flagImageView.image = [UIImage imageNamed:currencyInfo.flagImageName];
		NSNumberFormatter *nf = [self currencyFormatterWithCurrencyCode:_sourceCurrencyCode];
		cell.valueField.text = [nf stringFromNumber:_sourceValue];
	} else {
		cell.valueField.delegate = self;
		[cell.valueField setEnabled:NO];
		CurrencyRateItem *currencyInfo = [[[A3AppDelegate instance] cacheStoreManager] currencyInfoWithCode:_targetCurrencyCode];
		cell.flagImageView.image = [UIImage imageNamed:currencyInfo.flagImageName];
		cell.valueField.text = self.targetValueString;
		//		cell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@, Rate = %0.4f", @"%@, Rate = %0.4f"), self.targetItem.currencySymbol, self.conversionRate];
		cell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rate = %0.4f", @"Rate = %0.4f"), self.conversionRate];
		cell.codeLabel.text = _targetCurrencyCode;
		_targetTextField = cell.valueField;
	}
	return cell;
}

- (float)conversionRate {
	A3YahooCurrency *source = [_currencyDataManager dataForCurrencyCode:_sourceCurrencyCode];
	A3YahooCurrency *target = [_currencyDataManager dataForCurrencyCode:_targetCurrencyCode];
	return [target.rateToUSD floatValue] / [source.rateToUSD floatValue];
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

- (NSNumberFormatter *)currencyFormatterWithCurrencyCode:(NSString *)code {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:code];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return nf;
}

- (void)makeLinesSinglePixel {
	_lineViewAboveAdBGHeightConstraint.constant = 0.5;
	_lineTopSampleLabelsHeightConstraint.constant = 0.5;
	_lineBottomSampleLabelsHeightConstraint.constant = 0.5;
	
	[self.view layoutIfNeeded];
}

#pragma mark - Sample Values

- (void)setupSampleLabelsFont {
	UIFont *font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[_sampleTitleLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.font = font;
	}];
	[_sampleValueLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.font = font;
	}];
}

- (void)updateSampleCurrencyLabels {
	float rate = self.conversionRate;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:_sourceCurrencyCode];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSArray *titles = @[@5, @10, @25, @50, @100];
	NSInteger index = 0;
	for (UILabel *titleLabel in _sampleTitleLabels) {
		titleLabel.text = [nf stringFromNumber:titles[titleLabel.tag]];
		index++;
	}
	[nf setCurrencyCode:_targetCurrencyCode];
	index = 0;
	for (UILabel *valueLabel in _sampleValueLabels) {
		valueLabel.text = [nf stringFromNumber:@([titles[valueLabel.tag] floatValue] * rate)];
		index++;
	}
}

#pragma mark - Update Button

- (IBAction)updateButtonAction:(UIButton *)sender {
}

#pragma mark - Swap Button

- (IBAction)swapButtonAction:(UIButton *)sender {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];

	[_pickerView selectRow:toRow inComponent:0 animated:YES];
	[_pickerView selectRow:fromRow inComponent:1 animated:YES];

	[self didSelectPickerRow];
}

#pragma mark - Term Segmented Control

- (void)setupSegmentedControlTitles {
	if (IS_IPAD && [[NSLocale preferredLanguages][0] isEqualToString:@"it"]) {
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), 1] forSegmentAtIndex:0];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), 5] forSegmentAtIndex:1];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:2];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 5] forSegmentAtIndex:3];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), 1] forSegmentAtIndex:4];
	} else
		if (IS_IPHONE35) {
			[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:2];
			[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 5] forSegmentAtIndex:3];
		}
}

- (IBAction)termSelectValueChanged:(UISegmentedControl *)sender {
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

#pragma mark - UIPickerView 

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
	_sourceCurrencyCode = fromCurrencyInfo.currencyCode;
	
	A3YahooCurrency *toCurrencyInfo = [self currencyInfoAtRow:toRow];
	_targetCurrencyCode = toCurrencyInfo.currencyCode;

	[self updateSampleCurrencyLabels];
	[self.tableView reloadData];
}

- (A3YahooCurrency *)currencyInfoAtRow:(NSInteger)row {
	if (row >= [self.favorites count]) {
		return nil;
	}
	CurrencyFavorite *favorite = self.favorites[row];
	return [_currencyDataManager dataForCurrencyCode:favorite.uniqueID];
}

#pragma mark - Data Management

- (NSArray *)favorites {
	if (!_favorites) {
		_favorites = [CurrencyFavorite MR_findAllSortedBy:A3CommonPropertyOrder ascending:YES];
	}
	return _favorites;
}

#warning On the construction
- (void)resetIntermediateState {
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
	double inputValue = [_sourceTextField.text floatValueEx];
	return [NSString stringWithFormat:@"%@ %@ = %@ %@<br/>",
			fromCurrencyInfo.currencyCode,
			[_currencyDataManager stringFromNumber:@(inputValue) withCurrencyCode:fromCurrencyInfo.currencyCode isShare:YES],
			toCurrencyInfo.currencyCode,
			[_currencyDataManager stringFromNumber:@(inputValue * rate) withCurrencyCode:toCurrencyInfo.currencyCode isShare:YES]];
}

- (IBAction)yahooButtonAction:(UIButton *)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://finance.yahoo.com"]];
}

#pragma mark - Ad Received

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	if (IS_IPHONE) {
		[_adBackgroundView addSubview:bannerView];
		
		[bannerView remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_adBackgroundView);
		}];
	} else {
	}
}

@end
