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
#import "TranslatorHistory.h"
#import "NSDate+TimeAgo.h"
#import "A3TranslatorCircleView.h"
#import "A3TranslatorFavoriteDataSource.h"
#import "A3TranslatorListCell.h"
#import "common.h"
#import "UIView+Screenshot.h"
#import "UIViewController+A3Addition.h"

@interface A3TranslatorViewController () <UITableViewDataSource, UITableViewDelegate, A3TranslatorMessageViewControllerDelegate, A3TranslatorFavoriteDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *fetchedResults;
@property (nonatomic, strong) A3TranslatorFavoriteDataSource *favoriteDataSource;

@end

@implementation A3TranslatorViewController

- (void)cleanUp {
	_fetchedResults = nil;
	_fetchedResultsController = nil;
	_segmentedControl = nil;
	_tableView = nil;
	_addButton = nil;
	_favoriteDataSource = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.title = @"Translator";
		[self fetchedResults];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	@autoreleasepool {
		self.view.backgroundColor = [UIColor whiteColor];
		self.navigationItem.hidesBackButton = YES;
		[self makeBackButtonEmptyArrow];

		if (IS_IPHONE) {
			[self leftBarButtonAppsButton];
		}

		[self setupRightBarButton];
		[self setupSubviews];

		[self registerContentSizeCategoryDidChangeNotification];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
	@autoreleasepool {
		if ([self.tableView isEditing]) {
			[self editButtonAction:self.navigationItem.rightBarButtonItem];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self setupRightBarButton];
}

- (void)setupRightBarButton {
	@autoreleasepool {
		if (_segmentedControl.selectedSegmentIndex == 0) {
			if (![_fetchedResults count]) {
				[_tableView setEditing:NO];
				self.navigationItem.rightBarButtonItem = nil;
				[self leftBarButtonAppsButton];
			} else
			if ([_tableView isEditing]) {
				self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonAction:)];
				self.navigationItem.leftBarButtonItem = nil;
			} else {
				self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit	target:self action:@selector(editButtonAction:)];
				[self leftBarButtonAppsButton];
			}
		} else {
			self.navigationItem.rightBarButtonItem = nil;
			[self leftBarButtonAppsButton];
		}
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	@autoreleasepool {
		[self.tableView reloadData];
	}
}

- (void)dealloc {
	[self removeObserver];
    FNLOG();
}

#pragma mark - Setup Subview

