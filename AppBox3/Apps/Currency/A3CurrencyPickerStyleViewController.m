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
#import "CurrencyFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "A3CurrencyViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3CalculatorViewController.h"
#import "NSDate+TimeAgo.h"
#import "A3CurrencySelectViewController.h"
#import "NSManagedObject+extension.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Screenshot.h"
#import "CurrencyHistory.h"
#import "CurrencyHistoryItem.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "Reachability.h"
#import "A3InstructionViewController.h"
#import "UIColor+A3Addition.h"
#import "A3NumberFormatter.h"

NSString *const A3CurrencyPickerSelectedIndexColumnOne = @"A3CurrencyPickerSelectedIndexColumnOne";
NSString *const A3CurrencyPickerSelectedIndexColumnTwo = @"A3CurrencyPickerSelectedIndexColumnTwo";

@interface A3CurrencyPickerStyleViewController ()
		<UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate,
		UITextFieldDelegate, UIPopoverControllerDelegate, A3CalculatorViewControllerDelegate, A3SearchViewControllerDelegate, A3InstructionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UIView *lineAboveAdBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *adBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adBackgroundViewHeightConstraint;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sampleTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sampleValueLabels;
@property (weak, nonatomic) IBOutlet UISegmentedControl *termSelectSegmentedControl;

@property (weak, nonatomic) IBOutlet UIWebView *chartWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartWebViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartWebViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *chartCoverView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSTimer *activityIndicatorRemoveTimer;

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineBottomToPickerSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adBGBottomToLineUpTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineUpView;
@property (strong, nonatomic) UIButton *plusButton;
@property (nonatomic, strong) A3CurrencySelectViewController *currencySelectViewController;
@property (weak, nonatomic) IBOutlet UIView *lineViewPickerTop_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewPickerTopHeightConstraint_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineBottomToSegmentVSpace;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleTitlesBGViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleValuesBGViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *swapButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerBottom_bottomLayoutGuideConstraint;
@property (nonatomic, strong) NSNumberFormatter *decimalNumberFormatter;
@property (nonatomic, strong) GADNativeExpressAdView *admobNativeExpressAdView;

@end

@implementation A3CurrencyPickerStyleViewController {
	BOOL _didPressNumberKey;
	BOOL _didPressClearKey;
	BOOL _currentValueIsNotFromUser;
	BOOL _didFirstTimeRefresh;
	BOOL _isNumberKeyboardVisible;
    BOOL _didReceiveAds;
}

#pragma mark - View Lifecycle Management

- (void)viewDidLoad {
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = NO;
	
	_sourceValue = [self lastInputValue];
	
	[self setupPickerView];
    [self setupTableView];
	[self setupSampleLabelsFont];
	[self setupSegmentedControlTitles];
	
	[self refreshUpdateDateLabel];
	
	if (IS_IPHONE35) {
		[self setupConstantsFor3_5inchNoAds];
	} else if (IS_IPHONE) {
		[self setupConstantsFor4inchNoAds];
	} else {
		[self setupConstantsForiPad];
	}
    
    double delayInSeconds = 2.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (IS_IPHONE) {
            [self setupBannerViewForAdUnitID:AdMobAdUnitIDCurrencyPicker keywords:@[@"Finance", @"Money", @"Shopping", @"Travel"] gender:kGADGenderUnknown adSize:kGADAdSizeSmartBannerPortrait];
        } else {
            [self setupBannerViewForAdUnitID:AdMobAdUnitIDCurrencyPicker keywords:@[@"Finance", @"Money", @"Shopping", @"Travel"] gender:kGADGenderUnknown adSize:kGADAdSizeLeaderboard];
        }
    });

	UIView *superview = self.view;
	[self.view addSubview:self.plusButton];
	
    CGFloat verticalOffset = 0;
    if (IS_IPHONEX) {
        verticalOffset = 40;
    }
	[self.plusButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.centerY.equalTo(superview.bottom).with.offset(-32 - verticalOffset);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    UITapGestureRecognizer *chartCoverViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChartCoverView)];
    [_chartCoverView addGestureRecognizer:chartCoverViewTapGestureRecognizer];
}

