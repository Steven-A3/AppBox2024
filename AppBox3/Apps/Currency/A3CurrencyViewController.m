//
//  A3CurrencyViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyViewController.h"
#import "CurrencyFavorite.h"
#import "NSManagedObject+MagicalFinders.h"
#import "A3CurrencyTVActionCell.h"
#import "CurrencyHistory.h"
#import "CurrencyHistory+handler.h"
#import "CurrencyItem.h"
#import "common.h"
#import "SFKImage.h"
#import "A3CurrencyTVDataCell.h"
#import "A3AppDelegate.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "UIViewController+A3AppCategory.h"
#import "A3CurrencyTVEqualCell.h"
#import "NSMutableArray+A3Sort.h"
#import "CurrencyItem+NetworkUtility.h"
#import "A3CurrencyChartViewController.h"

@interface A3CurrencyViewController () <UITextFieldDelegate, ATSDragToReorderTableViewControllerDelegate, A3CurrencyMenuDelegate>

@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableDictionary *equalItem, *plusItem;
@property (nonatomic, strong) NSMutableDictionary *textFields;
@property (nonatomic, strong) CurrencyHistory *history;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *updateDateLabel;
@property (nonatomic, strong) UIButton *updateButton;
@property (nonatomic, strong) UIButton *yahooButton;
@property (nonatomic, weak)	UITextField *firstResponder;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;

@end

@implementation A3CurrencyViewController {
    BOOL _draggingFirstRow;
}

NSString *const A3CurrencyDataCellID = @"A3CurrencyDataCell";
NSString *const A3CurrencyActionCellID = @"A3CurrencyActionCell";
NSString *const A3CurrencyEqualCellID = @"A3CurrencyEqualCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		// Custom initialization
		self.title = @"Currency";
		self.dragDelegate = self;
	}
    return self;
}

- (void)viewDidLoad
{
	[self setupSwipeRecognizers];
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self	action:@selector(appsButtonAction:)];
	self.navigationItem.leftBarButtonItem = barButtonItem;

	[self rightButtonMoreButton];

	self.tableView.rowHeight = 84.0;
	self.tableView.separatorColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, -1.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 30.0, 0.0);

    [self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyActionCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVEqualCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyEqualCellID];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)rightButtonMoreButton {
	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"◦ ◦ ◦" style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];
	self.navigationItem.rightBarButtonItem = moreButtonItem;
}

- (void)reloadUpdateDateLabel {
	NSDate *latterDate = nil;
	for (id object in self.favorites) {
		if ([object isKindOfClass:[CurrencyFavorite class]]) {
			CurrencyFavorite *favorite = object;
			latterDate = [favorite.currencyItem.updated laterDate:latterDate];
		}
	}
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterShortStyle];
	[df setTimeStyle:NSDateFormatterMediumStyle];
	self.updateDateLabel.text = [NSString stringWithFormat:@"Updated %@", [df stringFromDate:latterDate]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (!_bottomView) {
		[self.view.superview insertSubview:self.bottomView aboveSubview:self.view];
	}
	[self reloadUpdateDateLabel];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appsButtonAction:(UIButton *)button {
	[_firstResponder resignFirstResponder];

	[[[A3AppDelegate instance] mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {

	}];
	if ([_moreMenuView superview]) {
		[self dismissMoreMenuView:_moreMenuView tableView:self.tableView];
		[self rightButtonMoreButton];
	}
}

- (void)moreButtonAction:(UIButton *)button {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];

	_moreMenuButtons = @[self.shareButton, self.historyButton , self.settingsButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView ];
}

- (void)doneButtonAction:(id)button {
	[self dismissMoreMenu];
}

- (void)dismissMoreMenu {
	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView tableView:self.tableView];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (NSNumberFormatter *)currencyFormatterWithCode:(NSString *)currencyCode {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:currencyCode];
	return nf;
}

- (void)shareButtonAction:(UIButton *)button {
	[self dismissMoreMenu];

	CurrencyFavorite *source = self.favorites[0], *target = self.favorites[2];
	NSNumberFormatter *sourceNF = [self currencyFormatterWithCode:source.currencyItem.currencyCode];
	NSNumberFormatter *targetNF = [self currencyFormatterWithCode:target.currencyItem.currencyCode];
	float rate = target.currencyItem.rateToUSD.floatValue / source.currencyItem.rateToUSD.floatValue;
	NSString *activityItem = [NSString stringWithFormat:@"%@ equals %@ with rate %0.4f",
		[sourceNF stringFromNumber:self.currencyHistory.value],
		[targetNF stringFromNumber:@(self.currencyHistory.value.floatValue * rate)],
			rate];

	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem] applicationActivities:nil];
	[self presentViewController:activityController animated:YES completion:^{

	}];
}

