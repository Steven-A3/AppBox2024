//
//  A3QRCodeDetailViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeDetailViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3QRCodeDetailCell.h"
#import "QRCodeHistory.h"
#import "UIViewController+A3Addition.h"
#import "A3QRCodeTextViewController.h"
#import "A3BasicWebViewController.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "UIViewController+extension.h"
#import "A3SyncManager.h"

@interface A3QRCodeDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@property (nonatomic, strong) MASConstraint *bottomBarBottomConstraint;

@end

@implementation A3QRCodeDetailViewController {
	BOOL _viewWillAppearDidRun;
	BOOL _searchDataHasNoResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Detail", @"Detail");

	[self setupTableView];

	if (!_historyData.searchData || _searchDataHasNoResult) {
		UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
																		style:UIBarButtonItemStylePlain
																	   target:self
																	   action:@selector(shareButtonAction:)];
		self.navigationItem.rightBarButtonItem = shareButton;
	}

	if (_showSearchOnGoogleButton) {
		UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search on Google", @"Search on Google") style:UIBarButtonItemStylePlain target:self action:@selector(searchOnGoogleButtonAction:)];
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		_bottomToolbar = [UIToolbar new];
		_bottomToolbar.items = @[flexibleSpace, searchButton, flexibleSpace];
		[self.view addSubview:_bottomToolbar];

		UIView *superview = self.view;
		[_bottomToolbar makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(superview.left);
			make.right.equalTo(superview.right);
			_bottomBarBottomConstraint = make.bottom.equalTo(superview.bottom);
		}];
	}
}

- (void)searchOnGoogleButtonAction:(UIBarButtonItem *)barButton {
	A3BasicWebViewController *viewController = [A3BasicWebViewController new];
	viewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@", _historyData.scanData]];
	viewController.titleString = NSLocalizedString(@"Search on Google", @"Search on Google");
	
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (!_viewWillAppearDidRun) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDQRCode keywords:@[@"Low Price", @"Shopping", @"Marketing"] adSize:IS_IPHONE ? GADAdSizeFluid : GADAdSizeLeaderboard delegate:self];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHistoryData:(QRCodeHistory *)data {
	_historyData = data;
	NSMutableArray *sections = [NSMutableArray new];
	if (data.searchData) {
		NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data.searchData];
		NSArray *resultsArray = dataDictionary[@"responseData"][@"results"];
		if ([resultsArray count]) {
			_searchDataHasNoResult = NO;
			for (NSDictionary *detail in resultsArray) {
				NSMutableArray *rows = [NSMutableArray new];
				[rows addObject:@{NSLocalizedString(@"Barcode", @"Barcode") : _historyData.scanData}];
				
				NSString *titleString = [detail[@"title"] stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
				titleString = [titleString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
				[rows addObject:@{NSLocalizedString(@"TITLE", @"TITLE") : titleString}];
				
				NSString *contentString = detail[@"content"];
				contentString = [contentString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
				contentString = [contentString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
				[rows addObject:@{NSLocalizedString(@"CONTENT", @"CONTENT") : contentString}];
				[rows addObject:@{NSLocalizedString(@"URL", @"URL") : [detail[@"url"] stringByRemovingPercentEncoding]}];
				[sections addObject:rows];
			}
		} else {
			_searchDataHasNoResult = YES;
			NSMutableArray *rows = [NSMutableArray new];
			[rows addObject:@{NSLocalizedString(@"TITLE", @"TITLE") : data.scanData}];
			[rows addObject:@{NSLocalizedString(@"PRODUCT NAME", @"PRODUCT NAME") : _historyData.productName ?: @""}];
			[sections addObject:rows];
		}
	}
	_sections = sections;
}

- (void)setupTableView {
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.rowHeight = 74;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.separatorInset = A3UITableViewSeparatorInset;

	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		_tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	[_tableView registerClass:[A3QRCodeDetailCell class] forCellReuseIdentifier:@"qrcodeDetailCell"];
	[self.view addSubview:_tableView];

	UIView *superview = self.view;
	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.top.equalTo(superview.top);
		make.bottom.equalTo(superview.bottom);
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *data = _sections[indexPath.section][indexPath.row];
	A3QRCodeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"qrcodeDetailCell" forIndexPath:indexPath];
	NSString *placeHolder = [data allKeys][0];
	cell.valueTextField.placeholder = placeHolder;
	cell.valueTextField.text = data[placeHolder];
	cell.valueTextField.enabled = _searchDataHasNoResult && [placeHolder isEqualToString:NSLocalizedString(@"PRODUCT NAME", @"PRODUCT NAME")];
	if (_searchDataHasNoResult && [placeHolder isEqualToString:NSLocalizedString(@"PRODUCT NAME", @"PRODUCT NAME")]) {
		cell.valueTextField.enabled = YES;
		cell.valueTextField.delegate = self;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.valueTextField.returnKeyType = UIReturnKeyDone;
	} else {
		cell.valueTextField.delegate = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	A3QRCodeDetailCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([cell.valueTextField.placeholder isEqualToString:NSLocalizedString(@"URL", @"URL")]) {
		NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
		NSTextCheckingResult *match = [dataDetector firstMatchInString:cell.valueTextField.text options:0 range:NSMakeRange(0, [cell.valueTextField.text length])];
		if ([[UIApplication sharedApplication] canOpenURL:match.URL]) {
			[self presentWebViewControllerWithURL:match.URL];
		}
	} else {
		A3QRCodeTextViewController *viewController = [A3QRCodeTextViewController new];
		viewController.text = cell.valueTextField.text;
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - AdMob

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
	[self.view addSubview:bannerView];

	UIView *superview = self.view;
	[bannerView remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.bottom.equalTo(superview.bottom);
		make.height.equalTo(@(bannerView.bounds.size.height));
	}];

	_bottomBarBottomConstraint.offset = -bannerView.bounds.size.height;
	
	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom = bannerView.bounds.size.height;
	self.tableView.contentInset = contentInset;

	[self.view layoutIfNeeded];
}

#pragma mark - ShareButtonAction

- (void)shareButtonAction:(id)sender {
	[self presentActivityViewControllerWithActivityItems:@[self]
									   fromBarButtonItem:sender
									   completionHandler:nil];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"QR Codes on AppBox Pro", @"QR Codes on AppBox Pro");
	}
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	return _historyData.scanData;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(A3AppName_QRCode, nil);
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.placeholder isEqualToString:NSLocalizedString(@"PRODUCT NAME", @"PRODUCT NAME")]) {
		_historyData.productName = textField.text;
		[_historyData.managedObjectContext saveContext];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

@end
