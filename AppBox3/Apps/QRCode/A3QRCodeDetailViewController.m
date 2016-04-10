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

@interface A3QRCodeDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation A3QRCodeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Detail";

	[self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO];
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
			for (NSDictionary *detail in resultsArray) {
				NSMutableArray *rows = [NSMutableArray new];
				[rows addObject:@{@"title" : detail[@"title"]}];
				[rows addObject:@{@"content" : detail[@"content"]}];
				[rows addObject:@{@"url" : [detail[@"url"] stringByRemovingPercentEncoding]}];
				[sections addObject:rows];
			}
		} else {
			NSMutableArray *rows = [NSMutableArray new];
			[rows addObject:@{@"title" : data.scanData}];
			[rows addObject:@{@"product name" : @""}];
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
	cell.valueTextField.placeholder = [data allKeys][0];
	cell.valueTextField.text = data[[data allKeys][0]];
	return cell;
}

@end