- (void)historyButtonAction:(UIButton *)button {
	[self dismissMoreMenu];


}

- (void)settingsButtonAction:(UIButton *)button {
	[self dismissMoreMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)bottomView {
	if (!_bottomView) {
		CGRect frame = self.view.bounds;
		frame.origin.y = frame.size.height - 30.0;
		frame.size.height = 30.0;
		_bottomView = [[UIView alloc] initWithFrame:frame];
		_bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.98];

		[_bottomView addSubview:self.updateDateLabel];
		[_bottomView addSubview:self.updateButton];
		[_bottomView addSubview:self.yahooButton];

		NSDictionary *views = NSDictionaryOfVariableBindings(_updateButton, _updateDateLabel, _yahooButton);
		[_bottomView addConstraint:
				[NSLayoutConstraint constraintWithItem:_updateDateLabel
											 attribute:NSLayoutAttributeCenterX
											 relatedBy:NSLayoutRelationEqual
												toItem:_bottomView
											 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

		[_bottomView addConstraint:
         [NSLayoutConstraint constraintWithItem:_updateDateLabel
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_bottomView
                                      attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
		[_bottomView addConstraint:
				[NSLayoutConstraint constraintWithItem:_updateButton
											 attribute:NSLayoutAttributeCenterY
											 relatedBy:NSLayoutRelationEqual
												toItem:_bottomView
											 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

		[_bottomView addConstraint:
				[NSLayoutConstraint constraintWithItem:_yahooButton
											 attribute:NSLayoutAttributeCenterY
											 relatedBy:NSLayoutRelationEqual
												toItem:_bottomView
											 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

		[_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_updateButton]-5-[_updateDateLabel]-5-[_yahooButton]" options:0 metrics:nil views:views]];
	}
	return _bottomView;
}

- (UILabel *)updateDateLabel {
	if (!_updateDateLabel) {
		_updateDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_updateDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_updateDateLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
		_updateDateLabel.text = [NSString stringWithFormat:@"Updated 2013/07/24 10:38:11 PM"];
		_updateDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _updateDateLabel;
}

- (UIButton *)updateButton {
	if (!_updateButton) {
		_updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_updateButton.translatesAutoresizingMaskIntoConstraints = NO;

		NIKFontAwesomeIconFactory *iconFactory = [NIKFontAwesomeIconFactory buttonIconFactory];
		iconFactory.colors = @[[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]];
		iconFactory.strokeColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        iconFactory.square = YES;
		iconFactory.edgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0);
        UIImage *buttonImage = [iconFactory createImageForIcon:NIKFontAwesomeIconRefresh];
		[_updateButton setImage:buttonImage forState:UIControlStateNormal];
		[_updateButton addTarget:self action:@selector(updateCurrencyRates) forControlEvents:UIControlEventTouchUpInside];
	}
	return _updateButton;
}

- (UIButton *)yahooButton {
	if (!_yahooButton) {
		_yahooButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_yahooButton.translatesAutoresizingMaskIntoConstraints = NO;
		[SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:20.0]];
        [SFKImage setDefaultColor:[UIColor colorWithRed:124.0/255.0 green:125.0/255.0 blue:124.0/255.0 alpha:1.0]];
        UIImage *buttonImage = [SFKImage imageNamed:@"yahoo"];
		[_yahooButton setImage:buttonImage forState:UIControlStateNormal];
        [_yahooButton addTarget:self action:@selector(openFinanceYahoo) forControlEvents:UIControlEventTouchUpInside];
	}
	return _yahooButton;
}

- (void)updateCurrencyRates {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyRatesUpdated) name:A3NotificationCurrencyRatesUpdated object:nil];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[CurrencyItem updateCurrencyRates];
	});

	CABasicAnimation *fullRotationAnimation;
	fullRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	fullRotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	fullRotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	fullRotationAnimation.duration = 4;
	fullRotationAnimation.repeatCount = HUGE_VALF;
	[self.updateButton.layer addAnimation:fullRotationAnimation forKey:@"360"];
	[self.updateButton setEnabled:NO];
}

- (void)currencyRatesUpdated {
	[self.tableView reloadData];
	[self reloadUpdateDateLabel];

	[self.updateButton.layer removeAllAnimations];
	[self.updateButton setEnabled:YES];
}

- (NSMutableArray *)favorites {
	if (nil == _favorites) {
		_favorites = [NSMutableArray arrayWithArray:[CurrencyFavorite MR_findAllSortedBy:@"order" ascending:YES]];
		[self addEqualAndPlus];
	}
	return _favorites;
}

- (void)openFinanceYahoo {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://finance.yahoo.com"]];
}

- (void)addEqualAndPlus {
	[_favorites insertObjectToSortedArray:self.equalItem atIndex:1];
	[_favorites addObjectToSortedArray:self.plusItem];
}

- (NSMutableDictionary *)equalItem {
	if (!_equalItem) {
		_equalItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"=",@"order":@""}];
	}
	return _equalItem;
}

- (NSMutableDictionary *)plusItem {
	if (!_plusItem) {
		_plusItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"+", @"order":@""}];
	}
	return _plusItem;
}

