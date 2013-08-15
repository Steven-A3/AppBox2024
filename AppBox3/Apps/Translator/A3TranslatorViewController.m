//
//  A3TranslatorViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorViewController.h"
#import "A3UIDevice.h"
#import "UIViewController+A3AppCategory.h"
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "A3TranslatorMessageViewController.h"

@interface A3TranslatorViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation A3TranslatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.title = @"Translator";
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

	if (IS_IPHONE) {
		[self leftBarButtonAppsButton];
	}
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction)];

	[self setupSubviews];
}

#pragma mark - Setup Subview

- (void)setupSubviews {
	_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Favorites"]];
	_segmentedControl.selectedSegmentIndex = 0;
	[self.view addSubview:_segmentedControl];

	[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + 10.0);
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(@(IS_IPHONE ? 206.0 : 300.0));
		make.height.equalTo(@28);
	}];

	UIView *line = [[UIView alloc] init];
	line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + 47.0);
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(self.view.width);
		make.height.equalTo(@1.0);
	}];

	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + 48.0);
		make.bottom.equalTo(self.view.bottom);
		make.width.equalTo(self.view.width);
		make.centerX.equalTo(self.view.centerX);
	}];

	_addButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
	[_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_addButton];

	[_addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.bottom.equalTo(self.view.bottom).with.offset(-15.0);
	}];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (IS_IPAD) {
		if (IS_LANDSCAPE) {
			self.navigationItem.leftBarButtonItem = nil;
		} else {
			[self leftBarButtonAppsButton];
		}
	}
}

- (void)appsButtonAction:(UIButton *)button {
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

}

- (void)addButtonAction {
	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)editButtonAction {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