- (void)didTapChartCoverView {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://tradingview.go2cloud.org/aff_c?offer_id=2&aff_id=4413"]];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissNumberKeypadAnimated:NO];
	[self dismissInstructionViewController:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_favorites = nil;
	_sourceValue = [self lastInputValue];
	[_pickerView reloadAllComponents];
	[self didSelectPickerRow];
	[self makeLinesSinglePixel];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (!_didFirstTimeRefresh) {
		_didFirstTimeRefresh = YES;

		Reachability *reachability = [Reachability reachabilityForInternetConnection];
		A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
		if ([[A3UserDefaults standardUserDefaults] currencyAutoUpdate]) {
			if ([reachability isReachableViaWiFi] ||
					([userDefaults currencyUseCellularData] && [A3UIDevice hasCellularNetwork])) {
                [self.currencyDataManager updateCurrencyRatesOnSuccess:^{
                    [self didSelectPickerRow];
                    [self refreshUpdateDateLabel];
                } failure:^{
                    
                }];
			}
		}
	}

	self.tableView.contentInset = UIEdgeInsetsZero;
	[self setupIPADLayoutToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
	
	if ([self.mainViewController.navigationController.navigationBar isHidden]) {
		[self.mainViewController showNavigationBarOn:self.mainViewController.navigationController];
	}
	[self setupInstructionView];
	if (self.instructionViewController) {
		[self.navigationController.view bringSubviewToFront:self.instructionViewController.view];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self dismissNumberKeypadAnimated:NO];
}

- (void)setupConstantsFor3_5inchNoAds {
	_adBackgroundViewHeightConstraint.constant = 0;
	[_adBackgroundView setHidden:YES];
	[_lineAboveAdBackgroundView setHidden:YES];

	_tableView.rowHeight = 70.0;
	if (!IS_IOS7) {
		_tableViewHeightConstraint.constant = 140.0;
	}
	_adBGBottomToLineUpTopConstraint.constant = -1;
	_lineBottomToPickerSpaceConstraint.constant = -11;
	
	[self.view layoutIfNeeded];
}

- (void)setupConstantsFor4inchNoAds {
	_adBackgroundViewHeightConstraint.constant = 0;
	[_adBackgroundView setHidden:YES];
	[_lineAboveAdBackgroundView setHidden:YES];

	if ([[UIScreen mainScreen] scale] > 2) {
		_tableView.rowHeight = 120.0;
		_tableViewHeightConstraint.constant = 240.0;
	} else {
		_tableView.rowHeight = 95.0;
		if (!IS_IOS7) {
			_tableViewHeightConstraint.constant = 190.0;
		}
	}
	_adBGBottomToLineUpTopConstraint.constant = -1;
	_lineBottomToPickerSpaceConstraint.constant = -7;
	_sampleTitlesBGViewHeightConstraint.constant = 40;
	_sampleValuesBGViewHeightConstraint.constant = 40;

	[self.view layoutIfNeeded];
}

- (void)setupConstantsForiPad {
	_adBackgroundViewHeightConstraint.constant = 0;
	[_adBackgroundView setHidden:YES];
	[_lineAboveAdBackgroundView setHidden:YES];
	
	_tableView.rowHeight = 95.0;
	if (!IS_IOS7) {
		_tableViewHeightConstraint.constant = 190.0;
	}
	
	[self.view layoutIfNeeded];
}

#pragma mark - TableView

- (void)setupTableView {
	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
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
		cell.valueField.textColor = [[A3AppDelegate instance] themeColor];
		
		//		cell.rateLabel.text = self.sourceItem.currencySymbol;
		cell.codeLabel.text = _sourceCurrencyCode;
		_sourceTextField = cell.valueField;

		cell.flagImageView.image = [UIImage imageNamed:[self.currencyDataManager flagImageNameForCode:_sourceCurrencyCode]];
		if (!_isNumberKeyboardVisible) {
			NSNumberFormatter *nf = [self currencyFormatterWithCurrencyCode:_sourceCurrencyCode];
			cell.valueField.text = [nf stringFromNumber:_sourceValue];
		}

		if (IS_IPHONE) {
			cell.rateLabel.text = [self.currencyDataManager symbolForCode:_sourceCurrencyCode];
		} else {
			cell.rateLabel.text = @"";
		}

	} else {
		cell.valueField.delegate = self;
		[cell.valueField setEnabled:NO];

		cell.flagImageView.image = [UIImage imageNamed:[_currencyDataManager flagImageNameForCode:_targetCurrencyCode]];

		cell.valueField.text = self.targetValueString;
		NSString *symbol = [_currencyDataManager symbolForCode:_targetCurrencyCode];
		if ([symbol length]) {
            cell.rateLabel.text =
                    [NSString stringWithFormat:@"%@, %@ = %@",
                                               symbol,
                                    NSLocalizedString(@"Rate", nil),
                                               [self.decimalNumberFormatter stringFromNumber:@(self.conversionRate)]
            ];
		} else {
            cell.rateLabel.text =
                    [NSString stringWithFormat:@"%@ = %@",
                                    NSLocalizedString(@"Rate", nil),
                                    [self.decimalNumberFormatter stringFromNumber:@(self.conversionRate)]
            ];
		}
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
	A3NumberFormatter *nf = [[A3NumberFormatter alloc] init];
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
	A3NumberFormatter *nf = [[A3NumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:_sourceCurrencyCode];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return [nf stringFromNumber:@(self.sourceValueConvertedFromTarget)];
}

- (NSNumberFormatter *)currencyFormatterWithCurrencyCode:(NSString *)code {
	A3NumberFormatter *nf = [[A3NumberFormatter alloc] init];
	
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:code];
	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return nf;
}

- (NSNumberFormatter *)decimalNumberFormatter {
    if (!_decimalNumberFormatter) {
        _decimalNumberFormatter = [NSNumberFormatter new];
        _decimalNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _decimalNumberFormatter.minimumFractionDigits = 2;
    }
    return _decimalNumberFormatter;
}

- (void)makeLinesSinglePixel {
	if ([UIScreen mainScreen].scale != 1) {
		_lineViewAboveAdBGHeightConstraint.constant = 0.5;
		_lineTopSampleLabelsHeightConstraint.constant = 0.5;
		_lineBottomSampleLabelsHeightConstraint.constant = 0.5;
		_lineViewPickerTopHeightConstraint_iPad.constant = 0.5;
		[self.view layoutIfNeeded];
	}
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
	A3NumberFormatter *nf = [[A3NumberFormatter alloc] init];
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
	[self dismissNumberKeypadAnimated:YES];
	[self.currencyDataManager updateCurrencyRatesOnSuccess:^{
		[self didSelectPickerRow];
		[self refreshUpdateDateLabel];
	} failure:^{
		
	}];
}

- (void)refreshUpdateDateLabel {
	NSDate *updateDate = [[A3UserDefaults standardUserDefaults] objectForKey:A3CurrencyUpdateDate];
	if (updateDate) {
		NSString *updateTitle = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [updateDate timeAgo]];
		
		NSMutableAttributedString *updateString = [[NSMutableAttributedString alloc] initWithString:updateTitle
																						 attributes:[self refreshControlTitleAttribute]];
		self.updateDateLabel.attributedText = updateString;
	}
}

- (NSDictionary *)refreshControlTitleAttribute {
	return @{
			NSFontAttributeName:[UIFont systemFontOfSize:12],
			NSForegroundColorAttributeName:[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0]
	};
}

#pragma mark - Plus Button

- (UIButton *)plusButton {
	if (!_plusButton) {
		_plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_plusButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
		[_plusButton addTarget:self action:@selector(plusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _plusButton;
}

- (void)plusButtonAction:(UIButton *)button {
	[self dismissNumberKeypadAnimated:YES];
	if (self.editingObject) {
		[self.editingObject resignFirstResponder];
		[self setEditingObject:nil];
		return;
	}
	
	[self resetIntermediateState];
	
	[_mainViewController enableControls:NO];
	
	_currencySelectViewController = [A3CurrencySelectViewController new];
	_currencySelectViewController.allowChooseFavorite = YES;
	_currencySelectViewController.isFromCurrencyConverter = YES;
	_currencySelectViewController.delegate = self;

	if (IS_IPHONE) {
		_currencySelectViewController.shouldPopViewController = NO;
		_currencySelectViewController.showCancelButton = YES;
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_currencySelectViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:_currencySelectViewController];
	}
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedCode {
	NSArray *result = [CurrencyFavorite MR_findByAttribute:@"uniqueID" withValue:selectedCode];
	if ([result count]) {
		NSInteger indexOfSelectedCurrency = [self.favorites indexOfObjectPassingTest:^BOOL(CurrencyFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			return [obj.uniqueID isEqualToString:selectedCode];
		}];
		if (indexOfSelectedCurrency != NSNotFound) {
			[_pickerView selectRow:indexOfSelectedCurrency inComponent:0 animated:YES];
			[self didSelectPickerRow];
		}
		return;
	}
	NSManagedObjectContext *_savingContext = [NSManagedObjectContext MR_rootSavingContext];

	CurrencyFavorite *newObject = [CurrencyFavorite MR_createEntityInContext:_savingContext];
	newObject.uniqueID = selectedCode;
	[newObject assignOrderAsLastInContext:_savingContext];
	[_savingContext MR_saveToPersistentStoreAndWait];

	_favorites = nil;
	[_pickerView reloadAllComponents];
	[_pickerView selectRow:[self.favorites count] - 1 inComponent:0 animated:YES];
	[self didSelectPickerRow];
}

#pragma mark - Swap Button

- (IBAction)swapButtonAction:(UIButton *)sender {
	NSInteger fromRow = [_pickerView selectedRowInComponent:0];
	NSInteger toRow = [_pickerView selectedRowInComponent:1];

	[_pickerView selectRow:toRow inComponent:0 animated:YES];
	[_pickerView selectRow:fromRow inComponent:1 animated:YES];

	[self didSelectPickerRow];
}

#pragma mark - Term Segmented Control & Chart View

- (void)setupSegmentedControlTitles {
	if (IS_IPAD && [[NSLocale preferredLanguages][0] hasPrefix:@"it"]) {
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), 1] forSegmentAtIndex:0];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 1] forSegmentAtIndex:1];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 3] forSegmentAtIndex:2];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld year", @"StringsDict", nil), 1] forSegmentAtIndex:3];
		[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), 5] forSegmentAtIndex:4];
	} else
		if (IS_IPHONE35) {
			[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), 3] forSegmentAtIndex:2];
			[_termSelectSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld year", @"StringsDict", nil), 1] forSegmentAtIndex:3];
		}
}

