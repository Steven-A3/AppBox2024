//
//  A3QRCodeHistoryViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/8/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeHistoryViewController.h"
#import "QRCodeHistory.h"
#import "A3StandardTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "A3QRCodeDetailViewController.h"
#import "A3QRCodeDataHandler.h"
#import "NSDate+TimeAgo.h"

@interface A3QRCodeHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *navigationBarExtensionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<QRCodeHistory *> *historyArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) A3QRCodeDataHandler *dataHandler;

@end

@implementation A3QRCodeHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"History";
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	[self setupSegmentedControl];
	[self setupTableView];
	
	[self setupBarButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[_navigationBarExtensionView setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[_navigationBarExtensionView setHidden:YES];
}

- (void)setupBarButton {
	if ([self.historyArray count]) {
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
		self.navigationItem.leftBarButtonItem = editButton;
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
	self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editButtonAction:(UIBarButtonItem *)editButton {
	if (![_tableView isEditing]) {
		[_tableView setEditing:YES];
		
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editDoneButtonAction:)];
		self.navigationItem.leftBarButtonItem = doneButton;
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (void)editDoneButtonAction:(UIBarButtonItem *)editDoneButton {
	if ([_tableView isEditing]) {
		[_tableView setEditing:NO];
		
		[self setupBarButton];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)doneButton {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupSegmentedControl {
	_navigationBarExtensionView = [UIView new];
	_navigationBarExtensionView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
	[_navigationBarExtensionView addSubview:self.segmentedControl];

	[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.left.equalTo(_navigationBarExtensionView.left).with.offset(15);
			make.right.equalTo(_navigationBarExtensionView.right).with.offset(-15);
		} else {
			make.centerX.equalTo(_navigationBarExtensionView.centerX);
			make.width.equalTo(@320);
		}
		make.bottom.equalTo(_navigationBarExtensionView.bottom).with.offset(-10);
		make.height.equalTo(@29);
	}];
	
	UIView *bottomLineView = [UIView new];
	bottomLineView.backgroundColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
	[_navigationBarExtensionView addSubview:bottomLineView];
	[bottomLineView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_navigationBarExtensionView.left);
		make.right.equalTo(_navigationBarExtensionView.right);
		make.bottom.equalTo(_navigationBarExtensionView.bottom);
		make.height.equalTo(@(1.0 / [[UIScreen mainScreen] scale]));
	}];

	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	_navigationBarExtensionView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + statusBarFrame.size.height,
												   self.view.bounds.size.width, 52);
	[self.navigationController.view addSubview:_navigationBarExtensionView];
}

- (UISegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Barcode", @"QR Code"]];
		_segmentedControl.selectedSegmentIndex = 0;
		[_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
	}
	return _segmentedControl;
}

- (void)segmentedControlValueChanged {
	_historyArray = nil;
	[self.tableView reloadData];
}

- (void)setupTableView {
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.rowHeight = 56;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.separatorInset = A3UITableViewSeparatorInset;

	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		_tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	[self.view addSubview:_tableView];

	UIView *superview = self.view;
	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.top.equalTo(superview.top).with.offset(64 + 52);
		make.bottom.equalTo(superview.bottom);
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.historyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
	if (!cell) {
		cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"defaultCell"];
	}
	QRCodeHistory *history = self.historyArray[indexPath.row];
	cell.textLabel.text = history.scanData;
	cell.detailTextLabel.text = [history.created timeAgoWithLimit:60*60*24*3 dateFormat:NSDateFormatterMediumStyle andTimeFormat:NSDateFormatterShortStyle];
	if (_segmentedControl.selectedSegmentIndex == 0) {
		if ([history.dimension isEqualToString:@"1"]) {
			cell.imageView.image = [UIImage imageNamed:@"BarcodeInList"];
		} else {
			cell.imageView.image = [UIImage imageNamed:@"QRCodeInList"];
		}
	} else {
		cell.imageView.image = nil;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];
		QRCodeHistory *history = self.historyArray[indexPath.row];
		[history MR_deleteEntityInContext:moc];

		[moc MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
			_historyArray = nil;
			[_tableView reloadData];
		}];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	QRCodeHistory *history = self.historyArray[indexPath.row];
	if ([history.dimension isEqualToString:@"1"]) {
		A3QRCodeDetailViewController *viewController = [A3QRCodeDetailViewController new];
		viewController.historyData = history;
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		[self.dataHandler performActionWithData:history.scanData inViewController:self];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Data Array

- (NSArray *)historyArray {
	if (!_historyArray) {
		if (self.segmentedControl.selectedSegmentIndex == 0) {
			_historyArray = [QRCodeHistory MR_findAllSortedBy:@"created" ascending:NO];
		} else {
			_historyArray = [QRCodeHistory MR_findByAttribute:@"dimension"
													withValue:[NSString stringWithFormat:@"%ld", (long)self.segmentedControl.selectedSegmentIndex]
												   andOrderBy:@"created"
													ascending:NO];
		}
	}
	return _historyArray;
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	return _dateFormatter;
}

- (A3QRCodeDataHandler *)dataHandler {
	if (!_dataHandler) {
		_dataHandler = [A3QRCodeDataHandler new];
	}
	return _dataHandler;
}

@end