- (CurrencyHistory *)currencyHistory {
	if (nil == _history) {
		_history = [CurrencyHistory firstObject];
	}
    return _history;
}

- (NSMutableDictionary *)textFields {
	if (!_textFields) {
		_textFields = [NSMutableDictionary new];
	}
	return _textFields;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	if ([self.favorites objectAtIndex:indexPath.row] == self.equalItem) {
		A3CurrencyTVEqualCell *equalCell = [self reusableEqualCellForTableView:tableView];

		cell = equalCell;
	} else if ([self.favorites objectAtIndex:indexPath.row] == self.plusItem) {
		// Bottom row is reserved for "plus" action.
		A3CurrencyTVActionCell *actionCell = [self reusableActionCellForTableView:tableView];
		actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
		[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];

		cell = actionCell;
	} else if ( [ [self.favorites objectAtIndex:indexPath.row] isKindOfClass:[CurrencyFavorite class] ] ) {
		A3CurrencyTVDataCell *dataCell;
		dataCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyDataCellID forIndexPath:indexPath];
		if (nil == dataCell) {
			dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyDataCellID];
			dataCell.menuDelegate = self;
		}

		[self configureDataCell:dataCell atIndexPath:indexPath];

		cell = dataCell;
	}

    return cell;
}

- (void)configureDataCell:(A3CurrencyTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
	dataCell.menuDelegate = self;

	NSInteger dataIndex = indexPath.row;

	dataCell.valueField.tag = dataIndex;
	dataCell.valueField.delegate = self;
	[self.textFields setObject:dataCell.valueField forKey:[NSString stringWithFormat:@"K%d", dataIndex]];

	CurrencyFavorite *favorite = self.favorites[dataIndex];
    
	NSNumber *value;
	if (dataIndex == 0) {
		value = self.currencyHistory.value;
		dataCell.valueField.textColor = self.tableView.tintColor;
		dataCell.rateLabel.text = @"";
	} else {
		CurrencyFavorite *favoriteZero = nil;
		for (id object in self.favorites) {
			if ([object isKindOfClass:[CurrencyFavorite class]]) {
				favoriteZero = object;
				break;
			}
		}

		float rate = favorite.currencyItem.rateToUSD.floatValue / favoriteZero.currencyItem.rateToUSD.floatValue;
		value = @(self.currencyHistory.value.floatValue * rate);

		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setCurrencyCode:favoriteZero.currencyItem.currencyCode];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

		dataCell.rateLabel.text = [NSString stringWithFormat:@"%@ = %.4f", [numberFormatter stringFromNumber:@1.0], rate];
		dataCell.valueField.textColor = [UIColor blackColor];
	}
	dataCell.valueField.text = [self currencyFormattedStringForCurrency:favorite.currencyItem.currencyCode value:value];
	dataCell.codeLabel.text = favorite.currencyItem.currencyCode;
}

- (NSString *)currencyFormattedStringForCurrency:(NSString *)code value:(NSNumber *)value {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:code];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencySymbol:@""];
	return [nf stringFromNumber:value];
}

- (A3CurrencyTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3CurrencyTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyActionCellID];
	if (nil == cell) {
		cell = [[A3CurrencyTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyActionCellID];
	}
	return cell;
}

- (A3CurrencyTVEqualCell *)reusableEqualCellForTableView:(UITableView *)tableView {
	A3CurrencyTVEqualCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyEqualCellID];
	if (nil == cell) {
		cell = [[A3CurrencyTVEqualCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyEqualCellID];
	}
	return cell;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self.favorites objectAtIndex:indexPath.row] isKindOfClass:[CurrencyFavorite class]];
}

// Override to support rearranging the table view.
// Assumption : self.favorites is a sorted list.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[self.favorites moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