- (IBAction)termSelectValueChanged:(UISegmentedControl *)sender {
	[self reloadChartImage];
}

- (void)reloadChartImage {
    if (!_chartWebView || _chartWebView.isHidden) {
        return;
    }

    [_activityIndicatorRemoveTimer invalidate];
    _activityIndicatorRemoveTimer = nil;
    [_activityIndicatorView removeFromSuperview];
    _activityIndicatorView = nil;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_chartCoverView addSubview:_activityIndicatorView];
    
    [_activityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_chartCoverView);
    }];
    
    [_activityIndicatorView startAnimating];
    
    _activityIndicatorRemoveTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                                     target:self
                                                                   selector:@selector(removeActivityIndicator)
                                                                   userInfo:nil
                                                                    repeats:NO];
    
    [self.chartWebView loadHTMLString:[self chartContentHTML] baseURL:nil];
}

- (void)removeActivityIndicator {
    [_activityIndicatorView removeFromSuperview];
    _activityIndicatorView = nil;
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
    CGSize chartSize = _chartWebView.frame.size;

    NSString *width = [NSString stringWithFormat:@"%0.0f", chartSize.width];
    NSString *height = [NSString stringWithFormat:@"%0.0f", chartSize.height];
    NSString *title = [NSString stringWithFormat:@"%@%@", _sourceCurrencyCode, _targetCurrencyCode];
    NSString *currencyPair = [NSString stringWithFormat:@"%@%@", _sourceCurrencyCode, _targetCurrencyCode];
    NSString *periods = periodsArray[_termSelectSegmentedControl.selectedSegmentIndex];
    return [NSString stringWithFormat:templateString, width, height, title, currencyPair, periods, width, height, locale];
}


