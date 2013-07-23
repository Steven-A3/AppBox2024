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
#import "A3CurrencyTVEqualCell.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSObject+SortInArray.h"
#import "NSManagedObjectContext+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "A3CurrencyTVDataCell.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "UITableViewController+swipeMenu.h"
#import "A3AppDelegate.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface A3CurrencyViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, strong) NSMutableDictionary *textFields;
@property (nonatomic, strong) CurrencyHistory *history;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *updateDateLabel;
@property (nonatomic, strong) UIButton *updateButton;
@property (nonatomic, strong) UIButton *yahooButton;

@end

@implementation A3CurrencyViewController

static NSString *const A3CurrencyCellID = @"A3CurrencyTableViewCell";
static NSString *const A3CurrencyDataCellID = @"A3CurrencyDataCell";
static NSString *const A3CurrencyActionCellID = @"A3CurrencyActionCell";
static NSString *const A3CurrencyEqualCellID = @"A3CurrencyEqualCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		// Custom initialization
		self.title = @"Currency";
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

	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self	action:@selector(appsButtonAction:)];
	self.navigationItem.leftBarButtonItem = barButtonItem;

	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"◦ ◦ ◦" style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];
	self.navigationItem.rightBarButtonItem = moreButtonItem;

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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (!_bottomView) {
		[self.view.superview insertSubview:self.bottomView aboveSubview:self.view];
        
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appsButtonAction:(UIButton *)button {
	[[[A3AppDelegate instance] mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {

	}];
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
        UIImage *buttonImage = [iconFactory createImageForIcon:NIKFontAwesomeIconRefresh];
		[_updateButton setImage:buttonImage forState:UIControlStateNormal];
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
	}
	return _yahooButton;
}


- (NSArray *)favorites {
	if (nil == _favorites) {
		_favorites = [CurrencyFavorite MR_findAllSortedBy:@"order" ascending:YES];
	}
	return _favorites;
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
    return [self.favorites count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	if (indexPath.row == 1) {
		// Second row is for equal sign
		A3CurrencyTVEqualCell *equalCell = [self reusableEqualCellForTableView:tableView];

		cell = equalCell;
	} else if (indexPath.row == ([_favorites count] + 1)) {
		// Bottom row is reserved for "plus" action.
		A3CurrencyTVActionCell *actionCell = [self reusableActionCellForTableView:tableView];
		actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
		[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];

		cell = actionCell;
	} else {
		A3CurrencyTVDataCell *dataCell;
		dataCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyDataCellID forIndexPath:indexPath];
		if (nil == dataCell) {
			dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyDataCellID];
		}

		[self configureDataCell:dataCell atIndexPath:indexPath];

		cell = dataCell;
	}

    return cell;
}

- (void)configureDataCell:(A3CurrencyTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
	NSInteger dataIndex = (indexPath.row > 1) ? indexPath.row  - 1 : indexPath.row;

	dataCell.valueField.tag = dataIndex;
	dataCell.valueField.delegate = self;
	[self.textFields setObject:dataCell.valueField forKey:[NSString stringWithFormat:@"K%d", dataIndex]];

	CurrencyFavorite *favorite = self.favorites[dataIndex];
	NSNumber *value;
	if (dataIndex == 0) {
		value = self.currencyHistory.value;
		dataCell.valueField.textColor = self.tableView.tintColor;
	} else {
		CurrencyFavorite *favoriteZero = self.favorites[0];
		float rate = favoriteZero.currencyItem.rateToUSD.floatValue / favorite.currencyItem.rateToUSD.floatValue;
		value = @(self.currencyHistory.value.floatValue * rate);
		dataCell.rateLabel.text = [NSString stringWithFormat:@"Rate = %.4f", rate];
		dataCell.valueField.textColor = [UIColor blackColor];
	}
	dataCell.valueField.text = [self currencyFormattedStringForCurrency:favorite.currencyItem.currencyCode value:value];
	dataCell.codeLabel.text = favorite.currencyItem.currencyCode;

//	if (dataIndex > 0) {
//		dataCell.separatorLineView.backgroundColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
//	} else {
//		dataCell.separatorLineView.backgroundColor = [UIColor clearColor];
//	}
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

// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (	(indexPath.row == 1) ||
//			(indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section] + 1))
//	{
//		return NO;
//	}
//	return YES;
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (	(indexPath.row == 1) ||
//			(indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section] + 1))
//	{
//		return UITableViewCellEditingStyleNone;
//	}
//	return UITableViewCellEditingStyleNone;
//}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//		NSInteger dataIndex = indexPath.row > 0 ? indexPath.row - 1 : 0;
//		CurrencyFavorite *favorite = self.favorites[dataIndex];
//		[favorite MR_deleteEntity];
//
//		// Clear fetched favorites and make it reload.
//		[[NSManagedObjectContext MR_context] MR_saveOnlySelfAndWait];
//		_favorites = nil;
//
//		// Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (	(indexPath.row == 1) ||
        (indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section] + 1))
	{
		return NO;
	}
    return YES;
}

// Override to support rearranging the table view.
// Assumption : self.favorites is a sorted list.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSInteger fromIndex = [self dataIndexForRow:fromIndexPath.row];
	NSInteger toIndex = [self dataIndexForRow:toIndexPath.row];

	[NSObject moveItemInSortedArray:self.favorites fromIndex:fromIndex toIndex:toIndex];
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
	_favorites = nil;
}

- (NSInteger)dataIndexForRow:(NSInteger)row {
	return row > 0 ? row - 1 : 0;
}

#pragma mark - ATSDragToReorderTableViewControllerDraggableIndicators

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	A3CurrencyTVDataCell *dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

	[self configureDataCell:dataCell atIndexPath:indexPath];

	return dataCell;
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
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
	float fromValue = [textField.text floatValue];
	NSInteger fromIndex = textField.tag;
	for (NSString *key in [self.textFields allKeys]) {
		UITextField *targetTextField = _textFields[key];
		if (targetTextField == textField) {
			continue;
		}
		CurrencyFavorite *sourceCurrency = self.favorites[fromIndex];
		CurrencyFavorite *targetCurrency = self.favorites[targetTextField.tag];
		float rate = [sourceCurrency.currencyItem.rateToUSD floatValue] / [targetCurrency.currencyItem.rateToUSD floatValue];
		targetTextField.text = [self currencyFormattedStringForCurrency:targetCurrency.currencyItem.currencyCode value:@(fromValue * rate)];
	}
}

@end