#pragma mark - ATSDragToReorderTableViewControllerDraggableIndicators

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	FNLOG();
	UITableViewCell *cell = nil;
	if ([self.favorites objectAtIndex:indexPath.row] == self.equalItem) {
		A3CurrencyTVEqualCell *equalCell = [[A3CurrencyTVEqualCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		cell = equalCell;
	} else if ([self.favorites objectAtIndex:indexPath.row] == self.plusItem) {
		// Bottom row is reserved for "plus" action.
		A3CurrencyTVActionCell *actionCell = [[A3CurrencyTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
		[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];

		cell = actionCell;
	} else if ([[self.favorites objectAtIndex:indexPath.row] isKindOfClass:[CurrencyFavorite class]]) {
		A3CurrencyTVDataCell *dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		[self configureDataCell:dataCell atIndexPath:indexPath];
		cell = dataCell;
	}
	return cell;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark -- UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if(textField.tag == 0) {
		A3NumberKeyboardViewController *keyboardVC = [self simpleNumberKeyboard];
		self.numberKeyboardViewController = keyboardVC;
		keyboardVC.keyInputDelegate = textField;
		keyboardVC.delegate = self;
		self.numberKeyboardViewController = keyboardVC;
		textField.inputView = [keyboardVC view];

		_firstResponder = textField;
		return YES;
	} else {
		return NO;
	}
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.keyInputDelegate;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self.numberKeyboardViewController.keyInputDelegate resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	FNLOG();
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}


- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = [notification object];
	[self updateTextFieldsWithSourceTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    FNLOG();
	[self updateTextFieldsWithSourceTextField:textField];

	_firstResponder = nil;
	self.numberKeyboardViewController = nil;
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
	float fromValue = [textField.text floatValue];
	self.currencyHistory.value = @(fromValue);
	NSInteger fromIndex = textField.tag;
	for (NSString *key in [self.textFields allKeys]) {
		UITextField *targetTextField = _textFields[key];
		if (targetTextField == textField) {
			continue;
		}
		CurrencyFavorite *sourceCurrency = self.favorites[fromIndex];
		CurrencyFavorite *targetCurrency = self.favorites[targetTextField.tag];
		float rate = [targetCurrency.currencyItem.rateToUSD floatValue] / [sourceCurrency.currencyItem.rateToUSD floatValue];
		targetTextField.text = [self currencyFormattedStringForCurrency:targetCurrency.currencyItem.currencyCode value:@(fromValue * rate)];
	}
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow {
    [self unswipeAll];
    _draggingFirstRow = (dragRow.row == 0);
	FNLOG();
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController willEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
	FNLOG();
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
	NSInteger equalIndex, plusIndex;
	NSInteger count = [self.favorites count];

	equalIndex = [self.favorites indexOfObject:self.equalItem];

	if (equalIndex != 1) {
		FNLOG(@"equal index %d is not 1.", equalIndex);
		[self.favorites moveItemInSortedArrayFromIndex:equalIndex toIndex:1];
		[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:equalIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (equalIndex == 0) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
        }
	}

	plusIndex = [self.favorites indexOfObject:self.plusItem];

	if (plusIndex != (count - 1)) {
		FNLOG(@"plusIndex %d is not %d.", plusIndex, count - 1);
		[self.favorites moveItemInSortedArrayFromIndex:plusIndex toIndex:count - 1];
		[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:plusIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]];
	}
    if ((_draggingFirstRow && (destinationIndexPath.row != 0)) || (destinationIndexPath.row == 0)) {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });
    }
}

- (BOOL)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController shouldHideDraggableIndicatorForDraggingToRow:(NSIndexPath *)destinationIndexPath {
	FNLOG();
	return NO;
}

#pragma mark - A3CurrencyMenuDelegate
- (void)swapActionForCell:(UITableViewCell *)cell {
	[self unswipeAll];

	NSIndexPath *sourceIndexPath = [self.tableView indexPathForCell:cell];
	NSIndexPath *targetIndexPath;
	if (sourceIndexPath.row == 0) {
		targetIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
	} else {
		targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	[self.favorites exchangeObjectInSortedArrayAtIndex:sourceIndexPath.row withObjectAtIndex:targetIndexPath.row];
	[self.tableView reloadRowsAtIndexPaths:@[sourceIndexPath, targetIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];

    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.tableView reloadData];
	});
}

- (void)chartActionForCell:(UITableViewCell *)cell {
	[self unswipeAll];

	A3CurrencyChartViewController *viewController = [[A3CurrencyChartViewController alloc] initWithNibName:@"A3CurrencyChartViewController" bundle:nil];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	CurrencyFavorite *favoriteZero = self.favorites[0], *favorite = self.favorites[indexPath.row];
	viewController.sourceCurrencyCode = favoriteZero.currencyItem.currencyCode;
	viewController.targetCurrencyCode = favorite.currencyItem.currencyCode;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)shareActionForCell:(UITableViewCell *)cell {
	[self unswipeAll];

}

- (void)deleteActionForCell:(UITableViewCell *)cell {
	[self unswipeAll];

}

@end