- (UIImage *)chartNotAvailableImage {
	CGSize chartSize = _chartWebView.frame.size;
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[_mainViewController dismissMoreMenu];
	if (IS_IPHONE && IS_LANDSCAPE) return NO;

	self.previousValue = textField.text;

	[self presentNumberKeyboardForTextField:textField];
	
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_didPressClearKey = NO;
	_didPressNumberKey = NO;

	_calculatorTargetTextField = textField;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	[self addNumberKeyboardNotificationObservers];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string length]) {
		_didPressNumberKey = YES;
		_didPressClearKey = NO;
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (_didPressClearKey) {
		textField.text = @"1";
		[self addHistoryWithValue:_previousValue];
	} else if (!_didPressNumberKey) {
		textField.text = _previousValue;
	} else {
		[self addHistoryWithValue:_previousValue];
		_currentValueIsNotFromUser = NO;
	}

	if (![textField.text length]) {
		textField.text = self.previousValue;
	}

	float value = [textField.text floatValueEx];

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

	_sourceValue = @(value);
	[[A3SyncManager sharedSyncManager] setObject:@(value) forKey:A3CurrencyUserDefaultsLastInputValue state:A3DataObjectStateModified];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	[self removeNumberKeyboardNotificationObservers];
	self.numberKeyboardViewController = nil;
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
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
	_sourceTextField.text = [self.decimalFormatter stringFromNumber:@0];
	_targetTextField.text = self.targetValueString;
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	double value = [_sourceTextField.text floatValueEx];
	NSNumberFormatter *nf;
	_sourceValue = @(value);
	nf = [self currencyFormatterWithCurrencyCode:_sourceCurrencyCode];
	_sourceTextField.text = [nf stringFromNumber:@(value)];
	
	[self dismissNumberKeypadAnimated:YES];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
	_didPressClearKey = NO;
	
	float value = [_sourceTextField.text floatValueEx];
	_sourceValue = @(value);
	[[A3SyncManager sharedSyncManager] setObject:@(value) forKey:A3CurrencyUserDefaultsLastInputValue state:A3DataObjectStateModified];
	_targetTextField.text = [self targetValueString];
}

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
	_didPressClearKey = NO;
	
	[self dismissNumberKeypadAnimated:YES];
	
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_sourceTextField.text = value;
	if ([value floatValueEx] != 0.0) {
		_didPressNumberKey = YES;
	}
	[self textFieldDidEndEditing:_sourceTextField];
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
			codeNameLabel.text = currencyCode;
			[codeNameLabel sizeToFit];
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
		imageView.image = [UIImage imageNamed:[self.currencyDataManager flagImageNameForCode:currencyCode]];
	}
	
	UILabel *codeNameLabel = [view viewWithTag:200];
	codeNameLabel.text = currencyCode;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	FNLOG();
	[self dismissNumberKeypadAnimated:YES];
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
	[self reloadChartImage];
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