- (void)setupSubviews {
	@autoreleasepool {;
		FNLOGRECT(self.view.frame);
		FNLOGRECT(self.navigationController.view.frame);

		_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Favorites"]];
		_segmentedControl.selectedSegmentIndex = 0;
		[_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
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
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	@autoreleasepool {
		if (segmentedControl.selectedSegmentIndex == 0) {
			[self setupRightBarButton];

			self.tableView.dataSource = self;
			self.tableView.delegate = self;
			[self.tableView reloadData];
		} else {
			[self.tableView setEditing:NO];

			self.navigationItem.rightBarButtonItem = nil;

			[self.favoriteDataSource resetData];
			self.tableView.dataSource = self.favoriteDataSource;
			self.tableView.delegate = self.favoriteDataSource;
			[self.tableView reloadData];
		}
	}
}

- (A3TranslatorFavoriteDataSource *)favoriteDataSource {
	if (!_favoriteDataSource) {
		_favoriteDataSource = [A3TranslatorFavoriteDataSource new];
		_favoriteDataSource.delegate = self;
	}
	return _favoriteDataSource;
}

- (void)translatorFavoriteItemSelected:(TranslatorHistory *)item {
	@autoreleasepool {
		A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];

		viewController.originalTextLanguage = item.originalLanguage;
		viewController.translatedTextLanguage = item.translatedLanguage;
		viewController.delegate = self;
		viewController.selectItem = item;
		[self.navigationController pushViewController:viewController animated:YES];
	}
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

- (void)addButtonAction {
	@autoreleasepool {
		A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
		viewController.delegate = self;
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (void)editButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.tableView setEditing:!self.tableView.isEditing];

	[self setupRightBarButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Data Source

- (NSFetchedResultsController *)fetchedResultsController {
	@autoreleasepool {
		if (!_fetchedResultsController) {
			_fetchedResultsController = [TranslatorHistory MR_fetchAllSortedBy:@"originalLanguage,translatedLanguage" ascending:YES withPredicate:nil groupBy:@"languageGroup" delegate:nil];
		}
	}

	return _fetchedResultsController;
}

- (NSMutableArray *)fetchedResults {
	@autoreleasepool {
		if (!_fetchedResults) {
			NSMutableArray *sortedByDateArray = [NSMutableArray arrayWithArray:[self.fetchedResultsController sections]];

			[sortedByDateArray sortUsingComparator:^NSComparisonResult(id <NSFetchedResultsSectionInfo> obj1, id <NSFetchedResultsSectionInfo> obj2) {
				return [[obj2.objects valueForKeyPath:@"@max.date"] compare:[obj1.objects valueForKeyPath:@"@max.date"]];
			}];
			_fetchedResults = sortedByDateArray;
		}
	}

	return _fetchedResults;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	@autoreleasepool {
		static NSString *cellIdentifier = @"TranslatorListCell";

		if (IS_IPHONE) {
			UITableViewCell *iPhone_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

			if(iPhone_cell == nil) {
				iPhone_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
			}

			iPhone_cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
			iPhone_cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
			iPhone_cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];

			id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];

			iPhone_cell.textLabel.text = sectionInfo.name;
			A3TranslatorCircleView *circleView = [[A3TranslatorCircleView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
			circleView.textLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[sectionInfo numberOfObjects]];
			iPhone_cell.imageView.image = [circleView imageByRenderingView];

			iPhone_cell.detailTextLabel.text = [[sectionInfo.objects valueForKeyPath:@"@max.date"] timeAgo];
			iPhone_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			cell = iPhone_cell;
		} else {
			A3TranslatorListCell *iPad_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

			if(iPad_cell == nil) {
				iPad_cell = [[A3TranslatorListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
			}

			id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];

			iPad_cell.textLabel.text = sectionInfo.name;
			A3TranslatorCircleView *circleView = [[A3TranslatorCircleView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
			circleView.textLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[sectionInfo numberOfObjects]];
			iPad_cell.imageView.image = [circleView imageByRenderingView];

			iPad_cell.dateLabel.text = [[sectionInfo.objects valueForKeyPath:@"@max.date"] timeAgo];
			iPad_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			cell = iPad_cell;
		}
	}

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	@autoreleasepool {
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalLanguage == %@ AND translatedLanguage == %@", [sectionInfo.objects[0] valueForKeyPath:@"originalLanguage"],  [sectionInfo.objects[0] valueForKeyPath:@"translatedLanguage"]];
			[TranslatorHistory MR_deleteAllMatchingPredicate:predicate];
			[[NSManagedObjectContext MR_mainQueueContext] MR_saveOnlySelfAndWait];

			[self.fetchedResults removeObjectAtIndex:indexPath.row];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		[self setupRightBarButton];
	}
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@autoreleasepool {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
		id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];
		viewController.originalTextLanguage = [sectionInfo.objects[0] valueForKeyPath:@"originalLanguage"];
		viewController.translatedTextLanguage = [sectionInfo.objects[0] valueForKeyPath:@"translatedLanguage"];
		viewController.delegate = self;
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (void)translatorMessageViewControllerWillDismiss:(id)viewController {
	@autoreleasepool {
		if (_segmentedControl.selectedSegmentIndex == 0) {
			_fetchedResults = nil;
			_fetchedResultsController = nil;
		} else {
			[_favoriteDataSource resetData];
		}
		[self.tableView reloadData];

		[self setupRightBarButton];
	}
}

@end
