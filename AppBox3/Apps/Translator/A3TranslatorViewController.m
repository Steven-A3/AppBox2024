//
//  A3TranslatorViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3TranslatorMessageViewController.h"
#import "TranslatorHistory.h"
#import "NSDate+TimeAgo.h"
#import "A3TranslatorCircleView.h"
#import "A3TranslatorFavoriteDataSource.h"
#import "A3TranslatorListCell.h"
#import "UIView+Screenshot.h"
#import "UIViewController+A3Addition.h"
#import "TranslatorGroup.h"
#import "A3TranslatorLanguage.h"
#import "TranslatorFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3TranslatorViewController () <FMMoveTableViewDataSource, FMMoveTableViewDelegate, A3TranslatorMessageViewControllerDelegate, A3TranslatorFavoriteDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) FMMoveTableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) A3TranslatorFavoriteDataSource *favoriteDataSource;

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
	[self makeBackButtonEmptyArrow];

	[self leftBarButtonAppsButton];

	[self setupSubviews];

	[self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)cleanUp {
	[self removeObserver];

	_fetchedResultsController = nil;
	_segmentedControl = nil;
	_tableView = nil;
	_addButton = nil;
	_favoriteDataSource = nil;
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	if (enable) {
		[_segmentedControl setTintColor:nil];
	} else {
		[_segmentedControl setTintColor:SEGMENTED_CONTROL_DISABLED_TINT_COLOR];
	}
	[self.addButton setEnabled:enable];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

#pragma mark - Setup Subview

- (void)setupSubviews {
	FNLOGRECT(self.view.frame);
	FNLOGRECT(self.navigationController.view.frame);

	_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Favorites"]];
	_segmentedControl.selectedSegmentIndex = 0;
	[_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_segmentedControl];

	[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + 10.0);
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(@(IS_IPHONE ? 170.0 : 300.0));
		make.height.equalTo(@28);
	}];

	UIView *line = [[UIView alloc] init];
	line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + (IS_RETINA ? 47.5 : 47.0));
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(self.view.width);
		make.height.equalTo(IS_RETINA ? @0.5 : @1);
	}];

	_tableView = [[FMMoveTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	if (IS_IPAD) self.tableView.separatorInset = UIEdgeInsetsMake(0, 28, 0, 0);
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.rowHeight = 48.0;
	[self.view addSubview:_tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(line.bottom);
		make.bottom.equalTo(self.view.bottom);
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
	}];

	_addButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
	[_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_addButton];

	[_addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
		make.bottom.equalTo(self.view.bottom).with.offset(IS_RETINA ? -10.5 : -10);
	}];
}

#pragma mark -------------- SegmentedControl

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.tableView.dataSource = self;
		self.tableView.delegate = self;
		[self.tableView reloadData];

		[self.addButton setHidden:NO];
	} else {
		self.navigationItem.rightBarButtonItem = nil;

		[self.favoriteDataSource resetData];
		self.tableView.dataSource = self.favoriteDataSource;
		self.tableView.delegate = self.favoriteDataSource;
		[self.tableView reloadData];

		[self.addButton setHidden:YES];
	}
}

- (A3TranslatorFavoriteDataSource *)favoriteDataSource {
	if (!_favoriteDataSource) {
		_favoriteDataSource = [A3TranslatorFavoriteDataSource new];
		_favoriteDataSource.delegate = self;
	}
	return _favoriteDataSource;
}

- (void)translatorFavoriteItemSelected:(TranslatorFavorite *)item {
	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];

	viewController.originalTextLanguage = item.text.group.sourceLanguage;
	viewController.translatedTextLanguage = item.text.group.targetLanguage;
	viewController.delegate = self;
	viewController.selectItem = item.text;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)addButtonAction {
	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView Data Source

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [TranslatorGroup MR_fetchAllSortedBy:@"order" ascending:YES withPredicate:nil groupBy:nil delegate:nil];
	}

	return _fetchedResultsController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	static NSString *cellIdentifier = @"TranslatorListCell";

	TranslatorGroup *group = self.fetchedResultsController.fetchedObjects[indexPath.row];

	if (IS_IPHONE) {
		UITableViewCell *iPhone_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if(iPhone_cell == nil) {
			iPhone_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		}

		iPhone_cell.textLabel.font = [UIFont systemFontOfSize:15];
		iPhone_cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		iPhone_cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];

		cell = iPhone_cell;
		cell.detailTextLabel.text = [[group.texts valueForKeyPath:@"@max.date"] timeAgo];
	} else {
		A3TranslatorListCell *iPad_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if(iPad_cell == nil) {
			iPad_cell = [[A3TranslatorListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		cell = iPad_cell;
		iPad_cell.dateLabel.text = [[group.texts valueForKeyPath:@"@max.date"] timeAgo];
	}

	cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@",
													 [A3TranslatorLanguage localizedNameForCode:group.sourceLanguage],
													 [A3TranslatorLanguage localizedNameForCode:group.targetLanguage]];

	A3TranslatorCircleView *circleView = [[A3TranslatorCircleView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	circleView.textLabel.text = [NSString stringWithFormat:@"%ld", (long)[group.texts count]];
	cell.imageView.image = [circleView imageByRenderingView];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		TranslatorGroup *group = self.fetchedResultsController.fetchedObjects[indexPath.row];
		[group MR_deleteEntity];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

		[self.fetchedResultsController performFetch:nil];

		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
	TranslatorGroup *group = self.fetchedResultsController.fetchedObjects[indexPath.row];

	viewController.originalTextLanguage = group.sourceLanguage;
	viewController.translatedTextLanguage = group.targetLanguage;
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)translatorMessageViewControllerWillDismiss:(id)viewController {
	if (_segmentedControl.selectedSegmentIndex == 0) {
		[self.fetchedResultsController performFetch:nil];
	} else {
		[_favoriteDataSource resetData];
	}
	[self.tableView reloadData];
}

#pragma mark --- FMMoveTableVeiwDelegate

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *mutableArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
	[mutableArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	_fetchedResultsController = nil;
}

@end