- (void)resetIntermediateState {
	[_sourceTextField resignFirstResponder];
}

#pragma mark - Share

- (void)shareButtonAction:(id)sender {
	_sharePopoverController =
			[self presentActivityViewControllerWithActivityItems:@[self]
											   fromBarButtonItem:sender
											   completionHandler:^() {
												   [_mainViewController enableControls:YES];
												   [self enableControls:YES];
											   }];
	_sharePopoverController.delegate = self;
	[_mainViewController enableControls:NO];
	[self enableControls:NO];
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
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://finance.yahoo.com"]];
}

#pragma mark - Admob Advertisement

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    FNLOGRECT(bannerView.bounds);
    FNLOG(@"%f", bannerView.adSize.size.height);
    
    _didReceiveAds = YES;
    
    [_mainViewController dismissMoreMenu];
    
    if (IS_IPHONE35) {
        [self.view addSubview:bannerView];
        
        [bannerView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lineUpView.top);
            make.left.equalTo(_lineUpView.left);
            make.right.equalTo(_lineUpView.right);
            make.height.equalTo(@50);
        }];
        
        [self.view layoutIfNeeded];
    } else if (IS_IPHONE) {
        FNLOGRECT(bannerView.frame);
        [_adBackgroundView setHidden:NO];
        [_lineAboveAdBackgroundView setHidden:NO];
        _adBackgroundViewHeightConstraint.constant = [self bannerHeight];
        
        if ([[UIScreen mainScreen] scale] > 2) {
            _tableView.rowHeight = 120.0;
            _tableViewHeightConstraint.constant = 240.0;
        } else {
            _tableView.rowHeight = 84.0;
            _tableViewHeightConstraint.constant = 168.0;
        }
        _lineBottomToPickerSpaceConstraint.constant = -6.0;
        
        [_adBackgroundView addSubview:bannerView];
        
        [bannerView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_adBackgroundView.top);
            make.left.equalTo(_adBackgroundView.left);
            make.right.equalTo(_adBackgroundView.right);
            make.bottom.equalTo(_adBackgroundView.bottom);
        }];
        
        [_tableView reloadData];
        [self.view layoutIfNeeded];
    } else {
        [_adBackgroundView setHidden:NO];
        [_lineAboveAdBackgroundView setHidden:NO];
        _adBackgroundViewHeightConstraint.constant = 90;
        [self setupIPADLayoutToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        
        FNLOGRECT(bannerView.frame);
        [self.view addSubview:bannerView];
        
        [bannerView remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_adBackgroundView.centerX);
            make.centerY.equalTo(_adBackgroundView.centerY);
        }];
        
        [self.view layoutIfNeeded];
    }
}

