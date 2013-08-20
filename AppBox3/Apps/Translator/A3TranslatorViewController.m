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
#import "NSManagedObject+MagicalFinders.h"
#import "NSDate+TimeAgo.h"
#import "A3TranslatorCircleView.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "A3TranslatorFavoriteDataSource.h"

@interface A3TranslatorViewController () <UITableViewDataSource, UITableViewDelegate, A3TranslatorMessageViewControllerDelegate, A3TranslatorFavoriteDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *fetchedResults;
@property (nonatomic, strong) A3TranslatorFavoriteDataSource *favoriteDataSource;

@end

@implementation A3TranslatorViewController

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

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.hidesBackButton = YES;
	[self makeBackButtonEmptyArrow];

	if (IS_IPHONE) {
		[self leftBarButtonAppsButton];
	}

	[self rightBarButtonEditButton];
	[self setupSubviews];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)rightBarButtonEditButton {
	if ([self.fetchedResults count]) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)dealloc {
	[self removeObserver];
}

#pragma mark - Setup Subview

- (void)setupSubviews {
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

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	if (segmentedControl.selectedSegmentIndex == 0) {
		[self rightBarButtonEditButton];

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

- (A3TranslatorFavoriteDataSource *)favoriteDataSource {
	if (!_favoriteDataSource) {
		_favoriteDataSource = [A3TranslatorFavoriteDataSource new];
		_favoriteDataSource.delegate = self;
	}
	return _favoriteDataSource;
}

- (void)translatorFavoriteItemSelected:(TranslatorHistory *)item {
	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];

	viewController.originalTextLanguage = item.originalLanguage;
	viewController.translatedTextLanguage = item.translatedLanguage;
	viewController.delegate = self;
	viewController.selectItem = item;
	[self.navigationController pushViewController:viewController animated:YES];
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
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)editButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.tableView setEditing:!self.tableView.isEditing];
	[barButtonItem setTitle: self.tableView.isEditing ? @"Done" : @"Edit"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Data Source

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [TranslatorHistory MR_fetchAllSortedBy:@"originalLanguage,translatedLanguage" ascending:YES withPredicate:nil groupBy:@"languageGroup" delegate:nil];
	}

	return _fetchedResultsController;
}

- (NSMutableArray *)fetchedResults {
	if (!_fetchedResults) {
		NSMutableArray *sortedByDateArray = [NSMutableArray arrayWithArray:[self.fetchedResultsController sections]];

		[sortedByDateArray sortUsingComparator:^NSComparisonResult(id <NSFetchedResultsSectionInfo> obj1, id <NSFetchedResultsSectionInfo> obj2) {
			return [[obj2.objects valueForKeyPath:@"@max.date"] compare:[obj1.objects valueForKeyPath:@"@max.date"]];
		}];
		_fetchedResults = sortedByDateArray;
	}

	return _fetchedResults;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResults count];
}

- (UIImage*)imageFromView:(UIView *)view
{
	// Create a graphics context with the target size
	// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
	// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	CGSize imageSize = [view bounds].size;
	if (NULL != UIGraphicsBeginImageContextWithOptions)
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	else
		UIGraphicsBeginImageContext(imageSize);

	CGContextRef context = UIGraphicsGetCurrentContext();

	// -renderInContext: renders in the coordinate space of the layer,
	// so we must first apply the layer's geometry to the graphics context
	CGContextSaveGState(context);
	// Center the context around the view's anchor point
	CGContextTranslateCTM(context, [view center].x, [view center].y);
	// Apply the view's transform about the anchor point
	CGContextConcatCTM(context, [view transform]);
	// Offset by the portion of the bounds left of and above the anchor point
	CGContextTranslateCTM(context,
			-[view bounds].size.width * [[view layer] anchorPoint].x,
			-[view bounds].size.height * [[view layer] anchorPoint].y);

	// Render the layer hierarchy to the current context
	[[view layer] renderInContext:context];

	// Restore the context
	CGContextRestoreGState(context);

	// Retrieve the screenshot image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return image;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}

	// Style for textLabel && detailTextLabel
	cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

	id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];

	cell.textLabel.text = sectionInfo.name;
	A3TranslatorCircleView *circleView = [[A3TranslatorCircleView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	circleView.textLabel.text = [NSString stringWithFormat:@"%d", [sectionInfo numberOfObjects]];
	cell.imageView.image = [self imageFromView:circleView];

	cell.detailTextLabel.text = [[sectionInfo.objects valueForKeyPath:@"@max.date"] timeAgoWithLimit:60 * 60 * 24 dateFormat:NSDateFormatterShortStyle andTimeFormat:NSDateFormatterShortStyle];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalLanguage == %@ AND translatedLanguage == %@", [sectionInfo.objects[0] valueForKeyPath:@"originalLanguage"],  [sectionInfo.objects[0] valueForKeyPath:@"translatedLanguage"]];
		[TranslatorHistory MR_deleteAllMatchingPredicate:predicate];
		[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

		[self.fetchedResults removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	[self rightBarButtonEditButton];
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
	id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResults[indexPath.row];
	viewController.originalTextLanguage = [sectionInfo.objects[0] valueForKeyPath:@"originalLanguage"];
	viewController.translatedTextLanguage = [sectionInfo.objects[0] valueForKeyPath:@"translatedLanguage"];
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)translatorMessageViewControllerWillDismiss:(id)viewController {
	if (_segmentedControl.selectedSegmentIndex == 0) {
		_fetchedResults = nil;
		_fetchedResultsController = nil;
	} else {
		[_favoriteDataSource resetData];
	}
	[self.tableView reloadData];

	[self rightBarButtonEditButton];
}

@end