#pragma mark - iPad Rotation

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
	
	if (IS_IPHONE) return;
	[self setupIPADLayoutToInterfaceOrientation:toInterfaceOrientation];
}

- (void)setupIPADLayoutToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (!IS_IPAD) return;
	
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		[_termSelectSegmentedControl setHidden:NO];
		[_chartWebView setHidden:NO];
		if (_didReceiveAds) {
			if (bounds.size.height == 1024) {
				_lineBottomToSegmentVSpace.constant = 15.0;
				self.tableView.rowHeight = 95;
				self.tableViewHeightConstraint.constant = 190;
			} else {
				_lineBottomToSegmentVSpace.constant = 150.0;
				self.tableView.rowHeight = 107;
				self.tableViewHeightConstraint.constant = 214;
			}
		} else {
			if (bounds.size.height == 1024) {
				_lineBottomToSegmentVSpace.constant = 65.0;
				self.tableView.rowHeight = 95;
				self.tableViewHeightConstraint.constant = 190;
			} else {
				_lineBottomToSegmentVSpace.constant = 190.0;
				self.tableView.rowHeight = 107;
				self.tableViewHeightConstraint.constant = 214;
			}
		}
		if (bounds.size.height == 1024) {
			_pickerBottom_bottomLayoutGuideConstraint.constant = 20.5;
		} else {
			_pickerBottom_bottomLayoutGuideConstraint.constant = 80;
		}
		[self.tableView reloadData];
	} else {
		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		if (bounds.size.height == 768) {
			[_termSelectSegmentedControl setHidden:YES];
			[_chartWebView setHidden:YES];
		}
		if (_didReceiveAds) {
			if (bounds.size.height != 768) {
				_lineBottomToSegmentVSpace.constant = 10;
				_pickerBottom_bottomLayoutGuideConstraint.constant = 20;
			} else {
				_pickerBottom_bottomLayoutGuideConstraint.constant = 30;
			}
			self.tableView.rowHeight = 107;
			self.tableViewHeightConstraint.constant = 214;
		} else {
			if (bounds.size.height != 768) {
				_lineBottomToSegmentVSpace.constant = 50;
				_pickerBottom_bottomLayoutGuideConstraint.constant = 30;
			} else {
				_pickerBottom_bottomLayoutGuideConstraint.constant = 30;
			}
			self.tableView.rowHeight = 107;
			self.tableViewHeightConstraint.constant = 214;
		}
		[self.tableView reloadData];
	}
	[self.view layoutIfNeeded];
}

#pragma mark - History

- (NSNumber *)lastInputValue {
	NSNumber *lastInput = [[A3SyncManager sharedSyncManager] objectForKey:A3CurrencyUserDefaultsLastInputValue];
	_currentValueIsNotFromUser = lastInput == nil;
	return lastInput ? lastInput : @1;
}

- (void)addHistoryWithValue:(NSString *)value {
	if ([value floatValueEx] == 1.0 && _currentValueIsNotFromUser) {
		return;
	}

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
	history.value = @([value floatValueEx]);
	
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

#pragma mark - Instruction

static NSString *const A3V3InstructionDidShowForCurrencyPicker = @"A3V3InstructionDidShowForCurrencyPicker";

- (void)setupInstructionView
{
	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForCurrencyPicker]) {
		[self showInstructionView];
	}
}

- (void)instructionHelpButtonAction:(id)sender {
	[_mainViewController dismissMoreMenu];
	[self showInstructionView];
}

- (void)showInstructionView
{
	[_mainViewController dismissMoreMenu];
	[self dismissNumberKeypadAnimated:YES];
	
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForCurrencyPicker];
	[[A3UserDefaults standardUserDefaults] synchronize];
	
	UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
	_instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"CurrencyConverter_Picker"];
	self.instructionViewController.delegate = self;
	[self.navigationController.view addSubview:self.instructionViewController.view];
	self.instructionViewController.view.frame = self.navigationController.view.frame;
	self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
	[self.instructionViewController.view removeFromSuperview];
	self.instructionViewController = nil;
}

#pragma mark - Keyboard

- (void)presentNumberKeyboardForTextField:(UITextField *) textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	
	_previousValue = _sourceTextField.text;
	textField.text = [self.decimalFormatter stringFromNumber:@0];

	self.numberKeyboardViewController = [self simpleNumberKeyboard];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	keyboardViewController.delegate = self;
	keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
	keyboardViewController.textInputTarget = textField;
	keyboardViewController.currencyCode = _sourceCurrencyCode;
	
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
	UIView *keyboardView = keyboardViewController.view;
	[self.view addSubview:keyboardView];
	[self addChildViewController:keyboardViewController];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	_targetTextField.text = [self targetValueString];
    
	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
	
}

- (void)dismissNumberKeypadAnimated:(BOOL)animated {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	[self removeNumberKeyboardNotificationObservers];

	if (_didPressClearKey) {
		_sourceTextField.text = @"0";
		[self addHistoryWithValue:_previousValue];
	} else if (!_didPressNumberKey) {
		_sourceTextField.text = _previousValue;
	} else {
		[self addHistoryWithValue:_previousValue];
		_currentValueIsNotFromUser = NO;
	}
	
	if (![_sourceTextField.text length]) {
		_sourceTextField.text = self.previousValue;
	}
	_targetTextField.text = [self targetValueString];
	NSNumberFormatter *nf = [self currencyFormatterWithCurrencyCode:_sourceCurrencyCode];
	// Reformat source text
	_sourceTextField.text = [nf stringFromNumber:@([_sourceTextField.text floatValueEx])];

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;

    void(^completion)(void) = ^{
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
	};

	if (animated) {
		[UIView animateWithDuration:0.3 animations:^{
			CGRect frame = keyboardView.frame;
			frame.origin.y += keyboardViewController.keyboardHeight;
			keyboardView.frame = frame;
		} completion:^(BOOL finished) {
			completion();
		}];
	} else {
		completion();
	}
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	[self.plusButton setEnabled:enable];
	[self.refreshButton setEnabled:enable];
	[self.swapButton setEnabled:enable];

	_sourceTextField.textColor = enable ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
}

@end
